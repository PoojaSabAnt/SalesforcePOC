/***************************************************************
Name: MDLZ_OrderTriggerTestClass
======================================================
Purpose:

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                11/02/2022     Initial Development    

***************************************************************/
@isTest
private class MDLZ_OrderTriggerTestClass {
    
    
    static testMethod void mdlzOrderReject(){
        List<ACCL__Order__c> ordList = new List<ACCL__Order__c>();
        Profile p1 = [select Id from Profile  where Name ='System Administrator']; 
        
        Profile p2 = [select Id from Profile  where Name ='MDLZ_Integration_User']; 
        User opUser = new User(alias = 'mdlz', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='01 Inbound AltREXwedcxss', languagelocalekey='en_US',IsActive=true,
                               localesidkey='en_US', profileid = p2.Id, country='United States',
                               timezonesidkey='America/Los_Angeles', username='test022al1@noemail.com', ACCL__Sales_Org__c='US01'); 
        
        
        User opUser2 = new User(alias = 'mdlz', email='test1234@noemail.com',
                                emailencodingkey='UTF-8', lastname='01 Inbound AltREXs', languagelocalekey='en_US',IsActive=true,
                                localesidkey='en_US', profileid = p1.Id, country='United States',
                                timezonesidkey='America/Los_Angeles', username='test001@noemail.com', ACCL__Sales_Org__c='US01'); 
        
        
        Account acct = new Account();
        acct.Name ='Mondelez Test Account';
        acct.ACCL__Account_Number__c='Demo Unique123';
        acct.Description ='Test Description';
        
        insert acct;
        
        ACCL__Order_Template__c ordertempEdi = new ACCL__Order_Template__c(Name ='EDI',
                                                                           RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                                           ACCL__Document_Type__c='Order Entry',ACCL__Valid_Thru__c=system.today()+365,
                                                                           ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='EDI_US01',
                                                                           ACCL__Sales_Org__c='US01',ACCL__Active__c=true);
        
        insert ordertempEdi;
        System.assertEquals(ordertempEdi.ACCL__Sales_Org__c , 'US01');
        MDLZ_Object_Logging__c trgs = new MDLZ_Object_Logging__c();
        trgs.MDLZ_isActive__c = true;
        trgs.MDLZ_LoggingObjectName__c ='Order';
        trgs.Name ='Order';
        insert trgs;
        
        ACCL__Order__c ord = new ACCL__Order__c();
        ord.MDLZ_LastSavedByUser__c = system.today() - 10;
        ord.ACCL__Phase__c ='Cancelled';
        ord.ACCL__Delivery_Date__c =System.today()+363;
        ord.ACCL__Order_Account__c =acct.Id;
        ord.ACCL__Order_Template__c =ordertempEdi.Id;
        ord.MDLZ_isChanged__c='True';
        ord.MDLZ_isOrderAccepted__c =true;
        ord.ACCL__Customer_Order_Id__c ='1234567899 ';
        ordList.add(ord);
        
        ACCL__Order__c ords = new ACCL__Order__c();
        ords.MDLZ_LastSavedByUser__c = system.today() - 10;
        ords.ACCL__Phase__c ='Routed';
        ords.ACCL__Delivery_Date__c =System.today()+363;
        ords.ACCL__Order_Account__c =acct.Id;
        ords.ACCL__Order_Template__c =ordertempEdi.Id;
        ords.MDLZ_isChanged__c='FALSE';
        ords.ACCL__Customer_Order_Id__c ='t6eteyue';
        ordList.add(ords);
        Database.insert(ordList) ;
        System.assertEquals(ordList[1].ACCL__Phase__c,'Routed');
      
        ACCL__Order_Item__c oItem = new ACCL__Order_Item__c(ACCL__Suggested_Quantity__c =2, MDLZ_BkpSuggestedQty__c =2 ,
                                                            ACCL__Order__c =ordList[0].id);
        insert oItem;
        
        if(ordList[0].ACCL__Phase__c != MDLZ_ConstantHelper.open){
            ordList[0].MDLZ_isChanged__c = MDLZ_ConstantHelper.ChangeFalse;
        }
        update ordList;
        
        
        
        ordList[0].ACCL__Phase__c ='Received By SAP';
        update ordList;
        ordList[0].ACCL__Phase__c='Routed';
        update ordList;
        System.assertEquals(ordList[0].ACCL__Phase__c,'Routed');
        
        
      
        
        ordList[1].ACCL__Phase__c ='Received By SAP';
        update ordList;
        ordList[1].ACCL__Phase__c='Routed';
      
        update ordList;
          
        MDLZ_OrderTriggerHandler pr3 = new MDLZ_OrderTriggerHandler();
        pr3.ResetIsChanged(new List<ACCL__Order__c> {ordList[0]});
        
        System.runAs(opUser){
            Test.startTest();
            ords.ACCL__Customer_Order_Id__c =null ;
            ords.ACCL__Phase__c =null;           
            update ordList[1];            
            Test.stopTest();             
        }
        
       
        System.runAs(opUser){
            ord.MDLZ_isOrderAccepted__c = false;
            update ord;
            MDLZ_OrderTriggerHandler pr = new MDLZ_OrderTriggerHandler();
            pr.ResetIsChanged(new List<ACCL__Order__c> {ordList[0]});
             
        }        
        
        
    }
    
    
}