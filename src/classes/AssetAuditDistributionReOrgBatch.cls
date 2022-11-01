/**  PROGRAM NAME : AssetAuditDistributionReOrgBatch 
     * This batch class is to process Asset Audit to make them distribution Relevant false and true.
       Distribution Relavant false Asset Audit will not sync with Mobility. 
       @ Scope of batchable context is Asset Audit.
*/
public class AssetAuditDistributionReOrgBatch implements Database.Batchable<sObject>, Schedulable { 
    /***** Private variables ********/
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;
    private String txId = ACCL.TransactionHandler.generateGUID();
    private static final string PROCESS_NAME = AddOnConstants.ASSET_AUDIT_DISTRIBUTION_SETTING;
    //private static final string ns = AddOnConstants.NAMESPACEPREFIX;

    /** Initializing the constructor for the batch class
     *  @name AssetAuditDistributionReOrgBatch    
     */
    public AssetAuditDistributionReOrgBatch() {
        List<sObject> sobjList =[SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME];
        //squery = String.format(squery, new List<String>{ns});
        //List<sObject> sobjList = Database.query(sQuery);
        if(!sobjList.isEmpty()) {
            batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();  
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
         return new AssetAuditDistributionReorgInputView().getObjectDataReader();
    }
    /** execute method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     */
    public void execute(Database.BatchableContext BC, List<sobject> scope)
    {    
     ACCL.LogTrace logHandle = null;
     logHandle = ACCL.LoggerUtility.enterMethod(txId, AssetAuditDistributionReOrgBatch.Class, 'execute', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {});
     Try
     {
        new AssetAuditDistributionReOrgExecution().process(scope); 
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
        //new AssetAuditDistributionReOrgExecution().processFinish();
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