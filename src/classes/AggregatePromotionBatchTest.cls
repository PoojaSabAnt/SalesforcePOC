@isTest
public class AggregatePromotionBatchTest {
    private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    private static String ns = AddOnConstants.NAMESPACEPREFIX;
    private final Static String PROMOTION_PHASE_COMMITTED = 'Committed';
    Date today = System.today();
    
    private static final String query = 'SELECT Id, ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c <=today AND ACCL__Date_Thru__c >= today AND ACCL__Active__c=true AND ACCL__Phase__c =:PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
    
    private static testMethod void insertPromotionData() {
        //createCustomSettingData();
        String query = 'SELECT Id, ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c <=today AND ACCL__Date_Thru__c >= today AND ACCL__Active__c=true AND ACCL__Phase__c =:PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
        system.debug('query' +query);
        sObject acc = AggregatePromotionTestFactory.getDefaultAccount();
        sObject promTemp = AggregatePromotionTestFactory.getDefaultPromotionTemplate();
        List<sObject> lstPromotion = AggregatePromotionTestFactory.getDefaultPromotion(3, promTemp, acc, 'Committed');
        system.debug('lstPromotion' +lstPromotion);
        //List<Promotion__c> lstPromotion = PromotionTestFactory.insertPromotions(PromotionTestFactory.buildCommittedPromotions(3));
        query = String.format(query, new List<String>{ns});
        List<sObject> promToBeProcess = Database.query(query);
        System.debug('promToBeProcess' +promToBeProcess);
        AggregatePromotionBatch sh1= new AggregatePromotionBatch();
        Test.startTest();
        //executionMethod.process(promToBeProcess);
        Id batchprocessId = Database.executeBatch(sh1,3);
        Test.stopTest();
        
        String storeQuery = 'SELECT Id FROM ACCL__Promotion_Store__c LIMIT 10';
        storeQuery = String.format(storeQuery, new List<String>{ns});
        List<sObject> listPromotionStore = Database.query(storeQuery);
        System.assertEquals(True, listPromotionStore.size() > 0);
        System.debug('listPromotionStore' +listPromotionStore.size());
    }
    
    
    private static testMethod void insertPromotionDataWithFlattenAccountHierarchy() {
        //createCustomSettingData();
        List<sObject> childAccounts = AggregatePromotionTestFactory.insertBulkAccounts(2);
        sObject promTemp = AggregatePromotionTestFactory.getDefaultPromotionTemplate();
        sObject promotion = AggregatePromotionTestFactory.getDefaultPromotion(childAccounts[0], promTemp, System.today(),System.today().addYears(1), 'Committed');
        sObject FlattenAccountHierarchy = AggregatePromotionTestFactory.insertFlattenAccountHierarchy(childAccounts[1], childAccounts[0]);
        
        String query = 'SELECT Id, ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c <=today AND ACCL__Date_Thru__c >= today AND ACCL__Active__c=true AND ACCL__Phase__c =:PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
        query = String.format(query, new List<String>{ns});
        List<sObject> promToBeProcess = Database.query(query);
        AggregatePromotionBatch sh1= new AggregatePromotionBatch();
        Test.startTest();
        Id batchprocessId = Database.executeBatch(sh1,3);
        Test.stopTest();
        
        String storeQuery = 'SELECT Id FROM ACCL__Promotion_Store__c LIMIT 10';
        storeQuery = String.format(storeQuery, new List<String>{ns});
        List<sObject> listPromotionStore = Database.query(storeQuery);
        System.assertEquals(True,listPromotionStore.size() > 0);
        
    } 
    
    private static testMethod void insertPromotionDataForDeletion() {
        //createCustomSettingData();
        String query = 'SELECT Id, ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c > today AND ACCL__Date_Thru__c > today AND ACCL__Active__c=true AND ACCL__Phase__c =:PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
        Date dateFrom = System.today().addDays(8);
        Date dateThru = System.today().addDays(12);
        system.debug('query' +query);
        sObject acc = AggregatePromotionTestFactory.getDefaultAccount();
        sObject promTemp = AggregatePromotionTestFactory.getDefaultPromotionTemplate();
        sObject lstPromotion = AggregatePromotionTestFactory.getDefaultPromotion(acc, promTemp, dateFrom,dateThru, 'Committed');
        //getDefaultPromotion(acc, promTemp, dateFrom,dateThru, 'Committed')
        system.debug('lstPromotion' +lstPromotion);
        //List<Promotion__c> lstPromotion = PromotionTestFactory.insertPromotions(PromotionTestFactory.buildCommittedPromotions(3));
        query = String.format(query, new List<String>{ns});
        List<sObject> promToBeProcess = Database.query(query);
        System.debug('promToBeProcess' +promToBeProcess);
        AggregatePromotionBatch sh1 = new AggregatePromotionBatch();
        Test.startTest();
        Database.executeBatch(sh1);
        //Id batchprocessId = Database.executeBatch(sh1,3);
        Test.stopTest();
        
        String storeQuery = 'SELECT Id FROM ACCL__Promotion_Store__c LIMIT 10';
        storeQuery = String.format(storeQuery, new List<String>{ns});
        List<sObject> listPromotionStore = Database.query(storeQuery);
        System.assertEquals(False, listPromotionStore.size() > 0);
        System.debug('listPromotionStore' +listPromotionStore.size());
    }

}