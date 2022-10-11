/**  PROGRAM NAME : AuthorizationListSetupInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     * This class returns the Flatten_Account_Hierarchy records from the Org where Result_Level includes 'Store'
     * @see    AuthorizationListSetupBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class AuthorizationListSetupInputView {
	private static final string STORE = 'Store';
    private static final string TRADE_ORG = 'Trade Org';
    
    /**
     *  @description Returning query for database.queryLocator passing this to start method in AuthorizationListSetupBatch
     *  @param None
     *  @return Database.QueryLocator
     *  @throws None
     */
    public Database.QueryLocator getObjectDataReader() {
        String query = 'SELECT Id, ACCL__Account__c,ACCL__Account__r.name, ACCL__Account_Level_01__c, ACCL__Account_Level_02__c, ACCL__Account_Level_03__c, ACCL__Account_Level_04__c, ACCL__Account_Level_05__c, ACCL__Account_Level_06__c, ACCL__Account_Level_07__c, ACCL__Account_Level_08__c, ACCL__Account_Level_09__c, ACCL__Account_Level_10__c, ACCL__Account_Level_11__c, ACCL__Account_Level_12__c, ACCL__Account_Level_13__c, ACCL__Account_Level_14__c, ACCL__Account_Level_15__c, ACCL__Node_Level__c FROM ACCL__Flatten_Account_Hierarchy__c WHERE (ACCL__Result_Level__c INCLUDES (:STORE,:TRADE_ORG)) and ACCL__Node_Level__c in (1,6)';
        Database.QueryLocator ql = Database.getQueryLocator(query);
        return ql;
    }
}