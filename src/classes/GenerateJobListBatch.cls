/**  PROGRAM NAME : GenerateJobListBatch 
     * @version  1.0
     * @Created Date 2018-10-18
     
/** This batch class is for Job List Generation  
*/
public class GenerateJobListBatch implements Database.Batchable<sObject>, Schedulable {
	/** Private Variables */
    private static final string PROCESS_NAME = 'JobListGeneration';
    private Integer batchSize;
    
    /** This is a contsructor of Batch class, used to determine the batch size.
     *  @name GenerateJobListBatch()
     *  @param None
     *  @return None
     *  @version 2018-10-18
     */
    public GenerateJobListBatch() {
        List<sObject> sobjList = [SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME];
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
     *  @version 2018-10-18   
     */
    public Database.QueryLocator start(Database.BatchableContext BC)    
    {
        return new GenerateJobListInputView().getObjectDataReader();
    }
    
    /** EXECUTE method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     *  @version 2018-10-18
     */
    public void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        new GenerateJobListExecution().process(scope); 
    }
    
    /** FINISH method of Batch class
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return void
     *  @version 2018-10-18
     */
    public void finish(Database.BatchableContext BC)
    {
        
    }
    
    /** Execute method of Batch class for Scheduling batch class
     *  @name execute
     *  @param Database.SchedulableContext 
     *  @return void
     *  @version 2018-10-18
     */
    public void execute(SchedulableContext context) 
    {    
        Database.executeBatch(this, batchSize);
    } 
}