/** 
 * This batch class Is for Aggregation Listing. We will get node level accounts for every anchor account 
   that Is associated with Promotion. Result of this will be store in Promotion Store. Child level hierarchy 
   can maximum go upto 7th level form top To down  
*/
//Sharing_With_Controller - False Positive
//This batch class has to be executed in system context without sharing enforced. Hence False Positive.    
global class AggregatePromotionBatch implements Database.Batchable<sObject>, Schedulable {     
    private static String className = String.valueOf(AggregatePromotionBatch.class);
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    //private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final string PROCESS_NAME = 'PromotionAggregation';
    private Integer batchSize;
    //private static String txId = TransactionHandler.generateGUID();
        
    /**
    global AggregatePromotionBatch() {
        super(Constants.PROMO_AGGREGATION);
        //LoggerUtility.log(txId, LoggingLevel.DEBUG, LogCodeCollection.PAB0001);
    }**/
    global AggregatePromotionBatch () {
        String squery ='SELECT {0}Batch_Size__c FROM {0}Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME';
            squery = String.format(squery, new List<String>{ns});
            List<sObject> sobjList = Database.query(sQuery);
            if(!sobjList.isEmpty()) {
                batchSize = ((Decimal)sobjList[0].get(ns +'Batch_Size__c')).intValue();  
            }
            else {
                batchSize = 50;
            }
    }      
    
    public Database.QueryLocator start(Database.BatchableContext BC)    
    {
        return new AggregatePromotionInputView().getObjectDataReader();
    }
    public void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        //Sharing_With_Controller - This batch class has to be executed in system context without sharing enforced. Hence False Positive.
        new AggregatePromotionExecution().process(scope); 
    }
    public void finish(Database.BatchableContext BC)
    {
        //Sharing_With_Controller - This batch class has to be executed in system context without sharing enforced. Hence False Positive.
        new AggregatePromotionExecution().processFinish();
    }
    public void execute(SchedulableContext context) 
    {    
        Database.executeBatch(this, batchSize);
    }
    
}