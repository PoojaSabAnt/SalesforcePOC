/***************************************************************
Name: MDLZ_UserPermissionSetAssignTestClass
======================================================
Purpose:
a.Create a batch of 100 users per batch for all users last modified today
to assign permission sets to each user based on role.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Bharath V              05/08/2021     Initial Development    Test class for MDLZ_UserPermissionSetAssignment and Batch
1.1      Vaidehi Heda           17/03/2022     Made the changes to cover MDLZ_UserTriggerHandler 
***************************************************************/
@isTest
private class MDLZ_UserPermissionSetAssignTestClass {
    
    static testMethod void userPermissionSet1(){
        Map<Id, User> userMap = new Map<Id, User>();
        List<UserRole> urList = new List<userRole>();
        Set<String>profileNameSet = new Set<String>();
        //creating different roles
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'DM');
        UserRole ur1 =new UserRole(DeveloperName = 'MyCustomRole1', Name = 'RDR');
        urList.add(ur);
        urList.add(ur1);
        profileNameSet.add('MDLZ_DSD_Manager');
        profileNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance('Integration_User').Profile_API_Name__c);
        Test.startTest();
        List<Profile> proList = [select Id,Name from Profile  where Name IN:profileNameSet];
        //insert userroles
        insert urList;
        System.assertEquals(urList[0].Name , 'DM');
        System.assertEquals(proList[0].Name, 'MDLZ_DSD_Manager');
        //creating the new user
        User opUser = new user(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', firstName='Test', lastname='Testing', languagelocalekey='en_US',IsActive=true,
                               localesidkey='en_US', profileid = proList[0].Id, country='United States',
                               timezonesidkey='America/Los_Angeles', username='test0234@noemail.com', ACCL__Sales_Org__c='US01',UserRoleId = urList[0].Id); 
        insert opUser;
        
        //MDLZ_UserPermissionSetAssignmentBatch batch1= new MDLZ_UserPermissionSetAssignmentBatch(10);
        // DataBase.executeBatch(batch1);
        SchedulableContext sc = null;
        MDLZ_UserPermissionSetAssignmentBatch bdsec=new MDLZ_UserPermissionSetAssignmentBatch(10);
        bdsec.execute(sc);
        
        opUser.UserRoleId =urList[1].id;
        //opUser.MDLZ_isRoleChanged__c = null;
        opUser.profileId =proList[1].id;
        update opUser;        
        system.assertEquals(proList[1].id, opUser.profileId);
        //added this to cover else condition
        opUser.profileId =proList[0].id;
        opuser.isactive = false;
        update opUser;
        
        //calling these 3 methods as Delete and undelete is not possible On User
        MDLZ_UserTriggerHandler.AfterDelete(userMap);
        MDLZ_UserTriggerHandler.AfterUndelete(userMap);
        MDLZ_UserTriggerHandler.BeforeDelete(userMap);
        
        //calling this method to cover future method from Exception handler class
        MDLZ_ErrorExceptionHandler.insertFutureExceptions('test','test',11,'test');
        
        Test.stopTest();
    } 
    
    @istest static void beforeUpdateTest(){
        
        List<UserRole> userRoleList = new List<userRole>();
        Set<String>profileNameSet = new Set<String>();
        //creating different roles
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'DM');
        UserRole ur1 =new UserRole(DeveloperName = 'MyCustomRole1', Name = 'RDR');
        userRoleList.add(ur);
        userRoleList.add(ur1);
        profileNameSet.add('MDLZ_DSD_Manager');
        profileNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance('Integration_User').Profile_API_Name__c);
        
        List<Profile> profileList = [select Id,Name from Profile  where Name IN:profileNameSet];
        //insert userroles
        insert userRoleList;
        System.assertEquals(userRoleList[0].Name , 'DM');
        System.assertEquals(profileList[0].Name, 'MDLZ_DSD_Manager');
        List<User> userList = new List<User>();
        
        for(Integer i=0; i<10; i++){
            User u = new User();
            u.alias = 'test'+i; 
      u.email='test'+i+'@noemail.com';
      u.emailencodingkey='UTF-8'; 
      u.firstName='Test'+i; 
      u.lastname='Testing'+i; 
      u.languagelocalekey='en_US';
      u.IsActive=true;
      u.localesidkey='en_US'; 
      u.profileid = profileList[0].Id; 
      u.country='United States';
      u.timezonesidkey='America/Los_Angeles'; 
            u.username='test'+i+i+i+'@noemail.com'+math.random(); 
      u.ACCL__Sales_Org__c='US01';
      u.UserRoleId = userRoleList[0].Id;
            userList.add(u);
           
        }
        
        Test.startTest();
        insert userList;
        Test.stopTest();
        
        userList[1].profileId = profileList[1].Id;
        update userList[1];
        
        userList[2].UserRoleId = userRoleList[1].Id;
        update userList[2];
        
    }
    
    @istest static void afterUpdateuserTest(){
        List<UserRole> urList = new List<userRole>();
        Set<String>profileNameSet = new Set<String>();
        //creating different roles
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'DM');
        UserRole ur1 =new UserRole(DeveloperName = 'MyCustomRole1', Name = 'RDR');
        urList.add(ur);
        urList.add(ur1);
        profileNameSet.add('MDLZ_DSD_Manager');
        profileNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance('Integration_User').Profile_API_Name__c);
        
        List<Profile> proList = [select Id,Name from Profile  where Name IN:profileNameSet];
        //insert userroles
        insert urList;
        System.assertEquals(urList[0].Name , 'DM');
        System.assertEquals(proList[0].Name, 'MDLZ_DSD_Manager');
        //creating the new user
        User opUser = new user(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', firstName='Test', lastname='Testing', languagelocalekey='en_US',IsActive=true,
                               localesidkey='en_US', profileid = proList[0].Id, country='United States',
                               timezonesidkey='America/Los_Angeles', username='test0234@noemail.com', ACCL__Sales_Org__c='US01',UserRoleId = urList[0].Id); 
        insert opUser;
        
        opUser.IsActive = false;
        update opUser;
        
        test.startTest();
        opUser.IsActive = true;
        update opUser;
        Test.stopTest();
        
    }
    
    @isTest static void testNewUser(){
        List<UserRole> urList = new List<userRole>();
        Set<String>profileNameSet = new Set<String>();
        Map<Id, User> userMap = new Map<Id, User>();
        //creating different roles
        UserRole ur = new UserRole(DeveloperName = 'MyCustomRole', Name = 'DM');
        UserRole ur1 =new UserRole(DeveloperName = 'MyCustomRole1', Name = 'RDR');
        urList.add(ur);
        urList.add(ur1);
        profileNameSet.add('MDLZ_DSD_Manager');
        profileNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance('Integration_User').Profile_API_Name__c);
        
        List<Profile> proList = [select Id,Name from Profile  where Name IN:profileNameSet];
        //insert userroles
        insert urList;
        System.assertEquals(urList[0].Name , 'DM');
        System.assertEquals(proList[0].Name, 'MDLZ_DSD_Manager');
        //creating the new user
        User opUser = new user(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', firstName='Test', lastname='Testing', languagelocalekey='en_US',IsActive=true,
                               localesidkey='en_US', profileid = proList[1].Id, country='United States',
                               timezonesidkey='America/Los_Angeles', username='test0234@noemail.com', ACCL__Sales_Org__c='US01',UserRoleId = urList[0].Id); 
        insert opUser;
        
        //calling these 3 methods as Delete and undelete is not possible On User
        MDLZ_UserTriggerHandler.AfterDelete(userMap);
        MDLZ_UserTriggerHandler.AfterUndelete(userMap);
        MDLZ_UserTriggerHandler.BeforeDelete(userMap);
        
    }
	
	@istest static void userPermissionSetAssignment(){
        
        Set<String>profileNameSet = new Set<String>();
        //creating different roles
        UserRole roleDM = [Select Id,Name from UserRole where Name = 'DM'];
        
        Profile profileDM = [Select Id , name from Profile where name = 'MDLZ_DSD_Manager'];

    
        Test.startTest();
       
        //creating the new user
        User opUser = new user(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', firstName='Test', lastname='Testing', languagelocalekey='en_US',IsActive=true,
                               localesidkey='en_US', profileid = profileDM.Id, country='United States',
                               timezonesidkey='America/Los_Angeles', username='test98021Psa@noemail.com', ACCL__Sales_Org__c='US01',UserRoleId = roleDM.Id); 
        insert opUser;
        
        List<User> userList = [select Id ,firstName , UserRoleId,UserRole.Name,profileId,Profile.name from User where firstName='Test' limit 1];
        List<ExceptionLog__c> logs = new List<ExceptionLog__c>();
        MDLZ_UserPermissionSetAssignment psa = new MDLZ_UserPermissionSetAssignment();
        psa.getUsersPermissionsSets(userList,logs);
        
        test.stopTest();
        
    }
   
    
}