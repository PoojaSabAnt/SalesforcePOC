public without sharing class FundCalculationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    private ACCL__Batch_Process_Configuration__c csBatchSettings = null;
    
    public FundCalculationBatch(ACCL__Batch_Process_Configuration__c csBatchSettings){
        this.csBatchSettings = csBatchSettings;
    }
    
    /**
     * Method returns the QueryLocator for the Fund Records that should be processed
     *
     * @param bc Batchable Context
     *
     * @return QueryLocator for the dynamic query
     */
    public Database.QueryLocator start (Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, ACCL__Fund_Template__c, ACCL__Fund_Template__r.ACCL__KPI_Set__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Anchor_Account__r.Id, ACCL__Fund_Template__r.ACCL__Sales_Org__c
            FROM ACCL__Fund__c 
            WHERE ACCL__Status__c = 'Active' 
            AND ACCL__Fund__c.ACCL__Fund_Template__r.ACCL__Sales_Org__c = :this.csBatchSettings.ACCL__Sales_Org__c
        ]);
    }

    /**
     * Method executes a batch of records and sends them to the Web service
     *
     * @param bc Batchable Context
     * @param objects List of objects to process
     */
    public void execute(Database.BatchableContext bc, List<ACCL__Fund__c> records) {

        String jobname = csBatchSettings.ACCL__Job_Name__c;
        Integer jobthread = (Integer)csBatchSettings.ACCL__Batch_Size__c;
        String batchchain = String.format('Fund_Batches_{0}_{1}', new List<String>{ csBatchSettings.ACCL__Sales_Org__c, System.now().format('YYYYMMdd') });
        String salesOrg = csBatchSettings.ACCL__Sales_Org__c;
        String txId = ACCL.TransactionHandler.generateGUID();
        
        Map<Id, ACCL__Fund__c> fundMap = new Map<Id, ACCL__Fund__c>();
        Set<Id> fundIds = new Set<Id>();
        Map<Id, Set<Id>>  fundCategoryMap = new Map<Id, Set<Id>>();
        Map<String, Set<Id>> categoriesMap = new Map<String, Set<Id>>();
        
        Map<Id,Map<String,Map<String, Object>>> productFilter = new Map<Id,Map<String,Map<String, Object>>>();
        Map<String,Map<String, Object>> tmpPf;
        String aggLvl = '';
        for(ACCL__Fund__c fundrcd : records){
            if(fundrcd.ACCL__Fund_Template__c != null 
                && fundrcd.ACCL__Fund_Template__r.ACCL__Sales_Org__c != null 
                && !fundMap.containsKey(fundrcd.Id)){
                fundMap.put(fundrcd.Id, fundrcd);
                fundIds.add(fundrcd.Id);  
            }
        }
        
        for(ACCL__Fund_Product__c fundp: [
            SELECT ACCL__Product__c, ACCL__Product__r.ACCL__Product_Level__c, 
            ACCL__Fund__c, ACCL__Product__r.ACCL__Criterion_1_Product__c 
            FROM ACCL__Fund_Product__c WHERE ACCL__Fund__c IN :fundIds            
        ]){
            if(!fundCategoryMap.containsKey(fundp.ACCL__Fund__c)){
                fundCategoryMap.put(fundp.ACCL__Fund__c, new Set<Id>());
            }
            if(fundp.ACCL__Product__r.ACCL__Product_Level__c != 'Category'){
                fundCategoryMap.get(fundp.ACCL__Fund__c)
                .add(fundp.ACCL__Product__r.ACCL__Criterion_1_Product__c);
            }
            else{
                fundCategoryMap.get(fundp.ACCL__Fund__c).add(fundp.ACCL__Product__c);
            }
            switch on fundp.ACCL__product__r.ACCL__product_level__c{
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
                if(!productFilter.containsKey(fundp.ACCL__Fund__c)){
                    productFilter.put(fundp.ACCL__Fund__c, new Map<String,Map<String, Object>>());
                    tmpPf = (Map<String,Map<String, Object>>)productFilter.get(fundp.ACCL__Fund__c);
                    tmpPf.put('productfilter', new Map<String, Object>());
                }
                tmpPf = (Map<String,Map<String, Object>>)productFilter.get(fundp.ACCL__Fund__c);
                Map<String, Object> critIdsmap = (Map<String, Object>)tmpPf.get('productfilter');
                if(!critIdsmap.containsKey(aggLvl)){
                    critIdsmap.put(aggLvl,new Set<String>());    
                }
                Set<String> idsprodf = (Set<String>)critidsmap.get(aggLvl);
                idsprodf.add(fundp.ACCL__Product__c);
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
        
        for(ACCL__Fund__c fund : fundMap.values()){
            if(!fundCategoryMap.containskey(fund.Id)){
                fundCategoryMap.put(fund.Id, categoriesMap.get(this.csBatchSettings.ACCL__Sales_Org__c));
            }
        }
        
        String requestBody = FundCalculationBatchService.buildFundWebRequest(salesOrg, txId, jobname, batchchain, jobthread, fundMap, fundCategoryMap, productFilter);
		
        ACCL.OffPlatformCallout request = new ACCL.OffPlatformCallout('SCHEDULE_FUND_CALCULATION', salesOrg);
		
        if(!test.isRunningTest()){
            //Gaurav Gupta: Added isRunningTest check for test class
            ACCL.OffplatformCalloutResponse wsResult = request.execute(txId, new Map<String,String>() ,requestBody);
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