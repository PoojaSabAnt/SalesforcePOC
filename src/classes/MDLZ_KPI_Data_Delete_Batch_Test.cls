/***************************************************************
Name: MDLZ_KPI_Data_Delete_Batch_Test
======================================================
Purpose:
Test class for MDLZ_KPI_Data_Delete_Batch class
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                 09/15/2022     Initial Development

***************************************************************/

@isTest
private class MDLZ_KPI_Data_Delete_Batch_Test {
    
    static testMethod void deleteIntelRecData(){
		MDLZ_KPIData__c kpiData = MDLZ_TestDataFactory.insertKPIDataRecords();
        test.startTest();
		MDLZ_KPI_Data_Delete_Batch batch = new MDLZ_KPI_Data_Delete_Batch(200);             
        SchedulableContext ctx = null;
        batch.execute(ctx);
        test.stopTest();
        System.assertEquals(0, [Select count(Id) From MDLZ_KPIData__c][0].get('expr0'));
    }

}