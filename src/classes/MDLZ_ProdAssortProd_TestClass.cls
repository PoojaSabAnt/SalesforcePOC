/***************************************************************
Name: MDLZ_ProdAssortProd_TestClass
======================================================
Purpose:

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0     Bharath Vikkurthi       		                       15/02/2022     Initial Development    

***************************************************************/

@isTest
public class MDLZ_ProdAssortProd_TestClass {
    
    static testMethod void cleanProdAssrt(){
        
        List<ACCL__Product_Template__c> prList = new List<ACCL__Product_Template__c>();
        List<ACCL__Product__c> prodList  = new List<ACCL__Product__c>();
        
        ACCL__Product_Template__c prtemp = new ACCL__Product_Template__c();
        prtemp.Name ='Product US01 Test';
        prtemp.ACCL__Active__c =true;
        prtemp.ACCL__Sales_Org__c ='US01';
        prtemp.RecordTypeId =Schema.SObjectType.ACCL__Product_Template__c.getRecordTypeInfosByName().
            get('Product').getRecordTypeId();
        prList.add(prtemp);
        System.assertEquals(prtemp.ACCL__Sales_Org__c, 'US01');
        ACCL__Product_Template__c prtemp1 = new ACCL__Product_Template__c();
        prtemp1.Name ='Product US02 Test';
        prtemp1.ACCL__Active__c =true;
        prtemp1.ACCL__Sales_Org__c ='0001';
        prtemp1.RecordTypeId =Schema.SObjectType.ACCL__Product_Template__c.getRecordTypeInfosByName().
            get('Product').getRecordTypeId();
        prList.add(prtemp1);
        insert prList;
        System.assertEquals(prList[0].ACCL__Active__c , true);
        ACCL__Product_Assortment_Template__c prasstemp = new ACCL__Product_Assortment_Template__c();
        prasstemp.Name ='Listing';
        prasstemp.ACCL__Description_Language_1__c ='Authorization List';
        prasstemp.ACCL__Sales_Org__c ='US01';
        prasstemp.RecordTypeId =Schema.SObjectType.ACCL__Product_Assortment_Template__c.getRecordTypeInfosByName().
            get('Assortment List').getRecordTypeId();
        insert prasstemp;
        
        ACCL__Product__c prd = new ACCL__Product__c();
        prd.Name ='Cookie Product 01';
        prd.ACCL__Product_Template__c =prList[0].Id;
        prd.ACCL__Product_Code__c ='1234556';
        prd.ACCL__Product_Level__c ='Product';
        prodList.add(prd);
        ACCL__Product__c prd1 = new ACCL__Product__c();
        prd1.Name ='Cookie Product 02';
        prd1.ACCL__Product_Template__c =prList[1].Id;
        prd1.ACCL__Product_Code__c ='1234552';
        prd1.ACCL__Product_Level__c ='Product1';
        prodList.add(prd1);
        insert prodList;
        
        ACCL__Product_Assortment__c prs = new ACCL__Product_Assortment__c();
        prs.Name ='US01_1017_Branch';
        prs.ACCL__Product_Assortment_Template__c =prasstemp.Id;
        prs.ACCL__Valid_From__c =System.today();
        prs.ACCL__Valid_Thru__c =System.today()+2;  
        insert prs;
        
        
        List<ACCL__Product_Assortment_Product__c> prdList = new  List<ACCL__Product_Assortment_Product__c>();
        ACCL__Product_Assortment_Product__c prdsst = new ACCL__Product_Assortment_Product__c();
        prdsst.ACCL__Product__c =prodList[0].Id;
        prdsst.ACCL__Product_Assortment__c =prs.Id;
        prdsst.ACCL__Valid_From__c =System.today();
        prdsst.ACCL__Valid_Thru__c = System.today()+2;  
        prdsst.ACCL__Active__c = true;
        prdList.add(prdsst);
        
        ACCL__Product_Assortment_Product__c prdsst2 = new ACCL__Product_Assortment_Product__c();
        prdsst2.ACCL__Product__c =prodList[0].Id;
        prdsst2.ACCL__Product_Assortment__c =prs.Id;
        prdsst2.ACCL__Active__c = true;
        prdList.add(prdsst2);
        insert prdList;
        
        ACCL__Product_Assortment_Product__c pp =[Select Id from ACCL__Product_Assortment_Product__c where id =:prdsst2.Id];
        
        Test.startTest();
        prdList[1].ACCL__Product__c =prodList[1].Id;
        
        MDLZ_ProdAssortProd_Cleanup pr = new MDLZ_ProdAssortProd_Cleanup();
        pr.getLastModrec(prdList);
        pr.getLastModrec(new List<ACCL__Product_Assortment_Product__c> {pp});
        
        MDLZ_ProdAssortProd_Batch b = new MDLZ_ProdAssortProd_Batch(1);
        Database.executeBatch(b, 1);
        SchedulableContext sc = null;
        
        MDLZ_ProdAssortProd_Batch bdsec=new MDLZ_ProdAssortProd_Batch(1);
        bdsec.execute(sc);
        Test.stopTest();
    }
}