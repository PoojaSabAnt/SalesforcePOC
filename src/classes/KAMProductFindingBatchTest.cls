@isTest
/**
 * @see     KAMProductFindingBatch.cls
 * @version 11-Jan-2017
 */
private class KAMProductFindingBatchTest {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /*Custom setting data preparation
      1. Batch_Process_Configuration__c custom setting data
      2. Aggregation_Traversal_Level__c custom setting Data
    */
    private static void createCustomSettingDataforBatch() {
        sObject sobj = KAMProductFindingBatchTestFactory.insertBatchProcessConfig();         
    }
    /*Method for testing Bulk scenario
      Product Level Product
    */
    private static testMethod void unitTestPositiveKAMProductFindingExecutionTest() {
        createCustomSettingDataforBatch();
        List<sObject> listProduct = new List<sObject>();
        sObject template = KAMProductFindingBatchTestFactory.insertProductTemplate(-2);
        sObject prdCriterion5 = KAMProductFindingBatchTestFactory.insertProductWithProductLevel(-1,AddOnConstants.PRODUCT_LEVEL_PACKAGE);
        for(integer i = 0; i<100; i++){
            sObject prd = KAMProductFindingBatchTestFactory.buildProduct(i,template);
            prd.put(ns+'Criterion_5_Product__c',prdCriterion5.id);
            prd.put(ns+'Product_Level__c',AddOnConstants.PRODUCT_LEVEL_PRODUCT);
            prd.put(ns+'KAM_Product__c',null);             
            listProduct.add(prd);
        }
        Database.insert(listProduct);         
        KAMProductFindingBatch sh = new KAMProductFindingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();         
        String squery ='SELECT {0}KAM_Product__c,{0}Criterion_5_Product__r.{0}Product_Level__c FROM {0}Product__c WHERE Id IN :listProduct LIMIT 1';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);
        system.assertNotEquals(null,batchJobId);
        System.assertEquals(sobjList[0].get(ns+'Criterion_5_Product__c'),sobjList[0].get(ns+'KAM_Product__c'));
        System.assertEquals(sobjList[0].getSObject(ns+'Criterion_5_Product__r').get(ns+'Product_Level__c'),AddOnConstants.PRODUCT_LEVEL_PACKAGE);
     }
     /*Method for testing scenario with
      null Criterion 5 product field
    */
    private static testMethod void unitTestPositiveKAMProductFindingExecutionTestNullCriterion5() {
        createCustomSettingDataforBatch();
        List<sObject> listProduct = new List<sObject>();
        sObject template = KAMProductFindingBatchTestFactory.insertProductTemplate(-3);
        for(integer i = 0; i<100; i++){
            sObject prd = KAMProductFindingBatchTestFactory.buildProduct(i,template);
            prd.put(ns+'Criterion_5_Product__c',null);
            prd.put(ns+'Product_Level__c',AddOnConstants.PRODUCT_LEVEL_PRODUCT);
            prd.put(ns+'KAM_Product__c',null);             
            listProduct.add(prd);
        }
        Database.insert(listProduct);
        KAMProductFindingBatch sh = new KAMProductFindingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        String squery ='SELECT {0}KAM_Product__c,{0}Criterion_5_Product__r.{0}Product_Level__c FROM {0}Product__c WHERE Id IN :listProduct LIMIT 1';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);
        system.assertNotEquals(null,batchJobId);
        System.assertEquals(sobjList[0].get(ns+'Criterion_5_Product__c'),sobjList[0].get(ns+'KAM_Product__c'));        
     }      
     /*Method for testing scenario with
      not null Kam Product field
    */
    private static testMethod void unitTestPositiveKAMProductFindingExecutionTestNotNullKamProduct() {
        //createCustomSettingDataforBatch();
        List<sObject> listProduct = new List<sObject>();
        sObject template = KAMProductFindingBatchTestFactory.insertProductTemplate(-4);
        sObject prdCriterion5 = KAMProductFindingBatchTestFactory.insertProductWithProductLevel(-1,AddOnConstants.PRODUCT_LEVEL_PACKAGE);
        for(integer i = 0; i<100; i++) {
           sObject prd = KAMProductFindingBatchTestFactory.buildProduct(i,template);
            prd.put(ns+'Criterion_5_Product__c',null);
            prd.put(ns+'Product_Level__c',AddOnConstants.PRODUCT_LEVEL_PRODUCT);
            prd.put(ns+'KAM_Product__c',prdCriterion5.id);             
            listProduct.add(prd);
        }
        Database.insert(listProduct);
        KAMProductFindingBatch sh = new KAMProductFindingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,200); 
        Test.stopTest();
        String squery ='SELECT {0}KAM_Product__c,{0}Criterion_5_Product__r.{0}Product_Level__c FROM {0}Product__c WHERE Id IN :listProduct LIMIT 1';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);
        system.assertNotEquals(null,batchJobId);
        System.assertNotEquals(sobjList[0].get(ns+'Criterion_5_Product__c'),sobjList[0].get(ns+'KAM_Product__c')); 
     }
}