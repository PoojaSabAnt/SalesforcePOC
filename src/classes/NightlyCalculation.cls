public with sharing class NightlyCalculation extends AddOns_SchedulerExecutable  {
	
	
	public NightlyCalculation() {
		
	}

	    public override void  startProcess(List<ACCL__Batch_Process_Configuration__c> configurations) {
			List<BatchProcessWrapper> batchesProcessToFire = new List<BatchProcessWrapper>();
			for(ACCL__Batch_Process_Configuration__c configuration : configurations){
				if(!String.isBlank(configuration.ACCL__Sales_Org__c)){
					batchesProcessToFire.add(new BatchProcessWrapper(configuration.ACCL__Sales_Org__c, configuration.ACCL__Refresh_Account_Product_List__c, configuration.ACCL__Execute_Nightly_Calculation__c));
				}
			}
			for( BatchProcessWrapper batchRecord : batchesProcessToFire) {
				ProductAssortmentAlignment schedulePrdAssortmentAlignment = new ProductAssortmentAlignment(batchRecord.salesOrg, batchRecord.refreshAccountProductList, batchRecord.executeNightlyCalculation);
        		schedulePrdAssortmentAlignment.execute(null);
        }
    }
    
    private class BatchProcessWrapper {
        String salesOrg {get; set;}
        Boolean refreshAccountProductList {get; set;}
        Boolean executeNightlyCalculation {get; set;}
        public BatchProcessWrapper(String salesOrg, Boolean refreshAccountProductList, Boolean executeNightlyCalculation) {
            this.salesOrg = salesOrg;
            this.refreshAccountProductList = refreshAccountProductList;
            this.executeNightlyCalculation = executeNightlyCalculation;
        }
    }

}