/**  PROGRAM NAME : KAMProductFindingBatch  
     * This batch class is for KAM Products
       A server process on the Accenture Cloud backend is needed to determine the Retail SKUs (Criterion 6 / Product level: Product) 
       for the KAM level products above it (Criterion 5: Package / Product Level: Product Price Group).
       Since Promotions are planned on KAM level, the associated Retail SKUs must be determined for survey and order taking
     * @version  1.0
     * @Created Date 2017-02-06    
*/
public class KAMProductFindingBatch  implements Database.Batchable<sObject>, Schedulable {
     /***** Private variables ********/
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;
    private String txId = ACCL.TransactionHandler.generateGUID();
    private static final string PROCESS_NAME = AddOnConstants.KAM_PRODUCTS;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /* Passing the process Name to parent class
     */
    public KAMProductFindingBatch() {
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
     /**�start�method�of�Batch�class�for�input�query
�����*��@name�start
�����*��@param�Database.BatchableContext�BC
�����*��@return�Database.QueryLocator
     */
     public Database.QueryLocator start(Database.BatchableContext BC)    
     {
         return new KAMProductFindingInputView().getObjectDataReader();
     }
     /**�execute�method�of�Batch�class
�����*��@name�execute
�����*��@param�Database.BatchableContext�BC,�List<sobject>�scope
�����*��@return�void 
     */
     public void execute(Database.BatchableContext BC, List<sobject> scope)
     {
         ACCL.LogTrace logHandle = null;
         logHandle = ACCL.LoggerUtility.enterMethod(txId, KAMProductFindingBatch.Class, 'execute', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {});
         Try
         {     	
            new KAMProductFindingExecution().process(scope); 
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
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return void
     */
    public void finish(Database.BatchableContext BC)
    {
        
    }
    /** execute method of Batch class for scheduling batch class
     *  @name execute
     *  @param Database.SchedulableContext 
     *  @return void
     */
    public void execute(SchedulableContext context) 
    {   
     	 Database.executeBatch(this, batchSize);
    }    
}