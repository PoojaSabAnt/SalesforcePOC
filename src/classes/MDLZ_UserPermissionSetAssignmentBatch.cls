/***************************************************************
Name: MDLZ_UserPermissionSetAssignmentBatch
======================================================
Purpose:
a.Create a batch of 100 users per batch for all users last modified today
to assign permission sets to each user based on role.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                05/08/2021     Initial Development    
1.0      Priya Tubachi    Abir Ghosh  04/01/2022    
1.1      Bharath/Vaidehi              01/03/2022    Made the changes as per 2927,changes in query to check if MDLZ_isRoleChanged__c
is changed.
***************************************************************/
global class MDLZ_UserPermissionSetAssignmentBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    //added this to insert all logs together in finish method so that mixed DML can be avoided
    global List<ExceptionLog__c>logs = new List<ExceptionLog__c>();
    //Defining the Scheduled Batch Size thru constructor
    public integer defaultChildBatchSize;
    public MDLZ_UserPermissionSetAssignmentBatch(){
    }
    public MDLZ_UserPermissionSetAssignmentBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;        
    } 
    String rolech = MDLZ_ConstantHelper.RoleChanged;
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        String query;
        if(Test.isRunningTest()){
            query = 'Select Id, UserRole.name,Profile.Name from User where isactive = true and MDLZ_isRoleChanged__c =:rolech limit 5' ;
        }else {
			query = 'Select Id, UserRole.name,Profile.Name from User where isactive = true and MDLZ_isRoleChanged__c =:rolech' ;
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        new MDLZ_UserPermissionSetAssignment().getUsersPermissionsSets(scope ,logs); 
    }
    global void execute(SchedulableContext ctx) {
        // Database.executeBatch(this, defaultChildBatchSize);   
        Database.executeBatch(new MDLZ_UserPermissionSetAssignmentBatch(200), 200);
    } 
    global void finish(Database.BatchableContext BC)
    {   //inserting all exception logs together
        if(logs.size()>0){
            insert logs;}
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                                CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
    }
    
}