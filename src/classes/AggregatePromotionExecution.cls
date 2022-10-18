/**
* @version  1.0
* Sharing_With_Controller - False Positive
* This class is batch execution class and does not require to be called from a controller.
*/    

/**
* This class is execution class for PromotionAggregationBatch implementing ACASBatchBLExecution
* processing the promotion record with batch size 1 configured in Batch_Process_Configuration__c and stores the result in Promotion store object.
* @see PromotionAggregationBatch
*/
global class AggregatePromotionExecution implements ACCL.ACSFBatchBLExecution {    
    private static final Type classType = AggregatePromotionExecution.class;    
    private static String txId = ACCL.TransactionHandler.generateGUID();
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    /**
* @Description This method processes a list of promotion record with the batch size configured in Batch_Process_Configuration__c and stores the result in Promotion store object.
* @param List<SObject> lstPromotion - List of promotions as the scope of batch execution
* @return none
* @throws none
*/
    //SOQL_SOSL_Injection, Parameter_Tempering - False Positive
    //This is a batch execution class called from AggregatePromotionBatch. 
    //so the list passed is retrieved from the init() method of the batch and scope CANNOT be modified during batch execution. Hence no SOQL injection or parameter tempering is possible.
    global void process(List<SObject> lstPromotion) {
        //LogTrace logTraceHandle = LoggerUtility.enterMethod(txId, classType, 'process', LogTrace.SOURCETYPE.Batch, new String[] {String.join(lstPromotion,';')});
        List<sObject> listPromotionStore = new List<sObject>(); //Promo Store
        List<sObject> promotionList = (List<sObject>)lstPromotion;
        Set<Id> setNewAccountId = new Set<Id>();
        Map<Id,Id> mapPromtionStore = new Map<Id,Id>();
        Set<Id> tempNewAccId = new Set<Id>();
        Set<Id> tempOldaccId = new Set<Id>();
        List<Id> accountIdTobeAdded = new List<Id>();
        List<Id> accountIdTobeDeleted = new List<Id>();
        List<Id> promotionStoreIdToDelete = new List<Id>();
        List<sObject> promotionStoreList = new List<sObject>();//Promo store
        AccountPromotionTraversalUtility prmAccTransverse= new AccountPromotionTraversalUtility();
        for (sObject promotion : promotionList) {
            setNewAccountId.clear();
            mapPromtionStore.clear();
            tempNewAccId.clear();
            tempOldaccId.clear();
            accountIdTobeAdded.clear();
            accountIdTobeDeleted.clear();
            promotionStoreList.clear();
            setNewAccountId = prmAccTransverse.getValidAccountID(promotion);
            //fetching existing records for the same promotion Id
            if(setNewAccountId !=null && setNewAccountId.size() >0) {
                System.debug('EnteringIfAccountId' +setNewAccountId);
                Id proId= promotion.Id;
                String promotionStore= 'SELECT Id,ACCL__Promotion__c,ACCL__Store__c from ACCL__Promotion_Store__c where ACCL__Promotion__c =:proId';
                System.debug('InsideIfPromotionStore' +promotionStore);
                //promotionStore = String.format(promotionStore, new List<String>{ns});
                promotionStoreList = Database.query(promotionStore);
                System.debug('InsideIfPromotionStoreList' +promotionStoreList);
                if(promotionStoreList !=null && promotionStoreList.size() > 0) {
                    System.debug('InsideIf2PromotionStoreList' +promotionStoreList);
                    for(sObject ps : promotionStoreList) {
                        mapPromtionStore.put((ID)ps.get('ACCL__Store__c'),ps.Id);
                        System.debug('mapPromtionStore If2For ' +mapPromtionStore);
                    }
                }
                if(promotionStoreList.size() == 0) {
                    accountIdTobeAdded.addAll(setNewAccountId);
                    System.debug('accIdToBeadded' +accountIdTobeAdded);
                }
                else {
                    //for getting new account Ids which are not present in Database
                    tempNewAccId.addAll(setNewAccountId);                 
                    tempNewAccId.removeAll(mapPromtionStore.keySet());
                    accountIdTobeAdded.addAll(tempNewAccId);                 
                    //for getting old account Ids which are not present in new Account Ids
                    tempOldaccId.addAll(mapPromtionStore.keySet());
                    tempOldaccId.removeAll(setNewAccountId);
                    accountIdTobeDeleted.addAll(tempOldaccId);
                    for(Id accId : accountIdTobeDeleted) {
                        Id tempId= mapPromtionStore.get(accId);
                        promotionStoreIdToDelete.add(tempId);
                        }
                }
            }
            if(accountIdTobeAdded.size()>0) {
                for(Integer i=0;i<accountIdTobeAdded.size();i++) {
                    //Promotion_Store__c store = new Promotion_Store__c();//promo store
                    sObject store = allObjMetaType.get('ACCL__Promotion_Store__c').newSObject();
                    //FLS_CREATE, FLS_CREATE_PARTIAL - False Positive
                    //This class is batch execution class and will execute in system mode. So no FLS check required.
                    store.put('ACCL__Promotion__c', promotion.Id);
                    store.put('ACCL__Store__c', accountIdTobeAdded[i]);
                    listPromotionStore.add(store);
                    
                }
            }
        }
        try {
            if (listPromotionStore != null && listPromotionStore.size()>0 && listPromotionStore.size() <=(Limits.getLimitDmlRows()-Limits.getDmlRows())) {//Check if List is empty or not
                Database.insert(listPromotionStore); 
            }
            if (promotionStoreIdToDelete != null && promotionStoreIdToDelete.size()>0 && promotionStoreIdToDelete.size() <=(Limits.getLimitDmlRows()-Limits.getDmlRows())) {//Check if List is empty or not
                Database.delete(promotionStoreIdToDelete); 
            }
        }
        catch(DmlException ex) {
            //LoggerUtility.handleException(txId, ex);
            System.debug('Exception: ' +ex);
        }
        
    }
    /**
* @Description This method is for any finish block processing like sending mails post successful execution of the batch 
*             This method is responsible for deleting all the invalid records from store for which promotion records not in valid date range.
* @param  none
* @return none
* @throws none
*/
    global void processFinish() {   
        System.debug('Process Finish Method');
        //LogTrace logTraceHandle;
        List<Id> listPromotionStoreToDelete = new List<Id>();
        
        try{
            //logTraceHandle = LoggerUtility.enterMethod(txId, classType, 'processFinish', LogTrace.SOURCETYPE.Batch, new String[] {});
            AggregatePromotionDelete storeDelete = new AggregatePromotionDelete();
            listPromotionStoreToDelete = storeDelete.invalidPromotionRecord();
            if(listPromotionStoreToDelete != null && listPromotionStoreToDelete.size() > 0) {
                System.debug('Inside-listPromotionStoreToDelete' +listPromotionStoreToDelete);
                Database.delete(listPromotionStoreToDelete);    
            }
        } catch(Exception ex) {
            System.debug('Exception: ' +ex);
        } 
    }
}