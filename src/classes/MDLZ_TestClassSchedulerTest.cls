/***************************************************************
Name: MDLZ_TestClassSchedulerTest
======================================================
Purpose:
Test class for TestClassScheduler class 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                              Initial Development 

***************************************************************/
@isTest
public class MDLZ_TestClassSchedulerTest {
    static testMethod void scheduleTestClass(){
        test.startTest();
        system.runAs(MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM)){
            TestClassScheduler batch = new TestClassScheduler();
            SchedulableContext ctx = null;
            batch.execute(ctx);
            test.stopTest();           
        }
    }
}