/**
* This class is used to schedule and trigger product assortments sync process with off platform
*/
public class ProductAssortmentAlignment implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private String query = 'SELECT Id, ACCL__Version__c, ACCL__Version_Off_Platform_APL__c, ' +
        				   'ACCL__Product_Assortment_Template__r.ACCL__Consider_For_APL_Generation__c ' +
        				   'FROM ACCL__Product_Assortment__c WHERE  ACCL__Sales_Org__c =:salesOrg';
    private static Integer DEFAULTBATCHSIZE = 1;
    private static final Type classType = ProductAssortmentAlignment.class;
    private Integer batchSize;
    private String txId = ACCL.TransactionHandler.generateGUID();
    private static final string PROCESS_NAME = 'ProductAssortmentAlignment';
    private String salesOrg { get; set; }
    private Boolean refreshAccountProductList { get; set; }
    private Boolean executeNightlyCalculation { get; set; }
    private Set<Id> productAssortmentsSyncedIds = new Set<Id>();

    // BRS_PARAMS
    private static final String  JOBNAME = 'Update';
    private static final Integer JOBTHREADS = 1;
    private static final String  BATCHCHAIN = 'Assortment';
    private static final String  BATCHCHAINTYPE = 'default';



    /**
    * Constructor.
    * @param salesOrg string value from Configuration record.
    * @param refreshAccountProductList Boolean value from Configuration, identify AccountProductList is either partial or full.
    * @param executeNightlyCalculation Boolean value from Configuration, identify nightly calculation executed after product assortment alignment
    */
    public ProductAssortmentAlignment(String salesOrg, Boolean refreshAccountProductList, Boolean executeNightlyCalculation) {
        this.salesOrg = salesOrg;
        this.refreshAccountProductList = refreshAccountProductList;
        this.executeNightlyCalculation = executeNightlyCalculation;
        String batchCheckQuery ='SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME';
        List<sObject> sobjList = Database.query(batchCheckQuery);
        if(!sobjList.isEmpty()) {
            batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();
        } else {
            batchSize = DEFAULTBATCHSIZE;
        }
    }

    /** start method of Batch class for input query
    *  @name start
    *  @param Database.BatchableContext BC
    *  @return Database.QueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /** execute method of Batch class
    *  @name execute
    *  @param Database.BatchableContext BC, List<sobject> scope
    *  @return void
    */
    public void execute(Database.BatchableContext BC, List<ACCL__Product_Assortment__c> scope) {
        ACCL.LogTrace logTraceHandle;
        try {
            logTraceHandle = ACCL.LoggerUtility.enterMethod(txId, classType, 'execute', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {String.join(scope,';')});
            Boolean isConsideredForAPLGeneration = false;
            for (ACCL__Product_Assortment__c prdAssortment : scope) {
                isConsideredForAPLGeneration = prdAssortment.ACCL__Product_Assortment_Template__r.ACCL__Consider_For_APL_Generation__c;
                if (isConsideredForAPLGeneration && (prdAssortment.ACCL__Version__c <> prdAssortment.ACCL__Version_Off_Platform_APL__c)) {
                    List<ACCL__Product_Assortment_Product__c> lstProducts = [SELECT Id, ACCL__Product__c, ACCL__Valid_From__c,
                                                                                     ACCL__Valid_Thru__c FROM ACCL__Product_Assortment_Product__c
                                                                       				 WHERE ACCL__Product_Assortment__c =: prdAssortment.Id AND ACCL__Active__c = true];
                    ACCL.ProductAssortmentWebServiceCall.generateAccountProductList(txId, prdAssortment.Id, lstProducts, JOBNAME, JOBTHREADS, BATCHCHAIN, BATCHCHAINTYPE);
                    productAssortmentsSyncedIds.add(prdAssortment.Id);
                }
            }
        } catch(Exception ex) {
            ACCL.LoggerUtility.log(txId, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', 'Internal Server Error', new Map<String, Object> {'Exception' => ex});
        } finally {
            ACCL.LoggerUtility.leaveMethod(logTraceHandle, '');
        }
    }

    /** finish method of Batch class
    *  @name finish
    *  @param Database.BatchableContext BC
    *  @return void
    */
    public void finish(Database.BatchableContext BC) {
        if(this.executeNightlyCalculation) {
      		Database.executeBatch(new NightlyCalculationBatch(this.salesOrg, this.refreshAccountProductList), 1000);
        }
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