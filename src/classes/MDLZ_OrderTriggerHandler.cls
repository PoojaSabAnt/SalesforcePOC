/***************************************************************
Name: MDLZ_OrderTriggerHandler
======================================================
Purpose:Resetting of isChanged flag on Order object to FALSE, when response comes back from SAP for the specific record
======================================================
History
-------

VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0                                      08/10/2021       Initial Development 
1.1         Vaidehi Heda                 27/04/2022       As per 2928,MDLZ_Is_Order_Accepted__c will be marked as 
true on order if flip object records also has MDLZ_Is_Order_Accepted__c = true
1.2         Vaidehi Heda                 09/05/2022       Changes added to avoid orders which has Routed and deleted phase.
1.3         Vaidehi Heda                 17/05/2022       As per 3584, added operation field on Flip object which will decide whether it is 2154, 3584 or 2829
1.4         Vaidehi Heda                 29/08/2022       Added condition to update Accountable/Responsible field
1.5         Namitha Francis              12/09/2022       MRELKXIW-4985, added condition form Routed and Locked phase
***************************************************************/ 
//Cmt: fixing defects: MRELKXIW-1925, MRELKXIW-1912 & MRELKXIW-1918
public with sharing class MDLZ_OrderTriggerHandler {
    
    //Cmt: Don't use static variables inside triggers. Achieve same functionality using local variables
    //public static Set<Id>orderlItemIDSet;
    //public static List<ACCL__Order__c>orderList;
    // private static Boolean isSysAdmin;
    // private static Boolean isIntegrationUser;
    
    public MDLZ_OrderTriggerHandler(){
        //orderlItemIDSet = new Set<Id>();  
        //orderList = new List<ACCL__Order__c>();
        //isSysAdmin = isSystemAdminUser();
        //isIntegrationUser = isIntegrationUser();
    } 
    
    
    public void ResetIsChanged(List<ACCL__Order__c> listOrders)
    {  
        try{
            //Cmt: Only apply this logic to the integration users
            
            /* integer userCount =0;
If (!Test.isRunningTest()){
userCount = [SELECT count() FROM MDLZ_Integration_User__mdt WHERE Integration_User_Id__c =: UserInfo.getUserId() and MasterLabel = :MDLZ_ConstantHelper.MDLZSap LIMIT 1];

}else{
User us  = [ select id from user where name = :MDLZ_ConstantHelper.OutboundSap ]; 
userCount = [SELECT count() FROM MDLZ_Integration_User__mdt WHERE Integration_User_Id__c =:us.Id and MasterLabel =: MDLZ_ConstantHelper.MDLZSap  LIMIT 1];
}
*/
            //changed as per MRELKXIW-4139   
            boolean isIntegrationUser = isIntegrationUser();
            
            if(isintegrationUser==true )
                //if(userCount > 0)
            {
                for(ACCL__Order__c  odr :listOrders)
                {  ACCL__Order__c oldOrder = (ACCL__Order__c)Trigger.oldMap.get(odr.id);
                 
                 //updated for Jira-2303
                 if(odr.ACCL__Phase__c != MDLZ_ConstantHelper.open){
                     odr.MDLZ_isChanged__c = MDLZ_ConstantHelper.ChangeFalse;
                 }
                 
                 String oldPhase = oldOrder.ACCL__Phase__c ;
                 String newPhase = odr.ACCL__Phase__c ;
                 
                 if ((oldPhase == MDLZ_ConstantHelper.PhaseCancelled || oldPhase== MDLZ_ConstantHelper.PhaseDeleted) && newPhase== MDLZ_ConstantHelper.ReceivedBySAP){
                     odr.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseCancelled; }
                 if ((oldPhase == MDLZ_ConstantHelper.PhaseRouted) && newPhase== MDLZ_ConstantHelper.ReceivedBySAP ) {
                     odr.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseRouted ; }
                 if ((oldPhase == MDLZ_ConstantHelper.PhaseRouted) && newPhase== MDLZ_ConstantHelper.PhaseLocked ) {
                     odr.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseRouted ; }
                }
            }
        }catch(Exception e){
            system.debug('An exception has occurred');
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
            exc.insertExceptions('MDLZ_OrderTriggerHandler.ResetIsChanged()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
        }
    }
    
    //method to log field changes for orders  
    //This will be used to troubleshoot the Jira-2154. 
    //Logging Can be turned off using the custom switch - MDLZ_Object_Logging__c instance = Order
    public void logFieldChanges(List<ACCL__Order__c> listOrders){
        ExceptionLog__c errorlog;
        try{integer userCount = [SELECT count() FROM MDLZ_Integration_User__mdt WHERE Integration_User_Id__c =: UserInfo.getUserId() ];
            if(userCount == 0){
                String fieldSet_Name = system.label.MDLZ_Order_FieldSet;
                set<String> fieldSet = new Set<String>();
                
                //dynamically get the fields from the field set and then use the same for comparison in the trigger. 
                //List<Schema.FieldSetMember> getFields = SObjectType.ACCL__Order__c.fieldSets.ACCL__MobilityRelevant.getFields();
                List<Schema.FieldSetMember> getFields = SObjectType.ACCL__Order__c.fieldSets.getMap().get(fieldSet_Name).getFields();
                
                for(Schema.FieldSetMember eachField :getFields){                    
                    fieldSet.add(eachField.getFieldPath());
                }                
                set<String> values  = new Set<String>();
                List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();
                for(ACCL__Order__c ordNew: listOrders){
                    values.clear();
                    ACCL__Order__c oldOrd = (ACCL__Order__c)trigger.oldMap.get(ordNew.Id);
                    
                    if(oldOrd.ACCL__Customer_Order_Id__c != null && (ordNew.ACCL__Customer_Order_Id__c == null || String.isBlank(ordNew.ACCL__Customer_Order_Id__c))){    
                        for(string fld: fieldSet){
                            if(ordNew.get(fld) != trigger.oldMap.get(ordNew.Id).get(fld)){
                                values.add(fld+': Old:'+trigger.oldMap.get(ordNew.Id).get(fld)+' | New:'+ordNew.get(fld));//adding changed values
                            }
                        }
                    }
                    if(values.size()>0){
                        //creating logs for order
                        errorlog = new ExceptionLog__c();
                        errorlog.ApexTrigger__c='MDLZ_Order_BeforeUpdateTrigger.logFieldChanges()'; 
                        errorlog.ExceptionDetails__c = values.toString();
                        errorlog.ExceptionCode__c = 'Order Name '+ordNew.Name;
                        expctlog.add(errorlog);
                    }
                    
                }
                //insert logs
                if(expctlog.size()>0){
                    database.insert(expctlog, false);  
                }
            }
           }catch(Exception e){
               MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
               exc.insertExceptions('MDLZ_OrderTriggerHandler.logFieldChanges()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
           }
        
    }
    
    //Method will be called on before insert
    public static void beforeInsert(List<ACCL__Order__c>NewOrderList){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        Id loggedinuserId =userinfo.getuserId();
        try{ for(ACCL__Order__c order : NewOrderList){
            system.debug(order.ACCL__Accountable__c);
            if(order.ACCL__Accountable__c == null ){
                order.ACCL__Accountable__c =loggedinuserId;
                order.ACCL__Responsible__c = loggedinuserId;
            }}
           }catch(Exception ex){                
               exc.insertExceptions('MDLZ_OrderTriggerHandler.beforeInsert()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName());      
           }
    }
    
    //Changes as per MRELKXIW-2928 / 2154______________START
    //This method wil be called in before Update scenario
    public static void sapErrBeforeUpdate(Map<Id,ACCL__Order__c>oldOrderMap, Map<Id,ACCL__Order__c>NewOrderMap){
        boolean isSysAdmin = isSystemAdminUser();
        boolean isIntegrationUser = isIntegrationUser();
        List<MDLZ_Orders_To_Flip__c> OrdersToFlip = new List<MDLZ_Orders_To_Flip__c>();        
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<ExceptionLog__c> excList = new List<ExceptionLog__c>();
        try{ for(ACCL__Order__c order : NewOrderMap.values()){           
            //Added as per 2154            
            if(isIntegrationUser){
                //when integration user is updating the order this field will get updated
                order.MDLZ_LastupdatedbySAP__c = order.MDLZ_ReceivedBySAP__c; }
            if(order.ACCL__Customer_Order_Id__c!= oldOrderMap.get(order.Id).ACCL__Customer_Order_Id__c ){
                order.ACCL__Customer_Order_Id__c = order.MDLZ_SAPExternalID__c;}
            if(system.label.MDLZ_order_line_item_update_flag == 'true' &&  !isSysAdmin &&  !isIntegrationUser
               && order.MDLZ_LastSavedByUser__c!= null && order.MDLZ_LastupdatedbySAP__c!= null
               && order.MDLZ_Total_Case_Quantity__c == oldOrderMap.get(order.id).MDLZ_Total_Case_Quantity__c
               && order.MDLZ_LastSavedByUser__c < order.MDLZ_LastupdatedbySAP__c  
              ){ //Cmt:Adding order id to MDLZ_Orders_To_Flip__c object so that header and line items will 
                  //be updated for this orderid
                  order.MDLZ_isChanged__c = MDLZ_ConstantHelper.ChangeFalse;
                  OrdersToFlip.Add(new MDLZ_Orders_To_Flip__c(OrderId__c = order.id, MDLZ_NewPhase__c = order.ACCL__Phase__c,
                                                              MDLZ_Operation__c = MDLZ_ConstantHelper.OrderSync,MDLZ_OldPhase__c =oldOrderMap.get(order.id).ACCL__Phase__c));                  
              } //added as per 2928
            //it will check if MDLZ_isOrderAccepted__c = false for new value and if it is the case then MDLZ_Is_Order_Accepted__c
            //will be updated to true on flip object and based on that MDLZ_isOrderAccepted__c value will be reverted
            else if(system.label.MDLZ_order_line_item_update_flag2 == 'true' && isIntegrationUser 
                    && order.MDLZ_Total_Case_Quantity__c == oldOrderMap.get(order.id).MDLZ_Total_Case_Quantity__c
                    && !order.MDLZ_isOrderAccepted__c && oldOrderMap.get(order.id).MDLZ_isOrderAccepted__c){
                        OrdersToFlip.Add(new MDLZ_Orders_To_Flip__c(OrderId__c = order.id , MDLZ_Operation__c=MDLZ_ConstantHelper.OrderAccepted));
                    }
        } insert OrdersToFlip;
           }catch(Exception ex){                
               exc.insertExceptions('MDLZ_OrderTriggerHandler.sapErrBeforeUpdate()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName());      
           }
    } 
    
    //Method will be called on after insert
    public static void afterInsert(Map<Id,ACCL__Order__c>NewOrderMap){
        // boolean isSysAdmin = isSystemAdminUser();
        boolean isIntegrationUser = isIntegrationUser();
        Id wrapperTemplateId =getWrapperTemplateId();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<MDLZ_Orders_To_Flip__c> OrdersToFlip = new List<MDLZ_Orders_To_Flip__c>();
        
        try{ for(ACCL__Order__c order: NewOrderMap.values()){
            //Added as per 3584
            if( !isIntegrationUser  && order.ACCL__Order_Template__c == wrapperTemplateId   ){
                OrdersToFlip.Add(new MDLZ_Orders_To_Flip__c(OrderId__c = order.id , MDLZ_Operation__c=MDLZ_ConstantHelper.DupWrapper));
            }}
            if(OrdersToFlip.size()>0){
                insert OrdersToFlip;  
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_OrderTriggerHandler.afterInsert()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName());   
            }
    }
    //Method will be called on after update
    public static void afterUpdate(Map<Id,ACCL__Order__c>NewOrderMap){
        boolean isIntegrationUser = isIntegrationUser();
        Id wrapperTemplateId =getWrapperTemplateId();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<MDLZ_Orders_To_Flip__c> OrdersToFlip = new List<MDLZ_Orders_To_Flip__c>();
        Map<String,MDLZ_Orders_To_Flip__c> OrdFlipdup = new Map<String,MDLZ_Orders_To_Flip__c> ();
        for(MDLZ_Orders_To_Flip__c flip : [Select Id,OrderId__c,MDLZ_Operation__c from MDLZ_Orders_To_Flip__c where OrderId__c IN :NewOrderMap.keySet()  ]){
            OrdFlipdup.put(flip.OrderId__c,flip);
        }
        
        try{ for(ACCL__Order__c order: NewOrderMap.values()){
            //Added as per 3584
            if( !isIntegrationUser && order.ACCL__Order_Template__c == wrapperTemplateId  && !OrdFlipdup.containsKey(order.Id) ){
                OrdersToFlip.Add(new MDLZ_Orders_To_Flip__c(OrderId__c = order.id , MDLZ_Operation__c=MDLZ_ConstantHelper.DupWrapper));
                
            }}
            if(OrdersToFlip.size()>0){
                insert OrdersToFlip;  
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_OrderTriggerHandler.afterUpdate()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName());   
            }
    }
    //Added as per 3584
    //method to get Wrapper template Id 
    public static Id getWrapperTemplateId(){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        Id wrapperTemplateId;
        try{ wrapperTemplateId=[SELECT id, name, MDLZ_IsOrderWrapper__c FROM ACCL__Order_Template__c WHERE MDLZ_IsOrderWrapper__c =: true LIMIT 1].Id;
           }catch(Exception ex){
               exc.insertExceptions('MDLZ_OrderTriggerHandler.getWrapperTemplateId()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
           }
        return wrapperTemplateId;
    }
    //method to check whether logged in user is integration user or not
    public static boolean isIntegrationUser(){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        Boolean isintegrationUser;
        try{String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            isintegrationUser = (profileName==LABEL.MDLZ_OrdDate_Profile)?true:false;
           }catch(Exception ex){
               exc.insertExceptions('MDLZ_OrderTriggerHandler.isIntegrationUser()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
           }
        return isintegrationUser;
    }
    
    //method to check whether logged in user is system admin user or not
    public static boolean isSystemAdminUser(){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        Boolean isSysAdmin;
        try{String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            isSysAdmin = (profileName==LABEL.MDLZ_OrDate_Profile2)?true:false;
           }catch(Exception ex){
               exc.insertExceptions('MDLZ_OrderTriggerHandler.issystemAdminUser()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
           }
        return isSysAdmin;
    }
    //Changes as per MRELKXIW-2928______________END
    
}