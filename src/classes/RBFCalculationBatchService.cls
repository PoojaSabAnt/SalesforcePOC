/**
 * Created by Jose Corona Cardenas on 11/09/18.
 */

public class RBFCalculationBatchService {

    public static String buildRBFWebRequest(String salesOrg,  String jobName, String batchChain, List<String> jobModes, Boolean isHourly, Integer jobThreads, Map<Id, ACCL__Rate_Based_Funding__c> rbfMap, Map<Id, Set<Id>>  rbfCategoryMap, Map<Id, Set<ACCL__RBF_Product__c>> rbfManualInputMap, Map<Id,Map<String,Map<String, Object>>> productFilter){    
        RBFWebRequestWrapper wrw = new RBFWebRequestWrapper();
        wrw.jobname = jobName;
        wrw.jobthreads = jobThreads;
        wrw.batchchain = batchChain;
        wrw.salesorg = salesOrg;
        wrw.jobmodes = jobModes;
        wrw.frequentupdate = isHourly;
        wrw.consideraccountproductlist = true;
        wrw.ratebasedfundings = new List<RBFWrapper>();

        Time zeroHour = Time.newInstance(0, 0, 0, 0); 
	
        for(ACCL__Rate_Based_Funding__c rbf : rbfMap.values()){
            RBFWrapper rbfw = new RBFWrapper();
            List<ACCL.ManualCalculationInput.ManualInput> manualInputs = new List<ACCL.ManualCalculationInput.ManualInput>();
            List<ACCL__RBF_Product__c> listProduct = new List<ACCL__RBF_Product__c>(rbfManualInputMap.get(rbf.Id));
            for (ACCL__RBF_Product__c manualInputRecord : listProduct){
                manualInputs.add(new ACCL.ManualCalculationInput.ManualInput(
                        manualInputRecord.ACCL__Measure_Code__c
                        , null
                        , null
                        , manualInputRecord.ACCL__Product__c
                        , Double.valueOf(manualInputRecord.ACCL__Value__c)
                ));
            }

            rbfw.manualInputs = createManualInputMap(manualInputs);

            rbfw.conditiontargetcode = rbf.ACCL__Rate_Based_Funding_Template__r.ACCL__Condition_Target_KPI__r.ACCL__Data_Source_Measure_Code__c;
            rbfw.conditionsourcecode = rbf.ACCL__Rate_Based_Funding_Template__r.ACCL__Condition_Source_KPI__r.ACCL__Editable_Measure_Code__c;

            rbfw.categoryids = new List<Id>(rbfCategoryMap.get(rbf.Id));            
            rbfw.datethru = ((DateTime)rbf.ACCL__Date_Thru__c).getTime();
            rbfw.datefrom = ((DateTime)rbf.ACCL__Date_From__c).getTime();
            rbfw.kpisetid = rbf.ACCL__Rate_Based_Funding_Template__r.ACCL__KPI_Set__c;
            rbfw.accountid = rbf.ACCL__Account__r.Id;
            rbfw.rbftemplateid = rbf.ACCL__Rate_Based_Funding_Template__c;
            rbfw.rbfid = rbf.Id;
            if(productfilter.containsKey(rbf.Id)){
            	rbfw.productfilter = productfilter.get(rbf.Id).get('productfilter');    
            } else {
                String aggLvl = 'ACCL__Criterion_1_Product__c';
                Map<String,Object> prodf = new Map<String,Object>();
                prodf.put(aggLvl, new List<Id>(rbfCategoryMap.get(rbf.Id)));
                rbfw.productfilter = prodf;
            }

            wrw.ratebasedfundings.add(rbfw);

        }
        return JSON.serialize(wrw);
    }
   
    private static Integer numberOfLookups(ACCL.ManualCalculationInput.Period period, String measure, String tacticId, String productId) {
        if (productId == null) {
            if (tacticId == null) {
                return 2;
            } else {
                return 3;
            }
        }
        return 4;
    }
    
    private static Integer getIndex(String key, Map<String, Integer> lookups) {
        if (lookups.containsKey(key)) {
            return lookups.get(key);
        } else {
            Integer size = lookups.size();
            lookups.put(key, size);
            return size;
        }
    }
    
    private static Integer getIndex(ACCL.ManualCalculationInput.Period key, Map<ACCL.ManualCalculationInput.Period, Integer> lookups) {
        if (lookups.containsKey(key)) {
            return lookups.get(key);
        } else {
            Integer size = lookups.size();
            lookups.put(key, size);
            return size;
        }
    }


    private static Map<String,Object> createManualInputMap(List<ACCL.ManualCalculationInput.ManualInput> manualInputs){
        Map<String,Object> mi = new Map<string,Object>();
        Map<ACCL.ManualCalculationInput.Period, Integer> periodMap = new Map<ACCL.ManualCalculationInput.Period, Integer>();
        Map<String, Integer> measureMap = new Map<String, Integer>();
        Map<String, Integer> tacticIdMap = new Map<String, Integer>();
        Map<String, Integer> productIdMap = new Map<String, Integer>();
        List<Object> data = new List<Object>();
        for (ACCL.ManualCalculationInput.ManualInput manualInput : manualInputs) {
            ACCL.ManualCalculationInput.Period period = manualInput.period;
            String measure = manualInput.measure;
            String tacticId = manualInput.tacticId;
            String productId = manualInput.productId;
            Integer numberOfLookups = numberOfLookups(period, measure, tacticId, productid);
            Double value = manualInput.value;
            Integer obsolete = (manualInput.obsolete != null && manualInput.obsolete) ? 1 : 0;
            List<Object> lookups = new List<Integer>();
            Integer periodIndex = getIndex(period, periodMap);
            lookups.add(periodindex);
            Integer measureIndex = getIndex(measure, measureMap);
            lookups.add(measureIndex);
            if (numberOfLookups >= 3) {
                Integer tacticIndex = getIndex(tacticId, tacticIdMap);
                lookups.add(tacticIndex);
                if (numberOfLookups >= 4) {
                    Integer productIndex = getIndex(productId, productIdMap);
                    lookups.add(productIndex);
                }
            }
            List<Object> dataItem = new List<Object>();
            dataItem.add(lookups);
            dataItem.add(value);
            dataItem.add(obsolete);
            data.add(dataItem);
        }
        List<Object> dimensions = new List<Object>();
        dimensions.add(createDimension(periodMap));
        dimensions.add(createDimension(measureMap, 'Measure'));
        dimensions.add(createDimension(tacticIdMap, 'Tactic'));
        dimensions.add(createDimension(productIdMap, 'Product'));
        mi.put('dimensions', dimensions);
        mi.put('data', data);
        return mi;
    }
    
     private static Map<String, Object> createDimension(Map<String, Integer> lookupMap, String name) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('name', name);
        result.put('type', name == 'Measure' ? 'measure' : 'regular');
        List<String> lookups = new String[lookupMap.size()];
        for (String lookup : lookupMap.keyset()) {
            Integer index = lookupMap.get(lookup);
            lookups[index] = lookup;
        }
        result.put('lookups', lookups);
        return result;
    }

    /**
    * Converts a lookup map to the time dimension format used in the manual input JSON
    * @param lookupMap mapping n periods to {0,..,n-1}
    * @return dimension information as use in manual input JSON
    */
    private static Map<String, Object> createDimension(Map<ACCL.ManualCalculationInput.Period, Integer> lookupMap) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('name', 'Week');
        result.put('type', 'time');
        List<ACCL.ManualCalculationInput.Period> details = new ACCL.ManualCalculationInput.Period[lookupMap.size()];
        for (ACCL.ManualCalculationInput.Period lookup : lookupMap.keyset()) {
            Integer index = lookupMap.get(lookup);
            details[index] = lookup;
        }
        result.put('details', details);
        return result;
    }
    
    private class RBFWebRequestWrapper{
        public String salesorg;
        public String jobname;
        public Integer jobthreads;
        public String batchchain;
        public List<String> jobmodes;
        public List<RBFWrapper> ratebasedfundings;
        public Boolean frequentupdate;
        public Boolean consideraccountproductlist;
    }
    private class RBFWrapper {
        public Map<String,Object> manualinputs;
        public String conditiontargetcode;
        public String conditionsourcecode;
        List<Id> categoryids;
        public Long datethru;
        public Long datefrom;
        public Id kpisetid;
        public Id accountid;
        public Id rbftemplateid;
        public Id rbfid;
        public Map<String,Object> productfilter;
    }
}