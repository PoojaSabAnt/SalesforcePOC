@isTest
private class MDLZ_EffectiveAccountManagerSyncTest {
    
    static testmethod void  testATM(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1]; 
        User u = new User(Alias = 'standt', Email='standarduserstest@testorg.com', 
                          LastName='Testing', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrecordtest123@testorg.com',ACCL__Sales_Org__c='US01');
        
        //create Account manager records
        Account acc=MDLZ_TestDataFactory.getAccount();
        ACCL__Org_Unit__c orgUnit= MDLZ_TestDataFactory.insertOrgUnit();
        List<ACCL__Account_Manager__c> acctMgrValid = MDLZ_TestDataFactory.createAccountManagerValidRecords(2,acc,orgUnit,u);
        List<ACCL__Account_Manager__c> acctMgrInValid = MDLZ_TestDataFactory.createAccountManagerInValidRecords(2,acc,orgUnit,u);
        List<ACCL__Account_Manager__c> acctMgrList = [select id,ACCL__Account__c,ACCL__User__c from ACCL__Account_Manager__c];
                
        test.startTest();
        MDLZ_EffectiveAccountManagerSyncBatch bt = new MDLZ_EffectiveAccountManagerSyncBatch(10);
        SchedulableContext sc= null;
        bt.execute(sc);
        test.stopTest();
        
        
    }
    
}