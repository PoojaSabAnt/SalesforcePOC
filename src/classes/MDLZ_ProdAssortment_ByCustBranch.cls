/***************************************************************
Name: MDLZ_ProdAssortment_ByCustBranch
======================================================
Purpose:
1. If Account/Store changes Branch assignment, Branch product listing is updated for 
the store and changes are synced to mobile device
2. Products that no longer exist in updated Branch are removed from mobile app ordering
3. Products that are available in the new Branch and not available in the old branch are
available in mobile app ordering.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                09/02/2022     Initial Development   

***************************************************************/
public with sharing class MDLZ_ProdAssortment_ByCustBranch {
    
    public void updateProductAssortment(List<Account> accList){
        
        //variable initializations
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        Map<String, id> prodAssortments = new Map<string, id>();
        List<String> listAccountUpdatedInserted = new List<String>();
        List<String> acctoDelete = new List<String>();
        ACCL__Product_Assortment_Account__c prodAssortAccount;
        
        
        system.debug('Size of account list '+accList.size());
        List<ACCL__Product_Assortment_Account__c> prodAssortDBList = new List<ACCL__Product_Assortment_Account__c>();
        //List<ACCL__Product_Assortment_Store__c> lstProdAssortStoreToDelete = new List<ACCL__Product_Assortment_Store__c>();
        new List<ACCL__Product_Assortment_Store__c>();
        
        //get product assortments for branch listing
        for(ACCL__Product_Assortment__c prdAssort:[select id,Name from ACCL__Product_Assortment__c where 
                                                   ACCL__Valid_Thru__c >= today and 
                                                   ACCL__Product_Assortment_Template__r.name=:MDLZ_ConstantHelper.Branch_Listing]){
                                                       prodAssortments.put(prdAssort.Name,prdAssort.Id);
                                                   }
        
        Map<id,ACCL__Product_Assortment_Account__c> allPAAMap = 
            new Map<id,ACCL__Product_Assortment_Account__c>([select id,ACCL__Account__c,ACCL__Product_Assortment__c,
                                                                                                                 ACCL__Product_Assortment__r.name,ACCL__Valid_Thru__c 
                                                                                                                 from ACCL__Product_Assortment_Account__c where 
                                                                                                                 ACCL__Account__c in :accList and 
                                                                                                                 ACCL__Product_Assortment__r.ACCL__Product_Assortment_Template__r.name=:MDLZ_ConstantHelper.Branch_Listing]);
        
        //create a map of existing records
        Map<String, ACCL__Product_Assortment_Account__c> prodAssorAccMap = new Map<String, ACCL__Product_Assortment_Account__c>();
        
        for(ACCL__Product_Assortment_Account__c prdAssortAcc : allPAAMap.values()){
            prodAssorAccMap.put(prdAssortAcc.ACCL__Account__c+'|'+prdAssortAcc.ACCL__Product_Assortment__r.name,prdAssortAcc);
        }
        
        try{
            for(Account acc:accList){
                
                String branchPA = MDLZ_ConstantHelper.Sales_Org+acc.MDLZ_SAPBranchId__c+MDLZ_ConstantHelper.Branch;
                //check if already the account to PA branch mapping exists
                //if exists extend valid thru
                //if not exists add new record for that branch and end the valid thru for all other records.
                if(prodAssorAccMap.containskey(acc.Id+'|'+branchPA)){
                    prodAssortAccount = prodAssorAccMap.get(acc.Id+'|'+branchPA);
                    if(prodAssortAccount.ACCL__Valid_Thru__c <= system.today()){
                        prodAssortAccount.ACCL__Valid_Thru__c = date.newInstance(2099, 12, 31);
                        prodAssortDBList.add(prodAssortAccount);
                        listAccountUpdatedInserted.add(acc.Id+'|'+branchPA);
                        acctoDelete.add(acc.Id);
                    }
                }else{
                    prodAssortAccount = new ACCL__Product_Assortment_Account__c();
                    prodAssortAccount.ACCL__Account__c = acc.Id;
                    prodAssortAccount.ACCL__Product_Assortment__c = prodAssortments.get(branchPA);
                    prodAssortAccount.ACCL__Valid_From__c = system.today();
                    prodAssortAccount.ACCL__Valid_Thru__c = date.newInstance(2099, 12, 31);
                    prodAssortAccount.MDLZ_ExternalId__c = branchPA+'_'+acc.ACCL__ExternalId__c+MDLZ_ConstantHelper.Store;
                    prodAssortDBList.add(prodAssortAccount);
                    listAccountUpdatedInserted.add(acc.Id+'|'+branchPA);
                    acctoDelete.add(acc.Id);
                }
            }
            //ending the valid thru for old records
            //Only update Assortment Account which were not updated/inserted so far
            for(ACCL__Product_Assortment_Account__c assortmentAccount:allPAAMAp.values())
            {
                String key = assortmentAccount.ACCL__Account__c+'|'+assortmentAccount.ACCL__Product_Assortment__r.name;
                
                if(!(listAccountUpdatedInserted.indexOf(key)>=0) && acctoDelete.contains(assortmentAccount.ACCL__Account__c))
                {
                    assortmentAccount.ACCL__Valid_Thru__c = system.today();
                    prodAssortDBList.add(assortmentAccount);
                }
                
            }
            
            //updating the accounts in prod assortment object
            system.debug('Inserting data into db of size '+prodAssortDBList.size());
            if(prodAssortDBList.size() > 0){
                List<database.UpsertResult>  srList =  database.upsert(prodAssortDBList,false);
                if(srList.size()>0){
                    exc.upsertResultErrors(srList,prodAssortDBList,'MDLZ_ProdAssortment_ByCustBranch()','ACCL__Product_Assortment_Account__c');
                }
                
            }else{
                system.debug('No records to be updated');
            }
            
        }catch(exception e){
            system.debug('An exception has occurred');
            
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('Exception-MDLZ_ProdAssortment_ByCustBranch()',e.getStackTraceString(),
                                 e.getLineNumber(),e.getTypeName()); 
        }
    }
}