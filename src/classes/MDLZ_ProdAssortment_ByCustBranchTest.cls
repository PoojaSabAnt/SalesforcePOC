/***************************************************************
Name: MDLZ_ProdAssortment_ByCustBranchTest
======================================================
Purpose:
1. Test Class for MDLZ_ProdAssortment_ByCustBranch
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                11/02/2022     Initial Development    

***************************************************************/
@isTest
private class MDLZ_ProdAssortment_ByCustBranchTest {
    
    private MDLZ_ProdAssortment_ByCustBranchTest(){
        
    }
    static testMethod void custBranch(){
        
        MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.createCustomSettings();
        
        List<Account> acList = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccount(2);
        sObject prodAssortTemplate = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentTemplate();
        sObject prodAssortment = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.getProductAssortmentWithValidRange(
            System.today(), System.today().addYears(2), prodAssortTemplate);
        ACCL__Product_Assortment_Account__c prodAssortmentAccount =
            MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccount(prodAssortment, acList[1]);
        ACCL__Product_Assortment_Account__c prodAssortmentAccountInValid = 
            MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccountInValid(prodAssortment, acList[0]);
         System.assertEquals(acList[1].ACCL__Sales_Org__c, null);
      	MDLZ_ProdAssortment_ByCustBranch pr = new MDLZ_ProdAssortment_ByCustBranch();
        pr.updateProductAssortment( acList );
        Test.startTest();
        acList[0].ACCL__Account_Template__c =null;
        MDLZ_ProdAssortment_ByCustBranchBatch b = new MDLZ_ProdAssortment_ByCustBranchBatch(10);
        Database.executebatch(b);
        SchedulableContext sc = null;        
        MDLZ_ProdAssortment_ByCustBranchBatch bdsec=new MDLZ_ProdAssortment_ByCustBranchBatch(10);
        bdsec.execute(sc);
       
        Test.stopTest();
        
    }
}