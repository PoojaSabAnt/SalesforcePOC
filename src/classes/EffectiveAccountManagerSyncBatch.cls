/**  PROGRAM NAME : EffectiveAccountManagerSyncBatch 
     * @version  1.0
     * @Created Date 2018-10-12 
     
/**	This Batch class & scheduler is used to sync (insert/delete) standard Account Team & 
 * 	Accont Share in Account object with effective Account Manager relationship on the day of batch run.
*/
public class EffectiveAccountManagerSyncBatch implements Schedulable, Database.Batchable<sObject> {
	/** Private Variables */ 
    private static final string PROCESS_NAME = AddOnConstants.EFFECTIVE_ACCOUNT_MANAGER_SYNC_BATCH;     
    
    /** START method of Batch class for input query
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     *  @version 2018-10-12   
     */
    public Database.QueryLocator start(Database.BatchableContext BC)    
    {
        return new EffectiveAccountManagerSyncInputView().getObjectDataReader();
    }
    
    /** EXECUTE method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     *  @version 2018-10-12  
     */
    public void execute(Database.BatchableContext BC, List<Account> scope)
    {
        new EffectiveAccountManagerSyncExecute().process(scope); 
    }
    
    /** FINISH method of Batch class
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return void
     *  @version 2018-10-12
     */
    public void finish(Database.BatchableContext BC) {
        
    }
    
    /** EXECUTE method of Batch class for scheduling batch class
     *  @name execute
     *  @param Database.SchedulableContext 
     *  @return void
     *  @version 2018-10-12
     */
    public void execute(SchedulableContext sc) {
        try {
            Integer batchSize;
            List<sObject> sobjList = [Select ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name =: PROCESS_NAME];
            if(!sobjList.isEmpty()) {
                batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();  
            }
            else {
                batchSize = 200;
            } 
            
            EffectiveAccountManagerSyncBatch instanceAccountEffectiveManagerSyncBatch = new EffectiveAccountManagerSyncBatch();
            database.executebatch(instanceAccountEffectiveManagerSyncBatch, batchSize);
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
        }
    }
}