/***************************************************************
Name: MDLZ_AddCustomerSetToCustomerTaskTest
======================================================
Purpose:
Tset class for MDLZ_AddCustomerSetToCustomerTask and MDLZ_CustomerTaskTrigger
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0         Namitha_Francis     Vaidehi       07/06/2021     Initial Development   
***************************************************************/
@isTest
private class MDLZ_AddCustomerSetToCustomerTaskTest {
    
    
    static testMethod void testClass(){
        
     Map<Id, ACCL__Account_Task__c> customerTaskMap = new Map<Id, ACCL__Account_Task__c>();
        Map<Id, ACCL__Account_Task__c> customerTaskMapOld = new Map<Id, ACCL__Account_Task__c>();
        //Customer Task Template
        ACCL__Account_Task_Template__c customerTaskTemp = new ACCL__Account_Task_Template__c();
        customerTaskTemp.Name = 'Customer Announcement Template';
        customerTaskTemp.ACCL__Description_Language_1__c ='Test data';
        customerTaskTemp.ACCL__Sales_Org__c ='US01';
        customerTaskTemp.ACCL__Active__c = true;
        Database.insert(customerTaskTemp,false);
      
        //Account Template
        ACCL__Account_Template__c acctemp = new ACCL__Account_Template__c();
        acctemp.Name ='Customer Template';
        acctemp.ACCL__Initial_Roles__c ='Customer';
        acctemp.ACCL__Sales_Org__c='US01';
        acctemp.ACCL__Active__c =true;
        acctemp.ACCL__Description_Language_1__c='Test Data';
        acctemp.RecordTypeId =Schema.SObjectType.ACCL__Account_Template__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Database.insert(acctemp,false);
     System.assertEquals('US01', acctemp.ACCL__Sales_Org__c);
     
        //Acount
        Account acct = new Account();
        acct.Name ='Demo Account';
        acct.ACCL__Account_Number__c='Demo Unique123';
        acct.Description ='Test Descr';
        acct.ACCL__Account_Template__c =acctemp.id;
        Database.insert(acct,false);
        System.assertNotEquals('US01', acct.ACCL__Sales_Org__c);
        
        Account acct1 = new Account();
        acct1.Name ='Demo Account';
        acct1.ACCL__Account_Number__c='Demo Unique123';
        acct1.Description ='Test Descr';
        acct1.ACCL__Account_Template__c =acctemp.id;
        Database.insert(acct1,false);
        System.assertNotEquals('US01', acct1.ACCL__Sales_Org__c);
     
        //Customer Set
        ACCL__Account_Set__c custSet = new ACCL__Account_Set__c();
        custSet.ACCL__Description_Language_1__c ='Mondelez Description';
        custSet.ACCL__Sales_Org__c ='US01';
       Database.insert(custSet,false);
        System.assertEquals('US01', custSet.ACCL__Sales_Org__c);
       
       //Customer set account
        ACCL__Account_Set_Account__c custSetaccount = new ACCL__Account_Set_Account__c();
        custSetaccount.ACCL__Account_Set_Account__c = acct1.Id;
        custSetaccount.ACCL__Account_Set__c =custSet.Id;
       Database.insert(custSetaccount,false);
       
       //Customer Task
        List<ACCL__Account_Task__c> custTaskList = new List<ACCL__Account_Task__c>(); 
        ACCL__Account_Task__c custTask = new ACCL__Account_Task__c(); 

        custTask.ACCL__Account_Task_Template__c=customerTaskTemp.Id;
        custTask.ACCL__Description_Language_1__c ='Test Demo';
        custTask.ACCL__Sales_Org__c=customerTaskTemp.ACCL__Sales_Org__c;
        custTask.ACCL__Due_Date__c=system.today()+5;
        custTask.ACCL__Account__c =acct.id;
        custTask.MDLZ_Master_Record__c = custTask.Id;
        custTask.ACCL__Priority__c ='A';
        custTask.MDLZ_Customer_Sets__c=custSet.Id;
        custTask.MDLZ_Parent_RecordId__c=custTask.Id;
        custTask.MDLZ_Unique_Name__c =custTask.MDLZ_Unique_Name__c; 
        Database.insert(custTask,false);
        
        custTaskList.add(custTask);
    //vf page
        PageReference pageRef = Page.MDLZ_AddCustomerSetToCustomerTask;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(custTask.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(custTask);
        MDLZ_AddCustomerSetToCustomerTask controller = new MDLZ_AddCustomerSetToCustomerTask(sc);
        controller.selectedPicklistValues = new List<String>{'Mondelez Description','Mondelez Description-2'};
            
        Test.startTest(); 
        List<SelectOption> options = controller.getCustomerSets();
        System.debug('options' + options);
        controller.save();
        controller.getmyID();
        controller.doFinish(); 
        controller.reset();
        Test.stopTest();
        
        Delete custTaskList; 
        
        //calling the methods
        MDLZ_CustomerTaskTriggerHandler triggerHandler = new MDLZ_CustomerTaskTriggerHandler();
    triggerHandler.beforeInsert(custTaskList);
        triggerHandler.afterDelete(customerTaskMap);
        triggerHandler.afterInsert(customerTaskMap);
        triggerHandler.AfterUndelete(customerTaskMap);
        triggerHandler.BeforeDelete(customerTaskMap);
        triggerHandler.afterUpdate(customerTaskMap,customerTaskMapOld);
        triggerHandler.beforeUpdate(customerTaskMap,customerTaskMapOld);
    
     /*List<ACCL__Account_Task__c> custTaskList11 = MDLZ_TestDataFactory.insertCustomerTask(1,false);
        custTaskList11[0].ACCL__Account__c = acct.Id;
        insert custTaskList11[0]; 
        
        delete custTaskList11;*/    
    }
    @isTest 
        static void testSaveErrorExceptions(){
        
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<Database.UpsertResult> upsertcustomerSetList;
        List<ACCL__Account_Set__c> custSetList = MDLZ_TestDataFactory.insertCustomerSetList(5,true);   
        system.assertEquals(5, custSetList.size());
        List<ACCL__Account_Task__c> custTaskList = MDLZ_TestDataFactory.insertCustomerTask(5,true);   
        system.assertEquals(5, custTaskList.size());
            
        Test.startTest();
        
        srList = Database.update(custTaskList,false);
        upsertcustomerSetList = Database.upsert(custSetList,false);
        exc.saveResultErrors(srList,custTaskList,'MDLZ_AddCustomerSetToCustomerTaskTest().testSaveErrorExceptions','ACCL__Account_Task__c', 'Name');
        exc.upsertResultErrors(upsertcustomerSetList,custSetList,'MDLZ_AddCustomerSetToCustomerTaskTest().testSaveErrorExceptions','ACCL__Account_Set__c');
       
        Test.stopTest();            
    }
    @isTest 
        static void testInsertErrorExceptions(){
        test.startTest();
        List<ACCL__Account_Task__c> custTaskList = MDLZ_TestDataFactory.insertCustomerTask(2,true);          
         system.debug(custTaskList);
        update custTaskList;
        delete custTaskList;
        test.stopTest();
        
    }
    @isTest 
        static void testDelete(){
        ACCL__Account_Task__c custTaskParent = MDLZ_TestDataFactory.insertCustomerTask(); 
        ACCL__Account_Task__c custTaskChild = MDLZ_TestDataFactory.insertCustomerTask();
        custTaskChild.MDLZ_Parent_RecordId__c = custTaskParent.Id;
        update custTaskChild;
        test.startTest();
        delete custTaskParent ;
        test.stopTest();       
    }
    
    @isTest
    static void testDeleteSwitchOff(){
        ACCL__Account_Task__c custTaskParent = MDLZ_TestDataFactory.insertCustomerTask(); 
        ACCL__Account_Task__c custTaskChild = MDLZ_TestDataFactory.insertCustomerTask();
        custTaskChild.MDLZ_Parent_RecordId__c = custTaskParent.Id;
        update custTaskChild;
        MDLZ_Trigger_Switch__c s = new MDLZ_Trigger_Switch__c ();
        s.name = 'MDLZ_CustomerTaskTrigger';
        s.MDLZ_Active__c = False;
        insert s;
        test.startTest();
        delete custTaskParent ;
        test.stopTest();       
    }
}