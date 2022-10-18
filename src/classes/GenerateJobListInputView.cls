/**  PROGRAM NAME : GenerateJobListInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     * This class returns the Job_Definition_List records from the Org.
     * @see    GenerateJobListBatch
     * @version  1.0
     * @Created Date 2018-10-18 
*/
public class GenerateJobListInputView {
	/** Private Variable */
    private static final string CANCELED = 'Canceled';
       
    
    /**
     *  @description Returning query for database.queryLocator passing this to start method in GenerateJobListBatch
     *  @param None
     *  @return Database.QueryLocator
     *  @throws None
     */
    public Database.QueryLocator getObjectDataReader() {
        Date today = System.today();
        String query = 'SELECT  '
            +'(SELECT ACCL__Account__c FROM ACCL__Job_Definition_List_Accounts__r WHERE ACCL__Excluded__c = false ),'
            +'(SELECT ACCL__Account_Set__c FROM ACCL__Job_Definition_List_Account_Sets__r ),'
            +' ACCL__Active__c, ACCL__Call_Template__c, ACCL__Default_Management_Type__c, Id, ACCL__User_Policy__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c '
            +' FROM ACCL__Job_Definition_List__c '
            +' WHERE ACCL__Active__c = true AND ACCL__Valid_Thru__c >= TODAY  AND ACCL__Job_Definition_List_Template__r.ACCL__Standard_Jobs__c = false AND ACCL__Approval_State__c != :CANCELED ';
        
        Database.QueryLocator ql = Database.getQueryLocator(query);
        return ql;
    }
}