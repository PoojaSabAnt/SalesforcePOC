/***************************************************************
Name: MDLZ_PromotionExportBatchTest
======================================================
Purpose:
Test class for MDLZ_PromotionExportBatch class
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Jinal Desai                  09/22/2022     Initial Development

***************************************************************/
@isTest
private class MDLZ_PromotionExportBatchTest {
    
     @testSetup static void dataCreation(){
                
       List<ACCL__Promotion_Template__c> newPromotionTemplateList = new List<ACCL__Promotion_Template__c>(); 
        
       ACCL__Promotion_Template__c promoFandDScriptedTemplate= new ACCL__Promotion_Template__c(Name='F&D Scripted', ACCL__Promotion_Type__c='SellablePromotion',
                                                                                   ACCL__Sales_Org__c='US01',ACCL__Description_Language_1__c='F&D Scripted',
                                                                                   ACCL__Product_Definition_Level__c='Tactic' ,ACCL__UI_Type__c='StandardUI');
        newPromotionTemplateList.add(promoFandDScriptedTemplate);
        
        ACCL__Promotion_Template__c promoFandDNonScriptedTemplate= new ACCL__Promotion_Template__c(Name='F&D Non Scripted', ACCL__Promotion_Type__c='SellablePromotion',
                                                                                   ACCL__Sales_Org__c='US01',ACCL__Description_Language_1__c='F&D Non Scripted',
                                                                                   ACCL__Product_Definition_Level__c='Tactic' ,ACCL__UI_Type__c='StandardUI');
        newPromotionTemplateList.add(promoFandDNonScriptedTemplate);
        
        ACCL__Promotion_Template__c promoTemplate= new ACCL__Promotion_Template__c(Name='Sellable Promotion Test', ACCL__Promotion_Type__c='SellablePromotion',
                                                                                   ACCL__Sales_Org__c='US01',ACCL__Description_Language_1__c='Sellable Promotion Test',
                                                                                   ACCL__Product_Definition_Level__c='Tactic' ,ACCL__UI_Type__c='StandardUI');
        
        newPromotionTemplateList.add(promoTemplate);
        
        if(newPromotionTemplateList.size() > 0){
            Database.Insert(newPromotionTemplateList,false);
        }
        
        system.assertEquals(3,newPromotionTemplateList.size());
        
         List<ACCL__Promotion_Template__c> promotionTemplateList = [Select Id from ACCL__Promotion_Template__c];
      
         // accountList for Customer Set Customer
        List<Account> accountList = MDLZ_TestDataFactory.insertAccount(6,true);
        
        accountList[0].MDLZ_Ad_Break_Day__c = 'Monday';
        accountList[1].MDLZ_Ad_Break_Day__c = 'Tuesday';
        accountList[2].MDLZ_Ad_Break_Day__c = 'Wednesday';
        accountList[3].MDLZ_Ad_Break_Day__c = 'Thursday';
        accountList[4].MDLZ_Ad_Break_Day__c = 'Friday';
        accountList[5].MDLZ_Ad_Break_Day__c = 'Saturday';
        
        Database.Update(accountList,false);
                
        // Customer Set 
        List<ACCL__Account_Set__c> customerSetList = MDLZ_TestDataFactory.insertCustomerSetList(1,true);
        
        // Customer Set Customers
        List<ACCL__Account_Set_Account__c> customerSetCustomerList = new List<ACCL__Account_Set_Account__c>();
        
        for(Integer i=0 ; i<accountList.size();i++){
            ACCL__Account_Set_Account__c customerSetCust = new ACCL__Account_Set_Account__c();
            customerSetCust.ACCL__Account_Set_Account__c = accountList[i].id;
            customerSetCust.ACCL__Account_Set__c = customerSetList[0].Id;
            customerSetCustomerList.add(customerSetCust);
        }
        
        if(customerSetCustomerList.size() > 0){
            Insert customerSetCustomerList;
        }
                
        List<ACCL__Promotion__c> promotionWithTacticList = new List<ACCL__Promotion__c>();
        
        ACCL__Promotion__c promotion1 = new ACCL__Promotion__c();
        promotion1.ACCL__Promotion_Template__c = promotionTemplateList[0].Id;
        promotion1.ACCL__Date_From__c= Date.Today();
        promotion1.ACCL__Date_Thru__c= Date.Today().addDays(60);
        promotion1.ACCL__Anchor_Account_Set__c = customerSetList[0].Id;
        promotion1.ACCL__Slogan_Language_1__c='Test Promotion 1';
        promotion1.ACCL__Active__c=True;
        promotion1.ACCL__Phase__c='Committed';
        promotionWithTacticList.add(promotion1);    
        
        ACCL__Promotion__c promotion2 = new ACCL__Promotion__c();
        promotion2.ACCL__Promotion_Template__c = promotionTemplateList[1].Id;
        promotion2.ACCL__Date_From__c= Date.Today();
        promotion2.ACCL__Date_Thru__c= Date.Today().addDays(60);
        promotion2.ACCL__Anchor_Account_Set__c = customerSetList[0].Id;
        promotion2.ACCL__Slogan_Language_1__c='Test Promotion 2';
        promotion2.ACCL__Active__c=True;
        promotion2.ACCL__Phase__c='Committed';
        promotionWithTacticList.add(promotion2); 
        
        ACCL__Promotion__c promotion3 = new ACCL__Promotion__c();
        promotion3.ACCL__Promotion_Template__c = promotionTemplateList[2].Id;
        promotion3.ACCL__Date_From__c= Date.Today();
        promotion3.ACCL__Date_Thru__c= Date.Today().addDays(60);
        promotion3.ACCL__Anchor_Account_Set__c = customerSetList[0].Id;
        promotion3.ACCL__Slogan_Language_1__c='Test Promotion 3';
        promotion3.ACCL__Active__c=True;
        promotion3.ACCL__Phase__c='Committed';
        promotionWithTacticList.add(promotion3);
        
        if(promotionWithTacticList.size() > 0){
            Database.Insert(promotionWithTacticList,false);
        }
        
        List<ACCL__Tactic__c> tacticList = new List<ACCL__Tactic__c>();
        
        List<ACCL__Promotion__c> insertedPromotionList = [Select Id from ACCL__Promotion__c];
        
        for(Integer i=0 ; i< insertedPromotionList.size() ; i++){
            ACCL__Tactic__c tactic = new ACCL__Tactic__c();
            tactic.ACCL__Promotion__c=insertedPromotionList[i].id;
            tactic.ACCL__Date_From__c= Date.today(); 
            tactic.ACCL__Date_Thru__c= Date.today().addDays(60);
            tacticList.add(tactic);
        }
        
        if(tacticList.size() > 0){
            Database.Insert(tacticList,false);
        }
        
        ACCL__Product__c product = new ACCL__Product__c(Name='Test Mondelez');
        insert product;
        
        List<ACCL__Tactic_Product__c> tacticProductList = new List<ACCL__Tactic_Product__c>();
        
        list<ACCL__Tactic__c> insertedTacticList = [Select Id from ACCL__Tactic__c];
        for(Integer i=0 ;i<insertedTacticList.size() ; i++){
           ACCL__Tactic_Product__c tacticProd = new ACCL__Tactic_Product__c();
           tacticProd.MDLZ_Price__c = 5;
           tacticProd.MDLZ_Location__c='xff'; 
           tacticProd.MDLZ_SubPPG__c='1Big Bags';
           tacticProd.MDLZ_PPG__c ='1Big Bags'; 
           tacticProd.ACCL__Tactic__c=insertedTacticList[i].id; 
           tacticProd.ACCL__Included__c=true;
           tacticProd.ACCL__Product__c =product.id;
           tacticProductList.add(tacticProd);
            
        }
        
        if(tacticProductList.size() > 0){
            Database.Insert(tacticProductList,false);
        }
        
        List<MDLZ_Promotion_Store__c> newPromoStoreList = new List<MDLZ_Promotion_Store__c>();
        
        for(Integer i=0 ; i<accountList.size() ; i++ ){
            for(Integer j=0 ; j<promotionWithTacticList.size() ;j++){
                MDLZ_Promotion_Store__c promoStore = new MDLZ_Promotion_Store__c();
                promoStore.Promotion__c = promotionWithTacticList[j].Id;
                promoStore.Store__c = accountList[i].Id;
                newPromoStoreList.add(promoStore);
            }
            
        }
        
        if(newPromoStoreList.size() > 0){
            Database.Insert(newPromoStoreList,false);
        }
        
    }
    
    @isTest static void testPromotionWithCustomerSet(){
        
        Test.startTest();
        MDLZ_PromotionExportBatch obj = new MDLZ_PromotionExportBatch();
        Database.executeBatch(obj);
        Test.stopTest();
             
    }

}