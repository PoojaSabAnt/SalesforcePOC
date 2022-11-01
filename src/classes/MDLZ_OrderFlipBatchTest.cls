/***************************************************************
Name: MDLZ_OrderFlipBatchTest
======================================================
Purpose:
Test class for MDLZ_OrderFlipBatch class 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Vaidehi Heda              20/04/2022     Initial Development 
1.1      Vaidehi Heda              10/05/2022     Added other method to cover else if condition

***************************************************************/
@isTest
private class MDLZ_OrderFlipBatchTest {
    static testMethod void createLineItem(){
        List<ACCL__Order_Item__c> ordItemList ;
        List<MDLZ_Orders_To_Flip__c> flipList ;
        test.startTest();
        system.runAs(MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM)){
            integer defaultChildBatchSize = integer.valueOf(Label.MDLZ_OrderFlipBatch);
            MDLZ_OrderFlipBatch batch = new MDLZ_OrderFlipBatch(defaultChildBatchSize);             
            ordItemList = MDLZ_TestDataFactory.insertOrderLineItem(1, true);
            MDLZ_Orders_To_Flip__c flip = new MDLZ_Orders_To_Flip__c(OrderID__c=ordItemList[0].ACCL__Order__c, MDLZ_Is_Order_Accepted__c = true);
            insert flip;
            SchedulableContext ctx = null;
            batch.execute(ctx);
            //Database.executeBatch(new MDLZ_OrderFlipBatch(defaultChildBatchSize), defaultChildBatchSize);
            delete ordItemList;
            batch.execute(ctx);
            undelete ordItemList;
            test.stopTest();           
        }
        system.assertEquals(ordItemList.size(), 1)  ;
    }
    
    //covering other else if condition
    static testMethod void createLineItem2(){
        List<ACCL__Order__c>ordList;
        List<ACCL__Order_Item__c> ordItemList ;
        test.startTest();
        system.runAs(MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM)){
            integer defaultChildBatchSize = integer.valueOf(Label.MDLZ_OrderFlipBatch);
            MDLZ_OrderFlipBatch batch = new MDLZ_OrderFlipBatch(defaultChildBatchSize);
            ordList =MDLZ_TestDataFactory.insertOrder(1, False);
            ordList[0].MDLZ_isOrderAccepted__c = false;
            ordList[0].ACCL__Phase__c= MDLZ_ConstantHelper.PhaseRejected;
            insert ordList; 
            ordList[0].ACCL__Phase__c= MDLZ_ConstantHelper.PhaseDeleted;
            update ordList;
            ordItemList = MDLZ_TestDataFactory.insertOrderLineItem(1, false);
            ordItemList[0].ACCL__Order__c = ordList[0].id;
            insert ordItemList;
            SchedulableContext ctx = null;
            batch.execute(ctx);
        }
        test.stopTest();  
    }
    
    //covering wrapper order condition
    static testMethod void createWrapperOrder(){
        test.startTest();
        system.runAs(MDLZ_TestDataFactory.getUser(MDLZ_ConstantHelper.UserPermOPSADM)){
            integer defaultChildBatchSize = integer.valueOf(Label.MDLZ_OrderFlipBatch);
            MDLZ_OrderFlipBatch batch = new MDLZ_OrderFlipBatch(defaultChildBatchSize);
            List<ACCL__Order__c> ordList =MDLZ_TestDataFactory.insertWrapperOrder(1, true);
            SchedulableContext ctx = null;
            batch.execute(ctx);
        }
        test.stopTest();
    }
}