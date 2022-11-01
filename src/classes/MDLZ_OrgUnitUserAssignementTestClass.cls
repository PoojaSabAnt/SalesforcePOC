@isTest
public class MDLZ_OrgUnitUserAssignementTestClass {
    
    static testMethod void mainClass(){
        List<ACCL__Org_Unit__c>orgUnitList = new List<ACCL__Org_Unit__c>();
        List<ACCL__Org_Unit_User__c>orgUnitUserList = new List<ACCL__Org_Unit_User__c>();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          LastName='Testing', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ACCL__Sales_Org__c='US01');
        
        //insert org unit 
        ACCL__Org_Unit__c orgun = new ACCL__Org_Unit__c();
        orgun.Name ='G500001';
        orgun.ACCL__Sales_Org__c ='US01';
        orgun.ACCL__Org_Type__c ='Sales';
        orgun.ACCL__Org_Level__c ='Team';
        orgun.ACCL__Description_Language_1__c ='MDLZ TerritoryTest Class';
        orgun.ACCL__Main__c =true;
        orgUnitList.add(orgun);
        
        ACCL__Org_Unit__c orgun2 = new ACCL__Org_Unit__c();
        orgun2.Name ='G500002';
        orgun2.ACCL__Sales_Org__c ='US01';
        orgun2.ACCL__Org_Type__c ='Sales';
        orgun2.ACCL__Org_Level__c ='Territory';
        orgun2.ACCL__Description_Language_1__c ='MDLZ TerritoryTest Class-Org2';
        orgUnitList.add(orgun2);     
        
        ACCL__Org_Unit__c orgunterr = new ACCL__Org_Unit__c();
        orgunterr.Name ='G500003';
        orgunterr.ACCL__Sales_Org__c ='US01';
        orgunterr.ACCL__Org_Type__c ='Sales';
        orgunterr.ACCL__Org_Level__c ='Territory';
        orgunterr.ACCL__Description_Language_1__c ='MDLZ TerritoryTest Class result';
        orgunterr.ACCL__Main__c =true; 
        orgUnitList.add(orgunterr);
        
        insert orgUnitList;
        
        //insert org unit hierarchy
        ACCL__Org_Unit_Hierarchy__c orghier = new ACCL__Org_Unit_Hierarchy__c();
        orghier.ACCL__Parent_Org_Unit__c = orgUnitList[0].Id;
        orghier.ACCL__Child_Org_Unit__c = orgUnitList[1].Id;
        
        insert orghier;
        
        //Insert Org unit user                 
        ACCL__Org_Unit_User__c orguser = new ACCL__Org_Unit_User__c();
        orguser.ACCL__Org_Unit__c =orgUnitList[0].Id;
        orguser.ACCL__User__c =u.Id;
        orguser.ACCL__Management_Type__c ='Sales';
        orguser.ACCL__Valid_From__c = System.today();
        orguser.ACCL__Valid_Thru__c = System.today()+10;
        orgUnitUserList.add(orguser);
        
        ACCL__Org_Unit_User__c orguser3 = new ACCL__Org_Unit_User__c();
        orguser3.ACCL__Org_Unit__c =orgUnitList[2].Id;
        orguser3.ACCL__User__c =u.id;
        orguser3.ACCL__Management_Type__c ='Manager';
        orguser3.ACCL__Valid_From__c = System.today();
        orguser3.ACCL__Valid_Thru__c = System.today()+365;
        orgUnitUserList.add(orguser3);
        
        insert orgUnitUserList;
        
        ACCL__Org_Unit__c tes = new ACCL__Org_Unit__c();
        tes.Id = orgun.Id;
        
        list<ACCL__Org_Unit__c>Emplist=new list<ACCL__Org_Unit__c>();
        update Emplist;
        
        MDLZ_TeamTerritoryUserAssignBatch batch= new MDLZ_TeamTerritoryUserAssignBatch(10);
        
        ID batchprocessid2 = Database.executeBatch(batch,10);  
        SchedulableContext sc = null;        
        
        MDLZ_TeamTerritoryUserAssignBatch bdsec2=new MDLZ_TeamTerritoryUserAssignBatch(10);
        bdsec2.execute(sc);
        
        Test.stopTest();
    }
    
}