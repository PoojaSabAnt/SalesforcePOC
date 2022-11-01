/***************************************************************
Name: MDLZ_ProdAssortProd_Batch
======================================================
Purpose:
Batch process  runs every day that identifies 
Product Assortment Products that have not been updated in the past X-weeks 
(X should be a configurable variable that can be changed but will have a default value of 2)
and deactivates these records. Deactivation sohuld include setting the Valid Thru date to the current date and setting the active flag to false.

======================================================
History
-------
VERSION     AUTHOR          REVIEWER      DATE             DETAIL              Description
1.0       Bharath_Vikkurthi            07/02/2022    Initial Development 
2.0       Bharath_Vikkurthi            12/05/2022    changed the query locator to consider only Branch 

***************************************************************/
global class MDLZ_ProdAssortProd_Batch implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    //Custom label for last-n-days
   Integer  dt = Integer.valueOf(System.Label.MDLZ_Prod_Cleanup_Days); 
    
    //Defining the Scheduled Batch Size thru constructor
    public integer defaultChildBatchSize;
    public MDLZ_ProdAssortProd_Batch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        
        // Query the records lastmodified date eq to 14 days default 
        String query = 'Select Id, Name, ACCL__Active__c, ACCL__Valid_Thru__c,ACCL__Valid_From__c,LastModifiedDate' 
            +' from  ACCL__Product_Assortment_Product__c where MDLZ_ExternalID__c like \'%Branch%\' and  ACCL__Active__c = true and LastModifiedDate < LAST_N_DAYS:'+dt;
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<ACCL__Product_Assortment_Product__c> scope)
    {
         new MDLZ_ProdAssortProd_Cleanup().getLastModrec(scope); 
    
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MDLZ_ProdAssortProd_Batch(200), defaultChildBatchSize);    
    } 
    
    global void finish(Database.BatchableContext BC)
    {
          
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                                CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
    }
    
}