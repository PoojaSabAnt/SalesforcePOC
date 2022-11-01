/***************************************************************
Name: MDLZ_AddPPGTest
======================================================
Purpose:
Test class for MDLZ_AddPPG class
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                 06/07/2022     Initial Development

***************************************************************/

@isTest
private class MDLZ_AddPPGTest {
    static testMethod void getTacticProductsTest(){
        List<ACCL__Tactic_Product__c> tacticProdList = new List<ACCL__Tactic_Product__c>();
        List<ACCL__Tactic_Product__c> tacticProd = new List<ACCL__Tactic_Product__c>();
        ACCL__Tactic__c tacticId = new ACCL__Tactic__c();
        test.startTest();
        tacticProd = MDLZ_TestDataFactory.insertTacticProducts(1,true);
        tacticId = [Select id From ACCL__Tactic__c Limit 1];
        tacticProdList=MDLZ_AddPPG.getTacticProducts(tacticId.id);
        test.stopTest();
        system.assertEquals(tacticProd.size(), 1);
    }
    
    static testMethod void getProductsTest(){
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        test.startTest();
        productList = MDLZ_TestDataFactory.createProductRecords(5);
        Map<string,List<String>> getProductsResult = MDLZ_AddPPG.getProducts();
        test.stopTest();
        system.assertEquals(getProductsResult.get('Big Bags').size(), 5);
    }
    
    static testMethod void updateTacticProdTest(){
        Map<String, String> updateResult = new Map<String, String>();
        List<ACCL__Tactic_Product__c> tacticProdList = new List<ACCL__Tactic_Product__c>();
        List<ACCL__Tactic_Product__c> data = new List<ACCL__Tactic_Product__c>();
        ACCL__Tactic__c tacticId = new ACCL__Tactic__c();
        test.startTest();
        tacticProdList = MDLZ_TestDataFactory.insertTacticProducts(1,true);
        tacticId = [Select id From ACCL__Tactic__c Limit 1];
        ACCL__Tactic_Product__c tacticProd = new ACCL__Tactic_Product__c();
        tacticProd.Id = tacticProdList[0].id;
        tacticProd.MDLZ_PPG__c = tacticProdList[0].MDLZ_PPG__c;
        tacticProd.MDLZ_SubPPG__c = tacticProdList[0].MDLZ_SubPPG__c;
        tacticProd.MDLZ_Price__c = tacticProdList[0].MDLZ_Price__c + 1;
        tacticProd.MDLZ_Location__c = 'new ' + tacticProdList[0].MDLZ_Location__c;
        data.add(tacticProd);
        updateResult = MDLZ_AddPPG.updateTacticProd(tacticProdList[0], data, tacticId.Id);
        test.stopTest();
        List<ACCL__Tactic_Product__c> tacticProdUpdated = [Select MDLZ_Location__c From ACCL__Tactic_Product__c Limit 1];
        System.assertEquals('new ' + tacticProdList[0].MDLZ_Location__c, tacticProdUpdated[0].MDLZ_Location__c);
        System.assertEquals(MDLZ_ConstantHelper.ResultMap_KeySuccess, updateResult.get(MDLZ_ConstantHelper.ResultMap_KeySuccess));
    }
    
    static testMethod void insertTacticProdTest(){
        String insertResult;
        List<ACCL__Tactic_Product__c> tacticProdToInsert = new List<ACCL__Tactic_Product__c>();
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        String jsonOfListOfTPRoducts;
        test.startTest();
        ACCL__Tactic__c tactic = MDLZ_TestDataFactory.insertTactic();
        productList = MDLZ_TestDataFactory.createProductRecords(1);
        ACCL__Tactic_Product__c tatcProd = new ACCL__Tactic_Product__c();
        tatcProd.MDLZ_PPG__c = productList[0].MDLZ_PPG__c;
        tatcProd.MDLZ_SubPPG__c = productList[0].MDLZ_SubPPG__c;
        tatcProd.MDLZ_Price__c = 5;
        tatcProd.MDLZ_Location__c='xff'; 
        tatcProd.ACCL__Tactic__c=tactic.id; 
        tatcProd.ACCL__Included__c=true;
        tatcProd.ACCL__Product__c =productList[0].id;
        tacticProdToInsert.add(tatcProd);
        jsonOfListOfTPRoducts = JSON.serialize(tacticProdToInsert);
        insertResult = MDLZ_AddPPG.insertTProds(jsonOfListOfTPRoducts);
        test.stopTest();
        List<ACCL__Tactic_Product__c> tacticProdInserted = [Select Id From ACCL__Tactic_Product__c];
		System.assertEquals(1, tacticProdInserted.size());
        System.assertEquals('Success : Products updated successfully', insertResult);
    }
    
    static testMethod void insertTacticProdTestBlankSubPPG(){
        String insertResult;
        List<ACCL__Tactic_Product__c> tacticProdToInsert = new List<ACCL__Tactic_Product__c>();
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        String jsonOfListOfTPRoducts;
        test.startTest();
        ACCL__Tactic__c tactic = MDLZ_TestDataFactory.insertTactic();
        productList = MDLZ_TestDataFactory.createProductRecords(1);
        ACCL__Tactic_Product__c tatcProd = new ACCL__Tactic_Product__c();
        tatcProd.MDLZ_PPG__c = productList[0].MDLZ_PPG__c;
        tatcProd.MDLZ_Price__c = 5;
        tatcProd.MDLZ_Location__c='xff'; 
        tatcProd.ACCL__Tactic__c=tactic.id; 
        tatcProd.ACCL__Included__c=true;
        tatcProd.ACCL__Product__c =productList[0].id;
        tacticProdToInsert.add(tatcProd);
        jsonOfListOfTPRoducts = JSON.serialize(tacticProdToInsert);
        insertResult = MDLZ_AddPPG.insertTProds(jsonOfListOfTPRoducts);
        test.stopTest();
        List<ACCL__Tactic_Product__c> tacticProdInserted = [Select Id From ACCL__Tactic_Product__c];
		System.assertEquals(1, tacticProdInserted.size());
        System.assertEquals('Success : Products updated successfully', insertResult);
    }
    
    static testMethod void deleteTacticProdTest(){
        Map<String, String> deleteResult = new Map<String, String>();
        List<ACCL__Tactic_Product__c> tacticProdList = new List<ACCL__Tactic_Product__c>();
        List<ACCL__Tactic_Product__c> tacticProd = new List<ACCL__Tactic_Product__c>();
        ACCL__Tactic__c tacticId = new ACCL__Tactic__c();
        test.startTest();
        tacticProd = MDLZ_TestDataFactory.insertTacticProducts(1,true);
        tacticId = [Select id From ACCL__Tactic__c Limit 1];
        deleteResult = MDLZ_AddPPG.deleteTacticProd(tacticProd[0], tacticId.Id);
        test.stopTest();
        List<ACCL__Tactic_Product__c> tacticProdRemaining = [Select Id From ACCL__Tactic_Product__c];
		System.assertEquals(0, tacticProdRemaining.size());
        System.assertEquals(MDLZ_ConstantHelper.ResultMap_KeySuccess, deleteResult.get(MDLZ_ConstantHelper.ResultMap_KeySuccess));
    }
    
}