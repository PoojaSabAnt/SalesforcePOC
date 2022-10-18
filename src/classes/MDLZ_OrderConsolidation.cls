/***************************************************************
Name: MDLZ_OrderConsolidation
======================================================
Purpose:
a. batch2 to update CAO orders to Routed or cancelled refer 
conditions in confluence matrix based on customer and delivery date
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi            	 18/09/2021     Initial Development   
1.1      Vaidehi Heda                28/03/2022     Maqde the changes as per Novasaas Report
1.2      Priya Tubachi               10/05/2022     Optimizing class for AMS issues
1.3      Vaidehi Heda                08/03/2022     Updated condition for Locked and Cancelled Phase orders 
1.4      Samiksha Reddy              09/12/2022     Removed condition for Locked
***************************************************************/
public with sharing class MDLZ_OrderConsolidation {
    
    public void updateCAOOrdersNew(List<ACCL__Order__c> orderList){ 
        
        List<ACCL__Order__c> updateDBList = new List<ACCL__Order__c>();
        Set<Id> accountId = new Set<Id>();
        Map<String,ACCL__Order__c> caoOrderMap = new Map<String,ACCL__Order__c>();
        Map<String,String> ediNOSMap = new Map<String,string>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        
        try{ 
        // get the unique accounts from the orderList
        for(ACCL__Order__c order: orderList){
            accountId.add(order.ACCL__Order_Account__c);
            caoOrderMap.put(order.ACCL__Order_Account__c+'|'+order.ACCL__Delivery_Date__c, order);
        }
        
        //for the account list retrieve NOS/EDI orders for the same delivery date
        for(ACCL__Order__c ord :[SELECT Id, ACCL__Delivery_Date__c,ACCL__Order_Account__c, 
                                 ACCL__Order_Template__r.Name,ACCL__Phase__C,MDLZ_Total_Case_Quantity__c 
                                 FROM ACCL__Order__c WHERE ACCL__Delivery_Date__c >=today and ACCL__Delivery_Date__c <= tomorrow and
                                 ACCL__Order_Template__r.Name in ('NOS','EDI','Order') and ACCL__Phase__c in ('Routed','Cancelled','Received By SAP') and
                                 ACCL__Order_Account__c in: accountId ]){
                                     
                                     string uniqueKey = ord.ACCL__Order_Account__c+'|'+ord.ACCL__Delivery_Date__c;
                                     String value = ord.ACCL__Phase__c;
                                     
                                     if(ediNOSMap.containsKey(uniqueKey)){
                                     	value = value+'|'+ediNOSMap.get(uniqueKey);                                         
                                     }
                                     
                                     ediNOSMap.put(uniqueKey,value);    
                                 }
        
        if(caoOrderMap.size() > 0){
            ACCL__order__c ord = new ACCL__order__c();
            for(String caoKey:caoOrderMap.keyset()){
                ord = caoOrderMap.get(caoKey);
                if(ediNOSMap.containsKey(caoKey) && ((ediNOSMap.get(caoKey).indexOf(MDLZ_ConstantHelper.PhaseRouted) != -1))){
                    ord.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseRouted;
                }else if(ediNOSMap.containsKey(caoKey) && ((ediNOSMap.get(caoKey).indexOf(MDLZ_ConstantHelper.PhaseCancelled) != -1)
                        && (ediNOSMap.get(caoKey).indexOf(MDLZ_ConstantHelper.ReceivedBySAP) == -1))){
                    ord.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseCancelled;
                }
                /*else{
                    ord.ACCL__Phase__c = MDLZ_ConstantHelper.PhaseRouted;
                }*/
                updateDBList.add(ord);
            }
            
        }
        
        system.debug('updating data into db of size '+updateDBList.size());
        if(updateDBList.size() > 0){                
            List<Database.SaveResult> srList =  database.update(updateDBList,false);
            if(srList.size()>0){
                exc.saveResultErrors(srList,updateDBList,'MDLZ_OrderConsolidation()','ACCL__order__c','id');
            }
            
        }else{
            system.debug('No records to be updated');
        } 
       }catch(exception e){
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('MDLZ_OrderConsolidation()',e.getStackTraceString(),e.getLineNumber(),e.getTypeName()); 
        } 
        
    }
    
}