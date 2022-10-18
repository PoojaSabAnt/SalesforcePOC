@isTest
/**  PROGRAM NAME : AuthorizationListSetupBatchTest 
     * This class is a test class for the AuthorizationListSetupBatchBatch.
     * @see    AuthorizationListSetupBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
private class AuthorizationListSetupBatchTest {
    /** Private Variable */
	private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    /** This method is for checking Account with no child accounts
		account will be added in Product assortment store with current Product Assortment */
    private static testMethod void insertProdAssortmentData() {
        AuthorizationListSetupTestFactory.createCustomSettingData(); //AuthorizationListSetupTestFactory
        
        SObject acc = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrg();
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(), System.today().addYears(2), prodAssortTemplate);
        AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, acc);
        AuthorizationListSetupTestFactory.insertFlattenAccountHierarchy(acc);
                
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True, listProdAssortStore.size() > 0);
    }
    
    private static testMethod void insertProdAssortmentAccountWithChildData() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        List<sObject> listAccount = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(2);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(), System.today().addYears(2), prodAssortTemplate);
        
        AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, listAccount[1]);
        AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, listAccount[0]);
        AuthorizationListSetupTestFactory.insertFlattenAccountHierarchy(listAccount[0], listAccount[1]);
        
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True, listProdAssortStore.size() > 0);
    }
    
    /** Insert account trade org hierarchy account for child records */
    private static testMethod void insertProdAssortmentwithTradeOrgHierarchyData() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        List<sObject> listAccount = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(5);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(), System.today().addYears(2), prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, listAccount[1]);
        
        sObject flatAccHier1 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier1.put('ACCL__Account__c', listAccount[1].Id);
        flatAccHier1.put('ACCL__Account_Level_01__c', listAccount[1].Id);
        flatAccHier1.put('ACCL__Node_Level__c', 1);
        //flatAccHier1.put(ns+'Result_Level__c', 'Store');
        flatAccHier1.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier1;
        
        sObject flatAccHier2 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier2.put('ACCL__Account__c', listAccount[0].Id);
        flatAccHier2.put('ACCL__Account_Level_01__c', listAccount[1].Id);
        flatAccHier2.put('ACCL__Account_Level_02__c', listAccount[0].Id);
        flatAccHier2.put('ACCL__Node_Level__c', 2);
        //flatAccHier2.put(ns+'Result_Level__c', 'Store');
        flatAccHier2.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier2;
        
        sObject flatAccHier3 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier3.put('ACCL__Account__c', listAccount[2].Id);
        flatAccHier3.put('ACCL__Account_Level_01__c', listAccount[1].Id);
        flatAccHier3.put('ACCL__Account_Level_02__c', listAccount[0].Id);
        flatAccHier3.put('ACCL__Account_Level_03__c', listAccount[2].Id);
        flatAccHier3.put('ACCL__Node_Level__c', 3);
        //flatAccHier3.put(ns+'Result_Level__c', 'Store');
        flatAccHier3.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier3;
        
        sObject flatAccHier4 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier4.put('ACCL__Account__c', listAccount[3].Id);
        flatAccHier4.put('ACCL__Account_Level_01__c', listAccount[1].Id);
        flatAccHier4.put('ACCL__Account_Level_02__c', listAccount[0].Id);
        flatAccHier4.put('ACCL__Account_Level_03__c', listAccount[3].Id);
        flatAccHier4.put('ACCL__Node_Level__c', 3);
        //flatAccHier4.put(ns+'Result_Level__c', 'Store');
        flatAccHier4.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier4;
        
        sObject flatAccHier5 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier5.put('ACCL__Account__c', listAccount[4].Id);
        flatAccHier5.put('ACCL__Account_Level_01__c', listAccount[1].Id);
        flatAccHier5.put('ACCL__Account_Level_02__c', listAccount[0].Id);
        flatAccHier5.put('ACCL__Account_Level_03__c', listAccount[2].Id);
        flatAccHier5.put('ACCL__Account_Level_04__c', listAccount[4].Id);
        flatAccHier5.put('ACCL__Node_Level__c', 4);
        //flatAccHier5.put(ns+'Result_Level__c', 'Store');
        flatAccHier5.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier5;
        
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() > 0);
    }
    
    /** new account will not be added in the list 
		account with same product assortment id is alreay present in Product Assortment store */
    private static testMethod void insertProdAssortmentStoreData() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        sObject acc = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrg();
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, acc);
        sObject prodAssortmentStore = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment, acc); 
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() > 0);
    }
    
    /** This method is for checking deletion logic of invalid Product assortment */
    private static testMethod void prodAssortmentStoreDataDeleteCheck() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        sObject acc = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrg();
        List<sObject> listAccount = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(5);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, acc);
        sObject prodAssortmentStore = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment,acc); 
        sObject prodAssortmentStorewithAnotherAcc = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment,listAccount[0]); 
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() > 0);
    }
    
    /** This method is for checking deletion logic of invalid Product assortment account as part of NR 2834*/
    private static testMethod void prodAssortmentAccountDataDeleteCheck() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        sObject acc = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrg();
        List<sObject> listAccount = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(5);
        sObject prodAssortTemplateListing = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateListing();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentListingWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplateListing);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, acc);
        sObject prodAssortmentAccountDate = AuthorizationListSetupTestFactory.insertProductAssortmentAccountWithDates(prodAssortment, listAccount[0], System.today().addYears(-3), System.today().addYears(-1));
        sObject prodAssortmentStore = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment,acc); 
        sObject prodAssortmentStorewithAnotherAcc = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment,listAccount[0]); 
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() > 0);
    }
    
    /** This method is for checking deletion part of AuthorizationAggregation batch
		Product assortment store list should be empty  */
    private static testMethod void deleteAuthorizationListingCheck() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        sObject acc = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrg();
        List<sObject> listAccount = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(5);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today().addYears(-3),System.today().addYears(-1),prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccount(prodAssortment, acc);
        sObject prodAssortmentStore = AuthorizationListSetupTestFactory.insertProdAssortStore(prodAssortment,acc); 
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() == 0);
    }
    
    /** Negative scenario
		this method is for testing exception part when final account list size equals to zero */
    private static testMethod void insertProductAssortmentWithNoAccount() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplate);
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() == 0);
    }
    
    /** Negative scenario
		this method is for testing exception part when current date is not in the validity range of the product assortment account */
    private static testMethod void insertProductAssortmentWithInvalidAccount() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        List<sObject> childAccounts = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(2);
        sObject FlattenAccountHierarchy = AuthorizationListSetupTestFactory.insertFlattenAccountHierarchy(childAccounts[1], childAccounts[0]);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccountWithDates(prodAssortment, childAccounts[0], System.today().addYears(-3), System.today().addYears(-1));
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() == 0);
    }
    
    /** Positive scenario
		this method is for testing exception part when current date is in the validity range of the product assortment account */
    private static testMethod void insertProductAssortmentWithValidAccount() {
        AuthorizationListSetupTestFactory.createCustomSettingData();
        
        List<sObject> childAccounts = AuthorizationListSetupTestFactory.getDefaultAccountWithSalesOrgList(2);
        sObject FlattenAccountHierarchy = AuthorizationListSetupTestFactory.insertFlattenAccountHierarchy(childAccounts[1], childAccounts[0]);
        sObject prodAssortTemplate = AuthorizationListSetupTestFactory.insertProductAssortmentTemplateWithRecordTypeId();
        sObject prodAssortment = AuthorizationListSetupTestFactory.getProductAssortmentWithValidRange(System.today(),System.today().addYears(2),prodAssortTemplate);
        sObject prodAssortmentAccount = AuthorizationListSetupTestFactory.insertProductAssortmentAccountWithDates(prodAssortment, childAccounts[0], System.today().addYears(-1), System.today().addYears(+1));
        AuthorizationListSetupBatch sh1 = new AuthorizationListSetupBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1);
        Test.stopTest();
        List<sObject> listProdAssortStore = [SELECT Id FROM ACCL__Product_Assortment_Store__c LIMIT 10];
        System.assertEquals(True,listProdAssortStore.size() > 0);
    }
}