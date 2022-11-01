/***************************************************************
Name: MDLZ_RDRTeamUserAssignBatch
======================================================
Purpose:
Assigns users from L4 to L5. This batch will be chained with MDLZ_TeamterritoryUserAssignBatch.
THe handler class - MDLZ_TeamTerritoryUserAssignment will be reused in both the batches.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                25/02/2021     Initial Development    

***************************************************************/

	global class MDLZ_RDRTeamUserAssignBatch implements Database.Batchable<sObject>,Schedulable{  
    
    //Defining the Scheduled Batch Size thru custom label
    private integer defaultChildBatchSize;
    //constructor for custom batch size
    global MDLZ_RDRTeamUserAssignBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    //queryLocator to get the org level = Market/District records
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        //Only take the org level L4 (Market/District) records
        String orglev = MDLZ_ConstantHelper.Market_District;
        String query = 'select id from ACCL__Org_Unit__c  where ACCL__Org_Level__c  =:orglev';
        return Database.getQueryLocator(query);
    }
    
        //execute method of batch class calls the handler class
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        
        //Calling the apex handler class
        new MDLZ_TeamTerritoryUserAssignment().assignUsers(scope);
        
    }
    
        //execute method to schedule the batch
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize); 
        
    } 
    
        //finish method of batch class
    global void finish(Database.BatchableContext BC)
    {
        //Chaining Org unit users creation Batch to execute after current batch is complete
        Database.executeBatch(new MDLZ_TeamTerritoryUserAssignBatch(defaultChildBatchSize), defaultChildBatchSize);
        
        // Query the AsyncApexJob object to retrieve the current job's information.
       AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                               FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        
    }
}