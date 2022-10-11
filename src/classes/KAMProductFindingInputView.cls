/**  PROGRAM NAME : KAMProductFindingInputView  
     * This class is used for making the start method query for KAMProductFindingBatch  
       fetching all the Product records where Product Level should be Package or Product
     * @see    KAMProductFindingBatch  
     * @version  1.0
     * @Created Date 2017-02-06  
*/
public class KAMProductFindingInputView {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final String PRODUCT_LEVEL_PRODUCT = AddOnConstants.PRODUCT_LEVEL_PRODUCT;
    private static String query ='SELECT Id,{0}KAM_Product__c,{0}Product_Level__c,{0}Criterion_5_Product__c,{0}Criterion_5_Product__r.{0}Product_Level__c,{0}Criterion_6_Product__c'
                                +' FROM {0}Product__c '
                                +' WHERE {0}KAM_Product__c = NULL AND {0}Product_Level__c =:PRODUCT_LEVEL_PRODUCT';
    /**Returning query for database.queryLocator passing this to start method in KAMProductFindingBatch  
     *  @name getObjectDataReader 
     *  @param None
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator getObjectDataReader() {         
        query = String.format(query, new List<String>{ns}); 
        return Database.getQueryLocator(query);
    }
   
}