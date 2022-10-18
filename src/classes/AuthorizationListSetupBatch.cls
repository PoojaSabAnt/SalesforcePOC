/**  PROGRAM NAME : AuthorizationListSetupBatch 
     * @version  1.0
     * @Created Date 2018-10-12 
     
/** This batch class Is for Aggregation Listing. We will get node level accounts for every anchor account that is associated with Product Assortment. 
 * 	Result of this will be store in Product Assortment Store. Child level hierarchy can maximum go upto 7th level form top To down.  
*/
public class AuthorizationListSetupBatch implements Database.Batchable<sObject>, Schedulable {
	/** Private Variables */
    private static final string PROCESS_NAME = 'AuthAggregation';
    private Integer batchSize;
    
    /** This Is a contsructor of Batch class, used to determine the batch size.
     *  @name AuthorizationListSetupBatch()
     *  @param None
     *  @return None
     *  @version 2018-10-12
     */
    public AuthorizationListSetupBatch() {
        List<sObject> sobjList = [SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name =: PROCESS_NAME];
        if(!sobjList.isEmpty()) {
            batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();  
        }
        else {
            batchSize = 200;
        }
    }
    
    /** START method of Batch class for input query
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     *  @version 2018-10-12   
     */
    public Database.QueryLocator start(Database.BatchableContext BC)    
    {
        return new AuthorizationListSetupInputView().getObjectDataReader();
    }
    
    /** EXECUTE method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     *  @version 2018-10-12  
     */
    public void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        new AuthorizationListSetupExecution().process(scope); 
    }
    
    /** FINISH method of Batch class
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return void
     *  @version 2018-10-12
     */
    public void finish(Database.BatchableContext BC)
    {
        new AuthorizationListSetupExecution().processFinish();
        
        //Chaining delete Product assortment Branch listing Batch to execute after current batch is complete
        Database.executeBatch(new MDLZ_DeleteProdAssortBranchListingBatch(200), batchSize);
    }
    
    /** Execute method of Batch class for Scheduling batch class
     *  @name execute
     *  @param Database.SchedulableContext 
     *  @return void
     *  @version 2018-10-12
     */
    public void execute(SchedulableContext context) 
    {    
        Database.executeBatch(this, batchSize);
    } 
}