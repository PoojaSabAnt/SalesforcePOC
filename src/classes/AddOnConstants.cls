/** 
 * This class is used to define constant values for outside managed package.
 * @version  2017-01-13  creation 
 */
public with sharing class AddOnConstants {

    public static final String NAMESPACEPREFIX = 'ACCL__';
    // Developer name of Account recordtype
    public final static String CUSTOMER_RECORD_TYPE = 'Customer';
    //Distribution Relevant changes 
     // Status__c picklist values of object Call__c
    public final static String CALL_STATUS_UNSCHEDULED = 'Unscheduled';
    public final static String CALL_STATUS_PLANNED = 'Plan';
    public final static String CALL_STATUS_COMPLETED = 'Completed';
    public final static String CALL_STATUS_CANCELED = 'Canceled';
    public final static String CALL_STATUS_DENIED = 'Denied';
    public final static String ORDER_PHASE_CANCELLED = 'Canceled'; 
    public final static String ORDER_PHASE_RELEASED = 'Released';
    public final static String ORDER_PHASE_READY = 'Ready';
    public final static String ORDER_PHASE_INITIAL = 'Initial';
    public final static String DISTRIBUTION_RELEVANT='Distribution_Relevant__c';
    public final static String CALL_DISTRIBUTION_SETTING = 'CallDistributionSetting';
    public final static String ORDER_DISTRIBUTION_SETTING = 'OrderDistributionSetting';
    public final static String DISTRIBUTION_SETTING = 'CallOrderDistributionReorganization';
    public final static String ASSET_AUDIT_DISTRIBUTION_SETTING = 'AssetAuditDistributionSetting';
    public final static String DISTRIBUTION_INPUT = 'DistributionReorganizationInputView';
    public final static String DISTRIBUTION_BL = 'DistributionReorganizationExecution'; 
    
    /**** KAM Product Batch *****************/
    public final static String PRODUCT_LEVEL_PRODUCT ='Product';
    public final static String PRODUCT_LEVEL_PACKAGE ='Package';
    public final static String KAM_PRODUCTS = 'KAMProducts';

    /**** AccountManagerCreationBatch *****************/
    public final static String SUBSTITUTION = 'Substitution';
    public final static String ACCOUNT_MANAGER_SETTING = 'AccountManager';

    /**** InventoryTxBalanceCalculationBatch *****************/
    public final static String INVENTORY_TX_BALANCE = 'InventoryTxBalance';
    public final static String TRANSACTION_TYPE_BALANCE = 'Balance';
    public final static String TRANSACTION_CONTROL_NEUTRAL = 'Neutral';
    public final static String PRODUCT_TEMP_RECORD_TYPE ='Product';
    public final static String INVENTORY_CONTROL_TEMP_RECORD_TYPE ='Inventory';
    public final static String TRANSACTION_CONTROL_ADD = 'Add';
    public final static String TRANSACTION_CONTROL_WITHDRAW = 'Withdraw';
    public final static String TRANSACTION_TYPE_ADDITION = 'Addition';

    /**** Clean Promotion Attachment Batch *****************/
    public final static String CLEAR_ATTACHMENT = 'ClearPromotionAttachment';

    /**** Picklist Toggle Mapping Batch *****************/
    public final static String PICKLIST_ATTRIBUTES_MAPPING ='PicklistAttributesMapping';
    public final static String PICKLIST_ATTRIBUTES_CLEANUP ='PicklistAttributesCleanup';
    public final static String STRING_SPLIT='_@@_';

	/**** Account Effective Parent Clear Batch *****************/
	public final static String ACCOUNT_CLEAR_BATCH = 'AccountClearBatch';

    public static final String ACTIVITY_ACCOUNT_SET_BATCH = 'UpdateActivityAccountSetsBatch';
    public static final String ACTIVITY_PRODUCT_BATCH = 'UpdateActivityProductsBatch';
    public static final String DAILY_REPORT_TEMPLATE_ACTIVITY_BATCH = 'UpdateDailyReportTemplateActivitiesBatch';
    public static final String UPDATE_ORDER_TEMPLATE_BATCH = 'UpdateOrderTemplateBatch';
    public static final String SALES_ORG_USER_BATCH = 'UpdateSalesOrganizationUsersBatch';

    /** KPI Definition */
    public static final String KPI_DEFINITION_FIELDS_BATCH = 'BatchMigration_KPIDefinitionFields';

    // Phase__c picklist values of object Promotion__c
    public final Static String PROMOTION_PHASE_CANCELLED = 'Cancelled';

    /** Color Schemas in Trade Calendar */
    public static final String COLOR_SCHEMAS_PROMOTION_BATCH = 'BatchMigration_ColorSchemasInPromotion';
    public static final String COLOR_SCHEMAS_SALESORG_BATCH = 'BatchMigration_ColorSchemasInSalesOrg';

     /******* EffectiveAccountManagerSyncBatch ********/
    public final Static String ACCOUNT_MANAGER_TEAM_ROLE = 'AccountManager';
    Public final Static String STRING_NEW_LINE = '\n';
    Public final Static String STRING_COMMA = ',';
    Public final Static String ACCOUNT_SHARE_EDIT = 'Edit';
    Public final Static String EFFECTIVE_ACCOUNT_MANAGER_SYNC_BATCH = 'EffectiveAccountManagerSyncBatch';
    Public final Static String EFFECTIVE_ACCOUNT_PAR_SYNC_BATCH = 'EffectiveAccountParentSyncBatch';

	/******* GenerateJobListBatch ********/
    public final Static String JOB_LIST_DONE_STATUS_CANCELLED = '2';
    Public final Static String JOB_LIST_DONE_STATUS_DONE = '1';
    Public final Static String JOB_LIST_DONE_STATUS_NOT_DONE = '0';
    Public final Static String JOB_DEFINITION_LIST_USER_POLICY_ALL = 'All';
    Public final Static String JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN = 'OnlyMain';
    Public final Static String JOB_DEFINITION_LIST_USER_POLICY_FIRST = 'First';

    //Default Filter criteria value
   	public final static String DEFAULT_FILTER_CRITERIA = '{"manualproducts":null,"criteria":{}}';
	
	// Variable for DeveloperName
    Public final Static String DEVELOPERNAME = 'DeveloperName';
	
    // Names of the recordtypes for object 'KPI_Definition__c'
    public final Static String KPIDEFINITION_RECORD_TYPE_READ = 'Read';   

	// Name for any object inside test classes
    Public final Static String NAME = 'TestClass_Testing';
	
	// Developer names of the recordtypes for object 'Promotion__c'
    public final static String PROMOTION_RECORD_TYPE_PROMOTION = 'Promotion';

    // Phase__c picklist values of object Promotion__c
    Public final Static String PROMOTION_PHASE_PLANNING = 'Planning';
    public final static String PROMOTION_PHASE_COMMITTED = 'Committed';

    //Language Master Values enum to be used in test class
    Public Enum LANGUAGE{en,fr,es,de,it}

    //Picklist values for Usage of Promotion Template Hierarchy
    Public final Static String PRM_TEMP_HIERARCHY_PUSH = 'Push';
    Public final Static String PRM_TEMP_HIERARCHY_DERIVE = 'Derive';

	public final static String PROFILE_USER = 'ACSF_User_Profile';    
    
    public final static String FUND_STATUS_INITIAL = 'Initial';

    public static final Date MIN_DATE = Date.newInstance(1700, 1, 1);
    public static final Date MAX_DATE = Date.newInstance(4000, 12, 31);

    //Picklist values for Anchor Type in Order_Template__c
    public final static String ANCHOR_TYPE_CUSTOMER = 'Customer';

	/****** Global Describe *********/
    public static Map<String, Schema.SObjectType> allObjectMetadataTypes = Schema.getGlobalDescribe();
}