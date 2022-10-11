@isTest
public with sharing class AddOnKpiSetTestFactory {
  public static final String USAGE_PLAN = 'Plan';
  public static final String USAGE_PROMOTION = 'Promotion';
  public static final String USAGE_FUNDING = 'Funding';
  public static final String USAGE_PAYMENT = 'Payment';
  public static final String USAGE_RBF = 'Rate Based Funding';
  public static final String USAGE_REPORTING = 'Reporting';
  private static ACCL__KPI_Set__c defaultKPISetFunding;
  private static ACCL__KPI_Set__c defaultKPISetPayment;
  private static ACCL__KPI_Set__c defaultKPISetRBF;

  public static ACCL__KPI_Set__c buildKpiSet(
    String name,
    String usage,
    Boolean childObjectDependency,
    String descLang1
  ) {
    ACCL__KPI_Set__c kpiSet = new ACCL__KPI_Set__c();
    kpiSet.Name = name;
    kpiSet.ACCL__Usage__c = usage;
    kpiSet.ACCL__Child_Object_Dependency__c = childObjectDependency;
    kpiSet.ACCL__Description_Language_1__c = descLang1;
    return kpiSet;
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSet() {
    return buildKpiSet('test1', USAGE_PROMOTION, false, '');
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSet(String name) {
    return buildKpiSet(name, USAGE_PROMOTION, false, '');
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSetUsagePlan(String name) {
    return buildKpiSet(name, USAGE_PLAN, false, '');
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSetUsagePromotion(String name) {
    return buildKpiSet(name, USAGE_PROMOTION, false, '');
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSetUsagePlan(
    String name,
    Boolean childObjectDependency
  ) {
    return buildKpiSet(name, USAGE_PLAN, childObjectDependency, '');
  }

  //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
  public static ACCL__KPI_Set__c buildDefaultKpiSetUsagePromotion(
    String name,
    Boolean childObjectDependency
  ) {
    return buildKpiSet(name, USAGE_PROMOTION, childObjectDependency, '');
  }

  public static ACCL__KPI_Set__c buildAndInsertDefaultKpiSet() {
    ACCL__KPI_Set__c kpiSet = buildDefaultKpiSet();
    insert kpiSet;
    return kpiSet;
  }

  public static ACCL__KPI_Set__c getDefaultKPISet() {
    //code review

    return buildAndInsertDefaultKpiSet();
  }

  //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
  public static List<ACCL__KPI_Set__c> buildListDefaultKpiSet(
    Integer numberOfKpiSets
  ) {
    List<ACCL__KPI_Set__c> kpisets = new List<ACCL__KPI_Set__c>();
    for (Integer i = 0; i < numberOfKpiSets; i++) {
      kpisets.add(buildDefaultKpiSet('test' + i));
    }
    return kpisets;
  }

  public static ACCL__Kpi_Set__c insertDefaultKpiSetUsagePlan(
    String name,
    Boolean childObjectDependency
  ) {
    ACCL__KPI_Set__c kpiSet = buildDefaultKpiSetUsagePlan(
      name,
      childObjectDependency
    );
    insert kpiSet;
    return kpiSet;
  }

  //Method to build KPI set with usage funding
  public static ACCL__KPI_Set__c buildDefaultKpiSetUsageFunding(
    String name,
    Boolean childObjectDependency,
    String description
  ) {
    return buildKpiSet(name, USAGE_FUNDING, childObjectDependency, description);
  }
  // Method to insert KPI set with usage funding
  public static ACCL__KPI_Set__c getDefaultKPISetUsageFunding() {
    if (defaultKPISetFunding == null) {
      defaultKPISetFunding = buildDefaultKpiSetUsageFunding(
        'Test-FundingPlan',
        false,
        'Test-FundingPlan'
      );
      insert defaultKPISetFunding;
    }
    return defaultKPISetFunding;
  }
  //Method to build KPI set with usage Payment
  public static ACCL__KPI_Set__c buildDefaultKpiSetUsagePayment(
    String name,
    Boolean childObjectDependency,
    String description
  ) {
    return buildKpiSet(name, USAGE_PAYMENT, childObjectDependency, description);
  }
  // Method to insert KPI set with usage Payment
  public static ACCL__KPI_Set__c getDefaultKPISetUsagePayment() {
    if (defaultKPISetPayment == null) {
      defaultKPISetPayment = buildDefaultKpiSetUsagePayment(
        'Test-FundingPlan',
        false,
        'Test-FundingPlan'
      );
      insert defaultKPISetPayment;
    }
    return defaultKPISetPayment;
  }

  //Method to build KPI set with usage Payment
  public static ACCL__KPI_Set__c buildDefaultKpiSetUsageRBF(
    String name,
    Boolean childObjectDependency,
    String description
  ) {
    return buildKpiSet(name, USAGE_RBF, childObjectDependency, description);
  }
  // Method to insert KPI set with usage Payment
  public static ACCL__KPI_Set__c getDefaultKPISetUsageRBF() {
    if (defaultKPISetRBF == null) {
      defaultKPISetRBF = buildDefaultKpiSetUsageRBF(
        'Test-FundingPlan',
        false,
        'Test-FundingPlan'
      );
      insert defaultKPISetRBF;
    }
    return defaultKPISetRBF;
  }

  public static ACCL__KPI_Set__c buildDefaultKpiSetUsageReporting(String name) {
    return buildKpiSet(name, USAGE_REPORTING, false, '');
  }
}