public with sharing class ScheduleAccountProductList {
	
	private static final String JOB_NAME = 'AccountProductList';
	private static final String ACCOUNT_PRODCUT_ENDPOINT = '/ACSF/Account/Schedule/UpdateAccountProductList';

	private ScheduleAccountProductList() {}

	public static void schedule(NightlyCalculationBatch.NightlyAccountSchedulingParameters parameters){
		List<Id> accIds = new List<Id>();
		ACCL.OffPlatformCallout request = new ACCL.OffPlatformCallout('SCHEDULE_GLOBAL_ACCOUNT_PRODUCT_LIST', parameters.salesOrg);
        for(Id accId : parameters.accountIds){
			accIds.add(accId);
			if(accIds.size() == 1000) {
                request.execute(parameters.txId, new Map<String,String>(), JSON.serialize(new AccountProductListScheduleRequest(JOB_NAME, parameters, accIds)));
                accIds = new List<Id>();
			}
		}
		if(!accIds.isEmpty()){
			request.execute(parameters.txId, new Map<String,String>(), JSON.serialize(new AccountProductListScheduleRequest(JOB_NAME, parameters, accIds))); 
		}
	}

	private class AccountProductListScheduleRequest {
			String jobname;
			String salesorg;
			List<Id> accountids;
			Boolean refreshaccountproductlist;
			String batchchain;
			public AccountProductListScheduleRequest( String jobName, NightlyCalculationBatch.NightlyAccountSchedulingParameters parameters, List<Id> accountIds) { 
				this.jobname = jobName;
				this.salesorg = parameters.salesOrg;
				this.accountids = accountIds; 
				this.refreshaccountproductlist = parameters.refreshAccountProductList;
				this.batchchain = parameters.batchChain;

			}
		}
}