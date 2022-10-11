/***************************************************************
Name: MDLZ_KPI_Data_Delete_Batch
======================================================
Purpose: this batch process will deleted old Intelligent Recommendation records from KPIDAta table 
where active feedback period has ended for the recommendation. Records from last 1 or 2 weeks will be
deleted where mobilityRelevant = 'No' as per story MRELKXIW-5039

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description 
1.0		 Gaurav Gupta				  09/14/2022
***************************************************************/

global class MDLZ_KPI_Data_Delete_Batch implements Database.Batchable<sObject>,Schedulable {

    //Defining the Batch Size thru constructor
    public integer defaultBatchSize;
    public MDLZ_KPI_Data_Delete_Batch(integer batchSize){
        defaultBatchSize = batchSize;
    }
     
    global Database.QueryLocator start(Database.BatchableContext btx){
       String mobilityRelevant = MDLZ_ConstantHelper.mobilityRelevant;
       String KPIGroup = MDLZ_ConstantHelper.KPIGroup;
       String NoOfWeeks = Label.Old_IntelRec_Weeks;
       Integer noOfDays = (Integer)(0 - (Integer.valueOf(NoOfWeeks) * 7));
       Date startDate = date.today().addDays(noOfDays);
       //query the records for last 1 or 2 weeks depending on the business choice, taking  the values from custom labels
       String query = 'Select Id From MDLZ_KPIData__c Where CreatedDate < :startDate AND'
                      + ' MDLZ_Mobility_Relevant__c = :mobilityRelevant AND MDLZ_KPIGroup__c = :KPIGroup';
        if(Test.isRunningTest()){
            query = 'Select Id From MDLZ_KPIData__c Where MDLZ_Mobility_Relevant__c = :mobilityRelevant AND MDLZ_KPIGroup__c = :KPIGroup';
        }
        
        return Database.getQueryLocator(query);
    }

    global MDLZ_KPI_Data_Delete_Batch(){
       
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
       MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();

       if(scope.size() > 0){
           List<Database.DeleteResult> dbList = Database.Delete(scope);
           exc.deleteResultErrors(dbList,scope,'MDLZ_KPI_Data_Delete_Batch()','MDLZ_KPIData__c','Id');
       }
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext sc){
        MDLZ_KPI_Data_Delete_Batch obj = new MDLZ_KPI_Data_Delete_Batch();
        database.executeBatch(obj,defaultBatchSize);
    }
    
}