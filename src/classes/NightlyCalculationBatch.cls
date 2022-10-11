/** This class is used to set the necessary parameters which is expected by each Schedule class (Example: ScheduleReorganization,ScheduleAccountWriteback).
 *  This class calls the Schedule worker class in specific order which invokes all the worker endpoints.(order of endpoint execution -> ScheduleReorgnization,ScheduleAccountProductList,PromotionLoader and ScheduleAccountWriteback).
 */

public class NightlyCalculationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	private static final String JOB_NAME = 'Promotions';
	private static final String PHASE_CANCELLED = 'Cancelled';
	private static final String PHASE_PREPARATION = 'Preparation';

	private String query = 'SELECT Id, ACCL__Version__c FROM ACCL__Promotion__c WHERE ACCL__Sales_Org__c = :salesOrg AND ACCL__Anchor_Account__c IN :accountIds AND ACCL__Phase__c NOT IN (\'' + PHASE_PREPARATION + '\',\'' + PHASE_CANCELLED + '\') AND ACCL__Active__c = true';
	public NightlyAccountSchedulingParameters scheduleParameters {
		get;set;
	}

	 /**
	 * Parmaters container used by the NightlyCalculationBatch.
	 */
	public class NightlyAccountSchedulingParameters {
		public String salesOrg {
			get; set;
		}
		public Set<Id> accountIds {
			get; set;
		}
		public Map<Id, List<Set<Id>>> kpiSetToSetOfAccounts {
			get; set;
		}
		public String txId {
			get; set;
		}
		public Set<Id> categoryids {
			get; set;
		}
		public Boolean refreshAccountProductList {
			get; set;
		}
        public String batchChain {
            get; set;
        }
	}

	 /**
     * Constructor.
     * @param salesOrg string value from Configuration record.
     * @param refreshAccountProductList Boolean value from Configuration, identify AccountProductList is either partial or full.
     */
	public NightlyCalculationBatch(String salesOrg, Boolean refreshAccountProductList) {
		this.scheduleParameters = new NightlyAccountSchedulingParameters();
		this.scheduleParameters.salesOrg = salesOrg;
		this.scheduleParameters.txId = ACCL.TransactionHandler.generateGUID();
		this.scheduleParameters.refreshAccountProductList = refreshAccountProductList;

        setScheduleParameters();

        ScheduleReorganization.schedule(this.scheduleParameters.txId, this.scheduleParameters.salesOrg, this.scheduleParameters.batchChain);
        ScheduleAccountProductList.schedule(this.scheduleParameters);
	}

	 /**
     *  @Description start function used to query the necessary SOQL data.
     *  @param BC BatchableContext
     *  @return query result
     */
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Set<Id> accountIds = scheduleParameters.accountIds;
		String salesOrg = scheduleParameters.salesOrg;
		return Database.getQueryLocator(query);
	}

	/**
    *  @Description execute
    *  @param BatchableContext BC hold the values which we queried in start method.
    *  @param scope List of promotion records.
    *  @return void.
    */

	public void execute(Database.BatchableContext BC, List<ACCL__Promotion__c> scope) {
        Set<Id> promotionIds = new Map<Id, ACCL__Promotion__c>(scope).keySet();
		try {
            PromotionScheduleRequest request = new PromotionScheduleRequest(JOB_NAME, this.scheduleParameters.salesOrg, promotionIds, this.scheduleParameters.batchChain);
            ACCL.OffPlatformCallout calloutRequest = new ACCL.OffPlatformCallout('SCHEDULE_PROMOTION_CALCULATION', this.scheduleParameters.salesOrg);
            calloutRequest.execute(this.scheduleParameters.txId, null, JSON.serialize(request));
        } catch(Exception ex) {
                String jobId = BC.getJobId();
                System.abortJob(jobId);
            }
        }

	/**
    *  @Description finish
    *  @param BC BatchableContext BC hold the values which we queried in start method.
    *  @return void.
    */

	public void finish(Database.BatchableContext BC) {
        try {
            ScheduleAccountWriteback.schedule(this.scheduleParameters);
        } catch(Exception ex) {
                String jobId = BC.getJobId();
                System.abortJob(jobId);
            }
        }

	public void setScheduleParameters() {
		this.scheduleParameters.batchChain = String.format('TPM_Batches_{0}_{1}', new List<String>{ this.scheduleParameters.salesOrg, System.now().format('YYYYMMdd') });
		this.scheduleParameters.accountIds = new Set<Id>();
		this.scheduleParameters.kpiSetToSetOfAccounts = new Map<Id,List<Set<Id>>>();
		for (ACCL__Account_Extension__c a : [SELECT ACCL__Account__c, ACCL__Account__r.ACCL__Account_Template__c , ACCL__Account__r.ACCL__Account_Template__r.ACCL__KPI_Set_Plan_Dependent__c , ACCL__Account__r.ACCL__Account_Template__r.ACCL__Available_Product_Level__c FROM ACCL__Account_Extension__c WHERE ACCL__Account__r.ACCL__Sales_Org__c =:scheduleParameters.salesOrg  AND ACCL__Account_Plan_Type__c = 'Plan' AND ACCL__Account__r.ACCL__Account_Template__r.ACCL__KPI_Set_Plan_Dependent__c !=null ]){
			Id currentKpiSetId = a.ACCL__Account__r.ACCL__Account_Template__r.ACCL__KPI_Set_Plan_Dependent__c;
			List<Set<Id>> currentAccIdsForKpiSet = scheduleParameters.kpiSetToSetOfAccounts.get(currentKpiSetId);
			if(currentAccIdsForKpiSet == null ) {
				scheduleParameters.kpiSetToSetOfAccounts.put(currentKpiSetId, new List<Set<Id>> { new Set<Id>{a.ACCL__Account__c}  });
			} else {
				Set<Id> currentSetOfValues = currentAccIdsForKpiSet.get(currentAccIdsForKpiSet.size()-1);
				if(currentSetOfValues.size() == 1000) { 
					currentAccIdsForKpiSet.add(new Set<Id>{a.ACCL__Account__c});
				} else {
					currentSetOfValues.add(a.ACCL__Account__c);
				}
			}
			scheduleParameters.accountIds.add(a.ACCL__Account__c);
		}
		this.scheduleParameters.categoryids = new Map<Id, ACCL__Product__c>([SELECT Id FROM ACCL__Product__c WHERE ACCL__Sales_Org__c =:scheduleParameters.salesOrg AND ACCL__Product_Level__c ='Category']).keySet();
	}

	/**
	* Parameters container used by WebServiceUtils invoking the Promotion endpoint.
	*/
	private class PromotionScheduleRequest {
		String jobname;
		String salesorg;
		Set<Id> promotionids;
		String batchchain;

		private PromotionScheduleRequest( String jobName, String salesOrg, Set<Id> promotionIds, String batchChain) { 
			this.jobname = jobName;
			this.salesorg = salesOrg;
			this.promotionids = promotionIds; 
			this.batchchain = batchChain;
		}
	}
}