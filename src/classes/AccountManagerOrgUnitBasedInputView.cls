/**  PROGRAM NAME : AccountManagerOrgUnitBasedInputView  
     * This class is used for making the start method query for AccountManagerCreationBatch
       fetching all the org unit records available in the system
     * @see  AccountManagerCreationBatch
     * @version  1.0     
*/
public class AccountManagerOrgUnitBasedInputView {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;  
    private static final Type classType = AccountManagerOrgUnitBasedInputView.class;
    private static String txId = ACCL.TransactionHandler.generateGUID();
	private static String query ='SELECT Id,Name FROM {0}Org_Unit__c';
    /**Returning query for database.queryLocator passing this to start method in AccountManagerCreationBatch
     *  @name getObjectDataReader 
     *  @param None
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator getObjectDataReader() { 
    	ACCL.LogTrace logTraceHandle = ACCL.LoggerUtility.enterMethod(txId, classType, 'getObjectDataReader', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {});        
        query = String.format(query, new List<String>{ns});
        ACCL.LoggerUtility.leaveMethod(logTraceHandle, query);
        return Database.getQueryLocator(query);
    }

}