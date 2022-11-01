@isTest
private class AddOnTestFactoryUtilityTest {
  private static String salesOrg = AddOnUserTestFactory.getSalesOrg()[0];
  private static Date validFrom = System.today();
  private static Date validThru = System.today().addDays(5);

  @isTest
  private static void parseLOFundTest() {
    Map<String, Object> returnedFundObj;

    Account account = AddOnAccountTestFactory.buildAccount(1);
    ACCL__Account_Extension__c accountExtension = AddOnAccountExtensionTestFactory.buildAccountExtension(
      account,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru,
      validFrom,
      validThru
    );
    ACCL__Product_Template__c productTemplate = AddOnProductTemplateTestFactory.buildProductTemplateForProductRecordType(
      1
    );
    ACCL__Product__c product = AddOnProductTestFactory.buildProduct(
      1,
      productTemplate
    );
    ACCL__Fund_Template__c fundTemplate = AddOnFundTemplateTestFactory.buildFundTemplate(
      1,
      'Customer',
      1,
      salesOrg
    );
    ACCL__Fund__c fund = AddOnFundTestFactory.buildFund(
      accountExtension,
      product,
      fundTemplate,
      AddOnConstants.FUND_STATUS_INITIAL,
      validFrom,
      validThru
    );

    ACCL__Promotion__c promotion = AddOnPromotionTestFactory.buildDefaultPromotion();
    ACCL__Tactic_Template__c tacticTemplate = AddOnTacticTemplateTestFactory.buildDefaultTacticTemplate();
    List<ACCL__Tactic__c> tactics = AddOnTacticTestFactory.buildTactics(
      2,
      tacticTemplate,
      promotion
    );

    Test.startTest();
    returnedFundObj = AddOnTestFactoryUtility.parseLOFund(fund, tactics);
    Test.stopTest();

    System.assertEquals(2, returnedFundObj.size());
    System.assertEquals(fund.Id, returnedFundObj.get('Id'));
  }
  @isTest
  private static void parseLOExtPromotionCategoryShareTest() {
    List<Map<String, Object>> returnedLoExtPromotionCategoryShare;
    List<ACCL__Product__c> includedProducts = new List<ACCL__Product__c>();
    List<ACCL__Product__c> excludedProducts = new List<ACCL__Product__c>();

    ACCL__Product_Template__c productTemplate = AddOnProductTemplateTestFactory.buildProductTemplateForProductRecordType(
      1
    );

    ACCL__Product__c includedProduct1 = AddOnProductTestFactory.buildProduct(
      1,
      productTemplate
    );
    ACCL__Product__c includedProduct2 = AddOnProductTestFactory.buildProduct(
      2,
      productTemplate
    );
    includedProducts.add(includedProduct1);
    includedProducts.add(includedProduct2);

    ACCL__Product__c excludedProduct1 = AddOnProductTestFactory.buildProduct(
      3,
      productTemplate
    );
    ACCL__Product__c excludedProduct2 = AddOnProductTestFactory.buildProduct(
      4,
      productTemplate
    );
    ACCL__Product__c excludedProduct3 = AddOnProductTestFactory.buildProduct(
      5,
      productTemplate
    );
    excludedProducts.add(excludedProduct1);
    excludedProducts.add(excludedProduct2);
    excludedProducts.add(excludedProduct3);

    Test.startTest();
    returnedLoExtPromotionCategoryShare = AddOnTestFactoryUtility.parseLOExtPromotionCategoryShare(
      includedProducts,
      excludedProducts
    );
    Test.stopTest();

    System.assertEquals(5, returnedLoExtPromotionCategoryShare.size());
  }
  @isTest
  private static void parseBOPromotionNullTest() {
    ACCL__Promotion__c promotion = AddOnPromotionTestFactory.getDefaultPromotion();
    List<Map<String, Object>> loExtPromotionCategoryShare;
    List<Map<String, Object>> loExtPromotionAttachment;
    List<Map<String, Object>> loTactic;
    List<Map<String, Object>> loFund;
    String target = 'Test';
    Map<String, Object> returnedBOPromotion;

    Test.startTest();
    returnedBOPromotion = AddOnTestFactoryUtility.parseBOPromotion(
      promotion,
      loExtPromotionCategoryShare,
      loExtPromotionAttachment,
      loTactic,
      loFund,
      target
    );
    Test.stopTest();

    Map<String, Object> promotionObject = (Map<String, Object>) returnedBOPromotion.get(
      'BOPromotion'
    );

    System.assertEquals(2, returnedBOPromotion.size());
    System.assertEquals('Test', returnedBOPromotion.get('target'));
    System.assertEquals(
      new List<Map<String, Object>>(),
      promotionObject.get('LOExtPromotionCategoryShare')
    );
    System.assertEquals(
      new List<Map<String, Object>>(),
      promotionObject.get('LOExtPromotionAttachment')
    );
    System.assertEquals(
      new List<Map<String, Object>>(),
      promotionObject.get('LOTactic')
    );
    System.assertEquals(
      new List<Map<String, Object>>(),
      promotionObject.get('LOFund')
    );
  }
  @isTest
  private static void parseBOPromotionNotNullTest() {
    ACCL__Promotion__c promotion = AddOnPromotionTestFactory.getDefaultPromotion();

    ACCL__Product_Template__c productTemplate = AddOnProductTemplateTestFactory.buildProductTemplateForProductRecordType(
      1
    );
    ACCL__Product__c product = AddOnProductTestFactory.buildProduct(
      1,
      productTemplate
    );
    Map<String, Object> productObject = new Map<String, Object>();
    List<Map<String, Object>> loExtPromotionCategoryShare = new List<Map<String, Object>>();
    productObject.put('Id', product.Id);
    productObject.put('Selected', true);
    productObject.put('Enabled', true);
    productObject.put('Label', product.Name);
    loExtPromotionCategoryShare.add(productObject);

    List<Map<String, Object>> loExtPromotionAttachment = new List<Map<String, Object>>();
    List<Map<String, Object>> loTactic = new List<Map<String, Object>>();
    List<Map<String, Object>> loFund = new List<Map<String, Object>>();
    String target = 'Test';
    Map<String, Object> returnedBOPromotion;

    Test.startTest();
    returnedBOPromotion = AddOnTestFactoryUtility.parseBOPromotion(
      promotion,
      loExtPromotionCategoryShare,
      loExtPromotionAttachment,
      loTactic,
      loFund,
      target
    );
    Test.stopTest();

    Map<String, Object> promotionObject = (Map<String, Object>) returnedBOPromotion.get(
      'BOPromotion'
    );

    System.assertEquals(2, returnedBOPromotion.size());
    System.assertEquals('Test', returnedBOPromotion.get('target'));
    System.assertEquals(
      loExtPromotionCategoryShare,
      promotionObject.get('LOExtPromotionCategoryShare')
    );
    System.assertEquals(
      loExtPromotionAttachment,
      promotionObject.get('LOExtPromotionAttachment')
    );
    System.assertEquals(loTactic, promotionObject.get('LOTactic'));
    System.assertEquals(loFund, promotionObject.get('LOFund'));
  }
  @isTest
  private static void parseSObjectTest() {
    sObject objectToParse = (sObject) AddOnPromotionTestFactory.getDefaultPromotion();
    Integer objectStatus = 1;
    Map<String, Object> parseObject;

    Test.startTest();
    parseObject = AddOnTestFactoryUtility.parseSObject(
      objectToParse,
      objectStatus
    );
    Test.stopTest();

    System.assertEquals(1, parseObject.get('__ObjectStatus'));
  }
}