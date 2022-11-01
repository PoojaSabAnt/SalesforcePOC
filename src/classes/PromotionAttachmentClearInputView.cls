/**  PROGRAM NAME : PromotionAttachmentClearBatchInputView  
     * This class is used for making the start method query for PromotionAttachmentClearBatchBatch
     * to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
     * @see    PromotionAttachmentClearBatchBatch
*/
global with sharing class PromotionAttachmentClearInputView {

	private static final String FORMAT_DATETIME = 'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'';
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static String query ='SELECT Id, CreatedDate, (SELECT Id FROM {0}Promotion_Attachment_Link__r)'
                                +'FROM {0}Promotion_Attachment__c WHERE CreatedDate < {1}';

    /**Returning query for database.queryLocator passing this to start method in PromotionAttachmentClearBatchBatch
     *  @name getObjectDataReader 
     *  @param None
     *  @return Database.QueryLocator
     */
    global Database.QueryLocator getObjectDataReader() {

		Datetime expiredTime = Datetime.now().addDays(-1);
        query = String.format(query, new List<String>{ns, expiredTime.format(FORMAT_DATETIME)}); 
        return Database.getQueryLocator(query); 
    }

}