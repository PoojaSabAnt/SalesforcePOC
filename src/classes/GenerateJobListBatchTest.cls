@isTest
/**  PROGRAM NAME : GenerateJobListBatchTest 
     * This class is a test class for the GenerateJobListBatch batch class.
     * @see    GenerateJobListBatch
     * @version  1.0
     * @Created Date 2018-10-18
*/
private class GenerateJobListBatchTest {
	    
    /** Method to test Job List Generation when the Account Manager is valid */
    private static testMethod void test_process_createJL_whenAccountManagerPairIsValid() {
        GenerateJobListTestFactory.createCustomSettingData();
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        
        Test.startTest();
        Database.executeBatch(bt);
        String sch = '0 0 23 * * ?'; 
        System.schedule('Job List Generation', sch, bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        System.assertEquals(1, jlList.size());
        System.assertEquals(manager.get('ACCL__User__c'), jlList[0].get('ACCL__Manager__c'));
    }
    
    /** Method to test Job List Generation when the Account Manager is valid & the Date From is changed */
    private static testMethod void test_process_updateJL_whenDateFromWasChanged_AndManagerIsStillValid() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl);
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject orginalJL = GenerateJobListTestFactory.getDefaultJobList(acc, ct, jdl);
                
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c], ' There should be only one JL by now, fix data setup.');
        System.assertEquals(System.today() , orginalJL.get('ACCL__Valid_From__c'));
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_Definition_List__c], ' There should be only one JDL by now, fix data setup.');
        
        sObject jdlObj = [SELECT Id, ACCL__Valid_From__c FROM ACCL__Job_Definition_List__c LIMIT 1][0];
        
        Date jdlDate = (Date)jdlObj.get('ACCL__Valid_From__c');
        jdlObj.put('ACCL__Valid_From__c', Date.newInstance(jdlDate.year(), jdlDate.month(), jdlDate.day() +1));
        update jdlObj;
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        
        System.assertEquals(1, jlList.size());
        System.assertEquals(System.today().addDays(1), jlList[0].get('ACCL__Valid_From__c'));
    }
    
    /** Method to test Job List Generation when the Account Manager is valid & the Date To is changed */
    private static testMethod void test_process_updateJL_whenDateToWasChanged_AndManagerIsStillValid() {
        
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl);
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject orginalJL = GenerateJobListTestFactory.getDefaultJobList(acc, ct, jdl);
        
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c], ' There should be only one JL by now, fix data setup.'); 
        System.assertEquals(System.today() , orginalJL.get('ACCL__Valid_From__c'));
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_Definition_List__c], ' There should be only one JDL by now, fix data setup.');
        
        sObject jdlObj = [SELECT Id, ACCL__Valid_Thru__c FROM ACCL__Job_Definition_List__c LIMIT 1][0];
        Date jdlDate = (Date)jdlObj.get('ACCL__Valid_Thru__c');
        jdlObj.put('ACCL__Valid_From__c', Date.newInstance(jdlDate.year(), jdlDate.month(), jdlDate.day() -1));
        update jdlObj;
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        System.assertEquals(1, jlList.size());
        System.assertEquals(jdl.get('ACCL__Valid_Thru__c'), jlList[0].get('ACCL__Valid_Thru__c'));
    }
    
    /** Method to test Job List Generation when the Account Manager is removed from the valid range & the Job is not magnetized */
    private static testMethod void test_process_delete_whenManagerFallsOutOfValidPeriod_andJobNotMagnetized() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl);
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject orginalJL = GenerateJobListTestFactory.getDefaultJobList(acc, ct, jdl);
        
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c],' There should be only one JL by now, fix data setup.');
        System.assertEquals(System.today() , orginalJL.get('ACCL__Valid_From__c'));
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_Definition_List__c], ' There should be only one JDL by now, fix data setup.');
        
        sObject jdlToBePutOutsideValidManagamentPeriod = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c FROM ACCL__Job_Definition_List__c LIMIT 1][0];
        Date jdlFromDate = (Date)jdlToBePutOutsideValidManagamentPeriod.get('ACCL__Valid_From__c');
        Date jdlThruDate = (Date)jdlToBePutOutsideValidManagamentPeriod.get('ACCL__Valid_Thru__c');
        jdlToBePutOutsideValidManagamentPeriod.put('ACCL__Valid_From__c', Date.newInstance(jdlFromDate.year(), jdlFromDate.month(), jdlFromDate.day() +100));
        jdlToBePutOutsideValidManagamentPeriod.put('ACCL__Valid_Thru__c', Date.newInstance(jdlThruDate.year(), jdlThruDate.month(), jdlThruDate.day() +100));
        update jdlToBePutOutsideValidManagamentPeriod;
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        System.assertEquals(0, jlList.size());
    }
    
    /** Method to test Job List Generation when Job List has a call lookup & existing corresponding calls. */
    private static testMethod void test_process_populateCallLookupOnJL_whenCorrespondingCallExists() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard(jdlt, ct);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl); 
        sObject defCall = GenerateJobListTestFactory.getDefaultCall(ct, acc); 
        
		GenerateJobListBatch bt = new GenerateJobListBatch();        
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        //System.assertEquals(defCall.Id, jlList[0].get('ACCL__Call__c') );
    }
    
    /** Method to test Job List Generation when Job List doesnt have a call lookup & existing corresponding calls. */
    private static testMethod void test_process_doesNotPopulateCallLookupOnJL_whenNoCorrespondingCallExists() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard(jdlt, ct);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl); 
        sObject defCall = GenerateJobListTestFactory.getDefaultCall(ct, acc); 
        defCall.put('ACCL__Start_Date_Time__c', System.today().addDays(-5));
        update defCall;
                
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        System.assertEquals(null, jlList[0].get('ACCL__Call__c'));
    }
    
    /** Method to test Job List Generation when the Call exists & the Account Manager is no longer in valid range. */
    private static testMethod void test_process_cancelJL_whenAccountManagerPairIsNoLongerValidButCallExists() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard(jdlt, ct);
        sObject jdlAccount = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(acc, jdl); 
        sObject defCall = GenerateJobListTestFactory.getDefaultCall(ct, acc); 
        sObject orginalJL = GenerateJobListTestFactory.getDefaultJobList(acc, ct, jdl);
        orginalJL.put('ACCL__Call__c', defCall.Id);
        update orginalJL;
        
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c], ' There should be only one JL by now, fix data setup.');
        System.assertEquals(System.today() , orginalJL.get('ACCL__Valid_From__c'));
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_Definition_List__c], ' There should be only one JDL by now, fix data setup.');
        
        sObject jdlToBePutOutsideValidManagamentPeriod = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c FROM ACCL__Job_Definition_List__c LIMIT 1][0];
        Date jdlFromDate = (Date)jdlToBePutOutsideValidManagamentPeriod.get('ACCL__Valid_From__c');
        Date jdlThruDate = (Date)jdlToBePutOutsideValidManagamentPeriod.get('ACCL__Valid_Thru__c');
        jdlToBePutOutsideValidManagamentPeriod.put('ACCL__Valid_From__c', Date.newInstance(jdlFromDate.year(), jdlFromDate.month(), jdlFromDate.day() +100));
        jdlToBePutOutsideValidManagamentPeriod.put('ACCL__Valid_Thru__c', Date.newInstance(jdlThruDate.year(), jdlThruDate.month(), jdlThruDate.day() +100));
        update jdlToBePutOutsideValidManagamentPeriod;
                
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Call__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c];
        System.assertEquals(AddOnConstants.JOB_LIST_DONE_STATUS_CANCELLED, jlList[0].get('ACCL__Done__c'));
    }
    
    /** Method to test Job List Generation when the User Policy is set to Main & mutiple Main Managers are assigned to the longest active period over JDL */
    private static testMethod void test_process_createJL_whenUserPolicyIsOnlyMainAndMultipleMainManagers_assignedToOnesWithLongestActivePeriodOverJDL() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(2);
        List<sObject> mainManagers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(10), System.today().addDays(50), 'Sales', true);
        List<sObject> mainMmanagersWithLongerTimeFrame = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(5), System.today().addDays(50), 'Sales', true);
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(2, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, System.today().addDays(6), System.today().addDays(50));
        sObject jdla0 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        sObject jdla1 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[1], jdls[1]);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        Id accId0 = accs[0].Id;
        Id accId1 = accs[1].Id;
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId0];
        sObject jls2 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId1];
        
        System.assertEquals(mainMmanagersWithLongerTimeFrame[0].get('ACCL__User__c'), jls1.get('ACCL__Manager__c') );
        System.assertEquals(mainMmanagersWithLongerTimeFrame[1].get('ACCL__User__c'), jls2.get('ACCL__Manager__c') );
    }
    
    /** Method to test Job List Generation when the User Policy is set to First & multiple non Main Managers are assigned to the longest active period over JDL */
    private static testMethod void test_process_createJL_whenUserPolicyIsFirstAndNoMainManagerButMultipleNonMain_assignedToOnesWithLongestActivePeriodOverJDL() {
		sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(10), System.today().addDays(50), 'Sales', false);
        List<sObject> managersWithLongerTimeFrame = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(5), System.today().addDays(50), 'Sales', false);
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(2, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_FIRST, System.today().addDays(6), System.today().addDays(50));
        sObject jdla0 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        sObject jdla1 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[1], jdls[1]);        
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        Id accId0 = accs[0].Id;
        Id accId1 = accs[1].Id;
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId0];
        sObject jls2 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId1];
        
        
        System.assertEquals(managersWithLongerTimeFrame[0].get('ACCL__User__c'), jls1.get('ACCL__Manager__c') );
        System.assertEquals(managersWithLongerTimeFrame[1].get('ACCL__User__c'), jls2.get('ACCL__Manager__c') );
    }
    
    /** Method to test Job List Generation when the User Policy is set to Main & mutiple Main Managers are assigned to the longest active period over JDL */
    private static testMethod void test_process_createJL_whenUserPolicyIsFirstAndMultipleMainManagers_assignedToOnesWithLongestActivePeriodOverJDL() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(10), System.today().addDays(50), 'Sales', true);
        List<sObject> managersWithLongerTimeFrame = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, System.today().addDays(5), System.today().addDays(50), 'Sales', true);
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(2, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_FIRST, System.today().addDays(6), System.today().addDays(50));
        sObject jdla0 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        sObject jdla1 = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[1], jdls[1]);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        Id accId0 = accs[0].Id;
        Id accId1 = accs[1].Id;
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId0];
        sObject jls2 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Account__c = :accId1];
        
        
        System.assertEquals(managersWithLongerTimeFrame[0].get('ACCL__User__c'), jls1.get('ACCL__Manager__c') );
        System.assertEquals(managersWithLongerTimeFrame[1].get('ACCL__User__c'), jls2.get('ACCL__Manager__c') );
    }
    
    /** Method to test Job List Generation when the User Policy is set to All & the JDL date is changed */
    private static testMethod void test_process_updateJLs_updateAllJLsWhenJDLDatesChangedAndUserPolicyALL() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        Date dateFromForAllObjectsInTest = System.today();
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        Date changedDateFromForJDL = System.today().addDays(1);
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> users = GenerateJobListTestFactory.insertUsers(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], dateFromForAllObjectsInTest, dateToForAllObjectsInTest, 'Sales', true);
        managers.addAll(GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[1], dateFromForAllObjectsInTest, dateToForAllObjectsInTest, 'Sales', true));
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ALL, dateFromForAllObjectsInTest, dateToForAllObjectsInTest);
        sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, dateFromForAllObjectsInTest, dateToForAllObjectsInTest);
        jdls[0].put('ACCL__Valid_From__c', changedDateFromForJDL);
        update jdls;
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        System.assertEquals(2, [SELECT count() FROM ACCL__Job_List__c]);
        
        Id userId0 = (Id)managers[0].get('ACCL__User__c'); 
        Id userId1 = (Id)managers[1].get('ACCL__User__c');
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId0];
        sObject jls2 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId1];
                
        System.assertEquals(changedDateFromForJDL, jls1.get('ACCL__Valid_From__c') );
        System.assertEquals(changedDateFromForJDL, jls2.get('ACCL__Valid_From__c') );
    }
    
    /** Method to test Job List Generation when the User Policy is set to Main & with the new multiple Main Managers,
		when JDL dates are changed */
    private static testMethod void test_process_updateJLs_updateJLWithNewMainManagerWhenJDLDatesChangedAndUserPolicyONLYMAIN() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        Date longerDateFrom = System.today();
        Date shorterDateFrom = System.today().addDays(1);
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> users = GenerateJobListTestFactory.insertUsers(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], shorterDateFrom, dateToForAllObjectsInTest, 'Sales', true);
        sObject managerWithLongerTimeFrame = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[1], longerDateFrom, dateToForAllObjectsInTest, 'Sales', true)[0];
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, longerDateFrom, dateToForAllObjectsInTest);
        sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, shorterDateFrom, dateToForAllObjectsInTest);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c]);
        
        Id userId1 = (Id)managerWithLongerTimeFrame.get('ACCL__User__c');
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId1];
        
        System.assertEquals(longerDateFrom, jls1.get('ACCL__Valid_From__c'));
    }
    
    /** Method to test Job List Generation when Account from the Account Set has the valid Manager */
    private static testMethod void test_process_createJLs_ifAccountFromAccountSetHasAValidManager() {
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        sObject jdl = GenerateJobListTestFactory.getDefaultJobDefinitionList_NonStandard(jdlt, ct);
        sObject manager = GenerateJobListTestFactory.getDefaultAccountManager(acc);
        sObject accSet = GenerateJobListTestFactory.getDefaultAccountSet();
        sObject accountSetAccount = GenerateJobListTestFactory.getDefaultAccountSetAccount(accSet, acc);
        sObject jdlToAcc = GenerateJobListTestFactory.getDefaultJobDefinitionListAccountSet(jdl, accSet);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        List<sObject> jlList = [SELECT Id, ACCL__Account__c FROM ACCL__Job_List__c];
        
        System.assertEquals(1, jlList.size());
        System.assertEquals(accountSetAccount.get('ACCL__Account_Set_Account__c'), jlList[0].get('ACCL__Account__c') );
    }
    
    /** Method to test Job List Generation when new Manager with the longest active period is available */
    private static testMethod void test_process_updateJL_whenNewManagerWithLongerActivePeriodIsAvailable() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        Date longerDateFrom = System.today();
        Date shorterDateFrom = System.today().addDays(1);
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> users = GenerateJobListTestFactory.insertUsers(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], shorterDateFrom, dateToForAllObjectsInTest, 'Sales', true);
        sObject managerWithLongerTimeFrame = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[1], longerDateFrom, dateToForAllObjectsInTest, 'Sales', true)[0];
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, longerDateFrom, dateToForAllObjectsInTest);
        sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, longerDateFrom, dateToForAllObjectsInTest);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM ACCL__Job_List__c]);
        
        Id userId1 = (Id)managerWithLongerTimeFrame.get('ACCL__User__c');
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId1];
        
        System.assertEquals(longerDateFrom, jls1.get('ACCL__Valid_From__c'));
    }
    
    /** Method to test Job List Generation when Job List is moved out of date range of Call */
    private static testMethod void test_process_cancelJL_cancelExistingJobListAndCreateNewOne_whenJobListIsMovedOutOfCallDateFrom() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        sObject call = GenerateJobListTestFactory.getDefaultCall(ct, acc);
        Date longerDateFrom = System.today();
        Date shorterDateFrom = System.today().addDays(1);
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> users = GenerateJobListTestFactory.insertUsers(2);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], shorterDateFrom, dateToForAllObjectsInTest, 'Sales', true);
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, shorterDateFrom, dateToForAllObjectsInTest);
        sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, longerDateFrom, dateToForAllObjectsInTest);
        orginalJLs[0].put('ACCL__Call__c', call.Id);
        update orginalJLs;
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        System.assertEquals(2, [SELECT count() FROM ACCL__Job_List__c]);
        
        Id userId1 = (Id)managers[0].get('ACCL__User__c');
        sObject jls1 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Done__c, ACCL__Manager__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId1 AND ACCL__Call__c != null];
        
        System.assertEquals(shorterDateFrom, jls1.get('ACCL__Valid_From__c'));
        System.assertEquals(AddOnConstants.JOB_LIST_DONE_STATUS_CANCELLED, jls1.get('ACCL__Done__c'));
        
        Id userId2 = (Id)managers[0].get('ACCL__User__c');
        sObject jls2 = [SELECT Id, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Done__c, ACCL__Manager__c, ACCL__Job_Definition_List__c FROM ACCL__Job_List__c WHERE ACCL__Manager__c = :userId2 AND ACCL__Call__c = null];
        
        System.assertEquals(shorterDateFrom, jls2.get('ACCL__Valid_From__c'));
        System.assertEquals(AddOnConstants.JOB_LIST_DONE_STATUS_NOT_DONE, jls2.get('ACCL__Done__c'));
        System.assertEquals(jdls[0].Id, jls2.get('ACCL__Job_Definition_List__c'));
    }
    
    /** Method to test Job List Generation when the Account is no longer connected to the JDL */
    private static testMethod void test_process_DeleteJL_whenAccountIsNoLongerConnectedToJDL() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        Date longerDateFrom = System.today();
        Date shorterDateFrom = System.today().addDays(1);
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> users = GenerateJobListTestFactory.insertUsers(1);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], shorterDateFrom, dateToForAllObjectsInTest, 'Sales', true);
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, shorterDateFrom, dateToForAllObjectsInTest);
		sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        jdla.put('ACCL__Excluded__c', true);
        update jdla;
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, longerDateFrom, dateToForAllObjectsInTest);
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM ACCL__Job_List__c]);
    }
	
	/** Method to test Job List Generation when the Account is no longer connected to the JDL & Job List is magnetized */
    private static testMethod void test_process_cancelOrDeleteJLs_whenAccountIsNoLongerConnectedToJDLAndOneJLIsMagnetized() {
        sObject ct = GenerateJobListTestFactory.getDefaultCallTemplate();
        sObject acc = GenerateJobListTestFactory.getDefaultAccount();
        sObject jdlt = GenerateJobListTestFactory.getDefaultJobDefinitionListTemplate_NonStandard();
        List<sObject> users = GenerateJobListTestFactory.insertUsers(2);
        sObject call = GenerateJobListTestFactory.getDefaultCall(ct, acc);
        call.put('ACCL__Responsible__c', users[0].Id);
        update call;
        Date longerDateFrom = System.today();
        Date dateToForAllObjectsInTest = System.today().addDays(50);
        List<sObject> accs = GenerateJobListTestFactory.insertBulkAccounts(1);
        List<sObject> managers = GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[0], longerDateFrom, dateToForAllObjectsInTest, 'Sales', true);
        managers.addAll(GenerateJobListTestFactory.insertAccountManagersWithDifferentDates(accs, users[1], longerDateFrom, dateToForAllObjectsInTest, 'Service', true));
        List<sObject> jdls = GenerateJobListTestFactory.insertJobDefinitionLists(1, ct, jdlt, 'Sales', AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN, longerDateFrom, dateToForAllObjectsInTest);
        sObject jdla = GenerateJobListTestFactory.getDefaultJobDefinitionListAccount_NonStandard(accs[0], jdls[0]);
        jdla.put('ACCL__Excluded__c', true);
        update jdla;
        List<sObject> orginalJLs = GenerateJobListTestFactory.insertJobLists(managers, ct, jdls, longerDateFrom, dateToForAllObjectsInTest);
        orginalJLs[0].put('ACCL__Call__c', call.Id);
        
        System.assertEquals(2, [SELECT count() FROM ACCL__Job_List__c]);
        
        GenerateJobListBatch bt = new GenerateJobListBatch();
        Test.startTest();
        Database.executeBatch(bt);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM ACCL__Job_List__c]);
    }
}
