/***************************************************************
Name: MDLZ_UpdateOrgUnitUserValidityTestFctry
======================================================
Purpose:
Test Factory for MDLZ_ProdAssortment_ByCustBranchBatch
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                03/30/2022     Initial Development    

***************************************************************/
public class MDLZ_UpdateOrgUnitUserValidityTestFctry {

    public static user createUser(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];
        User u = new User(Alias = 'standt', Email='orgUnituser@testorg.com', 
                          LastName='Testing', isActive =true,
                          ProfileId = p.Id,
                          MDLZ_isChanged__c = 'Int Updated', 
                          UserName='orgUnituser123456@testorg.com',ACCL__Sales_Org__c='US01');
        return u;
    }
    
    public static ACCL__Org_Unit__c insertOrgUnit(){
        ACCL__Org_Unit__c orgun1 = new ACCL__Org_Unit__c();
        orgun1.Name ='G500002';
        orgun1.ACCL__Sales_Org__c ='US01';
        orgun1.ACCL__Org_Type__c ='Sales';
        orgun1.ACCL__Org_Level__c ='Team';
        orgun1.ACCL__Description_Language_1__c ='MDLZ updateOrg user-Team Org2';
        orgun1.ACCL__Main__c =true;
        insert orgun1;
        System.assertEquals(orgun1.ACCL__Sales_Org__c,'US01');
        return orgun1;
        
    }
    
    public static ACCL__Org_Unit_User__c insertOrgUnitUser(ACCL__Org_Unit__c orgun1,user u){
        ACCL__Org_Unit_User__c orgusr = new ACCL__Org_Unit_User__c();
        orgusr.ACCL__User__c =u.Id;
        orgusr.ACCL__Org_Unit__c = orgun1.id;
        orgusr.MDLZ_isOrgUnitChanged__c ='Batch Processed';
        orgusr.ACCL__Valid_From__c =System.today()-100;
        orgusr.ACCL__Valid_Thru__c =System.today()+1;
        insert orgusr;
        System.assertEquals(orgusr.MDLZ_isOrgUnitChanged__c,'Batch Processed');
        return orgusr;
        
    }
}