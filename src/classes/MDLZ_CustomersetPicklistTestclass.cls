/***************************************************************
Name: MDLZ_CustomersetPicklistTestclass
======================================================
Purpose:
a.Fetch all the customer set description and add to custom multiselect picklist datatype
b.Based On the selection of picklist value create records and shellsheets
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0         Bharath_V                    08/17/2021     Initial Development    Test Class for MDLZ_CustomersetPicklist class  

***************************************************************/
@isTest
private class MDLZ_CustomersetPicklistTestclass {
    
    static testMethod void testClass(){
        
        ACCL__Sales_Folder_Template__c salestemp = new ACCL__Sales_Folder_Template__c();
        salestemp.Name = 'Customer Salesfolder Template';
        salestemp.ACCL__Anchor_Type__c ='Customer';
        salestemp.ACCL__Description_Language_1__c ='Test data';
        salestemp.ACCL__Sales_Org__c ='US01';
        salestemp.ACCL__Active__c = true;
       Database.insert(salestemp,false);
      
        
        ACCL__Sales_Folder__c custset = new ACCL__Sales_Folder__c(Name ='Salesdemo',ACCL__Sales_Org__c ='US01',
                                                                  ACCL__Sales_Folder_Template__c=salestemp.id,ACCL__Active__c=true,MDLZ_Unique_Name__c ='ASA-00000004' );
        
       Database.insert(custset,false);
        ACCL__Account_Template__c acctemp = new ACCL__Account_Template__c();
        acctemp.Name ='Customer Template';
        acctemp.ACCL__Initial_Roles__c ='Customer';
        acctemp.ACCL__Sales_Org__c='US01';
        acctemp.ACCL__Active__c =true;
        acctemp.ACCL__Description_Language_1__c='Test Data';
        acctemp.RecordTypeId =Schema.SObjectType.ACCL__Account_Template__c.getRecordTypeInfosByName().
            get('Customer').getRecordTypeId();
         Database.insert(acctemp,false);
     System.assertEquals('US01', acctemp.ACCL__Sales_Org__c);
        Account acct = new Account();
        acct.Name ='Demo Account';
        acct.ACCL__Account_Number__c='Demo Unique123';
        acct.Description ='Test Descr';
        acct.ACCL__Account_Template__c =acctemp.id;
        Database.insert(acct,false);
        System.assertNotEquals('US01', acct.ACCL__Sales_Org__c);
     
        
        ACCL__Account_Set__c custsets = new ACCL__Account_Set__c();
        custsets.ACCL__Description_Language_1__c ='Mondelez Description';
        custsets.ACCL__Sales_Org__c ='US01';
       Database.insert(custsets,false);
        System.assertEquals('US01', custsets.ACCL__Sales_Org__c);
       
        ACCL__Account_Set_Account__c custsetaccount = new ACCL__Account_Set_Account__c();
        custsetaccount.ACCL__Account_Set_Account__c = acct.Id;
        custsetaccount.ACCL__Account_Set__c =custsets.Id;
       Database.insert(custsetaccount,false);
       
        ACCL__Sales_Folder__c salesfold = new ACCL__Sales_Folder__c(); 
        salesfold.Name='Salesfolder Name';
        salesfold.ACCL__Active__c =true;
        salesfold.ACCL__Sales_Folder_Template__c=salestemp.Id;
        salesfold.ACCL__Description_Language_1__c ='Test Demo';
        salesfold.ACCL__Sales_Org__c=salestemp.ACCL__Sales_Org__c;
        salesfold.ACCL__Valid_From__c=system.today();
        salesfold.ACCL__Valid_Thru__c=system.today()+5;
        salesfold.ACCL__Account__c =acct.id;
        salesfold.MDLZ_Customer_Sets__c='Test Customer';
        salesfold.MDLZ_Parent_RecordId__c=custset.Id;
        salesfold.MDLZ_Unique_Name__c =custset.MDLZ_Unique_Name__c; 
        Database.insert(salesfold,false);
        
        
        ACCL__Sell_Sheet__c sellsheet = new ACCL__Sell_Sheet__c();
        sellsheet.Name = 'Sell Sheet Demo';
        sellsheet.ACCL__Active__c =true;
        sellsheet.ACCL__Description_Language_1__c ='SellSheet Test';
        sellsheet.ACCL__Sales_Org__c = custset.ACCL__Sales_Org__c;
        Database.insert(sellsheet,false);
        
        ACCL__Sales_Folder_Sell_Sheet__c salesfoldsell = new ACCL__Sales_Folder_Sell_Sheet__c();
        salesfoldsell.ACCL__Sales_Folder__c =custset.Id;
        salesfoldsell.ACCL__Sales_Org__c = custset.ACCL__Sales_Org__c;
        salesfoldsell.ACCL__Sell_Sheet__c =sellsheet.id;
        Database.insert(salesfoldsell,false);
       
        PageReference pageRef = Page.MDLZ_CustomersetPicklist;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(custset.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(custset);
        MDLZ_CustomersetPicklist controller = new MDLZ_CustomersetPicklist(sc);
        controller.selectedPicklistValues = new List<String>{'Mondelez Description','Mondelez Description-2'};
            
            Test.startTest(); 
        List<SelectOption> options = controller.getCustomerSets();
        System.debug('options' + options);
        controller.save();
        controller.getmyID();
        controller.doFinish(); 
        controller.reset();
        Test.stopTest();
        
    }
}