@isTest
public with sharing class AddOnProductTestFactory {
    
  public static ACCL__Product__c buildProduct(
    Integer nameSuffix,
    ACCL__Product_Template__c template
  ) {
    ACCL__Product__c product = new ACCL__Product__c();
    product.Name = AddOnConstants.NAME + nameSuffix;
    product.ACCL__State__c = '4';
    product.ACCL__Description_1_Language_1__c = 'description' + nameSuffix;
    product.ACCL__Product_Code__c = 'ProductCode' + nameSuffix;
    product.ACCL__Product_Template__c = template.Id;
    product.ACCL__Field_Valid_From__c = System.today();
    product.ACCL__Field_Valid_Thru__c = System.today().addMonths(5);
    product.ACCL__Delivery_Valid_From__c = System.today();
    product.ACCL__Delivery_Valid_Thru__c = System.today().addMonths(5);
    product.ACCL__KAM_Valid_From__c = System.today();
    product.ACCL__KAM_Valid_Thru__c = System.today().addMonths(5);
    product.ACCL__New_Item_Valid_From__c = System.today();
    product.ACCL__New_Item_Valid_Thru__c = System.today().addMonths(5);
    product.ACCL__Fund_Valid_From__c = System.today();
    product.ACCL__Fund_Valid_Thru__c = System.today().addMonths(5);
    product.ACCL__Category__c = null;
    return product;
  }

  //Test_Methods_With_No_Assert – False Positive
  //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
  public static List<ACCL__Product__c> insertProducts(Integer noOfRecords) {
    List<ACCL__Product__c> products = new List<ACCL__Product__c>();
    for (integer i = 0; i < noOfRecords; i++) {
      products.add(
        buildProduct(
          i,
          AddOnProductTemplateTestFactory.getDefaultProductTemplateForProduct()
        )
      );
    }
    insert products;
    return products;
  }
}