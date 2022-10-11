/***************************************************************
Name: MDLZ_AccountTriggerHandlerTest
======================================================
Purpose:
1. Test Class for MDLZ_AccountTriggerHandler and AccountTrigger
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Vaidehi                      09/03/2022     Initial Development    

***************************************************************/
@isTest
private class MDLZ_AccountTriggerHandlerTest {
    
    static testMethod void createAccount(){
        Test.startTest();
        ACCL__Account_Template__c template =MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccTemplate();
        template.name  = label.MDLZ_Product_Assortment_Template_Non_Listsing;
        update template;
        List<Account> accList = MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccount(1);
        System.assertEquals('Demo Account', accList[0].Name);
        update accList;
        delete accList;
        undelete accList;
        Test.stopTest();
    }
}