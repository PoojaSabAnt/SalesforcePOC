/** Sharing_With_Controller - False positive
 *  Batch classes execute in system mode so sharing is not required
 */
/**
* This batch class is used to reset/clear ParentId field in ACSF Account if no effective Trade Org Hierarchy parent present on the day of batch run
*/ 

public class AccountClearEffectiveParentBatch implements Database.Batchable<sObject>, Schedulable {
    private static final string PROCESS_NAME = AddOnConstants.ACCOUNT_CLEAR_BATCH;
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;

    public AccountClearEffectiveParentBatch() {
        List<sObject> sobjList = [SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name =: PROCESS_NAME];
        if(sobjList.isEmpty()){
            batchSize = DEFAULTBATCHSIZE;
            
        } else {
            batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();
        }
    }

    /** start method of Batch class for input query
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     */
     public Database.QueryLocator start(Database.BatchableContext BC) {
         return new AccountClearEffectiveParentInputView().getObjectDataReader();
     }

     /** execute method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     */
     public void execute(Database.BatchableContext BC, List<sobject> scope) {
        new AccountClearEffectiveParentExecution().process(scope); 
     }
    /** finish method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC
     *  @return void
     */
    public void finish(Database.BatchableContext BC) {

    }
    /** execute method of Batch class for scheduling batch class
     *  @name execute
     *  @param Database.BatchableContext BC
     *  @return void
    */
    public void execute(SchedulableContext context) {    
        Database.executeBatch(this, batchSize);
    }    
}
