@isTest
public class AddOnPromotionTestFactory {
    //FLS_Create, FLS_Create_Partial
    //This class is used for unit test data creation and is used in other test classes. It will be executed in System context, hence no FLS/CRUD check is required.
    public static ACCL__Promotion__c defaultPromotion;
    public static ACCL__Promotion__c defaultPromotionWithSalesOrg;

    public static ACCL__Promotion__c insertPromotion(Integer i, ACCL__Promotion_Template__c template, Account account, String phase){
        return (ACCL__Promotion__c)AddOnTestFactoryUtility.insertSObject(buildPromotion(i, template,  account, Phase));
    }

    public static ACCL__Promotion__c insertPromotion(Integer i, ACCL__Promotion_Template__c template, ACCL__Account_Set__c accountset, String phase){
        return (ACCL__Promotion__c)AddOnTestFactoryUtility.insertSObject(buildPromotion(i, template,  accountset, phase));
    }

        public static ACCL__Promotion__c buildPromotion(Integer nameSuffix, ACCL__Promotion_Template__c template, Account account, String phase) {
        return buildPromotion(nameSuffix, template, account, null, phase, true, System.today(), System.today().addYears(1));
    }

    public static ACCL__Promotion__c buildPromotion(Integer nameSuffix, ACCL__Promotion_Template__c template, ACCL__Account_Set__c accountset, String phase) {
        return buildPromotion(nameSuffix, template, null, accountset, phase, true, System.today(), System.today().addYears(1));
    }
        public static ACCL__Promotion__c buildPromotion(Integer nameSuffix, ACCL__Promotion_Template__c template,
                                              Account account, ACCL__Account_Set__c accountSet, String phase,
                                              Boolean active, Date dateFrom, Date dateThru) {
        return buildPromotion(nameSuffix, template, account, accountSet, phase, active, dateFrom, dateThru, null, null);
    }

    public static ACCL__Promotion__c buildPromotion(Integer nameSuffix, ACCL__Promotion_Template__c template, Account account, ACCL__Account_Set__c accountSet, String phase,
                                              Boolean active, Date dateFrom, Date dateThru, String slogan, String groupText) {
        ACCL__Promotion__c promotion = new ACCL__Promotion__c();
        promotion.ACCL__Active__c = active;
        promotion.ACCL__Anchor_Account__c = account != null ? account.Id : null;
        promotion.ACCL__Anchor_Account_Set__c = accountSet != null ? accountSet.Id : null;
        promotion.ACCL__Commit_Date__c = dateFrom;
        promotion.ACCL__Promotion_Template__c = template != null ? template.Id : AddOnPromotionTemplateTestFactory.getDefaultAccountSetPromotionTemplate().Id;
        promotion.ACCL__Date_From__c = dateFrom;
        promotion.ACCL__Date_Thru__c = dateThru;
        promotion.ACCL__Delivery_Date_From__c = promotion.ACCL__Date_From__c;
        promotion.ACCL__Delivery_Date_Thru__c = promotion.ACCL__Date_From__c.addDays(30);
        promotion.ACCL__Order_Date_From__c = promotion.ACCL__Date_From__c;
        promotion.ACCL__Order_Date_Thru__c = promotion.ACCL__Date_Thru__c;
        promotion.ACCL__Placement_Date_From__c = promotion.ACCL__Date_From__c;
        promotion.ACCL__Placement_Date_Thru__c = promotion.ACCL__Date_Thru__c;
        promotion.ACCL__Slogan_Language_1__c = (slogan != null) ? slogan : ('slogan '+nameSuffix);
        promotion.ACCL__Group_Text_Language_1__c = groupText;
        promotion.ACCL__Phase__c=phase;
        promotion.ACCL__Relevant_For_Account_Plan__c = true;
        return promotion;
    }

    public static List<ACCL__Promotion__c> buildPromotions( Integer numberOfPromotions ) {
        List<ACCL__Promotion__c> promotions = new List<ACCL__Promotion__c>();
        for(Integer i=0 ; i < numberOfPromotions ; i++){
            promotions.add(buildPromotion(i,AddOnPromotionTemplateTestFactory.getDefaultPromotionTemplate(),AddOnAccountTestFactory.getDefaultAccount(),AddOnConstants.PROMOTION_PHASE_PLANNING));
        }
        return promotions;
    }    

    public static ACCL__Promotion__c buildDefaultPromotion() {
        return buildPromotion(-1,AddOnPromotionTemplateTestFactory.getDefaultPromotionTemplate(),AddOnAccountTestFactory.getDefaultAccount(),AddOnConstants.PROMOTION_PHASE_PLANNING);
    }

    public static ACCL__Promotion__c getDefaultPromotion() {
        if( defaultPromotion == null ){
            defaultPromotion = insertPromotion(-1, AddOnPromotionTemplateTestFactory.getDefaultPromotionTemplate(),AddOnAccountTestFactory.getDefaultAccount(),AddOnConstants.PROMOTION_PHASE_PLANNING);
        }
        return defaultPromotion;
    }
}