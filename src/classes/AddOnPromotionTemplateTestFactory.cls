//FLS_Create, FLS_Create_Partial, FLS_Update, FLS_Update_Partial - False Positive
//This is a test data generation class and must be accessed in system context. No CRUD permission check is required.
public class AddOnPromotionTemplateTestFactory {
    
    public static ACCL__Promotion_Template__c defaultPromotionTemplate;
    public static ACCL__Promotion_Template__c defaultAccountSetPromotionTemplate;
    public static String theSalesOrg;
    public static final String SALES_ORG = '0001';
    
    public static ACCL__Promotion_Template__c insertPromotionTemplateWithSalesOrg(Integer nameSuffix, String salesOrg){
        ACCL__Promotion_Template__c promotionTemplate = buildPromotionTemplate(nameSuffix);
        promotionTemplate.ACCL__Sales_org__c = salesOrg;
        promotionTemplate.ACCL__UI_Type__c = 'SmartUI';
        insert promotionTemplate;
        return promotionTemplate;
    }
    public static ACCL__Promotion_Template__c getDefaultPromotionTemplate() {
        if( defaultPromotionTemplate == null ){
            defaultPromotionTemplate = insertPromotionTemplate( -1 );
        }
        return defaultPromotionTemplate;
    }
    
    public static ACCL__Promotion_Template__c insertPromotionTemplate(Integer nameSuffix){
        ACCL__Promotion_Template__c promotionTemplate = buildPromotionTemplate(nameSuffix);
        insert promotionTemplate;
        return promotionTemplate;
    }
    
    public static ACCL__Promotion_Template__c getDefaultAccountSetPromotionTemplate() {
        if( defaultAccountSetPromotionTemplate == null ){
            defaultAccountSetPromotionTemplate = insertAccountSetPromotionTemplate( -1 );
        }
        return defaultAccountSetPromotionTemplate;
    }
    
    public static ACCL__Promotion_Template__c insertAccountSetPromotionTemplate(Integer nameSuffix){
        ACCL__Promotion_Template__c promotionTemplate = buildCustomerSetPromotionTemplate(nameSuffix);
        insert promotionTemplate;
        return promotionTemplate;
    } 
    
    public static ACCL__Promotion_Template__c buildCustomerSetPromotionTemplate(Integer nameSuffix) {
        ACCL__Promotion_Template__c promotionTemplate = buildPromotionTemplateInternal(nameSuffix);
        promotionTemplate.ACCL__Anchor_Type__c = 'CustomerSet';
        return promotionTemplate;
    }
    
    public static ACCL__Promotion_Template__c buildPromotionTemplate(Integer nameSuffix) {
        ACCL__Promotion_Template__c promotionTemplate = buildPromotionTemplateInternal(nameSuffix);
        promotionTemplate.ACCL__Anchor_Type__c = 'Customer';
        return promotionTemplate;
    }
    
    private static ACCL__Promotion_Template__c buildPromotionTemplateInternal(Integer nameSuffix) {
        ACCL__Promotion_Template__c promotionTemplate = new ACCL__Promotion_Template__c();
        promotionTemplate.Name = 'test'+nameSuffix; 
        promotionTemplate.ACCL__Description_Language_1__c = 'lan'+nameSuffix;
        promotionTemplate.ACCL__Active__c = true;
        promotionTemplate.ACCL__Active_Policy__c= true;
        promotionTemplate.ACCL__Consider_Listing__c= true;
        promotionTemplate.ACCL__Creation_Platform__c= 'Laptop';
        promotionTemplate.ACCL__Display_In_call__c= true;
        promotionTemplate.ACCL__Mobility_Color__c= 'White';
        promotionTemplate.ACCL__Sort__c= 1;
        promotionTemplate.ACCL__Promotion_Type__c = AddOnConstants.PROMOTION_RECORD_TYPE_PROMOTION;
        promotionTemplate.ACCL__Product_Definition_Level__c = 'Tactic';
        promotionTemplate.ACCL__Product_Definition_Policy__c = 'Dynamic';
        promotionTemplate.ACCL__Is_Derivable__c = false;
        return promotionTemplate;
    }
    
    public static List<ACCL__Promotion_Template__c> buildPromotionTemplates( Integer numberOfPromotionTemplates ) {
        List<ACCL__Promotion_Template__c> promotionTemplates = new List<ACCL__Promotion_Template__c>();
        for(Integer i=0 ; i < numberOfPromotionTemplates ; i++){
            promotionTemplates.add(buildPromotionTemplate(i));
        }
        return promotionTemplates;
    } 
    
    public static ACCL__Promotion_Template__c getDefaultPromotionTemplateWithSalesOrg() {
        return getDefaultPromotionTemplateWithSalesOrg(AddOnUserTestFactory.getSalesOrg()[0], 1);
    }

    public static ACCL__Promotion_Template__c getDefaultPromotionTemplateWithSalesOrg(String salesOrg, Integer nameSuffix) {
        if(defaultPromotionTemplate == null || salesOrg != theSalesOrg){
            defaultPromotionTemplate = insertPromotionTemplateWithSalesOrg(nameSuffix,salesOrg );
            theSalesOrg = salesOrg;
        }
        return defaultPromotionTemplate;
    }
}