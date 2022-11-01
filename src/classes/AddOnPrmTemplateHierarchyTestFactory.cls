@isTest
public class AddOnPrmTemplateHierarchyTestFactory {
	public static ACCL__Promotion_Template_Hierarchy__c insertPromotionTemplateHierarchy(ACCL__Promotion_Template__c template, ACCL__Promotion_Template__c childTemplate){
		ACCL__Promotion_Template_Hierarchy__c promotionTemplateHierarchy = buildPromotionTemplateHierarchy( template,  childTemplate);
		insert promotionTemplateHierarchy;
		return promotionTemplateHierarchy;
	}
	
    public static ACCL__Promotion_Template_Hierarchy__c buildPromotionTemplateHierarchy(ACCL__Promotion_Template__c parentTemplate, ACCL__Promotion_Template__c childTemplate) {
        //FLS_Create, FLS_Create_Partial - False Positive
        //This class is used for unit test data creation and is used in other test classes. It will be executed in System context, hence no FLS/CRUD check is required.
        ACCL__Promotion_Template_Hierarchy__c hierarchy = new ACCL__Promotion_Template_Hierarchy__c();
		hierarchy.ACCL__Parent_Promotion_Template__c = parentTemplate.Id;
        hierarchy.ACCL__Child_Promotion_Template__c = childTemplate.Id;
        hierarchy.ACCL__Copied_Components__c = 'Tactics;Products;Notes';
        hierarchy.ACCL__Usage__c = 'Push';
        return hierarchy;
	}

	public static ACCL__Promotion_Template_Hierarchy__c buildPromotionTemplateHierarchy(ACCL__Promotion_Template__c parentTemplate, ACCL__Promotion_Template__c childTemplate, String usage) {
		ACCL__Promotion_Template_Hierarchy__c hierarchy = new ACCL__Promotion_Template_Hierarchy__c();
		hierarchy.ACCL__Parent_Promotion_Template__c = parentTemplate.Id;
        hierarchy.ACCL__Child_Promotion_Template__c = childTemplate.Id;
        hierarchy.ACCL__Copied_Components__c = 'Tactics;Products;Notes';
        hierarchy.ACCL__Usage__c = usage;
        return hierarchy;
	} 
}