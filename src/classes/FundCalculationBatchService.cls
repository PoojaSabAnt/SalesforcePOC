public class FundCalculationBatchService {

    public static String buildFundWebRequest(String salesOrg, String txId, String jobname, String batchain, Integer jobThreads, Map<Id, ACCL__Fund__c> fundMap, Map<Id, Set<Id>> fundCategoryMap, Map<Id,Map<String,Map<String, Object>>> productFilter){    
        FundWebRequestWrapper wrw = new FundWebRequestWrapper();
        wrw.jobname = jobname;
        wrw.jobthreads = jobThreads;
        wrw.batchchain = batchain;
        wrw.salesorg = salesOrg;
        wrw.consideraccountproductlist = true;
        wrw.funds = new List<FundWrapper>();
        

        Time zeroHour = Time.newInstance(0, 0, 0, 0); 
	
        for(ACCL__Fund__c fund : fundMap.values()){
            FundWrapper fundw = new FundWrapper();
            fundw.categoryids = new List<Id>(fundCategoryMap.get(fund.Id));          
            fundw.datethru = ((DateTime)fund.ACCL__Valid_Thru__c).getTime();
            fundw.datefrom = ((DateTime)fund.ACCL__Valid_From__c).getTime();
            fundw.kpisetid = fund.ACCL__Fund_Template__r.ACCL__KPI_Set__c;
            fundw.accountid = fund.ACCL__Anchor_Account__r.Id;
            fundw.fundtemplateid = fund.ACCL__Fund_Template__c;
            fundw.fundid = fund.Id;
            if(productfilter.containsKey(fund.Id)){
            	fundw.productfilter = productfilter.get(fund.Id).get('productfilter');    
            } else {
                String aggLvl = 'ACCL__Criterion_1_Product__c';
                Map<String,Object> prodf = new Map<String,Object>();
                prodf.put(aggLvl, new List<Id>(fundCategoryMap.get(fund.Id)));
                fundw.productfilter = prodf;
            } 
            wrw.funds.add(fundw);
        }
        return JSON.serialize(wrw);
    }
   
    private class FundWebRequestWrapper{
        public String salesorg;
        public String jobname;
        public Integer jobthreads;
        public String batchchain;                  
        public List<FundWrapper> funds;   
        public Boolean consideraccountproductlist;                    
    }
    
    private class FundWrapper {
        List<Id> categoryids;
        public Long datethru;
        public Long datefrom;
        public Id kpisetid;
        public Id accountid;
        public Id fundtemplateid;
        public Id fundid;
        public Map<String,Object> productfilter;
    }
}