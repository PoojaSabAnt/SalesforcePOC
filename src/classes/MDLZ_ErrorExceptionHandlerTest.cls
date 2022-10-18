/***************************************************************
Name: MDLZ_ErrorExceptionHandlerTest
======================================================
Purpose:
Test class for MDLZ_ErrorExceptionHandler to capture
errors in ExceptionLog__c
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Jinal desai                                Initial Development   

***************************************************************/
@isTest
public class MDLZ_ErrorExceptionHandlerTest {
    
    @isTest static void testInsertErrorExceptions(){
        List<Account> accountList = new List<Account>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        
        for(Integer i=0;i<5;i++){
            Account newAcct = new Account();
            newAcct.Name = 'Test Account '+i;
            newAcct.ACCL__Account_Number__c='Demo Unique123'+Integer.valueOf(Math.random() * 10);
            newAcct.Description ='Test Description '+i;
            accountList.add(newAcct);
        }
        
        Test.startTest();
        srList = Database.Insert(accountList,false);
        exc.insertExceptions('MDLZ_ErrorExceptionHandler()','Duplicate Value',11,'Duplicate value');
        MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_ErrorExceptionHandler()','Duplicate Value',11,'Duplicate value'); 
         
        Test.stopTest();
        
    }
    
    @isTest static void testSaveErrorExceptions(){
        
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<Account> accountList = MDLZ_TestDataFactory.insertAccount(5,true);
        List<Database.UpsertResult> upsertAccountList;
        system.assertEquals(5, accountList.size());
        
        accountList[1].ACCL__Account_Number__c = accountList[2].ACCL__Account_Number__c;
        
        Test.startTest();
        
        srList = Database.update(accountList,false);
        upsertAccountList = Database.upsert(accountList,false);
        exc.saveResultErrors(srList,accountList,'MDLZ_ErrorExceptionHandler().saveErrorResults','Account', 'Id');
        exc.upsertResultErrors(upsertAccountList,accountList,'MDLZ_ErrorExceptionHandler().upsertErrorResults','Account');
       
        Test.stopTest();            
    }
    
    @isTest static void deleteErrorExceptions(){
        
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        
        String profileName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        User runningUser = [Select Id from user where id = :UserInfo.getUserId()];
        User newUser = MDLZ_TestDataFactory.getUser(profileName);
        insert newUser;
        
        List<PermissionSet> permSetList = new List<PermissionSet>();
        List<PermissionSetAssignment> permSetAssignList = new List<PermissionSetAssignment>();
        
        // Creating the permission set
        System.runAs(runningUser){
           
    PermissionSet ps1 = new PermissionSet(Label='Account Permisson Set',Name='Account_Permisson_Set');
        PermissionSet ps2 = new PermissionSet(Label='Opportunity Permisson Set',Name='Opportunity_Permisson_Set');
        permSetList.add(ps1);
        permSetList.add(ps2);
    insert permSetList;

    //Assigning to the User
    PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId=newUser.Id,PermissionSetId=permSetList[0].id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId=newUser.Id,PermissionSetId=permSetList[1].id);
        permSetAssignList.add(psa1);
        permSetAssignList.add(psa2);
   
    insert permSetAssignList; 
        }
        
        List<PermissionSet> permSetToBeDeleted = [Select Id from PermissionSet limit 2];
        List<Database.DeleteResult> drList = new List<Database.DeleteResult>();
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();
        system.assertEquals(2, permSetToBeDeleted.size());
        
        Test.startTest();
        drList = Database.delete(permSetToBeDeleted,false);
        for(Database.DeleteResult dr : drList){
            ExceptionLog__c errorlog = new ExceptionLog__c();
            errorlog.MethodName__c = 'MDLZ_ErrorExceptionHandler.deleteResultErrors';
            errorlog.ExceptionDetails__c = 'Cannnot delete Permission Set';
            errorlog.Error_Line_Number__c = 10;
            errorlog.ExceptionCode__c = 'Invalid';
            exceptionLogList.add(errorlog);
        }
        exc.deleteResultErrors(drList,permSetToBeDeleted,'MDLZ_ErrorExceptionHandler.deleteResultErrors','PermissionSet', 'userName');
        exc.insertExceptions(exceptionLogList);
        Test.stopTest();
        
    }

}