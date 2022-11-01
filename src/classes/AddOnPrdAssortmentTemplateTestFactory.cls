@isTest
public class AddOnPrdAssortmentTemplateTestFactory{
    //Default Product_Assortment_Template__c
    public static ACCL__Product_Assortment_Template__c defaultProductAssortmentTemplate;
    /**This function is for building Product_Assortment_Template__c Data 
    *  @name buildProductAssortmentTemplate
    *  @param Integer: Name Suffix
    *  @return ACCL__Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c buildProductAssortmentTemplate(Integer nameSuffix) {
        //list<string> salesOrgList = UserTestFactory.getSalesOrg();
        //system.debug('salesOrgList**'+salesOrgList);
        ACCL__Product_Assortment_Template__c productAssortmentTemplate = new ACCL__Product_Assortment_Template__c();
        productAssortmentTemplate.Name='test'+nameSuffix; 
        productAssortmentTemplate.ACCL__Account_Multiplicity__c = 'n'; 
        productAssortmentTemplate.ACCL__Active__c = True;
        productAssortmentTemplate.ACCL__Description_Language_1__c = 'English';
        productAssortmentTemplate.ACCL__Sales_Org__c = AddOnUserTestFactory.getSalesOrg()[0];
        return productAssortmentTemplate;
    }
    /**This function is for building default  Product_Assortment_Template__c Data 
    *  @name buildDefaultProductAssortmentTemplate
    *  @param No Parameters
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c buildDefaultProductAssortmentTemplate() {
        return buildProductAssortmentTemplate(-1);
    }
    /**This function is for inserting Product_Assortment_Template__c Data 
    *  @name insertProductAssortmentTemplate
    *  @param Integer: Name Suffix
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c insertProductAssortmentTemplate(Integer nameSuffix){
        ACCL__Product_Assortment_Template__c productAssortmentTemp = buildProductAssortmentTemplate(nameSuffix);
        insert productAssortmentTemp;
        return productAssortmentTemp;
    }
    /**This function is for getting default Product_Assortment_Template__c Data 
    *  @name getDefaultproductAssortmentTemplate
    *  @param No parameters
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c getDefaultproductAssortmentTemplate() {
        if( defaultProductAssortmentTemplate == null ){
            defaultProductAssortmentTemplate = insertProductAssortmentTemplate(-1);
        }
        return defaultProductAssortmentTemplate;
    }
    /**This function is for building list of Product_Assortment_Template__c Data 
    *  @name buildProductAssortmentTemplates
    *  @param Integer: No of Records
    *  @return List of Product_Assortment_Template__c
    */
    public static List<ACCL__Product_Assortment_Template__c> buildProductAssortmentTemplates( Integer numberOfProductAssortmentTemplates ) {
    List<ACCL__Product_Assortment_Template__c> listProductAssortmentTemplates = new List<ACCL__Product_Assortment_Template__c>();
        for(Integer i=0 ; i < numberOfProductAssortmentTemplates ; i++){
          listProductAssortmentTemplates.add(buildProductAssortmentTemplate(i));
        }
        return listProductAssortmentTemplates;
    }
    /**This function is for inserting list of Product_Assortment_Template__c Data 
    *  @name insertProductAssortmentTemplates
    *  @param List of Product_Assortment_Template__c
    *  @return List of Product_Assortment_Template__c
    */
    public static List<ACCL__Product_Assortment_Template__c> insertProductAssortmentTemplates( List<ACCL__Product_Assortment_Template__c> productAssortmentTemplates){
        insert productAssortmentTemplates;
        return productAssortmentTemplates;
    }
    /**This function is for inserting list of Product_Assortment_Template__c Data 
    *  @name insertProductAssortmentTemplates
    *  @param Integer: No of Records
    *  @return List of Product_Assortment_Template__c
    */
    public static List<ACCL__Product_Assortment_Template__c> insertProductAssortmentTemplates( Integer numberOfProductAssortmentTemplates){
        List<ACCL__Product_Assortment_Template__c> productAssortmentTemplates = buildProductAssortmentTemplates(numberOfProductAssortmentTemplates);
        insert productAssortmentTemplates;
        return productAssortmentTemplates;
    }
    /**This function is for building Product_Assortment_Template__c with different Multiplicity
    *  @name buildProductAssortmentTemplateDynamicMultiplicity
    *  @param Integer: String: AccountMultiplicity
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c buildProductAssortmentTemplateDynamicMultiplicity(string AccountMultiplicity) {
        //list<string> salesOrgList = UserTestFactory.getSalesOrg();
        ACCL__Product_Assortment_Template__c productAssortmentTemplateBuild = new ACCL__Product_Assortment_Template__c();
        productAssortmentTemplateBuild.Name='test'; 
        productAssortmentTemplateBuild.ACCL__Account_Multiplicity__c = AccountMultiplicity; 
        productAssortmentTemplateBuild.ACCL__Active__c = True;
        productAssortmentTemplateBuild.ACCL__Description_Language_1__c = 'English';
        productAssortmentTemplateBuild.ACCL__Sales_Org__c = '0001';
        return productAssortmentTemplateBuild;
    }
    /**This function is for inserting Product_Assortment_Template__c with different Multiplicity
    *  @name insertProductAssortmentTemplateDynamicMultiplicity
    *  @param Integer: String: AccountMultiplicity
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c insertProductAssortmentTemplateDynamicMultiplicity(String AccountMultiplicity){
        ACCL__Product_Assortment_Template__c productAssortmentTemplate= buildProductAssortmentTemplateDynamicMultiplicity(AccountMultiplicity);
        insert productAssortmentTemplate;
        return productAssortmentTemplate;
    }
    /**This function is for inserting Product_Assortment_Template__c with Account multiplicity Exactly One
    *  @name insertProductAssortmentTemplateWithRecordTypeId
    *  @param null
    *  @return Product_Assortment_Template__c
    */
    public static ACCL__Product_Assortment_Template__c insertProductAssortmentTemplateWithRecordTypeId(){
        ACCL__Product_Assortment_Template__c productAssortmentTemplate= new ACCL__Product_Assortment_Template__c();
        productAssortmentTemplate.Name='test'; 
        productAssortmentTemplate.ACCL__Account_Multiplicity__c = 'Exactly One'; 
        productAssortmentTemplate.ACCL__Active__c = True;
        productAssortmentTemplate.ACCL__Description_Language_1__c = 'English';
        productAssortmentTemplate.RecordTypeId =Schema.SObjectType.ACCL__Product_Assortment_Template__c.getRecordTypeInfosByName().get('Assortment List').getRecordTypeId();
        productAssortmentTemplate.ACCL__Sales_Org__c = AddOnUserTestFactory.getSalesOrg()[0];
        insert productAssortmentTemplate;
        return productAssortmentTemplate;
    }
}