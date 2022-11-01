@isTest
/**
 * @see     PicklistAttributesMappingBatch.cls
 */

private class PicklistAttributesMappingBatchTest {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /*Custom setting data preparation
      Batch_Process_Configuration__c custom setting data      
    */ 
    
    private static void createCustomSettingDataforBatch() {
        sObject sobj = PicklistAttributeMapBatchTestFactory.insertBatchProcessConfig();         
    }
    /*Method for testing Bulk scenario
      
    */
    private static testMethod void unitTestPositivePicklistMapTest() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMapping();        
        insert sObj;       
        PicklistAttributesMappingBatch sh = new PicklistAttributesMappingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);
        
     }
     private static testMethod void unitTestnegativePicklistMapTest() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMapping();
        sObj.put(ns+'CASDomain__c','');        
        insert sObj;       
        PicklistAttributesMappingBatch sh = new PicklistAttributesMappingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);
        
     }
     private static testMethod void unitTestPositivePicklistMapExtTest() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMapping();        
        insert sObj;  
        sObject sObj1 = PicklistAttributeMapBatchTestFactory.getDefaulPicklistToggleMappingExt('shortDescription', 'cascode',sObj,'someTestValue');    
        insert sObj1;
        PicklistAttributesMappingBatch sh = new PicklistAttributesMappingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);
        
     }
     private static testMethod void unitTestNegativePicklistMapExtTest() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMapping();        
        insert sObj;  
        sObject sObj1 = PicklistAttributeMapBatchTestFactory.getDefaulPicklistToggleMappingExt('shortDescription', 'DomCssFilterType',sObj,'Banking');    
        insert sObj1;
        PicklistAttributesMappingBatch sh = new PicklistAttributesMappingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);
        
     }
    
    //*********** bulk test *******************
    private static testMethod void unitTestPositivePicklistMapBulkTest() {
        createCustomSettingDataforBatch(); 
        List<sObject> sObj = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMappingList(100);
        /*List<sObject> sObj = new List<sObject>();
        for(Integer i=0; i<100; i++)
        {
            sObject sObje = PicklistAttributeMapBatchTestFactory.getDefaultPicklistToggleMapping();
            sObj.add(sObje);
        } */
        insert sObj;       
        PicklistAttributesMappingBatch sh = new PicklistAttributesMappingBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);
        
     }
}