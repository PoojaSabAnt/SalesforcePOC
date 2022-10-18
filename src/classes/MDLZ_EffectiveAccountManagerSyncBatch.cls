/***************************************************************
Name: MDLZ_EffectiveAccountManagerSyncBatch
======================================================
Purpose:
Custom batch for the core batch - EffectiveAccountManagerSyncBatch. This was
rewritten to handle huge volume of data and the batch running for more than 6-8 hours
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                05/30/2022     Initial Development
1.1     Vaidehi Heda                  09/15/2022     Added flag to check active customer manager in start query to avoid error 

***************************************************************/
global class MDLZ_EffectiveAccountManagerSyncBatch implements Schedulable, Database.Batchable<sObject> {
    
     //Custom label for last-n-days
   Integer  dt = Integer.valueOf(System.Label.MDLZ_EffectiveAccountManager_Days);     
    
    //Defining the Scheduled Batch Size thru custom label
    public integer defaultChildBatchSize;
    
    global MDLZ_EffectiveAccountManagerSyncBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query ='select id, ACCL__Account__c, ACCL__User__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c from ACCL__Account_Manager__c where ACCL__User__r.IsActive = true'+
            ' AND LastModifiedDate >= LAST_N_DAYS:'+dt+' order by ACCL__Account__c';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        new MDLZ_EffectiveAccountManagerSync().addAccountTeamMember(scope);
    }
    
     global void execute(SchedulableContext SC){
        Database.executeBatch(this, defaultChildBatchSize); 
    }
    
    global void finish(Database.BatchableContext BC){
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                                FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);
    }

}