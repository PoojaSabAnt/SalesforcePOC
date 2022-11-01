/**
 * @description: This class createst test data for RateBasedFundingCalculationBatchTest
 */
public class RBFMassApprovalTestFactory {
  public static User systemAdmin;
  public static final String SALES_ORG = '0001';
  public static final String RESPARAM_GETMEASURES_RESPONSE = 'response';
  public static final String RESPONSE_GETMEASURES =
    '{"' +
    RESPARAM_GETMEASURES_RESPONSE +
    '":"success"}';

  public static String getLoggedInUserTimeZoneSidKey() {
    User loggedInUser = new User();
    loggedInUser = [
      SELECT TimeZoneSidKey
      FROM User
      WHERE id = :UserInfo.getUserId()
      LIMIT 1
    ];
    return loggedInUser.TimeZoneSidKey;
  }

  public static User buildUser(Integer i) {
    Profile p = [
      SELECT id
      FROM profile
      WHERE name = 'System Administrator'
      LIMIT 1
    ];
    String strUserTimeZoneSidKey = getLoggedInUserTimeZoneSidKey();
    User u = new User();
    u.FirstName = 'TestClass_Testing' + i;
    u.LastName = 'of Arendelle';
    u.Email = 'elsa@disney.com';
    u.Alias = 'elsa' + i;
    u.Username = 'TestClass_Testing' + i + '@disney.com';
    u.LocaleSidKey = 'en_US';
    u.TimeZoneSidKey = strUserTimeZoneSidKey;
    u.ProfileID = p.id;
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    return u;
  }

  public static ACCL__Sales_Organization__c getDefaultSalesOrg() {
    ACCL__Sales_Organization__c sOrg = new ACCL__Sales_Organization__c();
    sOrg.Name = '0001';
    sOrg.ACCL__Sales_Org_Value__c = '0001';
    sOrg.ACCL__Currency__c = 'USD';
    sOrg.ACCL__Default_Price_Type__c = 'Factory';
    sOrg.ACCL__Default_Price_List_Type__c = 'Direct Customers';
    sOrg.ACCL__Description_Language_1__c = '0001 (Engish)';
    sOrg.ACCL__Language_1__c = 'English';
    sOrg.ACCL__Enable_Auto_Tactic_Fund_Assignment__c = false;
    return sOrg;
  }

  public static void insertUserPermissionset(User user, String permissionSet) {
    if (systemAdmin == null) {
      systemAdmin = [
        SELECT id, name
        FROM User
        WHERE id = :Userinfo.getUserid()
      ];
    }
    System.runAs(systemAdmin) {
      PermissionSetAssignment psa = buildAssignUserPermissionset(
        user,
        permissionSet
      );
      if (psa != null) {
        insert psa;
      }
    }
  }

  public static PermissionSetAssignment buildAssignUserPermissionset(
    User user,
    String permissionSet
  ) {
    PermissionSetAssignment psa;
    if (systemAdmin == null) {
      systemAdmin = [
        SELECT id, name
        FROM User
        WHERE id = :Userinfo.getUserid()
      ];
    }
    try {
      System.runAs(systemAdmin) {
        PermissionSet ps = [
          SELECT Id
          FROM PermissionSet
          WHERE Name = :permissionSet
        ];
        psa = new PermissionSetAssignment(
          PermissionSetId = ps.Id,
          AssigneeId = user.id
        );
      }
    } catch (Exception e) {
      psa = null;
    }
    return psa;
  }

  public static ACCL__Account_Template__c getDefaultCustomerTemplate() {
    RecordType rt = getRecordType(
      ACCL__Account_Template__c.SObjectType.getDescribe().getName(),
      'Customer'
    );
    ACCL__Account_Template__c accTem = new ACCL__Account_Template__c();
    accTem.Name = 'Test Customer Template' + 3;
    accTem.ACCL__Initial_Roles__c = 'Customer';
    accTem.ACCL__Active__c = true;
    accTem.RecordTypeId = rt.Id;
    accTem.ACCL__Description_Language_1__c = 'Test Customer Template';
    accTem.ACCL__Sales_Org__c = '0001';
    insert accTem;
    return accTem;
  }

  public static Account getDefaultCustomer(ACCL__Account_Template__c accTem) {
    Account account = new Account();
    account.ACCL__Account_Template__c = accTem.Id;
    account.ACCL__City__c = 'Test City';
    account.ACCL__Street__c = 'Test Street';
    account.Name = 'Test Customer' + 3;
    account.ACCL__Name_2__c = 'Test Customer X' + 3;
    account.ACCL__ExternalId__c = 'ExtID_' + 'testCustomerX' + '_' + 3;
    insert account;
    return account;
  }

  public static ACCL__Account_Extension__c getDefaultCustomerExtension(
    Account account
  ) {
    ACCL__Account_Extension__c accExt = new ACCL__Account_Extension__c();
    accExt.ACCL__Account__c = account.id;
    accExt.ACCL__Fund_Role_Valid_From__c = System.Today();
    accExt.ACCL__Fund_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Bill_To_Role_Valid_From__c = System.Today();
    accExt.ACCL__Bill_To_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Broker_Role_Valid_From__c = System.Today();
    accExt.ACCL__Broker_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Customer_Role_Valid_From__c = System.Today();
    accExt.ACCL__Customer_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Delivery_Role_Valid_From__c = System.Today();
    accExt.ACCL__Delivery_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Order_Role_Valid_From__c = System.Today();
    accExt.ACCL__Order_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Payer_Role_Valid_From__c = System.Today();
    accExt.ACCL__Payer_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Promotion_Valid_From__c = System.Today();
    accExt.ACCL__Promotion_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Store_Role_Valid_From__c = System.Today();
    accExt.ACCL__Store_Role_Valid_Thru__c = System.Today().addDays(5);
    accExt.ACCL__Account_Plan_Type__c = 'Plan';
    insert accExt;
    return accExt;
  }
  public static ACCL__Rate_Based_Funding__c getDefaultRbf() {
    ACCL__RBF_Template__c rbfTemplate = getDefaultRbfTemplate();
    ACCL__Account_Template__c customerTemplate = getDefaultCustomerTemplate();
    Account customer = getDefaultCustomer(customerTemplate);
    ACCL__Account_Extension__c customerExt = getDefaultCustomerExtension(
      customer
    );

    ACCL__Rate_Based_Funding__c rbf = new ACCL__Rate_Based_Funding__c();
    rbf.ACCL__Account__c = customer.Id;
    rbf.ACCL__Active__c = true;
    rbf.ACCL__Fund_Anchor__c = 'RBF_Anchor';
    rbf.ACCL__Description__c = 'RBF Test';
    rbf.ACCL__Rate_Based_Funding_Template__c = rbfTemplate.Id;
    rbf.ACCL__Date_From__c = Date.today().addYears(-1);
    rbf.ACCL__Date_Thru__c = Date.today();
    return rbf;
  }

  public static ACCL__RBF_Template__c getDefaultRbfTemplate() {
    ACCL__Sales_Organization__c salesOrg = getDefaultSalesOrg();
    insert salesOrg;
    ACCL__Fund_Template__c fundTemplate = getDefaultFundTemplate();
    RecordType rt = getRecordType(
      ACCL__KPI_Definition__c.SObjectType.getDescribe().getName(),
      'read'
    );
    ACCL__KPI_Set__c kpiSet = getDefaultKpiSet();
    ACCL__KPI_Definition__c kpiDef = getDefaultKpiDefinition(rt);
    ACCL__KPI_Set_KPI_Definition__c kpiSetDefJunction = getKpiSetKpiDef(
      kpiSet,
      kpiDef
    );

    ACCL__RBF_Template__c rbfTemplate = new ACCL__RBF_Template__c();
    rbfTemplate.ACCL__Active__c = true;
    rbfTemplate.ACCL__KPI_Set__c = kpiSet.Id;
    rbfTemplate.Name = 'RBF Template Test';
    rbfTemplate.ACCL__RBF_Total_KPI__c = kpiDef.Id;
    rbfTemplate.ACCL__Anchor_Type__c = 'Customer';
    rbfTemplate.ACCL__Description_Language_1__c = 'Test';
    rbfTemplate.ACCL__Rate_Type__c = 'Percent of Revenue';
    rbfTemplate.ACCL__Sales_Org__c = salesOrg.Id;
    rbfTemplate.ACCL__Short_Code__c = '0001';
    rbfTemplate.ACCL__Sort__c = 1;
    rbfTemplate.ACCL__Fund_Template__c = fundTemplate.Id;
    insert rbfTemplate;
    return rbfTemplate;
  }

  public static ACCL__Fund_Template__c getDefaultFundTemplate() {
    ACCL__Fund_Template__c fundTemplate = new ACCL__Fund_Template__c();
    fundTemplate.Name = 'test' + (3);
    fundTemplate.ACCL__Active__c = true;
    fundTemplate.ACCL__Anchor_Type__c = 'Customer';
    fundTemplate.ACCL__Description_Language_1__c = 'English';
    fundTemplate.ACCL__Sort__c = 1;
    fundTemplate.ACCL__Sales_Org__c = '0001';
    insert fundTemplate;
    return fundTemplate;
  }

  public static ACCL__KPI_Set__c getDefaultKpiSet() {
    ACCL__KPI_Set__c kpiSet = new ACCL__KPI_Set__c();
    kpiSet.Name = 'Test RBF KPI Set';
    kpiSet.ACCL__Usage__c = 'Rate Based Funding';
    kpiSet.ACCL__Child_Object_Dependency__c = false;
    kpiSet.ACCL__Description_Language_1__c = 'Test KPI Set';
    insert kpiSet;
    return kpiSet;
  }

  public static ACCL__KPI_Definition__c getDefaultKpiDefinition(
    RecordType recordType
  ) {
    ACCL__KPI_Definition__c kpiDef = new ACCL__KPI_Definition__c();
    kpiDef.ACCL__Data_Source_Measure_Code__c = 'RBFR';
    kpiDef.ACCL__Description_Language_1__c = 'RateXBase';
    kpiDef.Name = 'RateXBase';
    kpiDef.RecordTypeId = recordType.Id;
    kpiDef.ACCL__Aggregation_Rule__c = 'Sum';
    kpiDef.ACCL__Total_Calculation_Rule__c = 'Sum';
    kpiDef.ACCL__Data_Source_Aggregation_Mode__c = 'Standard';
    kpiDef.ACCL__Data_Source_Table_Name__c = 'accountmeasure';
    kpiDef.ACCL__Data_Source_Monthly_Table_Name__c = 'accountmeasure';
	kpiDef.ACCL__BoM_Scope__c ='Product';
    insert kpiDef;
    return kpiDef;
  }

  public static ACCL__KPI_Set_KPI_Definition__c getKpiSetKpiDef(
    ACCL__KPI_Set__c kpiSet,
    ACCL__KPI_Definition__c kpiDef
  ) {
    ACCL__KPI_Set_KPI_Definition__c kpiSetKpiDef = new ACCL__KPI_Set_KPI_Definition__c();
    kpiSetKpiDef.ACCL__KPI_Definition__c = kpiDef.Id;
    kpiSetKpiDef.ACCL__KPI_Set__c = kpiSet.Id;
    kpiSetKpiDef.ACCL__Sort__c = 5;
    insert kpiSetKpiDef;
    return kpiSetKpiDef;
  }

  public static ACCL__Product_Template__c getDefaultProductTemplate() {
    ACCL__Product_Template__c productTemplate = new ACCL__Product_Template__c();
    productTemplate.Name = 'Test Product Template' + 3;
    productTemplate.ACCL__Description_Language_1__c =
      'Test Product Template' + 3;
    productTemplate.ACCL__Active__c = true;
    productTemplate.ACCL__Price_Required__c = true;
    productTemplate.ACCL__Sales_Org__c = '0001';
    insert productTemplate;
    return productTemplate;
  }

  public static ACCL__Product__c buildProduct(
    Integer nameSuffix,
    ACCL__Product_Template__c productTemplate
  ) {
    ACCL__Product__c product = new ACCL__Product__c();
    product.Name = 'Product ' + nameSuffix;
    product.ACCL__State__c = '4';
    product.ACCL__Description_1_Language_1__c =
      'Product Description' + nameSuffix;
    product.ACCL__Product_Code__c = 'ProductCode' + nameSuffix;
    product.ACCL__Product_Template__c = productTemplate.Id;
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

  public static RecordType getRecordType(
    String sobjectName,
    String developerName
  ) {
    if (sobjectName.countMatches('__') == 1) {
      sobjectName = 'ACCL__' + sobjectName;
    }
    RecordType rt = [
      SELECT Id
      FROM RecordType
      WHERE SobjectType = :sobjectName AND DeveloperName = :developerName
      LIMIT 1
    ];
    return rt;
  }
}