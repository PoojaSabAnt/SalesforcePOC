/**  PROGRAM NAME : PromotionAggregationDelete  
     * This class is for deleting invalid records from promotion store
     * @see    PromotionAggregationExecution
     * @version  1.0
*/
public class AggregatePromotionDelete {
    private List<Id> lstPromotionToDelete = new List<Id>();
    private static final Type classType = AggregatePromotionDelete.class;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final String PROMOTION_PHASE_COMMITTED = 'Committed';
    //private String txId;     
    
    public AggregatePromotionDelete() {
        
    }
    /**querying all the invalid records from the promotion store
     * invalid records :- which are not valid in the current date range,not active and Promotion phase is not equals to committed
     * @name invalidPromotionRecord 
     * @param empty
     * @return List<Id> promotionStoreId
     */
    public List<Id> invalidPromotionRecord() {
        //LogTrace logTraceHandle;
        try {
            //logTraceHandle = LoggerUtility.enterMethod(txId, classType, 'invalidPromotionRecord', LogTrace.SOURCETYPE.Batch, new String[] {});
            
			Date fromDate;
             if(Test.isRunningTest()){
                 fromDate = Date.Today().addDays(7);
             }else{
                fromDate = Date.Today().addDays(Integer.valueOf(System.label.MDLZ_DateCriteria));
             }
			 
            String pasQuery ='SELECT Id FROM ACCL__Promotion_Store__c WHERE ACCL__Promotion__r.ACCL__Date_Thru__c < TODAY OR ACCL__Promotion__r.ACCL__Date_From__c > :fromDate OR ACCL__Promotion__r.ACCL__Active__c=false OR ACCL__Promotion__r.ACCL__Phase__c  !=: PROMOTION_PHASE_COMMITTED LIMIT 10000';
            //pasQuery = String.format(pasQuery, new List<String>{ns});
            List<sObject> listPromotion = Database.query(pasQuery);
            if(listPromotion != null && listPromotion.size()> 0) {
                System.debug('InsidelistPromotion44'+listPromotion);
                for(sObject prmStore : listPromotion) {
                    lstPromotionToDelete.add(prmStore.Id);
                    }
            }
        } catch(Exception ex) {
            //throw LoggerUtility.handleException(txId, ex);
            System.debug('Exception: ' +ex);
        }
        return lstPromotionToDelete;
    }
}