/***************************************************************
Name: MDLZ_ProductUnitFlagTestClass
======================================================
Purpose:
a.Update the UOM for each product as an interim fix for SAP issue
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0     Bharath V       		 27/09/2021     Initial Development 
1.1     Vaidehi Heda              25/03/2022    MAde changes as per Nova Report

***************************************************************/

@isTest
Private class MDLZ_ProductUnitFlagTestClass {
    
    static testMethod void unitMeasure(){
        List<ACCL__Product__c>prodList = new List<ACCL__Product__c>();
        List<ACCL__Unit_of_Measure__c>uomList = new List<ACCL__Unit_of_Measure__c>();
        Test.startTest();
        
        //insert PRoduct Template
        ACCL__Product_Template__c ptemp = new ACCL__Product_Template__c();
        ptemp.Name ='Product Group US01';
        ptemp.ACCL__Description_Language_1__c='Product Group US01';
        ptemp.ACCL__Sales_Org__c ='US01';
        ptemp.RecordTypeId =Schema.SObjectType.ACCL__Product_Template__c.getRecordTypeInfosByName().get('Product').getRecordTypeId();
        ptemp.ACCL__Active__c =true;    
        insert ptemp;
        
        
        ACCL__Product__c prod = new ACCL__Product__c(Name ='Mondelez Product',ACCL__Product_Level__c ='Product',
                                                     ACCL__ExternalId__c='US01POSM0001', ACCL__Product_Template__c=ptemp.id,ACCL__Product_Code__c='US01POSM0001',
                                                     RecordTypeId =Schema.SObjectType.ACCL__Product__c.getRecordTypeInfosByName().get('Product Group').getRecordTypeId());
        
        insert prod;
        ACCL__Product__c prod2 = new ACCL__Product__c(Name ='Mondelez Product2',ACCL__Product_Level__c ='Product',
                                                      ACCL__Criterion_1_Product__c=prod.id,ACCL__Product_Template__c=ptemp.id);
        
        prodList.add(prod2);
        
        ACCL__Product__c prod3 = new ACCL__Product__c(Name ='Mondelez Product3',ACCL__Product_Level__c ='Product',
                                                      ACCL__Criterion_1_Product__c=prod.id,ACCL__Product_Template__c=ptemp.id);
        
        prodList.add(prod3);        
        insert prodList;        
        
        //Insert UOM
        ACCL__Unit_of_Measure__c unitmeasure = new ACCL__Unit_of_Measure__c();        
        unitmeasure.ACCL__Product__c = prodList[1].Id;
        unitmeasure.ACCL__Unit_Type__c ='ConsumerUnit';
        unitmeasure.ACCL__Sort__c =1;
        unitmeasure.ACCL__Is_Price_Unit__c = false;
        unitmeasure.ACCL__Is_Consumer_Unit__c = false;
        unitmeasure.ACCL__Is_Order_Unit__c = true;
        unitmeasure.ACCL__Order_Ability__c = true;
        uomList.add(unitmeasure);
        
        prod2 = [select id , name , ACCL__Criterion_1_Product_Code__c from ACCL__Product__c where id =: prodList[0].id];
        system.assertEquals('US01POSM0001',prod2.ACCL__Criterion_1_Product_Code__c);
        
        ACCL__Unit_of_Measure__c unitmeasure1 = new ACCL__Unit_of_Measure__c(); 
        unitmeasure1.ACCL__Product__c = prodList[1].Id;
        unitmeasure1.ACCL__Unit_Type__c ='Sales Unit';
        unitmeasure1.ACCL__Sort__c =2;
        unitmeasure1.ACCL__Is_Price_Unit__c = true;
        unitmeasure1.ACCL__Is_Consumer_Unit__c = false;
        unitmeasure1.ACCL__Is_Order_Unit__c = true;
        unitmeasure1.ACCL__Order_Ability__c = true;        
        uomList.add(unitmeasure1);
        
        ACCL__Unit_of_Measure__c unitmeasure2 = new ACCL__Unit_of_Measure__c();        
        unitmeasure2.ACCL__Product__c = prodList[0].id;
        unitmeasure2.ACCL__Unit_Type__c ='SalesUnit';
        unitmeasure2.ACCL__Sort__c =3;
        unitmeasure2.ACCL__Is_Price_Unit__c = true;
        unitmeasure2.ACCL__Is_Consumer_Unit__c = false;
        unitmeasure2.ACCL__Is_Order_Unit__c = true;
        unitmeasure2.ACCL__Order_Ability__c = true;
        uomList.add(unitmeasure2);
        
        database.insert(uomList);
        
        MDLZ_ProductUnitFlagChange pr = new MDLZ_ProductUnitFlagChange();
        pr.ConsumerSalesUnitChange(new List<ACCL__Unit_of_Measure__c> {uomList[0]});
        pr.ConsumerSalesUnitChange(new List<ACCL__Unit_of_Measure__c> {uomList[1]});
        
        Test.stopTest();  
    }
    
    
}