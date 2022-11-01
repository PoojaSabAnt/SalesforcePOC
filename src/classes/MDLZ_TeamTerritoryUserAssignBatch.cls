/***************************************************************
Name: MDLZ_TeamTerritoryUserAssignBatch
======================================================
Purpose:
Org unit users creation Batch. Assignment of users from L5 to L6.
THe handler class - MDLZ_TeamTerritoryUserAssignment will be reused in MDLZ_RDRTeamUserAssignBatch the batches.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                05/09/2021     Initial Development    

***************************************************************/

global class MDLZ_TeamTerritoryUserAssignBatch implements Database.Batchable<sObject>,Schedulable{  
    
    //Defining the Scheduled Batch Size thru custom label
    public integer defaultChildBatchSize;
    
    global MDLZ_TeamTerritoryUserAssignBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        //Only take the org level team records
        String orglev = MDLZ_ConstantHelper.Team;
        String query = 'select id from ACCL__Org_Unit__c  where ACCL__Org_Level__c  =:orglev';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        //This handler class is reused in MDLZ_RDRTeamUserAssignBatch
        //Calling the apex handler class
        
        new MDLZ_TeamTerritoryUserAssignment().assignUsers(scope);
        
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize); 
        
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        //Chaining Org unit users creation Batch to execute after current batch is complete
        Database.executeBatch(new MDLZ_UpdateTerritoryFlagBatch(defaultChildBatchSize), defaultChildBatchSize);
        
        // Query the AsyncApexJob object to retrieve the current job's inp/formation.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                                FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
        
    }
}