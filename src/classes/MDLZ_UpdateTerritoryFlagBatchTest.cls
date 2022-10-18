/***************************************************************
Name: MDLZ_UpdateTerritoryFlagBatchTest
======================================================
Purpose:
Test class for MDLZ_UpdateTerritoryFlagBatch class 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                 07/05/2022     Initial Development 

***************************************************************/
@isTest
private class MDLZ_UpdateTerritoryFlagBatchTest {
    static testMethod void createOrgUnit(){
        ACCL__Org_Unit__c OrgUnit = MDLZ_TestDataFactory.insertOrgUnit();
        User user = MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM);
        test.startTest();
        List<ACCL__Org_Unit_User__c> orgUnitUsers = MDLZ_TestDataFactory.createOrgUnitUserRecords(1, MDLZ_ConstantHelper.IntUpdated, OrgUnit, user);
        system.runAs(user){
            MDLZ_UpdateTerritoryFlagBatch batch = new MDLZ_UpdateTerritoryFlagBatch(10);             
            SchedulableContext ctx = null;
            batch.execute(ctx);
            test.stopTest();           
        }
        
        List<ACCL__Org_Unit_User__c> orgUnitUsersUpdated = [Select MDLZ_isOrgUnitChanged__c from ACCL__Org_Unit_User__c where ACCL__Org_Unit__r.ACCL__Org_Level__c =: MDLZ_ConstantHelper.Territory Limit 1];
        System.assertEquals(MDLZ_ConstantHelper.BatchProcessed, orgUnitUsersUpdated[0].MDLZ_isOrgUnitChanged__c);
    }
}