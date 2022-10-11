/**  PROGRAM NAME : CallOrderDistributionReOrgBatchTest
     * This class is to test batch class is to process Calls and Order to make them distribution Relevant False.
       Distribution Relavant false calls and orders will not sync with Mobility. 
     * @version  1.0
     * @Created Date 2017-01-16 creation 
*/

@isTest
private class CallOrderDistributionReOrgBatchTest {
   private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /*Custom setting data preparation
      1. Batch_Process_Configuration__c custom setting data
      2. Aggregation_Traversal_Level__c custom setting Data
    */
    private static void createCustomSettingDataforBatch() {
        sObject sobj = CallOrderDistributionBatchTestFactory.insertBatchProcessConfig();
        
    }
    @testSetup
    //Test_Methods_With_No_Assert - False Positive
    //This is data setup method only and is used in further test methods. So no assert required.
    private static void dataSetup()
    {
        //Create Customer Template for which Test will be run
        sObject accTemp = CallOrderDistributionBatchTestFactory.insertAccountTemplate();
        List<Account> lstAccount = CallOrderDistributionBatchTestFactory.insertAccounts(2,accTemp);
        
        /***************Order Data******************************/
        //Create Order Template
        sObject ordTemp = CallOrderDistributionBatchTestFactory.insertOrderTemplate(
                                                    10,system.today().addMonths(-1),system.today());
        
        //Create Orders for Each account with different Phase
        List<sObject> listOrder = returnOrders(lstAccount,ordTemp);
                                                    
        
        /**************Call Data******************************/
        //Create Call Template
        sObject callTemp = CallOrderDistributionBatchTestFactory.insertJCallTemplate(10);   
        
        //Create calls for Each account with different status
        List<sObject> listCall = returnCalls(lstAccount,callTemp)       ;                   
    }
    /*Method to create Orders for the given acount
    Orders are created with different status and different date range
    */
    private static List<sObject> returnOrders(List<Account>lstAccount, sObject ordTemp)
    {
        List<sObject> returnList = new List<sObject>();
        //Initial Orders
        List<sObject> lstOrderInitial_1 = BuildOrders(lstAccount,system.today().addDays(-3),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_INITIAL);
        returnList.addAll(lstOrderInitial_1);                                   
        List<sObject> lstOrderInitial_2 = BuildOrders(lstAccount,system.today().addDays(-11),
                                                        ordTemp,AddOnConstants.ORDER_PHASE_INITIAL);
        returnList.addAll(lstOrderInitial_2);
        //Cancelled Order
        List<sObject> lstOrderCancelled_1 = BuildOrders(lstAccount,system.today().addDays(-4),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_CANCELLED);
        returnList.addAll(lstOrderCancelled_1);
        List<sObject> lstOrderCancelled_2 = BuildOrders(lstAccount,system.today().addDays(-14),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_CANCELLED);
        returnList.addAll(lstOrderCancelled_2);
        //Release Order
        List<sObject> lstOrderReleased_1 = BuildOrders(lstAccount,system.today().addDays(-4),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_RELEASED);
        returnList.addAll(lstOrderReleased_1);
        List<sObject> lstOrderReleased_2 = BuildOrders(lstAccount,system.today().addDays(-11),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_RELEASED);
        returnList.addAll(lstOrderReleased_2);
        //Ready Order
        List<sObject> lstOrderReady_1 = BuildOrders(lstAccount,system.today().addDays(-3),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_READY);
        returnList.addAll(lstOrderReady_1);
        List<sObject> lstOrderReady_2 = BuildOrders(lstAccount,system.today().addDays(-11),
                                                    ordTemp,AddOnConstants.ORDER_PHASE_READY);
        returnList.addAll(lstOrderReady_2);

        Database.insert(returnList);
        return returnList;
        
    }
    
    /*Method to build Orders for the given acount
    Orders are built with different status and different date range
    */
    private static List<sObject> BuildOrders(List<Account>lstAccount,Date referenceDate,
                                                    sObject ordTemp,String phase)
    {
        List<sObject> lstOrder = new List<sObject>();
        for(Integer i=0;i<=lstAccount.size()-1;i++)
        {
            sObject sOrd = CallOrderDistributionBatchTestFactory.buildOrderRecWithOnlyOrderTemplateAndAccount(
                            lstAccount[i],referenceDate,ordTemp);
            sOrd.put(ns+'Phase__c',phase);
            lstOrder.add(sOrd);
        }
        return lstOrder;
    }
    /*Method to create calls for the given acount
    Calls are created with different status and different date range
    */
    private static List<sObject> returnCalls(List<Account>lstAccount, sObject callTemp)
    {
        List<sObject> returnList = new List<sObject>();
        //Plan Orders
        List<sObject> lstCallPlan_1 = BuildCalls(lstAccount,system.today().addDays(-3),
                                                    CallTemp,AddOnConstants.CALL_STATUS_PLANNED);
        returnList.addAll(lstCallPlan_1);                                   
        List<sObject> lstCallPlan_2 = BuildCalls(lstAccount,system.today().addDays(-11),
                                                        callTemp,AddOnConstants.CALL_STATUS_PLANNED);
        returnList.addAll(lstCallPlan_2);
        //Completed Call
        List<sObject> lstCallCompleted_1 = BuildCalls(lstAccount,system.today().addDays(-4),
                                                    callTemp,AddOnConstants.CALL_STATUS_COMPLETED);
        returnList.addAll(lstCallCompleted_1);
        List<sObject> lstCallCompleted_2 = BuildCalls(lstAccount,system.today().addDays(-11),
                                                    callTemp,AddOnConstants.CALL_STATUS_COMPLETED);
        returnList.addAll(lstCallCompleted_2);
        //Cancelled Call
        List<sObject> lstCallCanceled_1 = BuildCalls(lstAccount,system.today().addDays(-4),
                                                    callTemp,AddOnConstants.CALL_STATUS_CANCELED);
        returnList.addAll(lstCallCanceled_1);
        List<sObject> lstCallCanceled_2 = BuildCalls(lstAccount,system.today().addDays(-11),
                                                    callTemp,AddOnConstants.CALL_STATUS_CANCELED);
        returnList.addAll(lstCallCanceled_2);
        //Unscheduled Call
        List<sObject> lstCallUnscheduled_1 = BuildCalls(lstAccount,system.today().addDays(-3),
                                                    callTemp,AddOnConstants.CALL_STATUS_UNSCHEDULED);
        lstCallUnscheduled_1[0].put(ns+'Status__c',AddOnConstants.CALL_STATUS_DENIED);
        returnList.addAll(lstCallUnscheduled_1);
        List<sObject> lstCallUnscheduled_2 = BuildCalls(lstAccount,system.today().addDays(-11),
                                                    callTemp,AddOnConstants.CALL_STATUS_UNSCHEDULED);
        lstCallUnscheduled_2[0].put(ns+'Status__c',AddOnConstants.CALL_STATUS_DENIED);
        returnList.addAll(lstCallUnscheduled_2);
        
        Database.insert(returnList);
        return returnList;
    }
    /*Method to build call for the given acount
    cals are built with different status and different date range
    */
    private static List<sObject> BuildCalls(List<Account>lstAccount,Date referenceDate,
                                            sObject callTemp,String Status)
    {
        List<sObject> lstCall = new List<sObject>();
        for(Integer i=0;i<=lstAccount.size()-1;i++)
        {
            sObject call = CallOrderDistributionBatchTestFactory.buildCall(callTemp,lstAccount[i]);
            call.put(ns+'Start_Date_Time__c',referenceDate);
            call.put(ns+'Status__c',Status);             
            lstCall.add(call);
        }
        return lstCall;
    }
    /******************Test Methods *****************************/
    /*
    Case: custom Setting is present.
    No of records with and without Distribution Relevant = true
    */
    private static testMethod void checkBatchJobIdWithCustomSetting()
    {    
        createCustomSettingDataforBatch();
        CallOrderDistributionBatchTestFactory.createCustomSettingDataForCall(3,5);
        CallOrderDistributionBatchTestFactory.createCustomSettingDataForOrder(3,5);
        //Batch would be executed by system Administrator. 
        User usr = [Select Id from user where Id=:UserInfo.getUserId() limit 1];
        system.runAs(usr)
        {
            CallOrderDistributionReOrgBatch sBatch = new CallOrderDistributionReOrgBatch();
            Test.startTest();
            Id batchJobId = Database.executeBatch(sBatch);
            Test.stopTest();
            system.assertNotEquals(null,batchJobId);
        } 
    }
    /*
    Case: custom Setting is not correctly set
    Test for fall back scenario
    */
    private static testMethod void checkBatchJobIdWithoutCustomSetting()
    {
        createCustomSettingDataforBatch();
        CallOrderDistributionBatchTestFactory.createCustomSettingDataForCall(null,null);
        CallOrderDistributionBatchTestFactory.createCustomSettingDataForOrder(null,null);
        //Batch would be executed by system Administrator. 
        User usr = [Select Id from user where Id=:UserInfo.getUserId() limit 1];
        system.runAs(usr)
        {
            CallOrderDistributionReOrgBatch sBatch = new CallOrderDistributionReOrgBatch ();
            Test.startTest();
            Id batchJobId = Database.executeBatch(sBatch);
            Test.stopTest();
            system.assertNotEquals(null,batchJobId);
        } 
    }
}