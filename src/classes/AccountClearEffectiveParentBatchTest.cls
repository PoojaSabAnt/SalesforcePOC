@isTest

private class AccountClearEffectiveParentBatchTest {

    @testsetup
    static void createAccountData(){
        Map<String, Schema.SObjectType> AllObjects = Schema.getGlobalDescribe();
        List<sObject> accList = new List<sObject>();
        List<sObject> accParentList = new List<sObject>();
        List<sObject> accExtList = new List<sObject>();
        List<sObject> accNewList = new List<sObject>();
        List<sObject> accTradeOrgList = new List<sObject>();
        for(Integer i=0; i<200; i++) {
            sObject accObj = AllObjects.get('Account').newSObject();
            accObj.put('ACCL__City__c','Test City');
            accObj.put('ACCL__Street__c','Test Street');
            accObj.put('Name','Test Account'+i);
            accObj.put('ACCL__Name_2__c','testX'+i);
            accList.add(accObj);
        }
        insert accList;
        for(sObject acc : accList) {
            sObject accObjParent = AllObjects.get('Account').newSObject();
            accObjParent.put('Name','Test Account Child');
            accObjParent.put('ParentId', acc.Id);
            accParentList.add(accObjParent);
            // Account Extension
            sObject accExtObj = AllObjects.get('ACCL__Account_Extension__c').newSObject();
            accExtObj.put('ACCL__Account__c', acc.Id);
            accExtList.add(accExtObj);
        }
        insert accParentList;
        insert accExtList;
    }

    /** Positive scenario test */
    private static testMethod void insertAccountEffectiveParentClearData() {
        AccountClearEffectiveParentBatch sh1 = new AccountClearEffectiveParentBatch();
        Test.startTest();
        ID batchprocessid = Database.executeBatch(sh1,200);
        Test.stopTest();
        List<sObject> listAccParentIdCheck = [SELECT Id FROM Account WHERE ParentId=null LIMIT 1000];
        System.assert(listAccParentIdCheck.size() > 199, true);
    }

    /** Negative scenario test */
    private static testMethod void insertAccountEffectiveParentClearNegativeBulkData() {

        Map<String, Schema.SObjectType> AllObjectMeta = Schema.getGlobalDescribe();
        List<sObject> accTradeOrgList = new List<sObject>();
        List<sObject> accListnew = [SELECT Id, Name FROM Account WHERE ParentId != null];
        // Add Account Trade Org Hierarchy
        for(Integer i=0; i<accListnew.size()-1; i++) {
            sObject accTradeOrgObj = AllObjectMeta.get('ACCL__Account_Trade_Org_Hierarchy__c').newSObject();
            accTradeOrgObj.put('ACCL__Child_Account__c', accListnew[i].Id);
            accTradeOrgObj.put('ACCL__Valid_From__c',System.today().addMonths(-1));
            accTradeOrgObj.put('ACCL__Valid_Thru__c',System.today().addMonths(1));
            accTradeOrgObj.put('ACCL__Parent_Account__c',accListnew[i+1].Id);
            accTradeOrgList.add(accTradeOrgObj);
        }
		insert accTradeOrgList;
        AccountClearEffectiveParentBatch sh1 = new AccountClearEffectiveParentBatch();
        Test.startTest();
        ID batchprocessid = Database.executeBatch(sh1,200);
        Test.stopTest();
		List<Account> accList = [SELECT Id FROM Account WHERE ParentId!=null LIMIT 1000];
        System.assert(accList.size() > 0,True);        
    }  
}