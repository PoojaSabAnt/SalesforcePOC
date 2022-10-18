/***************************************************************
Name: MDLZ_UpdateNOSEDIOrdersBatch
======================================================
Purpose:
a. batch1 to update NOS and EDI orders to Routed or cancelled 
	refer conditions in confluence matrix.
======================================================
History
-------
VERSION     AUTHOR         REVIWER      DATE             DETAIL              Description
1.0      Bharath Vikkurthi            18/09/2021     Initial Development    

***************************************************************/

global with sharing class MDLZ_UpdateNOSEDIOrdersBatch implements Database.Batchable< sObject >,Schedulable {
    global   Database.QueryLocator start(Database.BatchableContext BC)    
    {
        
        //Date  systemYesterday =System.Today();
        
        //Retrieve list of orders with order template as EDI and NOS for the current day
            String query = 'SELECT Id, ACCL__Delivery_Date__c,ACCL__Order_Account__c, ACCL__Order_Template__r.Name,ACCL__Phase__C, '+
            'MDLZ_Total_Case_Quantity__c FROM ACCL__Order__c WHERE ACCL__Delivery_Date__c >= today and ACCL__Delivery_Date__c <= tomorrow '+
            'and ACCL__Order_Template__r.Name in (\'NOS\',\'EDI\') and ACCL__Phase__c in (\'Received By SAP\',\'Send to SAP\',\'Locked\')';
        //String query = 'SELECT Id from Account';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> orderList)
    {
       // new MDLZ_OrderConsolidation().updateNOSEDIOrders(orderList); 
    }
   
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MDLZ_UpdateNOSEDIOrdersBatch(), 500);   
    }
    
    global void finish(Database.BatchableContext BC)
    {
      // Query the AsyncApexJob object to retrieve the current job's information.
AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                        CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);   
    }
}