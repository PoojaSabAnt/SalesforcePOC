@isTest
public class RBFMassApprovalActionScheduleTest {
    
    public static String CRON_EXP = '0 0 0 ? * * *';
    
    @isTest
    static void testRBFMassApprovalActionSchedule() {

        Test.startTest();
        String jobid = System.schedule('RBFConditionRecordsScheduleTest', CRON_EXP, new RBFMassApprovalActionSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
       // System.assertEquals('2022-03-16 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
}