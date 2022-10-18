/**  PROGRAM NAME : AssetAuditDistributionReorgInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     *  This class returns all the Asset Audits for distribution process
     * @see    AssetAuditDistributionBatch
     * @version  1.0
     * @Created Date 2017-01-13 
*/
public class AssetAuditDistributionReorgInputView {
    /* Static query string to query all Asset Audits
    */
    @TestVisible
    private static String query ='SELECT createdDate,Name,ACCL__Distribution_Relevant__c,ACCL__Sighted__c,ACCL__Creation_Date__c,ACCL__Asset__c FROM ACCL__Asset_Audit__c Order By ACCL__creation_date__c desc,createddate desc';
    public Database.QueryLocator getObjectDataReader(){
        return Database.getQueryLocator(query);
    }
}