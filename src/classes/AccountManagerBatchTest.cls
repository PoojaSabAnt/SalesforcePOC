@isTest
public class AccountManagerBatchTest {

    /*Method for testing Bulk scenario
      Positive Inventory Transaction Insert
    */
    private static testMethod void insertAccountManagerPositiveData() {
        //Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunit = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');
        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(10);
        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(100,
                                          (Id)AccountManagerBatchTestFactory.getDefaultAccount().get('Id'),
                                          (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
        System.assertNotEquals(null,batchJobId);
        System.assertEquals(10, [SELECT count() FROM ACCL__Account_Manager__c]);

     }
    private static testMethod void insertMisconfigurationData() {
		//Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test'); //insert account
        sObject orgunit = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit'); //insert Org_Unit
        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(10); //insert users
        sObject accountManagerRecord = AccountManagerBatchTestFactory.insertAccountManager( //insert Account Manager
             (Id)account.get('Id'),(Id)orgunit.get('Id'),(Id)userList[0].get('Id'),
             system.today(),system.today()) ; 
         List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,   //Relation between users list and org_unit
                                        (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(100, //relation between account and org_unit
                                          (Id)AccountManagerBatchTestFactory.getDefaultAccount().get('Id'),
                                          (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
        System.assertNotEquals(null,batchJobId);
        System.assertEquals(10, [SELECT count() FROM ACCL__Account_Manager__c]);

     }
    private static testMethod void insertMainRecordMisconfigurationData() {
		//Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunit = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');
        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(10);
        sObject accountManagerRecord = AccountManagerBatchTestFactory.insertAccountManager(
             (Id)account.get('Id'),(Id)orgunit.get('Id'),(Id)userList[0].get('Id'),system.today(),system.today()) ; 
        sObject accountManagerRecord2 = AccountManagerBatchTestFactory.insertAccountManager(
         (Id)account.get('Id'),(Id)orgunit.get('Id'),(Id)userList[1].get('Id'),system.today(),system.today()) ;
        accountManagerRecord2.put('ACCL__Main__c', true);
        update accountManagerRecord2;
        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        sObject orgUnitUserRec =orgUnitUserList[0];
        orgUnitUserRec.put('ACCL__Main__c', true);
        sObject orgUnitUserMisconfigRecord =orgUnitUserList[1];
        orgUnitUserMisconfigRecord.put('ACCL__Main__c', true);
        update orgUnitUserRec;
        update orgUnitUserMisconfigRecord;
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(100,
                                            (Id)account.get('Id'),
                                            (Id)orgunit.get('Id'));
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
        List<ACCL__Account_Manager__c> accManList = [SELECT ACCL__Valid_From__c FROM ACCL__Account_Manager__c];
        System.assertEquals(true, accManList[0].ACCL__Valid_From__c == System.today());

     }
    private static testMethod void insertMainRecordMisconfigurationForNonOverLappingTimeFrame() {
		//Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunit = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');
        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(2);
        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)orgunit.get('Id'));
        sObject orgUnitUserRec =orgUnitUserList[0];
        orgUnitUserRec.put('ACCL__Main__c', true);
        sObject orgUnitUserMisconfigRecord =orgUnitUserList[1];
        orgUnitUserMisconfigRecord.put('ACCL__Main__c', true);
        orgUnitUserMisconfigRecord.put('ACCL__Valid_From__c',system.today().addyears(2));
        orgUnitUserMisconfigRecord.put('ACCL__Valid_Thru__c',system.today().addyears(2));
        update orgUnitUserRec;
        update orgUnitUserMisconfigRecord;
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(2,
                                            (Id)account.get('Id'),
                                            (Id)orgunit.get('Id'));
        accountOrgUnitList[1].put('ACCL__Valid_From__c',system.today().addyears(2));
        accountOrgUnitList[1].put('ACCL__Valid_Thru__c',system.today().addyears(2));
        update accountOrgUnitList;
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
		System.assertNotEquals(null,batchJobId);
        System.assertEquals(2, [SELECT count() FROM ACCL__Account_Manager__c]);
     }
    private static testMethod void insertManualMainRecordMisconfiguration() {
		//Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunit = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');
        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(10);
         sObject accountManagerRecord = AccountManagerBatchTestFactory.insertManualAccountManager(
         (Id)account.get('Id'),(Id)userList[0].get('Id'),system.today(),system.today()) ; 

        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(100,
                                          (Id)AccountManagerBatchTestFactory.getDefaultAccount().get('Id'),
                                          (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
        System.assertNotEquals(null,batchJobId);
        System.assertEquals(10, [SELECT count() FROM ACCL__Account_Manager__c]);

     }
    private static testMethod void insertMisconfigurationForDifferentOrgUnit() {
		//Arrange
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunitFirstRecord = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');
        sObject orgUnitSecondRecord = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit 2');

        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(10);
        sObject accountManagerRecord = AccountManagerBatchTestFactory.insertAccountManager(
                                         (Id)account.get('Id'),(Id)orgunitFirstRecord.get('Id'),
                                         (Id)userList[0].get('Id'),
                                         system.today(),system.today()) ; 

        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(100,
                                          (Id)AccountManagerBatchTestFactory.getDefaultAccount().get('Id'),
                                          (Id)AccountManagerBatchTestFactory.getDefaultOrgUnit().get('Id'));
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
		System.assertNotEquals(null,batchJobId);
        System.assertEquals(10, [SELECT count() FROM ACCL__Account_Manager__c]);
     } 
    private static testMethod void insertMisconfigurationForInactiveOrgUnit() {
        //Arrange
        String ns = AddOnConstants.NAMESPACEPREFIX;
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunitFirstRecord = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');

        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(1);
        sObject accountManagerRecord = AccountManagerBatchTestFactory.insertAccountManager(
                                         (Id)account.get('Id'),(Id)orgunitFirstRecord.get('Id'),
                                         (Id)userList[0].get('Id'),
                                         system.today(),system.today()) ; 

        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)orgunitFirstRecord.get('Id'));
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(1,
                                          (Id)AccountManagerBatchTestFactory.getDefaultAccount().get('Id'),
                                          (Id)(Id)orgunitFirstRecord.get('Id'));
        accountOrgUnitList[0].put(ns+'Active__c',false);
        update accountOrgUnitList;
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert
        System.assertNotEquals(null,batchJobId);
       // System.assertEquals(1, [SELECT count() FROM ACCL__Account_Manager__c]);

     } 
     private static testMethod void insertMisconfigurationForOldRecord() {
        //Arrange 
        String ns = AddOnConstants.NAMESPACEPREFIX;
        sObject account =  AccountManagerBatchTestFactory.insertAccount('Test');
        sObject orgunitFirstRecord = AccountManagerBatchTestFactory.insertOrgUnit('Test account manager Org Unit');

        List<sObject> userList = AccountManagerBatchTestFactory.insertUserWithProfile(1);
        sObject accountManagerRecord = AccountManagerBatchTestFactory.insertAccountManager(
                                         (Id)account.get('Id'),(Id)orgunitFirstRecord.get('Id'),
                                         (Id)userList[0].get('Id'),
                                         system.today().addmonths(-1),system.today().addmonths(-1)) ; 

        List<sObject> orgUnitUserList = AccountManagerBatchTestFactory.insertOrgUnitUser(userList,
                                        (Id)orgunitFirstRecord.get('Id'));
         orgUnitUserList[0].put(ns+'Valid_From__c',system.today().addmonths(-1));
         orgUnitUserList[0].put(ns+'Valid_Thru__c',system.today().addmonths(-1));
         update orgUnitUserList;
        List<sObject> accountOrgUnitList = AccountManagerBatchTestFactory.insertAccountOrgUnitList(1,
                                          (Id)account.get('Id'),
                                          (Id)(Id)orgunitFirstRecord.get('Id'));
        accountOrgUnitList[0].put(ns+'Valid_From__c',system.today().addmonths(-1));
         accountOrgUnitList[0].put(ns+'Valid_Thru__c',system.today().addmonths(-1));
        update accountOrgUnitList;
        AccountManagerOrgUnitBased sh = new AccountManagerOrgUnitBased();
        //Act
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        //Assert 
        System.assertNotEquals(null,batchJobId);
        System.assertEquals(1, [SELECT count() FROM ACCL__Account_Manager__c]);

     }
}