/***************************************************************
Name: MDLZ_DeleteProdAssortBranchListing
======================================================
Purpose:
Deletes the Product Assortment Store records for Branch listing assortment.
Creating this as a separate method as the existing method processFinish hits the limit of deleting 10K records
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                08/03/2022     Initial Development    
***************************************************************/
public with sharing class MDLZ_DeleteProdAssortBranchListing {
	//called from the batch class to delete invalid PAA records
    public void deleteInvalidPAARecord(List<ACCL__Product_Assortment_Account__c> getPAARecords) {
        try {
            
            List<ACCL__Product_Assortment_Store__c> listProdAssortStoreToDelete = new List<ACCL__Product_Assortment_Store__c>();
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();  
            //get the PAA list 
             Map<id,ACCL__Product_Assortment_Account__c> allPAAMap = new Map<id,ACCL__Product_Assortment_Account__c>(getPAARecords);
            
            //create a map of existing records wiht key = acc|branchname and values as list of acc id's
            Map<String, Id> prodAssorAccMap = new Map<String, Id>();
            
            for(ACCL__Product_Assortment_Account__c prdAssortAcc : allPAAMap.values()){
                prodAssorAccMap.put(prdAssortAcc.ACCL__Account__c+'|'+prdAssortAcc.ACCL__Product_Assortment__r.name,
                                    prdAssortAcc.ACCL__Account__c);
            }
            
            List<ACCL__Product_Assortment_Store__c> listProdAssortStore = 
                [select id,ACCL__Assortment__c, ACCL__Assortment__r.name,
                 ACCL__Store__c,ACCL__Assortment__r.ACCL__Product_Assortment_Template__r.name 
                 from ACCL__Product_Assortment_Store__c where 
                 ACCL__Store__c in :prodAssorAccMap.values() and 
                 ACCL__Assortment__r.ACCL__Product_Assortment_Template__r.name = :MDLZ_ConstantHelper.Branch_Listing];
            
            if(listProdAssortStore.size()>0){
                for(ACCL__Product_Assortment_Store__c assortmentStore:listProdAssortStore)
                {
                    String key = assortmentStore.ACCL__Store__c+'|'+assortmentStore.ACCL__Assortment__r.name;
                   
                    if(prodAssorAccMap.containsKey(key))
                    {
                        listProdAssortStoreToDelete.add(assortmentStore);
                     }
                }
            }else{
                system.debug('Prod Assort Store list empty');
            }
            
            if(!listProdAssortStoreToDelete.isEmpty()) {
                List<Database.DeleteResult> srList =database.Delete(listProdAssortStoreToDelete);
                MDLZ_ErrorExceptionHandler error = new MDLZ_ErrorExceptionHandler();
                error.deleteResultErrors(srList, listProdAssortStoreToDelete, 'MDLZ_DeleteProdAssortBranchListing()',
                                         'ACCL__Product_Assortment_Store__c', 'id');
            }
            
        } catch(Exception ex) {
            system.debug('An exception has occurred');
             MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('Exception-MDLZ_DeleteProdAssortBranchListing()',ex.getStackTraceString(),
                                 ex.getLineNumber(),ex.getTypeName()); 
        }
        
    }
}