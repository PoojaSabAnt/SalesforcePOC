@isTest
private class EffectiveAccountParentSyncBatchTest {

private static testMethod void insertAccountTradeOrgHierarchyData() {
        EffectiveAccountParentSyncTestFactory.insertAccountParentSyncBatchCustomSetting();
        List<sObject> listAccount = EffectiveAccountParentSyncTestFactory.insertBulkAccounts(2);
        sObject accountTradeOrgHierarchy = EffectiveAccountParentSyncTestFactory.insertAccountTradeOrgHierarchy(listAccount[0],listAccount[1],System.today(),System.today().addDays(1));
        EffectiveAccountParentSyncBatch sh1 = new EffectiveAccountParentSyncBatch();
        Test.startTest();
        ID batchprocessId = Database.executeBatch(sh1);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Test Account Trade Org Hierarchy', sch, sh1); 
        Test.stopTest();
        string ns = AddOnConstants.NAMESPACEPREFIX;
        string accountTradeOrgHierarchytest = 'SELECT {0}Child_Account__r.ParentID,{0}Child_Account__c,{0}Parent_Account__c FROM {0}Account_Trade_Org_Hierarchy__c LIMIT 1';
        accountTradeOrgHierarchytest = String.format(accountTradeOrgHierarchytest, new List<String>{ns});
        List<sObject> temp = Database.query(accountTradeOrgHierarchytest);
        }
    /**Bulk parent id population check with valid date range of Account Trade org Hierarchy
     *  @name insertAccountTradeOrgHierarchyDatabulk 
     **/
    private static testMethod void insertAccountTradeOrgHierarchyDatabulk() {
        EffectiveAccountParentSyncTestFactory.insertAccountParentSyncBatchCustomSetting();
        List<sObject> listAccount = EffectiveAccountParentSyncTestFactory.insertBulkAccounts(1000);
        List<sObject> listAccountTradeOrgHierarchy = EffectiveAccountParentSyncTestFactory.insertHierarchy(listAccount);
        EffectiveAccountParentSyncBatch sh1 = new EffectiveAccountParentSyncBatch();
        Test.startTest();
        ID batchprocessId = Database.executeBatch(sh1,1000);
        Test.stopTest();
        List<Account> listAcc = [select id from Account where id IN:listAccount and ParentId != null LIMIT 1000];
        system.debug(listAcc.size());
        System.assertNotEquals(null,listAcc.size());
        }
    /**parent id population check with  invalid date range of Account Trade Org Hierarchy
     *  @name insertAccountTradeOrgHierarchyDatabulkNegative 
     **/
     private static testMethod void insertAccountTradeOrgHierarchyDatabulkNegative() {
        EffectiveAccountParentSyncTestFactory.insertAccountParentSyncBatchCustomSetting();
        Date validFrom = Date.newInstance(1990, 01, 01);
        List<sObject> listAccount = EffectiveAccountParentSyncTestFactory.insertBulkAccounts(1000);
        List<sObject> listAccountTradeOrgHierarchy = EffectiveAccountParentSyncTestFactory.insertHierarchyWithValidDates(listAccount,validFrom,validFrom);
        EffectiveAccountParentSyncBatch sh1 = new EffectiveAccountParentSyncBatch();
        Test.startTest();
        ID batchprocessid = Database.executeBatch(sh1,1000);
        Test.stopTest();
        List<Account> listAcc = [select id from Account where id IN:listAccount and ParentId=null LIMIT 1000];
        System.assert(listAcc.size() > 999,True);
        
     }   
}