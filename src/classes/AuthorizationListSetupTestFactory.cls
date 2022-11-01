@isTest
/**  PROGRAM NAME : AuthorizationListSetupTestFactory 
     * This class is a test factory class to provide data setup to be refered in AuthorizationListSetupBatchTest class.
     * @see    AuthorizationListSetupBatchTest
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class AuthorizationListSetupTestFactory {
	/** Private Variables */
    private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    private final Static String CUSTOMER_RECORD_TYPE = 'Customer';
    private final Static String CUSTOMER_TEMPLATE_OBJECT = 'ACCL__Account_Template__c';
    private final Static String PROD_ASSORT_TEMPLATE = 'ACCL__Product_Assortment_Template__c';
    private final Static String PAT_RECORD_TYPE = 'Assortment_List';
    
    /**
     *  @description This method creates a record in the Batch_Process_Configuration__c custom setting to determine default batch size.
     *  @param None
     *  @return None
     *  @throws None
     */
    public static void createCustomSettingData() {
        sObject sObjA = allObjMetaType.get('ACCL__Batch_Process_Configuration__c').newSObject();
        sObjA.put('Name', 'AuthAggregation');
        sObjA.put('ACCL__Batch_Size__c', 1);
        insert sObjA;
        
        sObject sObjB = allObjMetaType.get('ACCL__Aggregation_Traversal_Level__c').newSObject();
        sObjB.put('Name', 'AuthorizationListSetupBatch');
        sObjB.put('ACCL__Counter_Value__c', 6);
        insert sObjB;
    }  
    
    /**
     *  @description This method inserts Account Template record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sobject getDefaultAccountTemplateWithSalesOrg() {
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType=:CUSTOMER_TEMPLATE_OBJECT AND DeveloperName=:CUSTOMER_RECORD_TYPE];
        sObject accTemp = allObjMetaType.get('ACCL__Account_Template__c').newSObject();
        accTemp.put('Name', 'TestName');
        accTemp.put('ACCL__Initial_Roles__c', 'customer');
        accTemp.put('ACCL__Active__c', true);
        accTemp.put('RecordTypeId', rt.Id);
        accTemp.put('ACCL__Description_Language_1__c', 'TestName');
        accTemp.put('ACCL__Sales_Org__c', '0001');
        insert accTemp;
        return accTemp;
    }
    
    /**
     *  @description This method insert Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sobject getDefaultAccountWithSalesOrg() {
        sObject acc = allObjMetaType.get('Account').newSObject();
        acc.put('Name', 'testName');
        acc.put('ACCL__City__c', 'testCity');
        acc.put('ACCL__Street__c', 'testStreet');
        acc.put('ACCL__Name_2__c', 'testName2');
        acc.put('ACCL__Account_Template__c', getDefaultAccountTemplateWithSalesOrg().Id);
        insert acc;
        return acc;
    }
    
    /**
     *  @description This method insert the Account records in bulk.
     *  @param Integer noOfAcc
     *  @return List<sobject>
     *  @throws None
     */
    public static List<sobject> getDefaultAccountWithSalesOrgList(Integer noOfAcc) {
        List<sobject> accList = new List<sObject>();
        for(Integer i=0; i<noOfAcc; i++) {
            sObject acc = allObjMetaType.get('Account').newSObject();
            acc.put('Name', 'testName'+i);
            acc.put('ACCL__City__c', 'testCity');
            acc.put('ACCL__Street__c', 'testStreet');
            acc.put('ACCL__Name_2__c', 'testName2_'+i);
            acc.put('ACCL__Account_Template__c', getDefaultAccountTemplateWithSalesOrg().Id);
            accList.add(acc);
        }    
        insert accList;
        return accList;
    }
    
    /**
     *  @description This method inserts Product Assortment Template record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject insertProductAssortmentTemplateWithRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType=:PROD_ASSORT_TEMPLATE AND DeveloperName=:PAT_RECORD_TYPE];
        sObject pat = allObjMetaType.get('ACCL__Product_Assortment_Template__c').newSObject();
        pat.put('Name', 'testName');
        pat.put('ACCL__Account_Multiplicity__c', 'Exactly One');
        pat.put('ACCL__Active__c', true);
        pat.put('ACCL__Description_Language_1__c', 'English');
        pat.put('RecordTypeId', rt.Id);
        pat.put('ACCL__Sales_Org__c', '0001');
        insert pat;
        return pat;
    }
    
    /**
     *  @description This method inserts Product Assortment Template as listing
     *  changes done as part of NR-2834.
     *  @param None
     *  @return sObject
     *  @throws None
     */
     public static ACCL__Product_Assortment_Template__c insertProductAssortmentTemplateListing() {
       	RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType='ACCL__Product_Assortment_Template__c' AND DeveloperName='Assortment_List'];
        ACCL__Product_Assortment_Template__c pat = new ACCL__Product_Assortment_Template__c();
        pat.Name = 'listing';
        pat.ACCL__Account_Multiplicity__c = 'Exactly One';
        pat.ACCL__Active__c = true;
        pat.ACCL__Description_Language_1__c = 'English';
        pat.RecordTypeId = rt.Id;
        pat.ACCL__Sales_Org__c = '0001';
        
        insert pat;
        return pat;
    }
    
    /**
     *  @description This method inserts Product Assortment record with template listing.
     *  @param Date validFrom, Date validThru, sObject productAssortmentTemplate
     *  @return sObject
     *  @throws None
     */
    public static sObject getProductAssortmentListingWithValidRange(Date validFrom, Date validThru, sObject prodAssortTemplateListing) {
        sObject prodAssort = allObjMetaType.get('ACCL__Product_Assortment__c').newSObject();
        prodAssort.put('Name', 'US01_1234_Branch');
        prodAssort.put('ACCL__Product_Assortment_Template__c', prodAssortTemplateListing.Id);
        prodAssort.put('ACCL__Valid_From__c', validFrom);
        prodAssort.put('ACCL__Valid_Thru__c', validThru);
        prodAssort.put('ACCL__Description_Language_1__c', 'English');
        insert prodAssort;
        return prodAssort;
    }
    
    /**
     *  @description This method inserts Product Assortment record.
     *  @param Date validFrom, Date validThru, sObject productAssortmentTemplate
     *  @return sObject
     *  @throws None
     */
    public static sObject getProductAssortmentWithValidRange(Date validFrom, Date validThru, sObject productAssortmentTemplate) {
        sObject prodAssort = allObjMetaType.get('ACCL__Product_Assortment__c').newSObject();
        prodAssort.put('Name', 'testName');
        prodAssort.put('ACCL__Product_Assortment_Template__c', productAssortmentTemplate.Id);
        prodAssort.put('ACCL__Valid_From__c', validFrom);
        prodAssort.put('ACCL__Valid_Thru__c', validThru);
        prodAssort.put('ACCL__Description_Language_1__c', 'English');
        insert prodAssort;
        return prodAssort;
    }
    
    /**
     *  @description This method inserts Product Assortment Account record.
     *  @param sObject productAssortment, sObject account
     *  @return sObject
     *  @throws None
     */
    public static sObject insertProductAssortmentAccount(sObject productAssortment, sObject account) {
        sObject prodAssortAcc = allObjMetaType.get('ACCL__Product_Assortment_Account__c').newSObject();
        prodAssortAcc.put('ACCL__Account__c', account.Id);
        prodAssortAcc.put('ACCL__Product_Assortment__c', productAssortment.Id);
        prodAssortAcc.put('ACCL__Valid_From__c', System.today());
        prodAssortAcc.put('ACCL__Valid_Thru__c', System.today().addYears(1));
        insert prodAssortAcc;
        return prodAssortAcc;
    }
    
    /**
     *  @description This method inserts Product Assortment Account record.
     *  @param sObject productAssortment, sObject account, Date validFrom, Date validThru
     *  @return sObject
     *  @throws None
     */
    public static sObject insertProductAssortmentAccountWithDates(sObject productAssortment, sObject account, Date validFrom, Date validThru) {
        sObject prodAssortAcc = allObjMetaType.get('ACCL__Product_Assortment_Account__c').newSObject();
        prodAssortAcc.put('ACCL__Account__c', account.Id);
        prodAssortAcc.put('ACCL__Product_Assortment__c', productAssortment.Id);
        prodAssortAcc.put('ACCL__Valid_From__c', validFrom);
        prodAssortAcc.put('ACCL__Valid_Thru__c', validThru);
        insert prodAssortAcc;
        return prodAssortAcc;
    }
    
    /**
     *  @description This method inserts Product Assortment Store record.
     *  @param sObject prodAssort, sObject acc
     *  @return sObject
     *  @throws None
     */
    public static sObject insertProdAssortStore(sObject prodAssort, sObject acc) {
        sObject prodAssortStore = allObjMetaType.get('ACCL__Product_Assortment_Store__c').newSObject();
        prodAssortStore.put('ACCL__Store__c', acc.Id);
        prodAssortStore.put('ACCL__Assortment__c', prodAssort.Id);
        insert prodAssortStore;
        return prodAssortStore;
    }
    
    /**
     *  @description This method inserts Flatten Account Hierarchy record.
     *  @param sObject acc
     *  @return sObject
     *  @throws None
     */
    public static sObject insertFlattenAccountHierarchy(sObject acc) {
        sObject flatAccHier = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        flatAccHier.put('ACCL__Account__c', acc.Id);
        flatAccHier.put('ACCL__Account_Level_01__c', acc.Id);
        flatAccHier.put('ACCL__Node_Level__c', 1);
        flatAccHier.put('ACCL__Result_Level__c', 'Store');
        flatAccHier.put('ACCL__ExternalID__c', 'ExternalId');
        insert flatAccHier;
        return flatAccHier;
    }
    
    /**
     *  @description This method inserts Flatten Account Hierarchy record.
     *  @param sObject childAccount, sObject parentAccount
     *  @return sObject
     *  @throws None
     */
    public static sObject insertFlattenAccountHierarchy(sObject childAccount, sObject parentAccount) {
        sObject level1 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        level1.put('ACCL__Account__c', parentAccount.Id);
        level1.put('ACCL__Account_Level_01__c', parentAccount.Id);
        level1.put('ACCL__Node_Level__c', 1);
        level1.put('ACCL__Result_Level__c', 'Store;Trade Org');
        level1.put('ACCL__ExternalID__c', 'ExternalId');
        
        sObject level2 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        level2.put('ACCL__Account__c', childAccount.Id);
        level2.put('ACCL__Account_Level_01__c', parentAccount.Id);
        level2.put('ACCL__Account_Level_02__c', childAccount.Id);
        level2.put('ACCL__Node_Level__c', 2);
        level2.put('ACCL__Result_Level__c', 'Store');
        level2.put('ACCL__ExternalID__c', 'ExternalId');
        
        insert level1;
        insert level2;
        return level1;
    }
}