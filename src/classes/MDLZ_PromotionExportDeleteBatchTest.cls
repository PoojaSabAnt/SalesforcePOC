/***************************************************************
Name: MDLZ_PromotionExportDeleteBatchTest
======================================================
Purpose:
Test class for MDLZ_PromotionExportDeleteBatch, MDLZ_PromotionStoreDeleteBatch, MDLZ_PromotionStoreCreateBatch and
MDLZ_PromotionStoreCreateBatchHandler class
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                 09/22/2022     Initial Development

***************************************************************/
@isTest
private class MDLZ_PromotionExportDeleteBatchTest {
    
    @testSetup static void dataCreation(){
       //test setup, creating promotionTemplate
       List<ACCL__Promotion_Template__c> promotionTemplateList = new List<ACCL__Promotion_Template__c>();
        
       ACCL__Promotion_Template__c promoFandDScriptedTemplate= new ACCL__Promotion_Template__c(Name='F&D Scripted', ACCL__Promotion_Type__c='SellablePromotion',
                                                                                   ACCL__Sales_Org__c='US01',ACCL__Description_Language_1__c='F&D Scripted',
                                                                                   ACCL__Product_Definition_Level__c='Tactic' ,ACCL__UI_Type__c='StandardUI');
        promotionTemplateList.add(promoFandDScriptedTemplate);
        
        if(promotionTemplateList.size() > 0){
            Database.Insert(promotionTemplateList,false);
        }
        system.assertEquals(1,promotionTemplateList.size());
        
    }
    
    //test method for testing the batch for promotion with customer set relation
    @isTest static void testDeletePromoExportBatchForCustomerSet(){
        List<ACCL__Promotion_Template__c> promotionTemplateList = [Select Id from ACCL__Promotion_Template__c];
        // accountList for Customer Set Customer
        List<Account> accountList = MDLZ_TestDataFactory.insertAccount(1,true);
        accountList[0].MDLZ_Ad_Break_Day__c = 'Wednesday';
        
        Database.Update(accountList,false);
                
        // Customer Set 
        ACCL__Account_Set__c customerSet = new ACCL__Account_Set__c(ACCL__Description_Language_1__c ='Mondelez Description', ACCL__Sales_Org__c='US01');
        Insert customerSet;
        
        // Customer Set Customers
        ACCL__Account_Set_Account__c customerSetCust = new ACCL__Account_Set_Account__c();
        customerSetCust.ACCL__Account_Set_Account__c = accountList[0].id;
        customerSetCust.ACCL__Account_Set__c = customerSet.Id;
        Insert customerSetCust;
        
        //Creating promotion test record
        ACCL__Promotion__c promotion1 = new ACCL__Promotion__c();
        promotion1.ACCL__Promotion_Template__c = promotionTemplateList[0].Id;
        promotion1.ACCL__Date_From__c= Date.Today();
        promotion1.ACCL__Date_Thru__c= Date.Today().addDays(60);
        promotion1.ACCL__Anchor_Account_Set__c = customerSet.Id;
        promotion1.ACCL__Slogan_Language_1__c='Test Promotion 1';
        promotion1.ACCL__Active__c=True;
        promotion1.ACCL__Phase__c='Committed';

        Database.Insert(promotion1,false);
        
        //Creating promotion store list record
        List<MDLZ_Promotion_Store__c> promoStoreList = new List<MDLZ_Promotion_Store__c>{new MDLZ_Promotion_Store__c(Promotion__c = promotion1.Id,
                                                                                                            Store__c = accountList[0].Id)};
        Database.Insert(promoStoreList,false);
        
        //Creating promotion export list records
        List<MDLZ_Promotion_Export__c> promoExportList = new List<MDLZ_Promotion_Export__c>();
        
        for(Integer i=0 ; i<5 ; i++){
            MDLZ_Promotion_Export__c promoExp = new MDLZ_Promotion_Export__c();
            promoExp.MDLZ_Activity_ID__c = 'TestPromotion' + i;
            promoExp.MDLZ_Activity_Task_Description__c = 'Test Template'+i;
            promoExp.MDLZ_Activity_Ad_Break_Date__c = Date.Today().addDays(3);
            promoExportList.add(promoExp);
        }
        
        if(promoExportList.size() > 0){
            Database.Insert(promoExportList,false);
        }
        
        Test.startTest();
        SchedulableContext sc = null;
        MDLZ_PromotionExportDeleteBatch obj = new MDLZ_PromotionExportDeleteBatch();
        obj.execute(sc);
        Test.stopTest();
    }
    
    //test method for testing the batch for promotion with anchor account relation
    @isTest static void testDeletePromoExportBatchForAnchorAccount(){
        List<ACCL__Promotion_Template__c> promotionTemplateList = [Select Id from ACCL__Promotion_Template__c];
        
        // accountList for Anchor Account
        List<Account> accountList = MDLZ_TestDataFactory.insertAccount(2,true);
        accountList[0].MDLZ_Ad_Break_Day__c = 'Wednesday';
        accountList[0].ACCL__Account_Number__c='24Demo Unique567'+Integer.valueOf(Math.random() * 10);
        
        //Flatten Account Hierarchy record for testing anchor account query
        ACCL__Flatten_Account_Hierarchy__c accountHierarchy = new ACCL__Flatten_Account_Hierarchy__c();
        accountHierarchy.ACCL__Account_Level_01__c = accountList[1].Id;
        accountHierarchy.ACCL__Account__c = accountList[0].Id;
        Database.insert(accountHierarchy, false);
        
        Database.Update(accountList,false);
        
        //Creating promotion record
        ACCL__Promotion__c promotion1 = new ACCL__Promotion__c();
        promotion1.ACCL__Promotion_Template__c = promotionTemplateList[0].Id;
        promotion1.ACCL__Date_From__c= Date.Today();
        promotion1.ACCL__Date_Thru__c= Date.Today().addDays(60);
        promotion1.ACCL__Anchor_Account__c = accountList[1].Id;
        promotion1.ACCL__Slogan_Language_1__c='Test Promotion 1';
        promotion1.ACCL__Active__c=True;
        promotion1.ACCL__Phase__c='Committed';
        
        Database.Insert(promotion1,false);
        
        Test.startTest();
        SchedulableContext sc = null;
        MDLZ_PromotionExportDeleteBatch obj = new MDLZ_PromotionExportDeleteBatch();
        obj.execute(sc);
        Test.stopTest();
    }

}