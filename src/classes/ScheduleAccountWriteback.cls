public with sharing class ScheduleAccountWriteback {
	
	private static final String JOB_NAME = 'AccountPlan';
	private static final String ACCOUNT_ENDPOINT = '/ACSF/Account/Schedule/Calculation';
    
	private ScheduleAccountWriteback() {}

    public static void schedule(NightlyCalculationBatch.NightlyAccountSchedulingParameters parameters){
        Dates datesParams = new Dates();
        ScheduleAccountWriteback.setDates(datesParams);
        ACCL.OffPlatformCallout request = new ACCL.OffPlatformCallout('SCHEDULE_ACCOUNT_PLAN_CALCULATION', ' ');
        for(Id kpiSetId : parameters.kpiSetToSetOfAccounts.keySet()) {
            for(Set<Id> accIds : parameters.kpiSetToSetOfAccounts.get(kpiSetId)){
                AccountWritebackScheduleRequest req = new AccountWritebackScheduleRequest(kpiSetId, JOB_NAME, parameters, accIds, datesParams.dateFromTimestamp, datesParams.dateThruTimestamp );
                request.execute(parameters.txId, new Map<String,String>(), JSON.serialize(req));
            }
        }
        
    }

	static void setDates(Dates datesObj){
		Account_Calculation_Server_Offset__c offset =  Account_Calculation_Server_Offset__c.getInstance();
		if( offset == null || offset.Days_Before__c == null || offset.Days_After__c == null ){
			offset = new Account_Calculation_Server_Offset__c(Days_Before__c = 60, Days_After__c = 300);
		}
		Datetime today  = System.now();
		Time myTime = Time.newInstance(0, 0, 0, 0);
		DateTime todayWithoutTime = DateTime.newInstanceGmt(today.dateGMT(), myTime);
		DateTime dateFrom  = todayWithoutTime.addDays(-Integer.valueOf(offset.Days_Before__c));
		DateTime dateThru = todayWithoutTime.addDays( Integer.valueOf(offset.Days_After__c));
		datesObj.dateFromTimestamp = dateFrom.getTime();
		datesObj.dateThruTimestamp = dateThru.getTime();
	}
	
	
	private class Dates {
		public Long dateFromTimestamp {get; set;}
		public Long dateThruTimestamp {get; set;}
	}

	private class AccountWritebackScheduleRequest {
			Id kpisetid;
			String jobname;
			String salesorg;
			Set<Id> accountids;
			Set<Id> categoryids;
			Long datefrom;
			Long datethru;
			String batchchain;
			private AccountWritebackScheduleRequest(String kpisetid, String jobName, NightlyCalculationBatch.NightlyAccountSchedulingParameters parameters, Set<Id> accountids, Long datefrom, Long datethru) { 
				this.kpisetid = kpisetid;
				this.jobname = jobName;
				this.salesorg = parameters.salesOrg;
				this.accountids = accountids;
				this.categoryids = parameters.categoryids; 
				this.datefrom = datefrom;
				this.datethru = datethru;
				this.batchchain = parameters.batchChain;
			}
	}
}