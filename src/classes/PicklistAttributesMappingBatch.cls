/**  PROGRAM NAME : PicklistAttributesMappingBatch
     * @version  1.0    
*/
public class PicklistAttributesMappingBatch implements Database.Batchable<sObject>, Schedulable {
     /***** Private variables ********/
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;
    private static final string PROCESS_NAME = AddOnConstants.PICKLIST_ATTRIBUTES_MAPPING;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /* Passing the process Name to parent class
     */
    public PicklistAttributesMappingBatch() {
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
         return new PicklistAttributesMappingInputView().getObjectDataReader();
     }
    /** execute method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     */
     public void execute(Database.BatchableContext BC, List<sobject> scope)
     {
        new PicklistAttributesMappingExecution().process(scope); 
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