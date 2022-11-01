/***************************************************************
Name: MDLZ_PromotionStoreCreateBatchHandler
======================================================
Purpose: Handler class for batch MDLZ_PromotionStoreCreateBatch, this class will and create Promotion Store records 
using either Account Hierarchy or Customer Set. Accounts will be queried for all the valid promotions 
based on the Anchor Customer or the Anchor customer set.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Gaurav Gupta                 09/19/2022        Initial Development    

***************************************************************/
public with sharing class MDLZ_PromotionStoreCreateBatchHandler {

    public static void createPromoStoreRecord(List<ACCL__Promotion__c> promotionList){

        List<MDLZ_Promotion_Store__c> promotionStoreRecords = new List<MDLZ_Promotion_Store__c>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();

        if(promotionList.size() > 1){
            exc.insertExceptions('MDLZ_PromotionStoreCreateBatchHandler()', MDLZ_ConstantHelper.promoExportBatchSizeError, 0, 'batchSizeError');
        } else {

            try{

                if(promotionList[0].ACCL__Anchor_Account__c != null){
                    //Query to fetch all L6 Accounts that are related to promotion Anchor Account in the Account Hierarchy
                    for(ACCL__Flatten_Account_Hierarchy__c rec : [Select ACCL__Account__c from ACCL__Flatten_Account_Hierarchy__c 
                                                    where (NOT ACCL__Account__r.ACCL__Account_Number__c LIKE 'US%') AND ACCL__Account__r.MDLZ_Ad_Break_Day__c != null AND
                                                    (ACCL__Account_Level_01__c = :promotionList[0].ACCL__Anchor_Account__c OR 
                                                    ACCL__Account_Level_02__c = :promotionList[0].ACCL__Anchor_Account__c OR
                                                    ACCL__Account_Level_03__c = :promotionList[0].ACCL__Anchor_Account__c OR
                                                    ACCL__Account_Level_04__c = :promotionList[0].ACCL__Anchor_Account__c OR
                                                    ACCL__Account_Level_05__c = :promotionList[0].ACCL__Anchor_Account__c)]){
                                                        promotionStoreRecords.add(new MDLZ_Promotion_Store__c(Promotion__c = promotionList[0].Id,
                                                                                                                Store__c = rec.ACCL__Account__c));
                                                    }
        
                } else if(promotionList[0].ACCL__Anchor_Account_Set__c != null) {
                    //Query to fetch all the account in a Customer set related to promotion
                    for(ACCL__Account_Set_Account__c csa : [Select Id, ACCL__Account_Set_Account__c from ACCL__Account_Set_Account__c where 
                                                ACCL__Account_Set__c = : promotionList[0].ACCL__Anchor_Account_Set__c AND ACCL__Account_Set_Account__r.MDLZ_Ad_Break_Day__c != null]){
                                                    promotionStoreRecords.add(new MDLZ_Promotion_Store__c(Promotion__c = promotionList[0].Id,
                                                                                                            Store__c = csa.ACCL__Account_Set_Account__c));
                                                }
                }
        
                //Inserting the promotion store records and logging the failure if any
                srList = Database.Insert(promotionStoreRecords,false);
                exc.saveResultErrors(srList,promotionStoreRecords,'MDLZ_PromotionStoreCreateBatchHandler().createPromoStoreRecord','MDLZ_Promotion_Store__c','Store__c');

            } catch (Exception e){
                exc.insertExceptions('MDLZ_PromotionStoreCreateBatchHandler()',e.getMessage(),e.getLineNumber(),e.getTypeName());
            }
        }
        
    }
}
