/***************************************************************
Name: MDLZ_CreateWrapperCAOOrder
======================================================
Purpose:
a.Create a batch of EDI Orders and NOS orders to check if there is a wrapper order corresponding to it, 
if not then create a wrapper order with no line items and phase as Received by SAP.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                19/09/2021     Initial Development    
2.0      Bharath Vikkurthi                11/05/2021     Initial Development

***************************************************************/
public with sharing class MDLZ_CreateWrapperCAOOrder {
    private MDLZ_ErrorExceptionHandler exc;
    
    public MDLZ_CreateWrapperCAOOrder(){
        exc = new MDLZ_ErrorExceptionHandler();
    }
    
    
    //creates wrapper orders for all NOS orders that do not have an existing wrapper
    public void createWrapper(List<ACCL__Order__c> NOSOrderList){
        //get the list of delivery dates and Accounts form EDI order list and 
        //remove the duplicate customer and delivery date combinations
        system.debug('NOSOrderList '+NOSOrderList.size());
        Set<Date> deliveryDateList = new Set<Date>();
        Set<Id> accountList = new Set<Id>();
        Map<String,String> NOSOrdMap = new Map<String,String>();
        Map<String,ACCL__Order__c> orderMap = new Map<String,ACCL__Order__c>();
        Set<String> wrapOrderSet = new Set<String>();
        String phase = '';
        Set<String> srcPhase = new set<string> {'Received By SAP','Routed','Locked'};
                
        try{
            for(ACCL__Order__c order :NOSOrderList){
                deliveryDateList.add(order.ACCL__Delivery_Date__c);
                accountList.add(order.ACCL__Order_Account__c);
                phase = order.ACCL__Phase__c;
                String uniq = order.ACCL__Order_Account__c+'|'+order.ACCL__Delivery_Date__c;
                system.debug('uniq '+uniq);
                if(NOSOrdMap != null && NOSOrdMap.containsKey(uniq)){
                    if(srcPhase.contains(order.ACCL__Phase__c)){  
                        NOSOrdMap.put(uniq,phase);
                        orderMap.put(uniq, order);
                    }
                }else{
                	NOSOrdMap.put(uniq,phase);
                    orderMap.put(uniq, order);
                }
               
            }
            
            //get all the CAO orders in the system for the specific account and delivery date
            for(ACCL__Order__c wrapOrder:[select id,ACCL__Phase__c,ACCL__Order_Account__c,ACCL__Delivery_Date__c,
                                          ACCL__Order_Template__r.Name from ACCL__Order__c where ACCL__Order_Template__r.name in ('Order Wrapper')
                                          and ACCL__Delivery_Date__c in: deliveryDateList and ACCL__Order_Account__c in: accountList 
                                          AND ACCL__Phase__c NOT IN ('REJECTED','DELETED','CANCELLED')]){
                                              
                                              String uniqKey=wrapOrder.ACCL__Order_Account__c+'|'+wrapOrder.ACCL__Delivery_Date__c;
                                              wrapOrderSet.add(uniqKey);
                                              
                                          }
            
            List<ACCL__Order_Template__c> ordTempl = [SELECT Id,name FROM ACCL__Order_Template__c where name =: 'Order Wrapper'];
            
            //create a list to insert new wrapper CAO orders into db for the same customer and delivery date
            List<ACCL__Order__c> CAOInsertDb = new List<ACCL__Order__c>();    
            
            
            //iterate through EDIOrders Map and check if order has a corresponding CAO order        
            //  for(ACCL__Order__c EDIOrder : EDIOrderList){
            if(NOSOrdMap.size()>0){
                for (String mapId : NOSOrdMap.keySet()){
                    ACCL__order__c createWrapper = new Accl__Order__c();
                    boolean exists = false;
                    if(wrapOrderSet != null && wrapOrderSet.size()>0 && wrapOrderSet.contains(mapId)){
                        //wrapper order exists
                        exists = true;
                    }
                    
                    if(exists == false){
                        String AccountNum = orderMap.get(mapId).ACCL__Order_Account__r.ACCL__Account_Number__c;
                        Date DeliveryDate = orderMap.get(mapId).ACCL__Delivery_Date__c;
                        createWrapper.ACCL__Order_Account__c = orderMap.get(mapId).ACCL__Order_Account__c;
                        createWrapper.ACCL__Delivery_Date__c = orderMap.get(mapId).ACCL__Delivery_Date__c;
                        createWrapper.ACCL__Order_Template__c = ordTempl[0].id;
                        createWrapper.ACCL__Order_Id__c = (MDLZ_ConstantHelper.CreateOW+orderMap.get(mapId).ACCL__Order_Id__c);
                        createWrapper.MDLZ_ExternalId__c = getExternalId(AccountNum,DeliveryDate);
                        createWrapper.MDLZ_IsSFAutoGenerated__c = true;
                        
                        if(srcPhase.contains(NOSOrdMap.get(mapId))){
                        	createWrapper.ACCL__Phase__c = MDLZ_ConstantHelper.ReceivedBySAP;
                        }else if(NOSOrdMap.get(mapId) == MDLZ_ConstantHelper.Open){
                            createWrapper.ACCL__Phase__c = MDLZ_ConstantHelper.Open;
                        }else if(NOSOrdMap.get(mapId) == MDLZ_ConstantHelper.PhaseSentToSAP){
                            createWrapper.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseSentToSAP;
                        }
                                                  CAOInsertDb.add(createWrapper);
                        system.debug('CAO order created for '+orderMap.get(mapId).Id);
                        
                    }
                    
                }
                //insert the wrapper orders to db
                system.debug('Inserting data into db of size '+CAOInsertDb.size());
                if(CAOInsertDb.size() > 0){                
                    List<Database.SaveResult> srList =  database.insert(CAOInsertDb,false);
					system.debug('srList : '+srList);
					system.debug('');
                    if(srList.size()>0){
                        exc.saveResultErrors(srList,CAOInsertDb,'MDLZ_CreateWrapperCAOOrder()','ACCL__order__c','ACCL__Order_Id__c');
                    }
                    
                }else{
                    system.debug('No records to be updated');
                } 
            }
        }catch(exception e){
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('MDLZ_CreateWrapperCAOOrder()',e.getStackTraceString(),e.getLineNumber(),e.getTypeName()); 
        }
        
    }
    
    public static String getExternalId(String AccountNumber , Date DeliveryDate){
        String externalId;
        String month = String.valueof(DeliveryDate.month());
		String day = String.valueof(DeliveryDate.day());
		if(month.length()==1){
  		month = '0' + month;
		}
		if(day.length()==1){
  		day = '0' + day;
		}

		String formatedDate = String.valueof(DeliveryDate.year()) + day + month;
        externalId = MDLZ_ConstantHelper.CreateOW+AccountNumber+'_'+formatedDate;
        return externalId;
    }
}