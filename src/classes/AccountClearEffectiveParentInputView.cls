public class AccountClearEffectiveParentInputView{

    Date today = System.today();    
	private static String query = 'SELECT Id, (SELECT Id from ACCL__Account_Extensions__r) FROM Account WHERE Id NOT IN (SELECT ACCL__Child_Account__c FROM ACCL__Account_Trade_Org_Hierarchy__c WHERE ACCL__Valid_From__c <= :today AND ACCL__Valid_Thru__c >= :today AND ACCL__Parent_Account__c != null) AND ParentID != null';

    /**Returning query for database.queryLocator passing this to start method in AccountEffectiveParentClearBatch
     *  @name getObjectDataReader 
     *  @param None
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator getObjectDataReader() {         
        return Database.getQueryLocator(query);
    }

}