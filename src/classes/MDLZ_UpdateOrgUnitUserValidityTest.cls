/***************************************************************
Name: MDLZ_UpdateOrgUnitUserValidityTest
======================================================
Purpose:
Test Factory for MDLZ_ProdAssortment_ByCustBranchBatch
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                03/30/2022     Initial Development    

***************************************************************/

@isTest
private class MDLZ_UpdateOrgUnitUserValidityTest {
    
    private MDLZ_UpdateOrgUnitUserValidityTest(){
        
    }
    static testMethod void updateOrgUnitUserValidity(){
        
        
        User u = MDLZ_UpdateOrgUnitUserValidityTestFctry.createUser();
        ACCL__Org_Unit__c orgun1 = MDLZ_UpdateOrgUnitUserValidityTestFctry.insertOrgUnit();
        ACCL__Org_Unit_User__c orgusr = MDLZ_UpdateOrgUnitUserValidityTestFctry.insertOrgUnitUser(orgun1,u);
        
        Test.startTest();
        Database.BatchableContext BC = null;
        SchedulableContext sc2 = null;
        //MDLZ_UpdateOrgUnitUserValidity pr = new MDLZ_UpdateOrgUnitUserValidity();
        //pr.updateUserValidity(new List<User> {u});
        
        MDLZ_UpdateOrgUnitUserValidityBatch bt = new MDLZ_UpdateOrgUnitUserValidityBatch(10);
        bt.execute(sc2);
        bt.execute(BC,new List<User> {u});
       
        Test.stopTest();
        
        
    }
    
}