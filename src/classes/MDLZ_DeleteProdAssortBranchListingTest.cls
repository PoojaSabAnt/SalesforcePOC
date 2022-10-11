/***************************************************************
Name: MDLZ_DeleteProdAssortBranchListingTest
======================================================
Purpose:
1. Test Class for MDLZ_DeleteProdAssortBranchListingTest 
2. This test class uses the factory - MDLZ_ProdAssortmnt_ByCustBrnchTestFctry 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                09/03/2022     Initial Development    

***************************************************************/
@isTest
private class MDLZ_DeleteProdAssortBranchListingTest {
	
    static testMethod void deleteRecords(){
    	List<Account> acList = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccount(2);
        sObject prodAssortTemplate = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentTemplate();
        sObject prodAssortment = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.getProductAssortmentWithValidRange
            (System.today(), System.today().addYears(2), prodAssortTemplate);
       // ACCL__Product_Assortment_Account__c prodAssortmentAccount = 
            MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccount(prodAssortment, acList[1]);
        //ACCL__Product_Assortment_Account__c prodAssortmentAccountInValid =
            MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccountInValid(prodAssortment, acList[0]);
        //ACCL__Product_Assortment_Store__c prodAssortmentStore =
            MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentStore(prodAssortment, acList[0]);
    	        
    	Test.startTest();
        System.assertEquals(acList.size(),2);
    	//MDLZ_DeleteProdAssortBranchListingBatch b = new MDLZ_DeleteProdAssortBranchListingBatch(10);
       // Database.executeBatch(b, 10);
        SchedulableContext sc = null;        
        MDLZ_DeleteProdAssortBranchListingBatch bdsec=new MDLZ_DeleteProdAssortBranchListingBatch(10);
        bdsec.execute(sc);
        
    	Test.stopTest();
    }
        
}