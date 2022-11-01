/***************************************************************
Name: MDLZ_NewUserSetupBatch
======================================================
Purpose:
a.Create a batch of 100 users per batch for all users last modified today
	to assign sales org and user settings.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                05/08/2021     Initial Development    
1.1		 Priya Tubachi	  Abir Ghosh  18/01/2022
***************************************************************/
global class MDLZ_NewUserSetupBatch implements Database.Batchable<sObject>,Schedulable {
	
    Integer dt = Integer.valueOf(System.Label.MDLZ_NewUser_Days);
    
    //Defining the Scheduled Batch Size thru custom label
    public integer defaultChildBatchSize;
    public MDLZ_NewUserSetupBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC)    
    {  String query;
     if(test.isRunningTest()){
         query = 'select id, UserRole.name from user where UserRole.name != \'\' and '
             +'IsActive =true and createddate <=LAST_N_DAYS:'+dt+' LIMIT 1' ;
     }else{
         query = 'select id, UserRole.name from user where UserRole.name != \'\' and '
             	+'IsActive =true and createddate >=LAST_N_DAYS:'+dt ; }
     return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        new MDLZ_NewUserSetup().getNewUsers(scope); 
    }
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize);    
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
    }

}