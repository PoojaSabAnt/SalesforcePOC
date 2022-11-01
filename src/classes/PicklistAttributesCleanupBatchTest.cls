@isTest
/**
 * @see     PicklistAttributesCleanupBatch.cls
 */

private class PicklistAttributesCleanupBatchTest {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /*Custom setting data preparation
      Batch_Process_Configuration__c custom setting data      
    */ 

    private static void createCustomSettingDataforBatch() {
        sObject sobj = PicklistCleanupBatchTestFactory.insertBatchProcessConfig();         
    }

    private static testMethod void unitTestPositivePicklistValDel() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistCleanupBatchTestFactory.getDefaultPicklistToggleMapping();        
        insert sObj;       
        PicklistAttributesCleanupBatch sh = new PicklistAttributesCleanupBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);

     }
     private static testMethod void unitTestPositivePicklistFieldDel() {
        createCustomSettingDataforBatch(); 
        sObject sObj = PicklistCleanupBatchTestFactory.getDefaultPicklistRepository();        
        insert sObj;       
        PicklistAttributesCleanupBatch sh = new PicklistAttributesCleanupBatch();
        Test.startTest();
        Id batchJobId = Database.executeBatch(sh,100); 
        Test.stopTest();         
        System.assertNotEquals(null,batchJobId);

     }

     private static testMethod void unitTestPositiveDeleteIgnoreForMobility() {
         createCustomSettingDataforBatch(); 
         // create PTME record with Ignore_for_Mobility__c set as True
         sObject pteRecord = PicklistCleanupBatchTestFactory.getDefaultPicklistToggleMapping();
         insert pteRecord;

         //sObject ptmeRecord = PicklistToggleMappingExtTestFactory.buildPicklistToggleMappingExtension('shortDescription', 'cascode', PicklistToggleMappingTestFactory.getDefaultPicklistToggleMapping(),'someTestValue');
         sObject ptmeRecord = PicklistCleanupBatchTestFactory.getDefaulPicklistToggleMappingExt('shortDescription', 'cascode', pteRecord, 'someTestValue');
         ptmeRecord.put(ns+'Ignore_for_Mobility__c', true);
         ptmeRecord.put(ns+'Sales_Org__c', '0001'); 
         System.debug('ptmeRecord --> '+ptmeRecord);
         insert ptmeRecord;
         // Create Picklist_Repository__c record
         sObject sObj = PicklistCleanupBatchTestFactory.getDefaultPicklistRepository();       
         sObj.put(ns+'Field__c','Industry');
         sObj.put(ns+'Sales_Org__c', '0001'); 
         insert sObj;       
         PicklistAttributesCleanupBatch sh = new PicklistAttributesCleanupBatch();
         Test.startTest();
         Id batchJobId = Database.executeBatch(sh,100); 
         Test.stopTest();         
         System.assertNotEquals(null,batchJobId);
     }
}