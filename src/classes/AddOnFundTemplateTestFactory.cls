@isTest
/**
 * Name          : AddOnFundTemplateTestFactory Addon Test Factory Class
 */
public with sharing class AddOnFundTemplateTestFactory {
  private static ACCL__Fund_Template__c defaultFundTemplate;
  private static ACCL__Fund_Template__c defaultFundTemplateWithSalesOrg;

  /**
   * Name          : buildFundTemplate
   */
  public static ACCL__fund_Template__c buildFundTemplate(
    Integer nameSuffix,
    String anchorType,
    Integer sortNumber,
    String salesOrg
  ) {
    ACCL__Fund_Template__c fundTemplate = new ACCL__Fund_Template__c();
    fundTemplate.Name = 'test' + nameSuffix;
    fundTemplate.ACCL__Active__c = true;
    fundTemplate.ACCL__Anchor_Type__c = anchorType;
    fundTemplate.ACCL__Description_Language_1__c = 'English';
    fundTemplate.ACCL__Sort__c = sortNumber;
    fundTemplate.ACCL__Sales_Org__c = salesOrg;
    return fundTemplate;
  }
  /**
   * Name          : buildDefaultFundTemplate
   * Description   : buildDefaultFundTemplate test class for createFundController
   * @author       : ankita.tukaram.parab@accenture.com
   * Date          : 03-May-2016
   */
  public static ACCL__Fund_Template__c buildDefaultFundTemplate() {
    return buildFundTemplate(-1, AddOnConstants.ANCHOR_TYPE_CUSTOMER, 1, null);
  }
  /**
   * Name          : insertFundTemplate
   * Description   : insertFundTemplate test class for createFundController
   * @author       : ankita.tukaram.parab@accenture.com
   * Date          : 03-May-2016
   */
  public static ACCL__Fund_Template__c insertFundTemplate(
    Integer nameSuffix,
    String anchorType,
    Integer sortNumber,
    String salesOrg
  ) {
    ACCL__Fund_Template__c fundTemplate = buildFundTemplate(
      nameSuffix,
      anchorType,
      sortNumber,
      salesOrg
    );
    insert fundTemplate;
    return fundTemplate;
  }
  /**
   * Name          : getDefaultFundTemplate
   * Description   : getDefaultFundTemplate test class for createFundController
   * @author       : ankita.tukaram.parab@accenture.com
   * Date          : 03-May-2016
   */
  public static ACCL__Fund_Template__c getDefaultFundTemplate() {
    if (defaultFundTemplate == null) {
      defaultFundTemplate = insertFundTemplate(
        -1,
        AddOnConstants.ANCHOR_TYPE_CUSTOMER,
        1,
        null
      );
    }
    return defaultFundTemplate;
  }

  public static ACCL__Fund_Template__c getDefaultFundTemplateWithSalesOrg() {
    if (defaultFundTemplateWithSalesOrg == null) {
      defaultFundTemplateWithSalesOrg = insertFundTemplate(
        -1,
        AddOnConstants.ANCHOR_TYPE_CUSTOMER,
        1,
        AddOnUserTestFactory.getDefaultSalesOrg()
      );
    }
    return defaultFundTemplateWithSalesOrg;
  }

  /**
   * Name          : buildFundTemplateList
   * Description   : buildFundTemplateList test class for createFundController
   * @author       : ankita.tukaram.parab@accenture.com
   * Date          : 03-May-2016
   */
  public static List<ACCL__Fund_Template__c> buildFundTemplateList(
    Integer noOfFundTemplate,
    String anchorType,
    Integer sortNumber,
    String salesOrg
  ) {
    List<ACCL__Fund_Template__c> listFundTemplate = new List<ACCL__Fund_Template__c>();
    for (Integer i = 0; i < noOfFundTemplate; i++) {
      listFundTemplate.add(
        buildFundTemplate(i, anchorType, sortNumber, salesOrg)
      );
    }
    return listFundTemplate;
  }
  /**
   * Name          : insertFundTemplates
   * Description   : insertFundTemplates test class for createFundController
   * @author       : ankita.tukaram.parab@accenture.com
   * Date          : 03-May-2016
   */

  public static List<ACCL__Fund_Template__c> insertFundTemplates(
    Integer noOfFundTemplate,
    String anchorType,
    Integer sortNumber,
    String salesOrg
  ) {
    List<ACCL__Fund_Template__c> fundTemplateList = buildFundTemplateList(
      noOfFundTemplate,
      anchorType,
      sortNumber,
      salesOrg
    );
    insert fundTemplateList;
    return fundTemplateList;
  }

  //Insert Fund Template With KPISet of Usage Funding
  public static ACCL__Fund_Template__c insertFundTemplateWithKPISet(
    Integer nameSuffix,
    String anchorType,
    Integer sortNumber,
    String salesOrg,
    Id KPISet
  ) {
    ACCL__Fund_Template__c ftemp = buildFundTemplate(
      nameSuffix,
      anchorType,
      sortNumber,
      salesOrg
    );
    ftemp.ACCL__KPI_Set__c = KPISet;
    insert ftemp;
    return ftemp;
  }
}