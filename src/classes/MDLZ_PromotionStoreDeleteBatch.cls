/***************************************************************
Name: MDLZ_PromotionStoreDeleteBatch
======================================================
Purpose: this batch process will delete all the existing promotion Store records. Developed as
part of JIRA MRELKXIW-4366. From the finish method we will call MDLZ_PromotionStoreCreateBatch
batch to create the records for Promotion Store Junction Object.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description 
1.0      Gaurav Gupta                 09/19/2022     Initial Development   
***************************************************************/

global class MDLZ_PromotionStoreDeleteBatch implements Database.Batchable<sObject>{
     
     global Database.QueryLocator start(Database.BatchableContext bCtx){
         
         String query = 'Select Id from MDLZ_Promotion_Store__c';
         
         return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, List<sobject> scope){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();

        List<Database.DeleteResult> dbList = Database.Delete(scope);
        exc.deleteResultErrors(dbList,scope,'MDLZ_PromotionStoreDeleteBatch()','MDLZ_Promotion_Store__c','Id');
     
     }
     
     global void finish(Database.BatchableContext BC){
        //Calling the MDLZ_PromotionStoreCreateBatch to create promotion store records
        Integer PromotionExportBatchSize = Integer.valueOf(Label.MDLZ_PromotionStoreCreateBatch);
        MDLZ_PromotionStoreCreateBatch createPromotionStoreBatch = new MDLZ_PromotionStoreCreateBatch();
        database.executeBatch(createPromotionStoreBatch, PromotionExportBatchSize);
     }
     
 }