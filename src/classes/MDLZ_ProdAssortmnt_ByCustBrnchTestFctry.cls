/***************************************************************
Name: MDLZ_ProdAssortmnt_ByCustBrnchTestFctry
======================================================
Purpose:
Test Factory for MDLZ_ProdAssortment_ByCustBranchBatch
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                11/02/2022     Initial Development    

***************************************************************/

public class MDLZ_ProdAssortmnt_ByCustBrnchTestFctry {
    private static MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
    public static void createCustomSettings (){
        try{
            MDLZ_LastmodifiedDate__c trgs = new MDLZ_LastmodifiedDate__c();
            trgs.MDLZ_NoOfDays__c = 2;
            trgs.Name ='MDLZ_ProdAssortBranch';
            insert trgs;
            System.assertEquals(trgs.MDLZ_NoOfDays__c, 2);
        }catch(Exception ex){
            exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.createCustomSettings()',ex.getMessage(),
                                 ex.getLineNumber(),ex.getTypeName());
        }
    }                           
    
    public static ACCL__Account_Template__c insertAccTemplate(){
        ACCL__Account_Template__c acctemp = new ACCL__Account_Template__c();
        try{
            acctemp.Name ='Customer Template';
            acctemp.ACCL__Initial_Roles__c ='Customer';
            acctemp.ACCL__Sales_Org__c='US01';
            acctemp.ACCL__Active__c =true;
            acctemp.ACCL__Description_Language_1__c='Test Data';
            acctemp.RecordTypeId =Schema.SObjectType.ACCL__Account_Template__c.getRecordTypeInfosByName().
                get('Customer').getRecordTypeId();
            insert acctemp;
            // System.assertEquals(acctemp.ACCL__Sales_Org__c,'US01');
        }
        catch(Exception ex){
            exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccTemplate()',ex.getMessage(),
                                 ex.getLineNumber(),ex.getTypeName());
        }  
        return acctemp;
    }
    
    public static List<Account> insertAccount(Integer cnt){
        List<Account> accList = new List<Account>();
        try{
            for(Integer i=0; i<cnt; i++) {
                Account acct = new Account();
                acct.Name ='Demo Account';
                acct.ACCL__Account_Number__c='Demo Unique123'+i;
                acct.Description ='Test Descr';
                acct.ACCL__Account_Template__c =insertAccTemplate().id;
                acct.MDLZ_SAPBranchId__c ='234'+i;
                accList.add(acct);
            }       
            insert accList;
            //System.assertEquals('Demo Account', accList[0].Name); 
            
        }catch(Exception ex){
            exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertAccount()',ex.getMessage(),
                                 ex.getLineNumber(),ex.getTypeName());
        } 
        return accList;
    }
    
    public static ACCL__Product_Assortment_Template__c insertProductAssortmentTemplate() {
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType='ACCL__Product_Assortment_Template__c' 
                         AND DeveloperName='Assortment_List'];
        ACCL__Product_Assortment_Template__c pat = new ACCL__Product_Assortment_Template__c();
        try{
            pat.Name = 'listing';
            pat.ACCL__Account_Multiplicity__c = 'Exactly One';
            pat.ACCL__Active__c = true;
            pat.ACCL__Description_Language_1__c = 'English';
            pat.RecordTypeId = rt.Id;
            pat.ACCL__Sales_Org__c = 'US01';
            
            insert pat;
            System.assertEquals(pat.ACCL__Sales_Org__c, 'US01');
        }catch(Exception ex){
            exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentTemplate()',ex.getMessage(),ex.getLineNumber(),
                                 ex.getTypeName());
        } 
        return pat;
    }
    
    public static ACCL__Product_Assortment__c getProductAssortmentWithValidRange(Date validFrom, Date validThru, 
                                                                                 sObject productAssortmentTemplate) {
                                                                                     ACCL__Product_Assortment__c prodAssort = new ACCL__Product_Assortment__c();
                                                                                     try{
                                                                                         prodAssort.name ='testName';
                                                                                         prodAssort.ACCL__Product_Assortment_Template__c = productAssortmentTemplate.Id;
                                                                                         prodAssort.ACCL__Valid_From__c = validFrom;
                                                                                         prodAssort.ACCL__Valid_Thru__c = validThru;
                                                                                         prodAssort.ACCL__Description_Language_1__c='English'; 
                                                                                         insert prodAssort;
                                                                                         System.assertEquals('testName', prodAssort.Name); 
                                                                                     }catch(Exception ex){
                                                                                         exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.getProductAssortmentWithValidRange()',ex.getMessage(),
                                                                                                              ex.getLineNumber(),ex.getTypeName());
                                                                                     } 
                                                                                     return prodAssort;
                                                                                 }
    
    
    public static ACCL__Product_Assortment_Account__c insertProductAssortmentAccount
        (sObject productAssortment, sObject account) {
            ACCL__Product_Assortment_Account__c prodAssortAcc = new ACCL__Product_Assortment_Account__c();
            try{
                prodAssortAcc.ACCL__Account__c= account.Id;
                prodAssortAcc.ACCL__Product_Assortment__c= productAssortment.Id;
                prodAssortAcc.ACCL__Valid_From__c=System.today();
                prodAssortAcc.ACCL__Valid_Thru__c= System.today().addYears(1);
                insert prodAssortAcc;
                System.assertEquals(System.today(), prodAssortAcc.ACCL__Valid_From__c); 
            }catch(Exception ex){
                exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccount()',ex.getMessage(),
                                     ex.getLineNumber(),ex.getTypeName());
            } 
            return prodAssortAcc;     
        }
    
    public static ACCL__Product_Assortment_Account__c insertProductAssortmentAccountInValid(sObject productAssortment,
                                                                                            sObject account) {
                                                                                                ACCL__Product_Assortment_Account__c prodAssortAcc = new ACCL__Product_Assortment_Account__c();
                                                                                                try{
                                                                                                    prodAssortAcc.ACCL__Account__c= account.Id;
                                                                                                    prodAssortAcc.ACCL__Product_Assortment__c= productAssortment.Id;
                                                                                                    prodAssortAcc.ACCL__Valid_From__c=System.today().addYears(-3);
                                                                                                    prodAssortAcc.ACCL__Valid_Thru__c= System.today().addYears(-1);
                                                                                                    insert prodAssortAcc;
                                                                                                    System.assertEquals(System.today().addYears(-3), prodAssortAcc.ACCL__Valid_From__c);             
                                                                                                }catch(Exception ex){
                                                                                                    exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentAccountInValid()',ex.getMessage(),
                                                                                                                         ex.getLineNumber(),ex.getTypeName());
                                                                                                } 
                                                                                                return prodAssortAcc;
                                                                                            }
    
    public static ACCL__Product_Assortment_Store__c insertProductAssortmentStore(sObject productAssort, sObject acc) {
        ACCL__Product_Assortment_Store__c prodAssortStore = new ACCL__Product_Assortment_Store__c();
        try{
            prodAssortStore.ACCL__Store__c= acc.Id;
            prodAssortStore.ACCL__Assortment__c= productAssort.Id;
            insert prodAssortStore;
            // System.assertEquals(prodAssortStore.ACCL__Assortment__c,productAssort.Id);            
        }catch(Exception ex){
            exc.insertExceptions('MDLZ_ProdAssortmnt_ByCustBrnchTestFctry.insertProductAssortmentStore()',ex.getMessage(),
                                 ex.getLineNumber(),ex.getTypeName());
        } 
        return prodAssortStore;
    }
}