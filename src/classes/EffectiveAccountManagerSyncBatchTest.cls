@isTest
/**  PROGRAM NAME : EffectiveAccountManagerSyncBatchTest 
     * This class is a test class for the EffectiveAccountManagerSyncBatch.
     * @see    EffectiveAccountManagerSyncBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
private class EffectiveAccountManagerSyncBatchTest {
	/** Private Variables */
    private static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    /** This method is for testing accountTeamMember User, should be match with userId which we are inserting.
		Record should be shared with only that user. */
    private static testMethod void insertAccountManagerDataWithAccount() {
        EffectiveAccountManagerSyncTestFactory.insertAccountEffectiveManagerSyncBatchCustomSetting();
        List<sobject> listAccount = EffectiveAccountManagerSyncTestFactory.insertBulkAccounts(2);
        User u = EffectiveAccountManagerSyncTestFactory.getDefaultUser();
        //sObject acc = (sObject)listAccount[0];
        sObject accountMangerPostiveCheck = EffectiveAccountManagerSyncTestFactory.insertAccountManager(listAccount[0], u.Id, System.today(), System.today().addDays(1), 'Sales');
        EffectiveAccountManagerSyncBatch sh1 = new EffectiveAccountManagerSyncBatch();
        Test.startTest();
        Database.executeBatch(sh1);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Account Team Member', sch, sh1); 
        Test.stopTest();
        AccountTeamMember accountTeamMemberPostiveCheck = [SELECT Id, AccountID, UserId FROM AccountTeamMember WHERE AccountID =:listAccount[0].Id LIMIT 1];
        System.assert(accountTeamMemberPostiveCheck.UserId == u.id, True);
    }
    
    /** This method is for checking Bulk Account Manager Data insertion and cration of Account Team member */
    private static testMethod void insertAccountManagerDataWithAccountBulk() {
        EffectiveAccountManagerSyncTestFactory.insertAccountEffectiveManagerSyncBatchCustomSetting();
        List<sObject> listAccount = EffectiveAccountManagerSyncTestFactory.insertBulkAccounts(1000); 
        List<sObject> listAccountManager = EffectiveAccountManagerSyncTestFactory.insertAccountManagerList(listAccount);
        EffectiveAccountManagerSyncBatch sh1 = new EffectiveAccountManagerSyncBatch();
        Test.startTest();
        Database.executeBatch(sh1,1000);
        Test.stopTest();
        List<AccountTeamMember> listAccountTeamMember = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN:listAccount LIMIT 1000];
        System.assert(listAccountTeamMember.size() > 0, True);
    }
    
    /** This method is for checking Bulk Manger Data insertion with invalidDate
		AccountTeamMember should be deleted here */
    private static testmethod void InsertAccountManagerDataWithInvalidDateRange() {
        EffectiveAccountManagerSyncTestFactory.insertAccountEffectiveManagerSyncBatchCustomSetting();
        Date fromDate = Date.newInstance(1990, 01, 01);
        List<sObject> toUpdateAccountManager = new List<sObject>();
        List<sObject> listAccount = EffectiveAccountManagerSyncTestFactory.insertBulkAccounts(1000); 
        User u = EffectiveAccountManagerSyncTestFactory.getDefaultUser();
        List<sObject> listAccountManager = EffectiveAccountManagerSyncTestFactory.insertAccountManagerList(listAccount, u.id, System.today(), System.today().addDays(1), 'Sales');
        EffectiveAccountManagerSyncBatch sh1 = new EffectiveAccountManagerSyncBatch();
        Test.startTest();
        Database.executeBatch(sh1,1000);
        for(sObject accountMangers : listAccountManager) {
            accountMangers.put('ACCL__Valid_From__c', fromDate);
            accountMangers.put('ACCL__valid_Thru__c', fromDate.addDays(1));
            toUpdateAccountManager.add(accountMangers);
        }
        update toUpdateAccountManager;
        EffectiveAccountManagerSyncBatch sh2 = new EffectiveAccountManagerSyncBatch();
        Database.executeBatch(sh2,1000);
        Test.stopTest();
        List<AccountTeamMember> listAccountTeamMember = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN:listAccount LIMIT 1000];
        System.assert(listAccountTeamMember.size() == 0, True);
    }
}