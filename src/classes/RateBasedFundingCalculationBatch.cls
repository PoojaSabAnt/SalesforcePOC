/**
 * Created by Jose Corona Cardenas on 11/10/18.
 */

public without sharing class RateBasedFundingCalculationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public final static String RBFMapCalculationResultsWithKpiMap = 'MapCalculationResultsWithKpiMap';
    public final static String RBFWritebackConditionRecords = 'WritebackConditionRecords';

    private ACCL__Batch_Process_Configuration__c csBatchSettings = null;
    private List<String> jobModes = new List<String>();
    private Boolean isHourly = false;
    private Integer jobThreads = null;
    
    public RateBasedFundingCalculationBatch(ACCL__Batch_Process_Configuration__c csBatchSettings, List<String> jobModes, Boolean isHourly, Integer jobThreads){
        this.csBatchSettings = csBatchSettings;
        this.jobModes = jobModes == null ? this.jobModes : jobModes;
        this.isHourly = isHourly == null ? this.isHourly : isHourly;
        this.jobThreads = jobThreads == null ? this.jobThreads : jobThreads;
    }
    
    /**
     * Method returns the QueryLocator for the RBF Records that should be processed
     *
     * @param bc Batchable Context
     *
     * @return QueryLocator for the dynamic query
     */
    public Database.QueryLocator start (Database.BatchableContext bc) {
        List<String> status = new List<String>();
        status.add('Approved');

        if(this.jobModes.contains('MapCalculationResultsWithKpiMap')){
            status.add('Processing');
            status.add('Processed');
        }

        return Database.getQueryLocator([
            SELECT Id, ACCL__Account__r.Id, ACCL__Rate_Based_Funding_Template__r.ACCL__KPI_Set__c, 
            ACCL__Date_From__c, ACCL__Date_Thru__c, ACCL__Rate_Based_Funding_Template__r.ACCL__Condition_Source_KPI__r.ACCL__Editable_Measure_Code__c,
            ACCL__Rate_Based_Funding_Template__r.ACCL__Condition_Target_KPI__r.ACCL__Data_Source_Measure_Code__c, ACCL__Rate_Based_Funding_Template__c,
            ACCL__Rate_Based_Funding_Template__r.ACCL__Sales_Org__r.Name, ACCL__Status__c
            FROM ACCL__Rate_Based_Funding__c 
            WHERE ACCL__Status__c IN :status
            AND ACCL__Rate_Based_Funding_Template__r.ACCL__Sales_Org__r.Name = :this.csBatchSettings.ACCL__Sales_Org__c
        ]);
    }

    /**
     * Method executes a batch of records and sends them to the Web service
     *
     * @param bc Batchable Context
     * @param objects List of objects to process
     */
    public void execute(Database.BatchableContext bc, List<ACCL__Rate_Based_Funding__c> records) {

        if(records != null && records.size() > 0){
            String txId = ACCL.TransactionHandler.generateGUID();
            String jobname = this.csBatchSettings.ACCL__Job_Name__c;
            String batchchain = String.format('RBF_Batches_{0}_{1}', new List<String>{ this.csBatchSettings.ACCL__Sales_Org__c, System.now().format('YYYYMMdd') });
            String salesorg = this.csBatchSettings.ACCL__Sales_Org__c;
            
            Map<Id, ACCL__Rate_Based_Funding__c> rbfMap = new Map<Id, ACCL__Rate_Based_Funding__c>();
            Map<Id, Set<Id>>  rbfCategoryMap = new Map<Id, Set<Id>>();
            Map<Id, Set<ACCL__RBF_Product__c>> rbfManualInputMap = new Map<Id, Set<ACCL__RBF_Product__c>>();
            Set<Id> rbfIds = new Set<Id>();
            Map<String, Set<Id>> categoriesMap = new Map<String, Set<Id>>();
            
            Map<Id,Map<String,Map<String, Object>>> productFilter = new Map<Id,Map<String,Map<String, Object>>>();
            Map<String,Map<String, Object>> tmpPf;
            String aggLvl = '';

            for(ACCL__Rate_Based_Funding__c rbfRecord : records){
                if(rbfRecord.ACCL__Rate_Based_Funding_Template__c != null && rbfRecord.ACCL__Rate_Based_Funding_Template__r.ACCL__Sales_Org__c != null && !rbfMap.containsKey(rbfRecord.Id)){
                    rbfMap.put(rbfRecord.Id, rbfRecord);
                    rbfIds.add(rbfRecord.Id);
                }
            }
            
            for(ACCL__RateBasedFunding_Product__c rbfp: [
                SELECT ACCL__Product__c, ACCL__Rate_Based_Funding__c , ACCL__Product__r.ACCL__Product_Level__c, ACCL__Product__r.ACCL__Criterion_1_Product__c
                FROM ACCL__RateBasedFunding_Product__c
                WHERE ACCL__Rate_Based_Funding__c IN :rbfIds
            ]){
                if(!rbfCategoryMap.containsKey(rbfp.ACCL__Rate_based_Funding__c)){
                    rbfCategoryMap.put(rbfp.ACCL__Rate_based_Funding__c, new Set<Id>());
                }
                if(rbfp.ACCL__Product__r.ACCL__Product_Level__c != 'Category'){
                    rbfCategoryMap.get(rbfp.ACCL__Rate_based_Funding__c).add(rbfp.ACCL__Product__r.ACCL__Criterion_1_Product__c);
                }
                else{
                    rbfCategoryMap.get(rbfp.ACCL__Rate_based_Funding__c).add(rbfp.ACCL__Product__c);
                }

                switch on rbfp.ACCL__product__r.ACCL__product_level__c{
                    when 'Category'{
                        aggLvl = 'ACCL__Criterion_1_Product__c';
                    }
                    when 'SubCategory' {
                        aggLvl = 'ACCL__Criterion_2_Product__c';
                    }
                    when 'Brand' {
                        aggLvl = 'ACCL__Criterion_3_Product__c';
                    }
                    when 'Flavor' {
                        aggLvl = 'ACCL__Criterion_4_Product__c';
                    }
                    when 'Package' {
                        aggLvl = 'ACCL__Criterion_5_Product__c';
                    }
                }
                // getting the ids for agglevels productfilter
                if(!productFilter.containsKey(rbfp.ACCL__Rate_based_Funding__c)){
                    productFilter.put(rbfp.ACCL__Rate_based_Funding__c, new Map<String,Map<String, Object>>());
                    tmpPf = (Map<String,Map<String, Object>>)productFilter.get(rbfp.ACCL__Rate_based_Funding__c);
                    tmpPf.put('productfilter', new Map<String, Object>());
                }
                tmpPf = (Map<String,Map<String, Object>>)productFilter.get(rbfp.ACCL__Rate_based_Funding__c);
                Map<String, Object> critIdsmap = (Map<String, Object>)tmpPf.get('productfilter');
                if(!critIdsmap.containsKey(aggLvl)){
                    critIdsmap.put(aggLvl,new Set<String>());    
                }
                Set<String> idsprodf = (Set<String>)critidsmap.get(aggLvl);
                idsprodf.add(rbfp.ACCL__Product__c);
            }
            
            for(ACCL__RBF_Product__c manualInput: [
                SELECT 
                Id,ACCL__Product__c,
                ACCL__Measure_Code__c,
                ACCL__Value__c,
                ACCL__Rate_Based_Funding__c
                FROM ACCL__RBF_Product__c 
                WHERE ACCL__Rate_Based_Funding__c
                IN :rbfIds 
                ORDER BY ACCL__Edit_Time__c ASC
            ]){
                if(!rbfManualInputMap.containsKey(manualInput.ACCL__Rate_Based_Funding__c)){
                    rbfManualInputMap.put(manualInput.ACCL__Rate_based_Funding__c, new Set<ACCL__RBF_Product__c>());
                }         
                rbfManualInputMap.get(manualInput.ACCL__Rate_based_Funding__c).add(manualInput);
            }
            
            for(ACCL__Product__c product : [
                SELECT Id, ACCL__Sales_Org__c from ACCL__Product__c 
                WHERE ACCL__Product_Level__c = 'Category'
                AND ACCL__Sales_Org__c = :this.csBatchSettings.ACCL__Sales_Org__c
            ]){
                if(!categoriesMap.containsKey(product.ACCL__Sales_Org__c)){
                    categoriesMap.put(product.ACCL__Sales_Org__c, new Set<Id>());
                }
                categoriesMap.get(product.ACCL__Sales_Org__c).add(product.Id);
            }
            
            for(ACCL__Rate_Based_Funding__c rbf : rbfMap.values()){
                if(!rbfCategoryMap.containsKey(rbf.Id)){
                    rbfCategoryMap.put(rbf.Id, categoriesMap.get(this.csBatchSettings.ACCL__Sales_Org__c));
                }
            }
            
            String request = RBFCalculationBatchService.buildRBFWebRequest(salesorg, jobname, batchchain, this.jobModes, this.isHourly, this.jobThreads, rbfMap, rbfCategoryMap, rbfManualInputMap, productFilter);
            ACCL.OffPlatformCallout calloutRequest = new ACCL.OffPlatformCallout('SCHEDULE_RATE_BASED_FUNDING_CALCULATION', salesorg);
            ACCL.OffPlatformCalloutResponse wsResult = calloutRequest.execute(txId, null, request);
            Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(wsResult.Result);
            if(mapResponse.get('status') == 200 && mapResponse.get('message') == 'OK' && this.jobModes.contains('WritebackConditionRecords')){
                for(ACCL__Rate_Based_Funding__c rbf : rbfMap.values()){
                    if(rbf.ACCL__Status__c == 'Approved'){
                        rbf.ACCL__Status__c = 'Processing';
                    }
                }
                update rbfMap.values();
            }
        }
    }

    /**
     * Run cleanup
     *
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
    }
}