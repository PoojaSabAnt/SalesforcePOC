/**  PROGRAM NAME : KAMProductFindingBatchTestFactory
     * This class is to create test data for batch class.       
     * @version  1.0
     * @Created Date 2017-02-06
*/
@isTest
public class KAMProductFindingBatchTestFactory {
    private static string ns = AddOnConstants.NAMESPACEPREFIX;
    public static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    /*********** Data creation for Objects****************/
    
    /**This function is for inserting Product Template related Data
    *  @name insertProductTemplate
    *  @param null
    *  @return sObject(Product_Template__c)
    */
    public static sObject insertProductTemplate(Integer nameSuffix) {
        sObject sObj = allObjMetaType.get(ns+'Product_Template__c').newSObject() ;
        sObj.put('Name','Test'+nameSuffix);
        sObj.put(ns+'Active__c',True);
        sObj.put(ns+'Price_Required__c',True);          
        insert sObj;
        return sObj;
    }
    /**This function is for preparing Product related Data
    *  @name buildProduct
    *  @param Integer nameSuffix,sObject template
    *  @return sObject(Product__c)
    */
    public static sObject buildProduct(Integer nameSuffix,sObject template) {
        sObject sObj = allObjMetaType.get(ns+'Product__c').newSObject() ;
        sObj.put('Name','Test'+nameSuffix);         
        sObj.put(ns+'Product_Code__c','ProductCode'+nameSuffix);
        sObj.put(ns+'Product_Template__c',template.Id);
        sObj.put(ns+'Field_Valid_From__c',System.today());
        sObj.put(ns+'Field_Valid_Thru__c',System.today().addMonths(5));         
        return sObj;
    }
    /**This function is for inserting Product related Data with Product Level
    *  @name insertProductWithProductLevel
    *  @param Integer i,String productLevel
    *  @return sObject(Product__c)
    */
    public static sObject insertProductWithProductLevel(Integer i,String productLevel){
        sObject sObj = allObjMetaType.get(ns+'Product__c').newSObject() ;
        sObject product= buildProduct(i,insertProductTemplate(-1));
        product.put(ns+'Product_Level__c',productLevel);
        insert product;
        return product;
    }
     /**************** Data creation for custom settings***********************/
    /**This function is for inserting Batch Process configuration Data
    *  @name insertBatchProcessConfig
    *  @param null
    *  @return sObject(Batch_Process_Configuration__c)
    */  
    public static sObject insertBatchProcessConfig() {
        sObject sObj = allObjMetaType.get(ns+'Batch_Process_Configuration__c').newSObject();
        sObj.put('Name',AddOnConstants.KAM_PRODUCTS);
        sObj.put(ns+'Batch_Size__c',200);
        insert sObj;
        return sObj;
    }
}