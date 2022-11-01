/***************************************************************
Name: MDLZ_PromotionExportDeleteBatch
======================================================
Purpose: this batch process will delete all the existing promotion Export records. Developed as
part of JIRA MRELKXIW-4366. Finish method will call the MDLZ_PromotionExportDeleteBatch batch
to delete the existing promotion store records.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description 
1.0      Gaurav Gupta                 09/19/2022     Initial Development   
***************************************************************/

global class MDLZ_PromotionExportDeleteBatch implements Database.Batchable<sObject>,Schedulable{

    public static Integer batchSize = Integer.valueOf(Label.MDLZ_PromotionExportDeleteBatch);
     
     global Database.QueryLocator start(Database.BatchableContext bCtx){
         
         String query = 'Select Id from MDLZ_Promotion_Export__c';
         
         return Database.getQueryLocator(query);
     }

     global MDLZ_PromotionExportDeleteBatch(){
        
     }
     
     global void execute(Database.BatchableContext BC, List<sobject> scope){
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();

        List<Database.DeleteResult> dbList = Database.Delete(scope);
        exc.deleteResultErrors(dbList,scope,'MDLZ_PromotionExportDeleteBatch()','MDLZ_Promotion_Export__c','Id');
        
     }
     
     global void finish(Database.BatchableContext BC){
        MDLZ_PromotionStoreDeleteBatch promotionStoreDeleteBatch = new MDLZ_PromotionStoreDeleteBatch();
        database.executeBatch(promotionStoreDeleteBatch, batchSize);
     }
     
     global void execute(SchedulableContext sc){         
         MDLZ_PromotionExportDeleteBatch obj = new MDLZ_PromotionExportDeleteBatch();
         database.executeBatch(obj,batchSize);
     }
     
 }