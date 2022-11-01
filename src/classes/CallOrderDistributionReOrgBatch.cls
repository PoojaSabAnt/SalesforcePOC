/**  PROGRAM NAME : CallOrderDistributionReOrgBatch 
     * This batch class is to process Calls and Order to make them distribution Relevant False.
       Distribution Relavant false calls and orders will not sync with Mobility. 
       @ Scope of batchable context is Account. Separate DML to be performed on Order__c and Call__c object
     * @version  1.0
     * @Created Date 2017-01-14 creation 
*/
public class CallOrderDistributionReOrgBatch  implements Database.Batchable<sObject>, Schedulable { 
    /***** Private variables ********/
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;
    private String txId = ACCL.TransactionHandler.generateGUID();
    private static final string PROCESS_NAME = AddOnConstants.DISTRIBUTION_SETTING;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    
    /** Initializing the constructor for the batch class
     *  @name CallOrderDistributionReOrgBatch    
     */
    public CallOrderDistributionReOrgBatch() {
        String squery ='SELECT {0}Batch_Size__c FROM {0}Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);
        if(!sobjList.isEmpty()) {
            batchSize = ((Decimal)sobjList[0].get(ns +'Batch_Size__c')).intValue();  
        }
        else
        {
           batchSize = DEFAULTBATCHSIZE;
        } 
    }
    /** start method of Batch class for input query
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext BC)    
    {
         return new CallOrderDistributionReOrgInputView().getObjectDataReader();
    }
    /** execute method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     */
    public void execute(Database.BatchableContext BC, List<sobject> scope)
    {
    
         ACCL.LogTrace logHandle = null;
         logHandle = ACCL.LoggerUtility.enterMethod(txId, KAMProductFindingBatch.Class, 'execute', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {});
         Try
         {     	
        new CallOrderDistributionReOrgExecution().process(scope); 
         }
         Catch(Exception ex)
         {
     	    ACCL.LoggerUtility.log(txId, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', 'Internal Server Error', new Map<String, Object> {'Exception' => ex});
     	    throw ex;
         }
         Finally
         {
     	    ACCL.LoggerUtility.leaveMethod(logHandle, '');
         }
    }
    /** finish method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC
     *  @return void
     */
    public void finish(Database.BatchableContext BC)
    {
        //new CallOrderDistributionReOrgExecution().processFinish();
    }
    /** execute method of Batch class for scheduling batch class
     *  @name execute
     *  @param Database.BatchableContext BC
     *  @return void
     */
    public void execute(SchedulableContext context) 
    {   
     	 Database.executeBatch(this, batchSize);

    }
}