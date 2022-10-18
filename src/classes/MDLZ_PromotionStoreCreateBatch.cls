/***************************************************************
Name: MDLZ_PromotionStoreCreateBatch
======================================================
Purpose: this batch process will create the records for junction Object Promotion Store and will call
the promotion export creation batch from the finish method.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Gaurav Gupta                 09/19/2022     Initial Development    

***************************************************************/

global class MDLZ_PromotionStoreCreateBatch implements Database.Batchable<sObject>{

    //Creating custom exception
    public class applicationException extends Exception {}

    String promotionStage = MDLZ_ConstantHelper.Promotion_Stage_Committed;
    public static MDLZ_Promotion_Export_AdBreak__mdt adbreakMetadata = getMetadataRecord();
    
    global Database.QueryLocator start(Database.BatchableContext btx){
        
        Date weekStartDate = Date.Today().addDays(Integer.valueOf(adbreakMetadata.Week_Start_Sun__c));
        Date weekEndDate = Date.Today().addDays(Integer.valueOf(adbreakMetadata.Week_End_Sat__c));
        String query = 'Select Id ,name,ACCL__Anchor_Account__c,ACCL__Anchor_Account_Set__c,'+
                        +'ACCL__Date_From__c,ACCL__Date_Thru__c,ACCL__Phase__c,ACCL__Active__c, '+
                        +'ACCL__Anchor_Account__r.MDLZ_Ad_Break_Day__c,ACCL__Anchor_Account__r.Name, '+
                        +'ACCL__Anchor_Account_Set__r.Name,ACCL__Promotion_Template_Description__c, '+
                        +'ACCL__Anchor_Account_Set__r.ACCL__Description__c from ACCL__Promotion__c'+
                        +' where ACCL__Active__c = TRUE AND ACCL__Date_From__c <= :weekEndDate AND ACCL__Date_Thru__c >= :weekStartDate AND ACCL__Phase__c = :promotionStage';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        //Calling the handler class to create the relevant records for Promotion store 
        MDLZ_PromotionStoreCreateBatchHandler.createPromoStoreRecord(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        //Calling the MDLZ_PromotionExportBatch to create the promotion Export Records
        if(Integer.valueOf(Label.MDLZ_PromotionStoreCreateBatch) > 1){
            //throwing exception for batch size greater than 1
            throw new applicationException(MDLZ_ConstantHelper.promoExportBatchSizeError);
        }
        else {
            Integer PromotionExportBatchSize = Integer.valueOf(Label.MDLZ_PromotionExportBatch);
            MDLZ_PromotionExportBatch createPromotionExportBatch = new MDLZ_PromotionExportBatch();
            database.executeBatch(createPromotionExportBatch, PromotionExportBatchSize);
        }
    }
    
    
    public static MDLZ_Promotion_Export_AdBreak__mdt getMetadataRecord(){
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        System.debug('###### Day : ' + dayOfWeek);
        
        MDLZ_Promotion_Export_AdBreak__mdt metadataRec = [Select Id , Label, Week_Start_Sun__c,Week_End_Sat__c,
                                                          Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,
                                                          Saturday__c,Sunday__c,Batch_Size__c
                                                          from MDLZ_Promotion_Export_AdBreak__mdt 
                                                          where Label = :dayOfWeek limit 1];
        
        return metadataRec;
        
    }
    
}