/***************************************************************
Name: MDLZ_FundCalculationBatchTest
======================================================
Purpose:
Test class for MDLZ_FundCalculationBatch class 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                 07/19/2022     Initial Development 

***************************************************************/
@isTest
public class MDLZ_FundCalculationBatchTest {
    
    static testMethod void fundCalculation(){
        ACCL__Batch_Process_Configuration__c csSettings = new ACCL__Batch_Process_Configuration__c(ACCL__Job_Name__c = 'Test', ACCL__Batch_Size__c = 100, ACCL__Sales_Org__c = 'US01');
        List<ACCL__Fund__c> fundList = new List<ACCL__Fund__c>();
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        List<ACCL__Fund_Product__c> fundProductList = new List<ACCL__Fund_Product__c>();
        User user = MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM);
        
        test.startTest();
        fundList = MDLZ_TestDataFactory.insertFundRecords(1,true);
        ACCL__Product__c product = MDLZ_TestDataFactory.insertProduct();
        productList = MDLZ_TestDataFactory.insertDiffLevelProducts(5,false);
        //productList[0].ACCL__Criterion_1_Product__c = product.Id;
        Insert productList;
        for(Integer i = 0; i < productList.size(); i++){
            ACCL__Fund_Product__c fundProduct = new ACCL__Fund_Product__c();
            fundProduct.ACCL__Product__c = productList[i].Id;
            fundProduct.ACCL__Fund__c = fundList[0].Id;
            fundProductList.add(fundProduct);
        }
        Insert fundProductList;
        fundList = MDLZ_TestDataFactory.updateFundRecords(fundList,true);
        system.runAs(user){
            FundCalculationBatch batch = new FundCalculationBatch(csSettings);             
            DataBase.executeBatch(batch);
        }
        test.stopTest();
    }
    
    static testMethod void fundCalculation2(){
        ACCL__Batch_Process_Configuration__c csSettings = new ACCL__Batch_Process_Configuration__c(ACCL__Job_Name__c = 'Test', ACCL__Batch_Size__c = 100, ACCL__Sales_Org__c = 'US01');
        List<ACCL__Fund__c> fundList = new List<ACCL__Fund__c>();
        User user = MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM);
        
        test.startTest();
        fundList = MDLZ_TestDataFactory.insertFundRecords(1,true);
        fundList = MDLZ_TestDataFactory.updateFundRecords(fundList,true);
        system.runAs(user){
            FundCalculationBatch batch = new FundCalculationBatch(csSettings);             
            DataBase.executeBatch(batch);
        }
        test.stopTest();
    }
    
}