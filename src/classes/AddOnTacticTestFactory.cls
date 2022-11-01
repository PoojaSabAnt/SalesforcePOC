@isTest
public class AddOnTacticTestFactory {
    public AddOnTacticTestFactory() {
    }

    public static ACCL__Tactic__c defaultTactic;
    public static ACCL__Tactic__c defaultTacticWithSalesOrg;

    public static ACCL__Tactic__c getDefaultTactic() {
        if( defaultTactic == null ){
            defaultTactic = insertDefaultTactic();
        }
        return defaultTactic;
    }

    public static ACCL__Tactic__c insertDefaultTactic() {
        ACCL__Tactic__c tactic = buildDefaultTactic();
        return (ACCL__Tactic__c) AddOnTestFactoryUtility.insertSObject(tactic);
    }

    public static ACCL__Tactic__c buildDefaultTactic() {
        return buildTactic(AddOnPromotionTestFactory.getDefaultPromotion(), AddOnTacticTemplateTestFactory.getDefaultTacticTemplate());
    }
 
    public static ACCL__Tactic__c buildTactic(ACCL__Promotion__c promotion, ACCL__Tactic_Template__c tacticTemplate) {

        ACCL__Tactic__c tactic = new ACCL__Tactic__c();
        tactic.ACCL__Tactic_Template__c = tacticTemplate.id;
        tactic.ACCL__Promotion__c=promotion.id;
        tactic.ACCL__Date_From__c=System.today();
        tactic.ACCL__Date_Thru__c=System.today().addMonths(1);
        tactic.ACCL__Scenario_Participation__c = 1;
        tactic.ACCL__Lift_Type__c = '%';
        tactic.ACCL__Amount__c = 10;

        return tactic;

    }

    //method for inserting Tactic for PromotionFindingTest class
    public static ACCL__Tactic__c insertTactic(ACCL__Promotion__c promotion,ACCL__Tactic_Template__c tacticTemplate) {

        ACCL__Tactic__c tactic = buildTactic(promotion, tacticTemplate);
        return (ACCL__Tactic__c) AddOnTestFactoryUtility.insertSObject(tactic);

    }

    public static List<ACCL__Tactic__c> insertTactics(Integer numTactics, ACCL__Tactic_Template__c tacticTemplate, ACCL__Promotion__c promo){
        List<ACCL__Tactic__c> tacticList = buildTactics(numTactics, tacticTemplate, promo);
        return (List<ACCL__Tactic__c>) AddOnTestFactoryUtility.insertBulkSObject(tacticList);
    }

    public static List<ACCL__Tactic__c> buildTactics(Integer numTactics, ACCL__Tactic_Template__c tacticTemplate, ACCL__Promotion__c promo){
        List<ACCL__Tactic__c> tacticList = new List<ACCL__Tactic__c>();
        for(Integer i = 0; i<numTactics;i++){
            tacticList.add(buildTactic(promo, tacticTemplate));
        }
        return tacticList;
    }

    public static List<ACCL__Tactic__c> buildInsertTactics(Integer numTactics, ACCL__Tactic_Template__c tacticTemplate, List<ACCL__Promotion__c> promos){
        List<ACCL__Tactic__c> tacticList = new List<ACCL__Tactic__c>();
        for(Integer i = 0; i<numTactics;i++){
            tacticList.add(buildTactic(promos[i], tacticTemplate));
        }
        return (List<ACCL__Tactic__c>) AddOnTestFactoryUtility.insertBulkSObject(tacticList);
    }

    public static List<ACCL__Tactic__c> buildInsertTactics(Integer numTactics, ACCL__Tactic_Template__c tacticTemplate, ACCL__Promotion__c promo){
        List<ACCL__Tactic__c> tacticList = new List<ACCL__Tactic__c>();
        for(Integer i = 0; i<numTactics;i++){
            tacticList.add(buildTactic(promo, tacticTemplate));
        }
        return (List<ACCL__Tactic__c>) AddOnTestFactoryUtility.insertBulkSObject(tacticList);
    }

}