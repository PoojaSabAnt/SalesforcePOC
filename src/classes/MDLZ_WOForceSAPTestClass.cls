@isTest
private class MDLZ_WOForceSAPTestClass {
    
    static testMethod void mdlzOrderReject(){
        
        System.assertEquals(MDLZ_ConstantHelper.PhaseSentToSAP,'Send to SAP');
        System.assertEquals(MDLZ_ConstantHelper.PhaseRejected,'Rejected');
        System.assertEquals(MDLZ_ConstantHelper.ReceivedBySAP,'Received By SAP');
        System.assertEquals(MDLZ_ConstantHelper.ChangeTrue,'TRUE');
        System.assertEquals(MDLZ_ConstantHelper.ChangeFalse,'FALSE');        
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
        
        list<ACCL__Order__c>Ordlist=new list<ACCL__Order__c>();
        for(integer i = 0; i < 10; i++) {
            ACCL__Order__c ord = new ACCL__Order__c();
            ord.ACCL__Phase__c ='Send to SAP';
            ord.ACCL__Delivery_Date__c =System.today()+i;
            ord.ACCL__Order_Account__c =acct.Id;
            ord.MDLZ_isChanged__c =MDLZ_ConstantHelper.ChangeFalse;
            ord.ACCL__Order_Template__c =ordertempEdi.Id;
            Ordlist.add(ord);
        }
        insert Ordlist;
        Ordlist =[Select Id, name,ACCL__Phase__c from ACCL__Order__c where Id =:Ordlist[0].Id];
        Ordlist[0].ACCL__Phase__c = MDLZ_ConstantHelper.ReceivedBySAP;
        update Ordlist;
        
        Test.startTest();
        MDLZ_WOForceSAPReceivedBatch batch = new MDLZ_WOForceSAPReceivedBatch(200);
        Database.executeBatch(batch);
        Database.QueryLocator ql = batch.start(null);
        batch.execute(null,Ordlist);
        batch.Finish(null);
        
        Test.stopTest();
        
    }
}