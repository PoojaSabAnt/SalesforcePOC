/***************************************************************
Name: MDLZ_TeamTerritoryTestClass
======================================================
Purpose:
Test Class Coverage for MDLZ_TeamTerritoryUserAssignment 
Test Class Coverage for MDLZ_RDRTeamUserAssignBatch
Test Class Coverage for MDLZ_RDRTeamUserAssignBatch
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0               Bharath_V                       Initial Development    

***************************************************************/
@isTest
private class MDLZ_TeamTerritoryTestClass {
    
    
    private  MDLZ_TeamTerritoryTestClass(){
        
    }
    
    static testMethod void mainClass(){
        List<ACCL__Org_Unit__c>orgList = new List<ACCL__Org_Unit__c>();
        List<ACCL__Org_Unit_User__c>orgUnitUserList = new List<ACCL__Org_Unit_User__c>();
        List<ACCL__Org_Unit_Hierarchy__c>orgUnitUserHieList = new List<ACCL__Org_Unit_Hierarchy__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1]; 
        User u = new User(Alias = 'standt', Email='standarduserstest@testorg.com', 
                          LastName='Testing', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          IsActive = true,
                          emailencodingkey='UTF-8', 
                          languagelocalekey='en_US',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrecordtest123@testorg.com',ACCL__Sales_Org__c='US01');
        insert u;
        
        User u1 = new User(Alias = 'standt', Email='standarduserstest1@testorg.com', 
                          LastName='Testing', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          IsActive = false,
                          emailencodingkey='UTF-8', 
                          languagelocalekey='en_US',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrecordtest1234@testorg.com',ACCL__Sales_Org__c='US01');
        insert u1;
        
        //Parent Org Unit
        ACCL__Org_Unit__c orgun = new ACCL__Org_Unit__c();
        orgun.Name ='G500001';
        orgun.ACCL__Sales_Org__c ='US01';
        orgun.ACCL__Org_Type__c ='Sales';
        orgun.ACCL__Org_Level__c ='Team';
        orgun.ACCL__Description_Language_1__c ='MDLZ RedesignTeamTerritoryTestClass-Team Org1';
        orgun.ACCL__Main__c =true;
        orgList.add(orgun);
        
        ACCL__Org_Unit__c orgun10 = new ACCL__Org_Unit__c();
        orgun10.Name ='G5000010';
        orgun10.ACCL__Sales_Org__c ='US01';
        orgun10.ACCL__Org_Type__c ='Sales';
        orgun10.ACCL__Org_Level__c ='Market/District';
        orgun10.ACCL__Description_Language_1__c ='MDLZ RedesignTeamTerritoryTestClass-Team Org1';
        orgun10.ACCL__Main__c =true;
        orgList.add(orgun10);
        
        ACCL__Org_Unit__c orgun1 = new ACCL__Org_Unit__c();
        orgun1.Name ='G500002';
        orgun1.ACCL__Sales_Org__c ='US01';
        orgun1.ACCL__Org_Type__c ='Sales';
        orgun1.ACCL__Org_Level__c ='Team';
        orgun1.ACCL__Description_Language_1__c ='MDLZ RedesignTeamTerritoryTestClass-Team Org2';
        orgun1.ACCL__Main__c =true;
        orgList.add(orgun1);
        
        //Main Org Unit Child Record1
        ACCL__Org_Unit__c orgun2 = new ACCL__Org_Unit__c();
        orgun2.Name ='G600002';
        orgun2.ACCL__Sales_Org__c ='US01';
        orgun2.ACCL__Org_Type__c ='Sales';
        orgun2.ACCL__Org_Level__c ='Territory';
        orgun2.ACCL__Description_Language_1__c ='MDLZ RedesignTeamTerritoryTestClass-Terr Org1';
        orgList.add(orgun2);
        
        //Main Org Unit Child Record2
        ACCL__Org_Unit__c orgunterr = new ACCL__Org_Unit__c();
        orgunterr.Name ='G600003';
        orgunterr.ACCL__Sales_Org__c ='US01';
        orgunterr.ACCL__Org_Type__c ='Sales';
        orgunterr.ACCL__Org_Level__c ='Territory';
        orgunterr.ACCL__Description_Language_1__c ='MDLZ RedesignTeamTerritoryTestClass-Terr Org2';
        orgunterr.ACCL__Main__c =true;
        orgList.add(orgunterr); 
        
        if(orgList.size()>0){
            insert orgList;}
        
        //Create parent child record1   ---- Team:G500001, Territory:G600002
        ACCL__Org_Unit_Hierarchy__c orghier1 = new ACCL__Org_Unit_Hierarchy__c();
        orghier1.ACCL__Parent_Org_Unit__c = orgList[0].id;
        orghier1.ACCL__Child_Org_Unit__c = orgList[3].id;
        orghier1.ACCL__Valid_From__c = System.today();
        orghier1.ACCL__Valid_Thru__c =System.today()+300;
        orgUnitUserHieList.add(orghier1);
        System.assertEquals( orghier1.ACCL__Valid_From__c, System.today());
        //Orgunit Hierarchy -1 Team:G500001, Territory:G600003
        ACCL__Org_Unit_Hierarchy__c orghier2 = new ACCL__Org_Unit_Hierarchy__c();
        orghier2.ACCL__Parent_Org_Unit__c = orgList[2].id;
        orghier2.ACCL__Child_Org_Unit__c = orgList[4].id;
        orghier2.ACCL__Valid_From__c = System.today();
        orghier2.ACCL__Valid_Thru__c =System.today()+300;
        orgUnitUserHieList.add(orghier2);
        
        ACCL__Org_Unit_Hierarchy__c orghier10 = new ACCL__Org_Unit_Hierarchy__c();
        orghier10.ACCL__Parent_Org_Unit__c = orgList[1].id;
        orghier10.ACCL__Child_Org_Unit__c = orgList[2].id;
        orghier10.ACCL__Valid_From__c = System.today();
        orghier10.ACCL__Valid_Thru__c =System.today()+300;
        orgUnitUserHieList.add(orghier10);
        
        ACCL__Org_Unit_User__c orguser3 = new ACCL__Org_Unit_User__c();
        orguser3.ACCL__Org_Unit__c =orgList[2].id;
        orguser3.ACCL__User__c =u1.id;
        orguser3.ACCL__Management_Type__c ='Sales';
        orguser3.ACCL__Valid_From__c = System.today()-365;
        orguser3.ACCL__Valid_Thru__c = System.today()-1;
        orguser3.MDLZ_ExternalId__c = 'US01_3';
        orguser3.MDLZ_isOrgUnitChanged__c = 'Int Updated';
        
        orgUnitUserList.add(orguser3);
        
         ACCL__Org_Unit_User__c orguser41 = new ACCL__Org_Unit_User__c();
        orguser41.ACCL__Org_Unit__c =orgList[0].id;
        orguser41.ACCL__User__c =u.id;
        orguser41.ACCL__Management_Type__c ='Sales';
        orguser41.ACCL__Valid_From__c = System.today()-365;
        orguser41.ACCL__Valid_Thru__c = System.today()-1;
        orguser41.MDLZ_ExternalId__c = 'US01_41';
        orguser41.MDLZ_isOrgUnitChanged__c = 'Int Updated';
        orgUnitUserList.add(orguser41);
        
        ACCL__Org_Unit_User__c orguser4 = new ACCL__Org_Unit_User__c();
        orguser4.ACCL__Org_Unit__c =orgList[3].id;
        orguser4.ACCL__User__c =u.id;
        orguser4.ACCL__Management_Type__c ='Sales';
        orguser4.ACCL__Valid_From__c = System.today().addYears(-3);
        orguser4.ACCL__Valid_Thru__c = System.today()-365;
        orguser4.MDLZ_ExternalId__c = 'US01_4';
        orguser4.MDLZ_isOrgUnitChanged__c = 'Batch Processed';
        orgUnitUserList.add(orguser4);
        
        ACCL__Org_Unit_User__c orguser5 = new ACCL__Org_Unit_User__c();
        orguser5.ACCL__Org_Unit__c =orgList[1].id;
        orguser5.ACCL__User__c =u.id;
        orguser5.ACCL__Management_Type__c ='Sales';
        orguser5.ACCL__Valid_From__c = System.today().addYears(-2);
        orguser5.ACCL__Valid_Thru__c = System.today()-365;
        orguser5.MDLZ_isOrgUnitChanged__c = 'Int Updated';
        orguser5.MDLZ_ExternalId__c = 'US01_5';
        orgUnitUserList.add(orguser5);
        System.assertEquals( orguser5.ACCL__Management_Type__c, 'Sales');
        
        ACCL__Org_Unit_User__c orguser51 = new ACCL__Org_Unit_User__c();
        orguser51.ACCL__Org_Unit__c =orgList[2].id;
        orguser51.ACCL__User__c =u.id;
        orguser51.ACCL__Management_Type__c ='Sales';
        orguser51.ACCL__Valid_From__c = System.today().addYears(-2);
        orguser51.ACCL__Valid_Thru__c = System.today()-365;
        orguser51.MDLZ_isOrgUnitChanged__c = 'Int Updated';
        orguser51.MDLZ_ExternalId__c = 'US01_51';
        orgUnitUserList.add(orguser51);
        System.assertEquals( orguser51.ACCL__Management_Type__c, 'Sales');
        
        ACCL__Org_Unit_User__c orguser10 = new ACCL__Org_Unit_User__c();
        orguser10.ACCL__Org_Unit__c =orgList[4].id;
        orguser10.ACCL__User__c =u1.id;
        orguser10.ACCL__Management_Type__c ='Sales';
        orguser10.ACCL__Valid_From__c = System.today()-365;
        orguser10.ACCL__Valid_Thru__c = System.today();
        orguser10.MDLZ_isOrgUnitChanged__c = 'Batch Processed';
        orguser10.MDLZ_ExternalId__c = 'US01_10';
        orgUnitUserList.add(orguser10);
         System.assertEquals( orguser10.ACCL__Valid_From__c, System.today()-365);
        
        
        ACCL__Org_Unit_User__c orguser12 = new ACCL__Org_Unit_User__c();
        orguser12.ACCL__Org_Unit__c =orgList[2].id;
        orguser12.ACCL__User__c =u.id;
        orguser12.MDLZ_isOrgUnitChanged__c ='Batch Processed';
        orguser12.ACCL__Management_Type__c ='Sales';
        orguser12.ACCL__Valid_From__c =System.today().addYears(-3);
        orguser12.ACCL__Valid_Thru__c = System.today().addYears(-2);
        orguser12.MDLZ_ExternalId__c = 'US01_12';
        orgUnitUserList.add(orguser12);
        
        if(orgUnitUserList.size()>0){
            database.insert(orgUnitUserList);
        }
        if(orgUnitUserHieList.size()>0){
            database.insert(orgUnitUserHieList);
        }
        
        System.assertEquals(orgUnitUserList[0].ACCL__Management_Type__c,'Sales');
        
        Test.startTest();
       // MDLZ_TeamTerritoryUserAssignment reTeam= new MDLZ_TeamTerritoryUserAssignment();
        //reTeam.assignUsers(new List<ACCL__Org_Unit__c>{orgun});
        //reTeam.assignUsers(new List<ACCL__Org_Unit__c>{orgun1});
        SchedulableContext sc2 = null;
        
        MDLZ_TeamTerritoryUserAssignBatch bdsec1=new MDLZ_TeamTerritoryUserAssignBatch(10);
        bdsec1.execute(sc2); 
        
        MDLZ_RDRTeamUserAssignBatch batch2= new MDLZ_RDRTeamUserAssignBatch(10);
        DataBase.executeBatch(batch2);  
        
        
        MDLZ_RDRTeamUserAssignBatch bdsec2=new MDLZ_RDRTeamUserAssignBatch(10);
        bdsec2.execute(sc2);  
        
        
        Test.stopTest();
    }
}