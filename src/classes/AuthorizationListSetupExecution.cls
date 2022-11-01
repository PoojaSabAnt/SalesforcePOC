/**  PROGRAM NAME : AuthorizationListSetupExecution 
     * This class is execution class for AuthorizationListSetupBatch class.
     * @see    AuthorizationListSetupBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class AuthorizationListSetupExecution {
	/** Private Variables */
    private static final string PROD_ASSORT_TEMP_RECORDTYPE = 'Assortment List';
    private static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    /** 
    *  @description Processing Flatten_Account_Hierarchy records.
    *  @param List<SObject> storeListInput
    *  @return void 
    *  @throws  Standard exception
    */
    public void process(List<SObject> storeListInput) {
        system.debug('storeListInput '+storeListInput);
        List<SObject> productAssortmentStoresToBeInserted;
        try {
            List<SObject> storeList = (List<SObject>)storeListInput;
            Map<Id, List<Id>> nodesAboveStore = new Map<Id, List<Id>>();
            
            for(SObject store : storeList) {
                nodesAboveStore.put((Id)store.get('ACCL__Account__c'), new List<Id>());
                for(Integer i = 1; i < (Decimal)store.get('ACCL__Node_Level__c'); i++){
                    string numberPrefix = i < 10 ? '0' : '';
                    nodesAboveStore.get((Id)store.get('ACCL__Account__c')).add((Id)store.get('ACCL__Account_Level_' + numberPrefix + i + '__c'));
                }
            }
            Set<Id> idsForAssortmentSet = new Set<Id>();
            for(Id key : nodesAboveStore.keySet()) {
                idsForAssortmentSet.add(key);
                for(Id idInList : nodesAboveStore.get(key)) {
                    idsForAssortmentSet.add(idInList);
                }
            }

            Map<Id, Set<Id>> customerToAssignedProductAssortments = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> customerToAssortmentActual = new Map<Id, Set<Id>>();

            for(Id customerId : idsForAssortmentSet) {
                customerToAssignedProductAssortments.put(customerId, new Set<Id>());
            }

            for(Id store : nodesAboveStore.keySet()) {
                customerToAssortmentActual.put(store, new Set<Id>());
            }

            String prodAssortAccQuery = 'SELECT ACCL__Account__c, ACCL__Product_Assortment__c FROM ACCL__Product_Assortment_Account__c WHERE ACCL__Account__c IN :idsForAssortmentSet AND ACCL__Product_Assortment__r.ACCL__Product_Assortment_Template__r.RecordType.Name = :PROD_ASSORT_TEMP_RECORDTYPE AND ACCL__Product_Assortment__r.ACCL__Valid_From__c <= TODAY AND ACCL__Product_Assortment__r.ACCL__Valid_Thru__c >= TODAY  AND  ACCL__Valid_From__c <= TODAY AND ACCL__Valid_Thru__c >= TODAY';
            List<sObject> productAssortments = Database.query(prodAssortAccQuery);
            for(sObject record : productAssortments) {
                customerToAssignedProductAssortments.get((Id)record.get('ACCL__Account__c')).add((Id)record.get('ACCL__Product_Assortment__c'));
            }

            Set<Id> storeIds = new Set<Id>(nodesAboveStore.keySet());
            String prodAssortStoreQuery = 'SELECT ACCL__Store__c, ACCL__Assortment__c FROM ACCL__Product_Assortment_Store__c WHERE ACCL__Store__c IN :storeIds AND ACCL__Assortment__r.ACCL__Product_Assortment_Template__r.RecordType.Name = :PROD_ASSORT_TEMP_RECORDTYPE AND ACCL__Assortment__r.ACCL__Valid_From__c <= TODAY AND ACCL__Assortment__r.ACCL__Valid_Thru__c >= TODAY';
            List<sObject> actualAssortments = Database.query(prodAssortStoreQuery);
            for(sObject record : actualAssortments) {
                customerToAssortmentActual.get((Id)record.get('ACCL__Store__c')).add((Id)record.get('ACCL__Assortment__c'));
            }

            Map<Id, Set<Id>> customerToAssortmentTarget = new Map<Id, Set<Id>>();
            Map<Id, Id> IdsPAS = new Map<Id, Id>();
           
            for(sObject store : storeList) {
                
                Set<Id> assignedAssortments = customerToAssignedProductAssortments.get((Id)store.get('ACCL__Account__c'));
                if(assignedAssortments.size() > 0) {
                    customerToAssortmentTarget.put((Id)store.get('ACCL__Account__c'), assignedAssortments);
                } else {
                    List<Id> nodesAbove = nodesAboveStore.get((Id)store.get('ACCL__Account__c'));
                    if(nodesAbove.size() > 0) {
                        Integer i = nodesAbove.size() - 1;
                        while(i >= 0 && assignedAssortments.size() == 0) {
                            assignedAssortments = customerToAssignedProductAssortments.get(nodesAbove[i]);
                            i--;
                        }
                        customerToAssortmentTarget.put((Id)store.get('ACCL__Account__c'), assignedAssortments);
                    } else {
                        customerToAssortmentTarget.put((Id)store.get('ACCL__Account__c'), new Set<Id>());
                    }
                }
            }

            String ProdAssortStoreListType = 'List<' + 'ACCL__Product_Assortment_Store__c' + '>';
            productAssortmentStoresToBeInserted = (List<SObject>)Type.forName(ProdAssortStoreListType).newInstance();
            Set<Id> idsForDeletion = new Set<Id>();
            for(sObject store : storeList) {
                for(Id targetId : customerToAssortmentTarget.get((Id)store.get('ACCL__Account__c'))) {
                    if(!customerToAssortmentActual.get((Id)store.get('ACCL__Account__c')).contains(targetId)) {

                        sObject pasObj = allObjMetaType.get('ACCL__Product_Assortment_Store__c').newSObject();
                        pasObj.put('ACCL__Assortment__c', targetId);
                        pasObj.put('ACCL__Store__c', (Id)store.get('ACCL__Account__c'));
                        productAssortmentStoresToBeInserted.add(pasObj);
                    }
                }

                for(Id actualId : customerToAssortmentActual.get((Id)store.get('ACCL__Account__c'))) {
                    if(!customerToAssortmentTarget.get((Id)store.get('ACCL__Account__c')).contains(actualId)) {
                        IdsPAS.put(actualId, (Id)store.get('ACCL__Account__c'));
                        idsForDeletion.add((Id)store.get('ACCL__Account__c'));
                    }
                }
            }
            Set<Id> IdsPASkey = new Set<Id>(IdsPAS.keySet());
            Set<Id> IdsPASvalue = new Set<Id>(IdsPAS.values());
            List<sObject> prodAssortStoreTBD = [SELECT Id FROM ACCL__Product_Assortment_Store__c WHERE ACCL__Assortment__c IN:IdsPASkey AND ACCL__Store__c IN:idsForDeletion];
            //CRUD_Delete, FLS_Create False Positive
            //This class is a Batch Execution logic class and needs to run in System Context.
            Database.delete(prodAssortStoreTBD);
            Database.insert(productAssortmentStoresToBeInserted);
        }
        catch(Exception ex) {
            System.debug('Exception : '+ex.getLineNumber());
            System.debug('Exception : '+ex.getMessage());
            System.debug('Exception : '+ex.getStackTraceString());
        } 
    }

    /** 
    *  @description Deletes the Product Assortment Store records.
    *  @param None
    *  @return void 
    *  @throws  Standard exception
    */
    public void processFinish() {
        List<Id> listProdAssortStoreToDelete = new List<Id>();
        try{
            AuthorizationListSetupDelete storeDelete = new AuthorizationListSetupDelete();
            listProdAssortStoreToDelete = storeDelete.invalidProductAssortmentRecord();
            if(!listProdAssortStoreToDelete.isEmpty()) {
                Database.delete(listProdAssortStoreToDelete);    
            }
            
        }
        catch(Exception ex) {
            System.debug('Exception : '+ex);
        }
    }
    
     
}