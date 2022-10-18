/***************************************************************
Name: MDLZ_ProdAssortment_ByCustBranchBatch
======================================================
Purpose:
1. If Account/Store changes Branch assignment, Branch product listing is updated for 
   the store and changes are synced to mobile device
2. Products that no longer exist in updated Branch are removed from mobile app ordering
3. Products that are available in the new Branch and not available in the old branch are
   available in mobile app ordering.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                09/02/2022     Initial Development   

***************************************************************/
global class MDLZ_ProdAssortment_ByCustBranchBatch implements Database.Batchable<sObject>,Schedulable {

    //Defining the Scheduled Batch Size thru custom label
    private integer defaultChildBatchSize;
    public MDLZ_ProdAssortment_ByCustBranchBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    //query locator retrieving thedata for accounts modified
    global Database.QueryLocator start(Database.BatchableContext bCtx){
        
        string custmStart='';
        string custmEnd ='';
        String query = '';
		//custom setting for lastmodified date to run for today - no.ofdays        
        MDLZ_LastmodifiedDate__c custSetting = MDLZ_LastmodifiedDate__c.getInstance('MDLZ_ProdAssortBranch');
        Integer noOfDays = Integer.valueOf(custSetting.MDLZ_NoOfDays__c);
        if(custSetting != Null ){
            custmStart = DateTime.now().addDays(-noOfDays).format('yyyy-MM-dd\'T\'00:00:00\'z\''); 
        	custmEnd = DateTime.now().addDays(-noOfDays).format('yyyy-MM-dd\'T\'23:59:59\'z\'');
            query ='select id,MDLZ_SAPBranchId__c,ACCL__ExternalId__c from Account'
                +' where MDLZ_SAPBranchId__c != null and LastModifiedDate > '+custmStart+' and LastModifiedDate <'+custmEnd;
            }else{
            query ='select id,MDLZ_SAPBranchId__c,ACCL__ExternalId__c from Account'
                +' where MDLZ_SAPBranchId__c != null and LastModifiedDate = today';
        }
        
        
        return Database.getQueryLocator(query);
    }
    
//execute method calling the handler class
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        //Calling the apex handler class
        new MDLZ_ProdAssortment_ByCustBranch().updateProductAssortment(scope);
    }
    
    //schedulable method of batch class
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MDLZ_ProdAssortment_ByCustBranchBatch(200), defaultChildBatchSize); 
        
    }
    //finish method calling the AuthorizationListSetupBatch 
    global void finish(Database.BatchableContext BC)
    {
        //chaining with AuthorizationlistSetup batch
        Database.executeBatch(new AuthorizationListSetupBatch(), defaultChildBatchSize);
        // Query the AsyncApexJob object to retrieve the current job's information.
        //AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,
                               // TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
    }
}