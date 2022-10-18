@isTest
public class AddOnTacticTemplateTestFactory {
    public AddOnTacticTemplateTestFactory() {
    }
    
    public static ACCL__Tactic_Template__c defaultTacticTemplate;
    public static String theSalesOrg;
    
    public static ACCL__Tactic_Template__c getDefaultTacticTemplate() {
        if( defaultTacticTemplate == null ){
          defaultTacticTemplate = insertDefaultTacticTemplate( );
        }
        return defaultTacticTemplate;
    }
    
    public static ACCL__Tactic_Template__c insertDefaultTacticTemplate() {
        ACCL__Tactic_Template__c tctMeta = buildDefaultTacticTemplate();
        insert tctMeta;
        return tctMeta;
    }
    
    public static ACCL__Tactic_Template__c buildDefaultTacticTemplate() {
        return buildTacticTemplate(true, 'Display');
    }
    
    public static ACCL__Tactic_Template__c buildTacticTemplate(Boolean active, String tacticType) {
        ACCL__Tactic_Template__c tctMeta = new ACCL__Tactic_Template__c();
        tctMeta.ACCL__Active__c = active;
        tctMeta.ACCL__Tactic_Type__c = tacticType;
        tctMeta.ACCL__Default_Lift_Type__c = 'Percentage';
        tctMeta.ACCL__Possible_Lift_Types__c = 'Percentage';
        Return tctMeta;
    }
    
    //Test Methods With No Assert - This method creates test factory data, Assert is not needed - False Positive
    public static ACCL__Tactic_Template__c buildAndInsertTacticTemplate() {
        ACCL__Tactic_Template__c tctMeta = buildDefaultTacticTemplate();
        insert tctMeta;
        return tctMeta;
    }
    
    public static ACCL__Tactic_Template__c buildTacticTemplateWithSalesOrg(Boolean active, String tacticType) {
        ACCL__Tactic_Template__c tctMeta = new ACCL__Tactic_Template__c();
        tctMeta.ACCL__Active__c = active;
        tctMeta.ACCL__Tactic_Type__c = tacticType;
        tctMeta.ACCL__Default_Lift_Type__c = 'Percentage';
        tctMeta.ACCL__Possible_Lift_Types__c = 'Percentage';
        tctMeta.ACCL__Sales_Org__c = AddOnUserTestFactory.getSalesOrg()[0];
        Return tctMeta;
    }
    
    public static ACCL__Tactic_Template__c insertDefaultTacticTemplateWithSalesOrg(String salesOrg) {
        ACCL__Tactic_Template__c tctMeta = buildTacticTemplateWithSalesOrg(true, 'Display');
        tctMeta.ACCL__Sales_Org__c = salesOrg;
        insert tctMeta;
        return tctMeta;
    }
    
    public static ACCL__Tactic_Template__c getDefaultTacticTemplateWithSalesOrg(String salesOrg) {
        if( defaultTacticTemplate == null || salesOrg != theSalesOrg){
          defaultTacticTemplate = insertDefaultTacticTemplateWithSalesOrg(salesOrg); 
            theSalesOrg = salesOrg;
        }
        return defaultTacticTemplate;
    }


    public static ACCL__Tactic_Template__c insertDefaultTacticTemplateWithSalesOrg() {
        ACCL__Tactic_Template__c tctMeta = buildTacticTemplateWithSalesOrg(true, 'Display');
        insert tctMeta;
        return tctMeta;
    }

    public static ACCL__Tactic_Template__c getDefaultTacticTemplateWithSalesOrg() {
        return getDefaultTacticTemplateWithSalesOrg(AddOnUserTestFactory.getSalesOrg()[0]);
        }
    
}