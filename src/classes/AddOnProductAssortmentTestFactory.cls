@isTest
public class AddOnProductAssortmentTestFactory{
    public static ACCL__Product_Assortment__c defaultProductAssortment;
    public static ACCL__Product_Assortment__c defaultProductAssortmentQueried;
    public static ACCL__Product_Assortment__c buildProductAssortment(Integer nameSuffix,ACCL__Product_Assortment_Template__c productAssortmentTemplate) {
        ACCL__Product_Assortment__c productAssortment = new ACCL__Product_Assortment__c();
        productAssortment.Name= AddOnConstants.Name+nameSuffix;
        productAssortment.ACCL__Product_Assortment_Template__c = productAssortmentTemplate.id; 
        productAssortment.ACCL__Valid_From__c = System.today();
        productAssortment.ACCL__Valid_Thru__c = System.today().addYears(1);
        productAssortment.ACCL__Description_Language_1__c='English';
        productAssortment.ACCL__Version__c = 0;
        productAssortment.ACCL__Version_Off_Platform_APL__c = 0;
        return productAssortment;
    }
    public static ACCL__Product_Assortment__c buildDefaultProductAssortment() {
        return buildProductAssortment(-1,AddOnPrdAssortmentTemplateTestFactory.getDefaultproductAssortmentTemplate());
    }
    public static ACCL__Product_Assortment__c insertProductAssortment(integer i,ACCL__Product_Assortment_Template__c productAssortmentTemplate) {
        ACCL__Product_Assortment__c productAssortment = buildProductAssortment(i,productAssortmentTemplate);
        insert productAssortment;       
        return productAssortment;
    }
    public static ACCL__Product_Assortment__c getDefaultProductAssortment() {
        if( defaultProductAssortment == null ){
            defaultProductAssortment = insertProductAssortment(-1,AddOnPrdAssortmentTemplateTestFactory.getDefaultproductAssortmentTemplate());            
            defaultProductAssortmentQueried = [select id, ACCL__sales_org__c,Name,ACCL__Product_Assortment_Template__c,
                                               ACCL__Valid_From__c,ACCL__Valid_Thru__c,ACCL__Description_Language_1__c
                                               from ACCL__Product_Assortment__c where id =:defaultProductAssortment.id];
        }
        return defaultProductAssortmentQueried;
    }
    public static List<ACCL__Product_Assortment__c> buildProductAssortments( List<ACCL__Product_Assortment_Template__c> lstproductAssortmentTemplates) {
        List<ACCL__Product_Assortment__c> productAssortments = new List<ACCL__Product_Assortment__c>();
        for(integer i=0; i < lstproductAssortmentTemplates.size(); i++){
            productAssortments.add(buildProductAssortment(i,lstproductAssortmentTemplates[i]));
        }
        return productAssortments;
    }
    public static List<ACCL__Product_Assortment__c> insertProductAssortments(List<ACCL__Product_Assortment_Template__c> lstproductAssortmentTemplates) {
        List<ACCL__Product_Assortment__c> productAssortments=buildProductAssortments(lstproductAssortmentTemplates); 
        insert productAssortments;
        return productAssortments;
    }
    public static ACCL__Product_Assortment__c getProductAssortmentWithValidRange(Date validFrom,Date validThru,ACCL__Product_Assortment_Template__c productAssortmentTemplate){
        ACCL__Product_Assortment__c productAssortment = new ACCL__Product_Assortment__c();
        productAssortment.Name= AddOnConstants.Name;
        productAssortment.ACCL__Product_Assortment_Template__c = productAssortmentTemplate.id; 
        productAssortment.ACCL__Valid_From__c = validFrom;
        productAssortment.ACCL__Valid_Thru__c = validThru;
        productAssortment.ACCL__Description_Language_1__c='English';
        insert productAssortment;
        return productAssortment;
    }
    public static ACCL__Product_Assortment__c getProductAssortmentDuplicate(String productAssortmentName,Date validFrom,Date validThru,ACCL__Product_Assortment_Template__c productAssortmentTemplate) {
        ACCL__Product_Assortment__c productAssortment = new ACCL__Product_Assortment__c();
        productAssortment.Name=productAssortmentName;
        productAssortment.ACCL__Product_Assortment_Template__c = productAssortmentTemplate.id; 
        productAssortment.ACCL__Valid_From__c = validFrom;
        productAssortment.ACCL__Valid_Thru__c = validThru;
        productAssortment.ACCL__Description_Language_1__c='English';
        return productAssortment;    
    }
    //Listing Finding
    public static ACCL__Product_Assortment__c getProductAssortmentWithValidRangeForListing(Date validFrom,Date validThru,ACCL__Product_Assortment_Template__c productAssortmentTemplate,Boolean Obligatory){
        ACCL__Product_Assortment__c productAssortment = new ACCL__Product_Assortment__c();
        productAssortment.Name = AddOnConstants.Name;
        productAssortment.ACCL__Product_Assortment_Template__c = productAssortmentTemplate.id; 
        productAssortment.ACCL__Valid_From__c = validFrom;
        productAssortment.ACCL__Valid_Thru__c = validThru;
        productAssortment.ACCL__Obligatory__c = Obligatory;
        productAssortment.ACCL__Description_Language_1__c='English';
        insert productAssortment;
        return productAssortment;
    }
}