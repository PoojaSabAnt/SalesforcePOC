/***************************************************************
Name: MDLZ_OrderConsolidationTestClass
======================================================
Purpose:
a. if an order that is in ‘Send to SAP’ does not return with ‘Received by SAP’ 
status by the time batch runs overnight (e.g. midnight), status will be updated 
from ‘Send to SAP’ to ‘Rejected’. This applies to all orders regardless of delivery date
======================================================
History
-------
VERSION     AUTHOR         REVIWER      DATE             DETAIL              Description
1.0      Bharath V            	 30/09/2021     Initial Development 
1.1      Priya Tubachi           20/05/2022     MRELKXIW-2108
1.2      Samiksha Reddy          12/09/2022     MRELKXIW-4860
***************************************************************/
@isTest
private class MDLZ_OrderConTestClass {
    
    static testMethod void testConOrder(){
        List<ACCL__Order__c>orderList = new List<ACCL__Order__c>();
        
        List<ACCL__Order_Template__c>tempList = new List<ACCL__Order_Template__c>();
        
        ACCL__Order_Template__c ordertempEdi = new ACCL__Order_Template__c(Name ='EDI',
                                                                           RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                                           ACCL__Document_Type__c='Order Entry',ACCL__Valid_Thru__c=system.today()+365,
                                                                           ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='EDI_US01',
                                                                           ACCL__Sales_Org__c='US01',ACCL__Active__c=true);
        
        tempList.add(ordertempEdi);
        
        System.assertEquals(ordertempEdi.ACCL__Sales_Org__c , 'US01');
        ACCL__Order_Template__c ordertempNos = new ACCL__Order_Template__c(Name ='NOS',
                                                                           RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                                           ACCL__Document_Type__c='Order Entry',ACCL__Valid_Thru__c=system.today()+365,
                                                                           ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='NOS_US01',
                                                                           ACCL__Sales_Org__c='US01',ACCL__Active__c=true);
        

        ACCL__Order_Template__c ordertempOrd = new ACCL__Order_Template__c(Name ='Order Wrapper',
                                                                           RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                                           ACCL__Document_Type__c='Order Entry',ACCL__Valid_Thru__c=system.today()+365,
                                                                           ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='Ord_US01',
                                                                           ACCL__Sales_Org__c='US01',ACCL__Active__c=true);
        
        
        tempList.add(ordertempNos);
        tempList.add(ordertempOrd);
        insert tempList;
        System.assertEquals(ordertempNos.ACCL__Sales_Org__c , 'US01');
        
        Account acct = new Account();
        acct.Name ='Mondelez Test';
        acct.ACCL__Account_Number__c='Demo Unique123';
        acct.Description ='Test Description';
        insert acct;      
        
        Account acct1 = new Account();
        acct1.Name ='Mondelez Test';
        acct1.ACCL__Account_Number__c='Demo Unique12';
        acct1.Description ='Test Description';
        
        insert acct1; 
        
        ACCL__Order__c order = new ACCL__Order__c();
        order.ACCL__Phase__c ='Received by SAP';
        order.ACCL__Delivery_Date__c =System.today();
        order.ACCL__Order_Account__c =acct.Id;
        order.ACCL__Order_Template__c =tempList[2].Id; 
        order.ACCL__Customer_Order_Id__c ='';
        orderList.add(order);
        
        ACCL__Order__c order2 = new ACCL__Order__c();
        order2.ACCL__Phase__c ='Locked';
        order2.ACCL__Order_Account__c =acct.Id;
        order2.ACCL__Order_Template__c =tempList[1].Id;  
        order2.ACCL__Delivery_Date__c =System.today();   
        orderList.add(order2);
        
        ACCL__Order__c order3 = new ACCL__Order__c();
        order3.ACCL__Phase__c ='Cancelled';
        order3.ACCL__Delivery_Date__c =System.today();
        order3.ACCL__Order_Account__c =acct.Id;
        order3.ACCL__Order_Template__c =tempList[0].Id; 
        order3.ACCL__Customer_Order_Id__c ='';
        orderList.add(order3);
        
        ACCL__Order__c order4 = new ACCL__Order__c();
        order4.ACCL__Phase__c ='Routed';
        order4.ACCL__Delivery_Date__c =System.today()+1;
        order4.ACCL__Order_Account__c =acct.Id;
        order4.ACCL__Order_Template__c =tempList[0].Id; 
        order4.ACCL__Customer_Order_Id__c ='';
        orderList.add(order4);
        
        ACCL__Order__c order5 = new ACCL__Order__c();
        order5.ACCL__Phase__c ='Received by SAP';
        order5.ACCL__Delivery_Date__c =System.today()+1;
        order5.ACCL__Order_Account__c =acct.Id;
        order5.ACCL__Order_Template__c =tempList[2].Id; 
        order5.ACCL__Customer_Order_Id__c ='';
        orderList.add(order5);
        
        ACCL__Order__c order6 = new ACCL__Order__c();
        order6.ACCL__Phase__c ='Locked';
        order6.ACCL__Delivery_Date__c =System.today()+1;
        order6.ACCL__Order_Account__c =acct1.Id;
        order6.ACCL__Order_Template__c =tempList[1].Id; 
        order6.ACCL__Customer_Order_Id__c ='';
        orderList.add(order6);
        
        ACCL__Order__c order7 = new ACCL__Order__c();
        order7.ACCL__Phase__c ='Received by SAP';
        order7.ACCL__Delivery_Date__c =System.today()+1;
        order7.ACCL__Order_Account__c =acct1.Id;
        order7.ACCL__Order_Template__c =tempList[2].Id; 
        order7.ACCL__Customer_Order_Id__c ='';
        orderList.add(order7);
        
        insert orderList;
        System.assertEquals(orderList[1].ACCL__Phase__c, 'Locked');
        
        Test.startTest();      
              
        SchedulableContext sc = null;
        MDLZ_UpdateCAOOrdersBatch bdsec=new MDLZ_UpdateCAOOrdersBatch();
        bdsec.execute(sc);
        
        MDLZ_UpdateCAOOrdersBatch batch2 = new MDLZ_UpdateCAOOrdersBatch();
        Database.executeBatch(batch2,100);
                
        Test.stopTest();
    }
}