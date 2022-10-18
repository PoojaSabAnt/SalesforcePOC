/**  PROGRAM NAME : EffectiveAccountManagerSyncInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     * This class returns Ids of the Account records in the Org
     * @see    EffectiveAccountManagerSyncBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class EffectiveAccountManagerSyncInputView {
        
    /**
     *  @description Returning query for database.queryLocator passing this to start method in EffectiveAccountManagerSyncBatch
     *  @param None
     *  @return Database.QueryLocator
     *  @throws None
     */
    public Database.QueryLocator getObjectDataReader() {
        String query ='SELECT Id FROM Account';
        return Database.getQueryLocator(query);
    }
}