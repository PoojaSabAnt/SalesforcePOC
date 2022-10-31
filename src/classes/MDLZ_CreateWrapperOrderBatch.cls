/***************************************************************
Name: MDLZ_CreateWrapperOrderBatch
======================================================
Purpose:
a. 
======================================================
History
-------
VERSION     AUTHOR         REVIWER      DATE             DETAIL              Description
1.0               Bharath Vikkurthi        		 06/05/2022     Initial Development    
***************************************************************/
//Changes as per JIRA MRELKXIW-2299

global with sharing class MDLZ_CreateWrapperOrderBatch  implements Database.Batchable< sObject >, Schedulable,Database.Stateful{
    
      //Defining the Scheduled Batch Size thru constructor
    public integer defaultChildBatchSize;
    public MDLZ_CreateWrapperOrderBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
     global   Database.QueryLocator start(Database.BatchableContext BC)    
    {
        String query = 'Select Id, ACCL__Order_Account__c, ACCL__Delivery_Date__c,ACCL__Order__c.ACCL__Phase__c, ACCL__Order_Template__c,ACCL__Order__c.ACCL__Order_Id__c,'+
		+'ACCL__Order_Account__r.ACCL__Account_Number__c'+
            +' from ACCL__Order__c where ACCL__Order_Template__r.Name in (\'Order\',\'NOS\',\'EDI\') and  '+
            +'ACCL__Phase__c NOT IN (\'REJECTED\',\'DELETED\',\'CANCELLED\') and createdDate >=yesterday';

        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        new MDLZ_CreateWrapperCAOOrder().createWrapper(scope);
    }
    
      global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize);    
    } 
    
    global void finish(Database.BatchableContext BC)
    {
          // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                                CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
    }
    

}