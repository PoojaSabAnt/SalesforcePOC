/***************************************************************
Name: MDLZ_AccountTriggerHandler
===================================================================
Purpose:
a. In this after insert method will check for which all accounts don't have Prod Assortment and Prod ASsortment 
-   Account records and it will create related records for all account those who don't have.
=============================================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Vaidehi                      08/03/2022     Initial Development    
***************************************************************/
public class MDLZ_AccountTriggerHandler implements MDLZ_ITrigger {
    
    private static Boolean TriggerDisabled = false; 
    private static Id templateId;
    private static MDLZ_ErrorExceptionHandler exc ; 
    
    //Constructor for AccountTriggerHanlder class
    public MDLZ_AccountTriggerHandler() {       
        exc = new MDLZ_ErrorExceptionHandler(); 
    }
    
    //method to check is trigger disabled or not
    public Boolean isDisabled(){
        MDLZ_Trigger_Switch__c switchVar = MDLZ_Trigger_Switch__c.getInstance('MDLZ_AccountTrigger');
        if(switchVar != NULL && !switchVar.MDLZ_Active__c){ 
            TriggerDisabled=  true;
        }
        return TriggerDisabled;
    }
    
    
    //This method will be called on after insert
    public void afterInsert(Map<Id,sObject>newAccountMap) {        
        Map<Id,Account>accMap = (Map<Id, Account>)newAccountMap;
        Map<Id, Account>accountMap = new Map<Id, Account>();
        try{
            for(Account acc:accMap.values()){
                if(acc.MDLZ_SAPBranchId__c != null){                    
                    accountMap.put(acc.Id, acc);
                }}
            if(accountMap.size()>0){
                getAllProductAssortmentAccount(accountMap);
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_AccountTriggerHandler.afterInsert()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName());        
            }        
    }
    
    
    //this method will get all the accounts for whcih no schematics are there
    public static void getAllProductAssortmentAccount(Map<Id, Account>accountMap){
        //Search for all Product Assortment Account for newly added accounts
        try{ for(ACCL__Product_Assortment_Account__c  prodAAccount: [SELECT id FROM ACCL__Product_Assortment_Account__c 
                                                                     WHERE ACCL__Product_Assortment__r.name  
                                                                     LIKE: '%Schematic%' AND ACCL__Account__c  IN : accountMap.keySet()]){
                                                                         //removing the account records for which schematics are already there                      
                                                                         accountMap.remove(prodAAccount.ACCL__Account__c);                    
                                                                     }
            if( accountMap.size()>0){
                createProductAssortment(accountMap);
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_AccountTriggerHandler.getAllProductAssortmentAccount()'
                                     ,ex.getMessage(),ex.getLineNumber(),ex.getTypeName());    
            }
    }
    
    //method to create Product Assortment
    public static void createProductAssortment(Map<Id,Account>accountMap){
        templateId = getProductAssortmentTemplateName();
        list<ACCL__Product_Assortment__c> prdAList = new List<ACCL__Product_Assortment__c>();
        Map <string,ACCL__Product_Assortment__c> productAssortmentMap = new Map<string, ACCL__Product_Assortment__c>();
        Map<String, String>accProdAssMap = new Map<String, String>();
        try{
            for(Id accID : accountMap.keySet()){
                ACCL__Product_Assortment__c pAssortment  = new ACCL__Product_Assortment__c();
                string uniqueKey = 'US01_'+accountMap.get(accID).ACCL__Account_Number__c+'__Schematic';
                pAssortment.Name =uniqueKey;
                pAssortment.ACCL__Product_Assortment_Template__c = templateId;
                pAssortment.ACCL__Valid_Thru__c = DATE.valueOf(system.label.MDLZ_Valid_Through_Date) ;
                pAssortment.ACCL__Valid_From__c = system.today(); 
                pAssortment.ACCL__Description_Language_1__c =uniqueKey;
                pAssortment.MDLZ_ExternalId__c =  uniqueKey;
                accProdAssMap.put(uniqueKey, accID);
                prdAList.add(pAssortment);	
            }
            if(prdAList.size()> 0){
                //inserting all product assortment records
                List<Database.SaveResult>prodAssortmentResultList = database.insert(prdAList, false);
                //For success record all the values will get added to map which has externalid as key and record as value
                for(Integer index = 0; index < prodAssortmentResultList.size(); index++) {
                    if(prodAssortmentResultList [index].isSuccess()) {
                        //in map adding product assortment records
                        productAssortmentMap.put(prdAList[index].MDLZ_ExternalId__c,prdAList[index]);
                    }}      
                exc.saveResultErrors(prodAssortmentResultList,prdAList,
                                     'MDLZ_AccountTriggerhandler.afterUpdate()','ACCL__Product_Assortment__c','Id');
            }
            if(productAssortmentMap.size()>0){
                //after creating product assortment,createProductAssortmentAccountmethod() is used to create product assortment account records
                createProductAssortmentAccount(productAssortmentMap,accProdAssMap, accountMap);  
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_AccountTriggerHandler.createProductAssortment()',
                                     ex.getMessage(),ex.getLineNumber(),ex.getTypeName());   
            }
        // return accProdAssMap;
    }
    
    //This method will create Product Assortment  Account
    public static void createProductAssortmentAccount(Map <string,ACCL__Product_Assortment__c>productAssortmentMap,
                                                      Map<String, String>accProdAssMap, Map<Id, Account>accountMap){
        List<ACCL__Product_Assortment_Account__c> pAAList = new List<ACCL__Product_Assortment_Account__c>();
        try{ for(ACCL__Product_Assortment__c pAssortment: productAssortmentMap.values()){
            if(accProdAssMap.containsKey(pAssortment.MDLZ_ExternalId__c)){
                ACCL__Product_Assortment_Account__c pAAccount = new ACCL__Product_Assortment_Account__c();
                pAAccount.ACCL__Account__c = accProdAssMap.get(pAssortment.MDLZ_ExternalId__c);
                pAAccount.ACCL__Product_Assortment__c = pAssortment.id;
                pAAccount.ACCL__Valid_From__c = system.today();
                pAAccount.ACCL__Valid_Thru__c = DATE.valueOf(system.label.MDLZ_Valid_Through_Date);
                //to create external id we are using account map to get account number
                pAAccount.MDLZ_ExternalId__c ='US01_'+accountMap.get(accProdAssMap.get(pAssortment.MDLZ_ExternalId__c)).
                    ACCL__Account_Number__c+'_Schematic_Store';
                pAAList.add(pAAccount);
            }}
            if(pAAList.size()>0){
                //inserting all the product assortment account records	
                List<Database.SaveResult>prodAAccResultList = database.insert(pAAList, false);
                exc.saveResultErrors(prodAAccResultList,pAAList,'MDLZ_AccountTriggerhandler.createProductAssortmentAccount()',
                                     'ACCL__Product_Assortment_Account__c','ACCL__Account__c');
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_AccountTriggerHandler.createProductAssortmentAccount()',
                                     ex.getMessage(),ex.getLineNumber(),ex.getTypeName());   
            }
    }
    
    //fetching Product Assortment template id for 'Store Non-Listing'
    public static Id getProductAssortmentTemplateName(){
        try{templateId = [SELECT id, name FROM ACCL__Product_Assortment_Template__c 
                          WHERE Name=: label.MDLZ_Product_Assortment_Template_Non_Listsing LIMIT 1].id;
           }catch(Exception ex){
               exc.insertExceptions('MDLZ_AccountTriggerHandler.createProductAssortmentAccount()',
                                    ex.getMessage(),ex.getLineNumber(),ex.getTypeName());  
           }return templateId;}
    
    //This method is called on before insert
    public void beforeInsert(List<Account> newAccountList){}
    //This method will be called on before delete action
    public void beforeDelete(Map<Id, sObject> oldItems) {}
    //This method will be called on after update action
    public void afterUpdate(Map<Id, sObject> newAccountMap, Map<Id, sObject> oldAccountMap) {}
    //This method will be called on before update action
    public void beforeUpdate(Map<Id, sObject> newItems, Map<Id, sObject> oldItems) {} 
    //This method will be called on after delete action
    public void afterDelete(Map<Id, sObject> oldItems) {}
    //This method will be called on after undelete action
    public void afterUndelete(Map<Id, SObject> oldItems) {}
    
}