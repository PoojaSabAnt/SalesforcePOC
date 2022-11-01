/***************************************************************
Name: MDLZ_DeleteProdAssortBranchListingBatch
======================================================
Purpose:
Deletes the Product Assortment Store records for Branch listing assortment.
Creating this as a separate method as the existing method processFinish hits the limit of deleting 10K records
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                08/03/2022     Initial Development    
***************************************************************/

global class MDLZ_DeleteProdAssortBranchListingBatch implements Database.Batchable<sObject>,Schedulable{
	
    //Defining the Scheduled Batch Size thru custom label
    private integer defaultChildBatchSize;
    public MDLZ_DeleteProdAssortBranchListingBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    //query locator extracts invalid PAA records for PA template = listing
    global Database.QueryLocator start(Database.BatchableContext bCtx){
        
        String templateName = MDLZ_ConstantHelper.Branch_Listing;
        String query ='select id,ACCL__Account__c,ACCL__Product_Assortment__c, ACCL__Product_Assortment__r.name,ACCL__Valid_Thru__c from ACCL__Product_Assortment_Account__c'
            +' where ACCL__Valid_Thru__c <= today and ACCL__Product_Assortment__r.ACCL__Product_Assortment_Template__r.name=:templateName';
        
        return Database.getQueryLocator(query);
    }
    
    //execute method of batch class
   global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        //Calling the apex handler class
        new MDLZ_DeleteProdAssortBranchListing().deleteInvalidPAARecord(scope);
    }
    
    //schedulable execute method of batch class
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MDLZ_DeleteProdAssortBranchListingBatch(200), defaultChildBatchSize); 
        
    }
    
    //finish method of the batch class
    global void finish(Database.BatchableContext BC)
    {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                                FROM AsyncApexJob WHERE Id =:BC.getJobId()];
          
    }
}