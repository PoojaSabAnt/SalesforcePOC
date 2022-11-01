/***************************************************************
Name: MDLZ_UpdateOrgUnitUserValidityBatch
======================================================
Purpose: this is the pre-processing batch process will be created for Org Unit User Clean-up
o New process will run before the current Org Unit User process runs
o New process will identify all users that have updates and deactivate all Org Unit User records (Today - 1) and then unset the new "update" flag
o Existing process will then run and expand the existing District and Team Org Unit User records from the top down (G4->G5 and G5->G6)
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Priya Tubachi                03/30/2022     Initial Development    

***************************************************************/

global class MDLZ_UpdateOrgUnitUserValidityBatch implements Database.Batchable<sObject>,Schedulable{  
    
    //Defining the Scheduled Batch Size thru custom label
    public integer defaultChildBatchSize;
    global MDLZ_UpdateOrgUnitUserValidityBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    //query locator for the batch to retrieve records
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        String intUpdated = MDLZ_ConstantHelper.IntUpdated;
        String query ;
        if(test.isRunningTest()){
         query = 'Select Id from User where MDLZ_isChanged__c =: intUpdated and isActive = true LIMIT 1';   
        }else{
            //Made changes to the query as part of MRELKXIW-4033
        	query = 'Select Id from User where MDLZ_isChanged__c =: intUpdated and IsActive = true and id in (select ACCL__User__c from ACCL__Org_Unit_User__c where MDLZ_isOrgUnitChanged__c =: intUpdated)';}
        return Database.getQueryLocator(query);
        
    }
    
    //execute method of the batch class
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        //Calling the apex handler class
        system.debug('size of the list '+ scope.size());
        new MDLZ_UpdateOrgUnitUserValidity().updateUserValidity(scope); 
    }
    
    //schedulable execute method for the batch class
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize); 
    } 
    
    //finish method of the batch class
    global void finish(Database.BatchableContext BC)
    {
        //Chaining Batch chain the L4 -> L5 -> L6 batch         
             Database.executeBatch(new MDLZ_RDRTeamUserAssignBatch(defaultChildBatchSize), defaultChildBatchSize);
        
    }
}