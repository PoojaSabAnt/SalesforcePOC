public class EffectiveAccountParentSyncTestFactory {
 private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
 private static String ns = AddOnConstants.NAMESPACEPREFIX;
  
  public static void insertAccountParentSyncBatchCustomSetting(){
    sObject sObj = allObjMetaType.get(ns+'Batch_Process_Configuration__c').newSObject();
        sObj.put('Name', AddOnConstants.EFFECTIVE_ACCOUNT_PAR_SYNC_BATCH);
        sObj.put(ns+'Batch_Size__c', 200);
        insert sObj;
    }
    
    public static List<sObject> insertBulkAccounts(Integer noOfAcc) {
    List<sObject> accList = new List<sObject>();
        for(Integer i=0; i<noOfAcc; i++) {
            sObject acc = allObjMetaType.get('Account').newSObject();
      acc.put(ns+'City__c', 'Test City');
      acc.put(ns+'Street__c', 'Test Street');
      acc.put('Name', 'Test'+i); 
      acc.put(ns+'Name_2__c', 'testX'+i);
      accList.add(acc);
        }
    insert accList;
        return accList;
  }
    public static sobject insertAccountTradeOrgHierarchy(sObject childAccount,sObject parentAccount,Date validFrom,Date validThru){
        sObject accTradeOrg = allObjMetaType.get(ns+'Account_Trade_Org_Hierarchy__c').newSObject();
        accTradeOrg.put(ns+'Child_Account__c', childAccount.Id);
        accTradeOrg.put(ns+'Parent_Account__c', parentAccount.Id);
        accTradeOrg.put(ns+'Valid_From__c', validFrom);
        accTradeOrg.put(ns+'Valid_Thru__c', validThru);
        insert accTradeOrg;
        return accTradeOrg;
    }
    
    public static List<sObject> insertHierarchy(List<Account> listOfAcc) {
    List<sobject> accTradeOrgList = new List<sobject>();
    
    sObject acc1 = allObjMetaType.get('Account').newSObject();
      acc1.put(ns+'City__c', 'Test City');
      acc1.put(ns+'Street__c', 'Test Street');
      acc1.put('Name', 'Test'); 
      acc1.put(ns+'Name_2__c', 'testX');
    insert acc1;
    for(Account acc : listOfAcc) {
      sObject accTradeOrg = allObjMetaType.get(ns+'Account_Trade_Org_Hierarchy__c').newSObject();
      accTradeOrg.put(ns+'Child_Account__c', acc1.Id);
      accTradeOrg.put(ns+'Parent_Account__c', acc.Id);
      accTradeOrg.put(ns+'Valid_From__c', System.today());
      accTradeOrg.put(ns+'Valid_Thru__c', System.today().addDays(50));
      accTradeOrgList.add(accTradeOrg);
    }
    insert accTradeOrgList;
    return accTradeOrgList;
  }
    /*@Name : buildHierarchyWithValidDates
   *@Description Creating this method for AccountEffectiveParentClearBatch bulk test
   *@Param accountsToConnect, ValidThru
   */
      public static List<sObject> insertHierarchyWithValidDates(List<Account> accountsToConnect,Date validFrom,Date ValidThru) {
        List<sObject> listHierarchyWithValidDateBuild = new List<sObject>();
        // connect each account with his next account
        sObject acc1 = allObjMetaType.get('Account').newSObject();
              acc1.put(ns+'City__c', 'Test City');
              acc1.put(ns+'Street__c', 'Test Street');
              acc1.put('Name', 'Test'); 
              acc1.put(ns+'Name_2__c', 'testX');
            insert acc1;
        for(Account acc : accountsToConnect) {
      sObject accTradeOrg = allObjMetaType.get(ns+'Account_Trade_Org_Hierarchy__c').newSObject();
      accTradeOrg.put(ns+'Child_Account__c', acc1.Id);
      accTradeOrg.put(ns+'Parent_Account__c', acc.Id);
      accTradeOrg.put(ns+'Valid_From__c', System.today());
      accTradeOrg.put(ns+'Valid_Thru__c', System.today().addDays(1));
      listHierarchyWithValidDateBuild.add(accTradeOrg);
    }
        insert listHierarchyWithValidDateBuild;
        return listHierarchyWithValidDateBuild;
    }
    
}