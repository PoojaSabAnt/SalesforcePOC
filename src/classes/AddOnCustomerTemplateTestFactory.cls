/*
 * PROGRAM NAME : AddOnCustomerTemplateTestFactory Addon Test Factory Class
 *
 */
@isTest
public with sharing class AddOnCustomerTemplateTestFactory {
  public static ACCL__Account_Template__c defaultAccountTemplateWithSalesOrg;
  //Public static Customer Template
  public static ACCL__Account_Template__c defaultCustomerTemplate;

  /*
    Account Template Build Method 
    Return: Account_Template__c
    */
  public static ACCL__Account_Template__c buildCustomerTemplate(Integer nameSuffix) {
    ACCL__Account_Template__c accTem = new ACCL__Account_Template__c();
    accTem.Name = AddOnConstants.Name + nameSuffix;
    accTem.ACCL__Initial_Roles__c = 'customer';
    accTem.ACCL__Active__c = true;
    accTem.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sObjectType = :ACCL__Account_Template__c.SObjectType.getDescribe().getName()
        AND DeveloperName = :AddOnConstants.CUSTOMER_RECORD_TYPE
    ]
    .Id;
    accTem.ACCL__Description_Language_1__c = accTem.Name;
    accTem.ACCL__Available_Product_Level__c = 'Category;Brand';
    return accTem;
  }

  /*
    Insert Single Customer Template
    Return: Account_Template__c
    */
  public static ACCL__Account_Template__c insertCustomerTemplate(Integer nameSuffix) {
    ACCL__Account_Template__c accTem = buildCustomerTemplate(nameSuffix);
    insert accTem;
    return accTem;
  }

  /*
    Build Default Customer Template
    Return: Account_Template__c
    */
  public static ACCL__Account_Template__c buildDefaultCustomerTemplate() {
    return buildCustomerTemplate(-1);
  }
  /*
    Return Default Customer Template
    */
  //Test_Methods_With_No_Assert – False Positive
  //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
  public static ACCL__Account_Template__c getDefaultCustomerTemplate() {
    if (defaultCustomerTemplate == null) {
      defaultCustomerTemplate = insertCustomerTemplate(-1);
    }
    return defaultCustomerTemplate;
  }
  /*
        Insert sales org specific customer template
        avineesh.k.mishra
    */
  public static ACCL__Account_Template__c insertCustomerTemplateWithSalesOrg(
    Integer nameSuffix
  ) {
    ACCL__Account_Template__c accTem = buildCustomerTemplate(nameSuffix);

    List<String> lstSalesOrg = AddOnUserTestFactory.getSalesOrg();
    accTem.ACCL__Sales_Org__c = lstSalesOrg[0];
    insert accTem;
    return accTem;
  }
  /*
    Account Template Build Method with Sales Org Parameter
    Return: Account_Template__c
    */
  public static ACCL__Account_Template__c buildCustomerTemplate(
    Integer nameSuffix,
    String salesOrg
  ) {
    ACCL__Account_Template__c accTem = new ACCL__Account_Template__c();
    accTem.Name = AddOnConstants.Name + nameSuffix;
    accTem.ACCL__Initial_Roles__c = 'customer';
    accTem.ACCL__Active__c = true;
    accTem.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE
        sObjectType = :ACCL__Account_Template__c.SObjectType.getDescribe().getName()
        AND DeveloperName = :AddOnConstants.CUSTOMER_RECORD_TYPE
    ]
    .Id;
    accTem.ACCL__Description_Language_1__c = accTem.Name;
    accTem.ACCL__Sales_Org__c = salesOrg;
    return accTem;
  }
  public static ACCL__Account_Template__c insertCustomerTemplate(
    Integer nameSuffix,
    String salesOrg
  ) {
    ACCL__Account_Template__c accTem = buildCustomerTemplate(nameSuffix, salesOrg);
    insert accTem;
    return accTem;
  }
  public static ACCL__Account_Template__c getDefaultAccountTemplateWithSalesOrg() {
    if (defaultAccountTemplateWithSalesOrg == null) {
      defaultAccountTemplateWithSalesOrg = insertCustomerTemplate(
        1,
        AddOnUserTestFactory.getSalesOrg()[0]
      );
      return defaultAccountTemplateWithSalesOrg;
    }
    return defaultAccountTemplateWithSalesOrg;
  }

  public static ACCL__Account_Template__c insertCustomerTemplateWithDefaultKpiSet(
    Integer nameSuffix
  ) {
    ACCL__Account_Template__c accTem = buildCustomerTemplate(nameSuffix);
    ACCL__Kpi_Set__c kpiSet = AddOnKpiSetTestFactory.insertDefaultKpiSetUsagePlan(
      AddOnConstants.NAME + nameSuffix,
      true
    );
    accTem.ACCL__Kpi_Set_Plan_Dependent__c = kpiSet.Id;

    insert accTem;
    return accTem;
  }
}