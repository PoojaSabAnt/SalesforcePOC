@isTest
public with sharing class AddOnProductTemplateTestFactory {
  public static ACCL__Product_Template__c defaultProductTemplate;  
  public static ACCL__Product_Template__c buildProductTemplateForProductRecordType(
    Integer nameSuffix
  ) {
    Map<String, Id> mapProductTemplateRecordTypesByDeveloperName = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(
      ACCL__Product_Template__c.sObjectType
    );
    ACCL__Product_Template__c productTemplate = new ACCL__Product_Template__c();
    productTemplate.Name = 'test' + nameSuffix;
    productTemplate.ACCL__Description_Language_1__c = 'lan' + nameSuffix;
    productTemplate.ACCL__Active__c = true;
    productTemplate.ACCL__Price_Required__c = true;
    productTemplate.recordtypeid = mapProductTemplateRecordTypesByDeveloperName.get(
      'Product'
    );
    return productTemplate;
  }
  //Test_Methods_With_No_Assert – False Positive
  //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
   public static ACCL__Product_Template__c getDefaultProductTemplateForProduct() {
    if (defaultProductTemplate == null) {
      defaultProductTemplate = insertProductTemplateForProduct(-1);
    }
    return defaultProductTemplate;
  }  
  public static ACCL__Product_Template__c insertProductTemplateForProduct(
    Integer nameSuffix
  ) {
    ACCL__Product_Template__c productTemplate = buildProductTemplateForProductRecordType(
      nameSuffix
    );
    insert productTemplate;
    return productTemplate;
  }
}