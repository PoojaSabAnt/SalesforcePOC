/**  PROGRAM NAME : CallOrderDistributionReorgInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     *  This class returns all the accounts which are to be processed for Call Order distribution process
     * @see    CallOrderDistributionBatch
     * @version  1.0
     * @Created Date 2017-01-13 
*/
public class CallOrderDistributionReOrgInputView {
    /* Static query string to query accounts and all related calls and orders
    Future Note : To Optimize the query by using anti join or Roll up Summary
    Query Locator in batch context returns 50 million records.Hence using Sub Query.
    */
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final String CUSTOMER_RECORD_TYPE = AddOnConstants.CUSTOMER_RECORD_TYPE;
    @TestVisible
    private static String query ='SELECT '
                            +'(Select {0}Distribution_Relevant__c,{0}Start_Date__c,{0}Status__c From {0}Calls__r WHERE {0}Distribution_Relevant__c = true Order By {0}Start_Date__c DESC),'
                            +'(SELECT {0}Distribution_Relevant__c,{0}Order_Date__c,{0}Phase__c FROM {0}Order__r WHERE  {0}Distribution_Relevant__c = true Order By {0}Order_Date__c DESC)'
                            +' FROM Account '
                            +' WHERE {0}Account_Template__r.RECORDTYPE.DEVELOPERNAME=:CUSTOMER_RECORD_TYPE';
    public Database.QueryLocator getObjectDataReader(){
        query = String.format(query, new List<String>{ns});         
        return Database.getQueryLocator(query);
    }
}