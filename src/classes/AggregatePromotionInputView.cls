/**
* This class is used for determining the promotion record set as a QueryLocator object that will be batched for execution
* @see    PromotionAggregationBatch
*/
global class AggregatePromotionInputView implements ACCL.ACSFBatchInputView {
    private static final Type classType = AggregatePromotionInputView.class;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX; 
    private static final String PROMOTION_PHASE_COMMITTED = 'Committed';
    //private static String txId = TransactionHandler.generateGUID();
   
    /**
    * Description Method for determining the promotion record set as a QueryLocator object that will be batched for execution
    * @param None
    * @return QueryLocator object that will be batched for execution
    */
    global Database.QueryLocator getObjectDataReader() {
        //LogTrace logTraceHandle = LoggerUtility.enterMethod(txId, classType, 'getObjectDataReader', LogTrace.SOURCETYPE.Batch, new String[] {});   
			
		Date fromDate;
        if(Test.isRunningTest()){
            fromDate = Date.Today().addDays(7);
        }else{
            fromDate = Date.Today().addDays(Integer.valueOf(System.label.MDLZ_DateCriteria));
        }
		
        String query ='SELECT Id,ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c <= :fromDate AND ACCL__Date_Thru__c >=today AND ACCL__Active__c=true AND ACCL__Phase__c=: PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
        Database.QueryLocator ql = Database.getQueryLocator(query);
        System.debug('ql'+ql);
        return ql;
    }
}