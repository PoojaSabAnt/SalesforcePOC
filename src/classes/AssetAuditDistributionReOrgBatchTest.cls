/**  PROGRAM NAME : AssetAuditDistributionReOrgBatchTest
     * This class is to test batch class is to process Asset Audits to make them distribution Relevant true and false.
       Distribution Relavant false Asset Audits will not sync with Mobility. 
     * @version  1.0
     * @Created Date 2017-10-18 creation 
*/
@istest
private class AssetAuditDistributionReOrgBatchTest{
private static testMethod void checkAssetAuditCreation(){

        User usr = [Select Id from user where Id=:UserInfo.getUserId() limit 1];
        system.runAs(usr)
        {
            sObject asseet01 = CallOrderDistributionBatchTestFactory.insertAsset();
            List<sObject>assetAuditList = CallOrderDistributionBatchTestFactory.insertAssetAuditList(10,(Asset)asseet01);
            Sobject assetAuditDistributionRelevant= CallOrderDistributionBatchTestFactory.buildAssetAudit((Asset)asseet01);
            assetAuditDistributionRelevant.put('ACCL__Sighted__c',true);
            insert assetAuditDistributionRelevant;
            AssetAuditDistributionReOrgBatch sBatch = new AssetAuditDistributionReOrgBatch ();
            Test.startTest();
            Id batchJobId = Database.executeBatch(sBatch);
            Test.stopTest();
            System.assertNotEquals(null, batchJobId);
        }
    }
    private static testMethod void checkAssetAuditCreationForNonDistributionRelevant(){

        User usr = [Select Id from user where Id=:UserInfo.getUserId() limit 1];
        system.runAs(usr)
        {
            sObject asseet01 = CallOrderDistributionBatchTestFactory.insertAsset();
            List<sObject>assetAuditList = CallOrderDistributionBatchTestFactory.insertAssetAuditList(10,(Asset)asseet01);
            Sobject assetAuditDistributionRelevant= CallOrderDistributionBatchTestFactory.buildAssetAudit((Asset)asseet01);
            assetAuditDistributionRelevant.put('ACCL__Distribution_Relevant__c',false);
            assetAuditDistributionRelevant.put('ACCL__Sighted__c',true);
            insert assetAuditDistributionRelevant;
            AssetAuditDistributionReOrgBatch sBatch = new AssetAuditDistributionReOrgBatch ();
            Test.startTest();
            Id batchJobId = Database.executeBatch(sBatch);
            Test.stopTest();
            System.assertNotEquals(null, batchJobId);
        }
    }
}