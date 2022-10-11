/**
 * Batch to update Kpi Set records to force update (via trigger) the Kpi Set configuration in offplatform. 
 */ 
public class KpiSetTransferBatch implements Database.Batchable<sObject> {

    /** start method of Batch class for input query
     *  @name start
     *  @param Database.BatchableContext BC
     *  @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM ACCL__KPI_Set__c';
        return Database.getQueryLocator(query);
    }
    /** execute method of Batch class
     *  @name execute
     *  @param Database.BatchableContext BC, List<sobject> scope
     *  @return void
     */
    public void execute(Database.BatchableContext BC, List<ACCL__KPI_Set__c> scope) {
        Database.update(scope);
    }

    /** finish method of Batch class
     *  @name finish
     *  @param Database.BatchableContext BC
     *  @return void
     */
    public void finish(Database.BatchableContext BC) {}

}