/***************************************************************
Name: MDLZ_OrderFlipBatch
======================================================
Purpose:
This batch will update order header and line item to address MRELKXIW-2154.
i.e. Mobile is overwriting updates from SAP due to sync / timing issue

Several options were evaluated to address JIRA-2154 issue before the batch implementation
Option 1: Before & After triggers on Order header. with after trigger applying switch of line item records
Ran into order of execution error --> 1) line item update, 2) after trigger because of rollup summary field and 3) after trigger because of header record
So the line items were getting updated thrice, switch not handled correctly

Option 2: Workflow field update on Line Items
Limitations as picklist field MDLZ_ItemStatus__c be updated from MDLZ_BkpItemStatus__c
Order of execution will make Workflow to fire before Order Hdr BeforeUpdate

Option 3: BeforeUpdate trigger on Line Items
Order of execution will make Workflow to fire before Order Hdr BeforeUpdate (https://help.salesforce.com/s/articleView?id=000333606&type=1)
So the line items didnt have context whether to apply the switch or not, and resulting in incorrect updates

Option 4: Queueable Class invoked from Header, to update line items
Will lead to recursive invocation of header trigger, because - when line items are updated, header trigger will fire again
and queueable class cannot be controlled to run as "Sysadmin" user, so header will initiate queueable class again
Static variables to stop recursive trigger execution, will not work too, as context for queueable execution is different each time.

Option 5: Batch jobs to handle Order header and line switch
Finally it was decided to move the code to scheduled batch class. Order Header Trigger will insert relevant OrderIds into MDLZ_Orders_To_Flip__c object
Batch class running as "Sysadmin" will perform the switch. Since its executing as Sysadmin, header trigger will not fire again

======================================================
History
-------
VERSION     AUTHOR               REVIEWER     DATE        DETAIL                Description
1.0         Amit Mirchandani     Navaneet N   20/04/2022  Initial Development   As stated above
1.2         Vaidehi Heda                      27/04/2022  As per 2928,MDLZ_Is_Order_Accepted__c will be marked as true on order if flip object records also has MDLZ_Is_Order_Accepted__c = true
1.3         Amit Mirchandani                  04/05/2022  Added filter/comparison condition for lastsavedbyUser and MDLZ_LastupdatedbySAP
1.4         Vaidehi Heda                      10/05/2022  Changes added to avoid phase change in orders as per below logic if old version in (Routed/Cancelled), then flip, but phase should remain Routed/Cancelled
if new version is Deleted and old version is Routed, the flip but leave phase as Routed.
1.5        Vaidehi Heda                       17/05/2022  As per 3584, This will delete duplicate wrappers based on account and delivery date  
1.6        Vaidehi Heda                       21/09/2022  Removed the condition to check created by for duplicate wrappers
***************************************************************/
global class MDLZ_OrderFlipBatch implements Database.Batchable<sObject> ,Schedulable {
    
    public integer defaultChildBatchSize;
    //Adding deleted and routed phase in set
    Set<String> orderPhase = new  Set<String>{MDLZ_ConstantHelper.PhaseRouted ,MDLZ_ConstantHelper.PhaseDeleted ,MDLZ_ConstantHelper.PhaseCancelled};
        Set<String> orderItemStatus = new  Set<String>{'A', 'C'};    
            public MDLZ_OrderFlipBatch(integer childBatchSize){
                defaultChildBatchSize = childBatchSize;
            }
    
    global Database.QueryLocator start(Database.BatchableContext BC)    
    { String query ;
     if(test.isRunningtest()){
         query = 'SELECT ID, MDLZ_NewPhase__c,MDLZ_OldPhase__c,MDLZ_Operation__c,MDLZ_Is_Order_Accepted__c, OrderID__c FROM MDLZ_Orders_To_Flip__c LIMIT 1';
     }
     else{ 
         query = 'SELECT ID, MDLZ_NewPhase__c,MDLZ_OldPhase__c,MDLZ_Operation__c,MDLZ_Is_Order_Accepted__c, OrderID__c FROM MDLZ_Orders_To_Flip__c ';
     }
     
     return Database.getQueryLocator(query);
    }
    
    //pending change public to global
    global void execute(Database.BatchableContext BC, List<MDLZ_Orders_To_Flip__c> listOrdersToFip){
        Map<Id, MDLZ_Orders_To_Flip__c>flipMap = new  Map<Id, MDLZ_Orders_To_Flip__c>();
        Set<Id>wrapperOrderIDs = new Set<Id>();
        List<ACCL__Order__c> ordList = new List<ACCL__Order__c>();
        Set<ID> orderIDs = new Set<Id>();    
        Set<ID> acceptedOrderIDs = new Set<Id>();
        Set<Id> orderAccount = new Set<Id>();
        Map<String, Date>orderstobeDeleted = new Map<String, Date>();    
        //SELECT ID FROM ACCL__Order__c WHERE ID IN (
        for(MDLZ_Orders_To_Flip__c odrFlip:listOrdersToFip){
            if(odrFlip.MDLZ_Operation__c == MDLZ_ConstantHelper.OrderSync){
                flipMap.put(odrFlip.OrderID__c , odrFlip);
            }
            //Added as per 2928
            else if(odrFlip.MDLZ_Operation__c == MDLZ_ConstantHelper.OrderAccepted){acceptedOrderIDs.add(odrFlip.OrderID__c);}
            //Added as per 3584
            else if(odrFlip.MDLZ_Operation__c == MDLZ_ConstantHelper.DupWrapper){wrapperOrderIDs.add(odrFlip.OrderID__c);}
            orderIDs.add(odrFlip.OrderID__c);
        }
        //Adding orders in map for delayed line items
        Map<Id, ACCL__Order__c> orderMap =getLineItems(orderIDs);
        
        List<ACCL__Order__c> listOfOrderToFlip = [SELECT id,MDLZ_LastupdatedbySAP__c,MDLZ_LastSavedByUser__c, MDLZ_isChanged__c,MDLZ_isOrderAccepted__c, ACCL__Delivery_Date__c,ACCL__Order_Account__c,
                                                  ACCL__Phase__c, MDLZ_SAPDeliveryDate__c FROM ACCL__Order__c 
                                                  WHERE Id  IN : orderIDs ];
        //AM: Code updated
        Set<ID> orderIDsThatFlipped = new Set<Id>();
        for(ACCL__Order__c order: listOfOrderToFlip){
            if(wrapperOrderIDs.contains(order.id)){
                orderstobeDeleted.put(order.ACCL__Order_Account__c+'|'+order.ACCL__Delivery_Date__c, order.ACCL__Delivery_Date__c );  
                orderAccount.add(order.ACCL__Order_Account__c);
            }else if(acceptedOrderIDs.contains(order.Id)){
                order.MDLZ_isOrderAccepted__c = true;
                order.ACCL__Phase__c =MDLZ_ConstantHelper.ReceivedBySAP;
                order.MDLZ_isChanged__c =MDLZ_ConstantHelper.ChangeFalse;
                order.ACCL__Delivery_Date__c =order.MDLZ_SAPDeliveryDate__c; 
                //AM: Code updated
                orderIDsThatFlipped.add(order.Id);
            }//Added as per 2928
            
            //AM: Code updated
            else if(order.MDLZ_LastSavedByUser__c!= null 
                    && order.MDLZ_LastupdatedbySAP__c!= null
                    && order.MDLZ_LastSavedByUser__c < order.MDLZ_LastupdatedbySAP__c)
            {               
                order.MDLZ_isChanged__c =MDLZ_ConstantHelper.ChangeFalse;
                order.ACCL__Delivery_Date__c =order.MDLZ_SAPDeliveryDate__c; //Added as per 2154
                
                if(orderPhase.Contains(flipMap.get(order.Id).MDLZ_OldPhase__c)){
                    order.ACCL__Phase__c =flipMap.get(order.Id).MDLZ_OldPhase__c;
                    orderIDsThatFlipped.add(order.Id);
                }else if(flipMap.get(order.Id).MDLZ_NewPhase__c== MDLZ_ConstantHelper.PhaseDeleted && flipMap.get(order.Id).MDLZ_OldPhase__c!=MDLZ_ConstantHelper.PhaseRouted){
                    order.ACCL__Phase__c =flipMap.get(order.Id).MDLZ_NewPhase__c; }
                else { 
                    if(orderMap.containsKey(order.Id)){
                        order.MDLZ_isChanged__c =MDLZ_ConstantHelper.ChangeTrue;
                    }else{
                        order.ACCL__Phase__c =MDLZ_ConstantHelper.ReceivedBySAP;
                        orderIDsThatFlipped.add(order.Id);
                    }}
            }                
            
        }            
        
        List<ACCL__Order_Item__c> listOfLineItemsToFlip = [SELECT id, MDLZ_ItemStatus__c, ACCL__Quantity__c, ACCL__Suggested_Quantity__c, MDLZ_BkpItemStatus__c,
                                                           MDLZ_BkpSuggestedQty__c, ACCL__Order__c  FROM ACCL__Order_Item__c 
                                                           WHERE ACCL__Order__c  IN : orderIDsThatFlipped ];
        for(ACCL__Order_Item__c lineItem: listOfLineItemsToFlip){
            lineItem.MDLZ_ItemStatus__c = lineItem.MDLZ_BkpItemStatus__c; //added as per 2154
            lineItem.ACCL__Quantity__c = lineItem.MDLZ_BkpSuggestedQty__c; //added as per 2154
            lineItem.ACCL__Suggested_Quantity__c = lineItem.MDLZ_BkpSuggestedQty__c;//Added as per 2154
        }
        
        Savepoint dbSavepoint;
        try{
            //create save point so that we can rollback any changes in case of failure
            dbSavepoint = Database.setSavepoint();
            UPDATE listOfLineItemsToFlip;
            UPDATE listOfOrderToFlip;
            DELETE listOrdersToFip; 
            //Added as per 3584
            if(orderstobeDeleted.size()>0){
                ordList= getWrapperOrders(orderstobeDeleted, wrapperOrderIDs, orderAccount);
                DELETE ordList; 
            }           
            //Cmt: Check if we need to commit the dbSavePoint
        }catch(Exception ex){
            if(!Test.isRunningTest()) { Database.rollback(dbSavepoint);}
            system.debug('Error: ' + ex);
            throw ex;
        }        
    }
    
    global void execute(SchedulableContext ctx) {        
        //CMt : For scheduled batch the size will be taken from Label.MDLZ_OrderFlipBatch
        integer defaultChildBatchSize = integer.valueOf(Label.MDLZ_OrderFlipBatch);
        Database.executeBatch(new MDLZ_OrderFlipBatch(defaultChildBatchSize), defaultChildBatchSize);   
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    } 
    
    //method to get orders for delayed line items
    public Map<Id, ACCL__Order__c> getLineItems(Set<Id>orderIdSet){
        Map<Id, ACCL__Order__c> orderMap = New Map<Id,ACCL__Order__c >([SELECT id, name FROM ACCL__Order__c WHERE
                                                                        Id IN (SELECT ACCL__Order__c FROM ACCL__Order_Item__c WHERE ACCL__Order__c IN:orderIdSet
                                                                               AND (MDLZ_LineItemNumber__c = NULL
                                                                                    OR  MDLZ_BkpItemStatus__c NOT IN: orderItemStatus)) 
                                                                       ]);
        return orderMap;
    }
    
    
    
    //method to get the duplicate wrapper orders based on delivery date and account
    public List<ACCL__Order__c> getWrapperOrders(Map<String, Date>orderstobeDeleted , Set<Id>wrapperOrderIDs, Set<Id>orderAccount){
        List<ACCL__Order__c> ordList = new List<ACCL__Order__c>();
        Map<String, ACCL__Order__c>ordMap = new Map<String, ACCL__Order__c>();
        Map<Id, ACCL__Order__c>dupOrderMap = new Map<Id, ACCL__Order__c>();
		Set<String> deletePhaseSet = new  Set<String>{MDLZ_ConstantHelper.PhaseDeleted};
        string keyOrderAndDelivery;
        Id sysadmin = getProId(LABEL.MDLZ_OrDate_Profile2);
        for (ACCL__Order__c order :[SELECT id, ACCL__Delivery_Date__c,createdby.profileId, ACCL__Order_Account__c, CreatedById,MDLZ_IsSFAutoGenerated__c FROM ACCL__Order__c WHERE 
                                    ACCL__Order_Account__c IN :orderAccount AND ACCL__Delivery_Date__c > LAST_N_Days:0 AND ACCL__Delivery_Date__c IN: orderstobeDeleted.values()
                                    AND ACCL__Order_Template__r.MDLZ_IsOrderWrapper__c=true AND ACCL__Phase__c NOT IN: deletePhaseSet  ORDER BY CreatedDate])
        {  
            
            keyOrderAndDelivery = order.ACCL__Order_Account__c+'|'+order.ACCL__Delivery_Date__c;
            
            if (orderstobeDeleted.containsKey(keyOrderAndDelivery)){
                if(!ordMap.containsKey(keyOrderAndDelivery)){
                    //Order comes first time either a user created or Sys admin created
                    ordMap.put(keyOrderAndDelivery , order);
                }else{  
                    //this is executed only if Order wrapper is duplicate
                    dupOrderMap.put(order.id, order);//This map will keep all the duplicate wrapper ids
                }}}      
        return dupOrderMap.values();
    }
    
    public static Id getProId(String proName){
        Id sysAdminId = [SELECT id, name FROM PRofile WHERE name =:proName LIMIT 1].Id;
        system.debug(sysAdminId);
        return sysAdminId;
    }
}