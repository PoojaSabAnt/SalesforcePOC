/**  PROGRAM NAME : PromotionAttachmentClearExecution
  * This class is execution class for PromotionAttachmentClearBatch implementing ACSFBatchBLExecution
  * to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
  * @see    PromotionAttachmentClearBatch
*/
global with sharing class PromotionAttachmentClearExecution {

    private static final string ns = AddOnConstants.NAMESPACEPREFIX;

    /**Processing product assortment record with batch size 1 And storing the result in Product assortment store object
     * @name process
     * @param List<sObject>
     * @return void
     */
    //Paramter_Tempering - False Positive
    //This method is part of PromotionAttachmentClearBatch and List <Sobject> is retrieved from the init() method of the batchhence it is not modifiable. So no parameter tempering possible.
    global void process(List<SObject> attachsList ){
        Set<Id> promotionId = new Set<Id>();

        List<SObject> listPromoAttachToDelete = new List<SObject>();

        for(sObject prom : attachsList ) {
            if( prom.getSObjects(ns+'Promotion_Attachment_Link__r') == null ) {
                listPromoAttachToDelete.add(prom);
                promotionId.add((Id)prom.get('Id'));
            }
        }

        // Get all the atachments that are part of an unused Promotion Attachment Link
        List<Attachment> listAttachToDelete = [SELECT Id FROM Attachment WHERE ParentId IN :promotionId];

        //Check if List is empty or not
        if(!listAttachToDelete.isEmpty() && listAttachToDelete.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
                if (Attachment.sObjectType.getDescribe().isDeletable()){
                    Database.delete(listAttachToDelete, false);
                }else{
                    throw new InsufficientPriviledgesToDeleteAttachmentException('Insufficient privileges');
                }
        }

        if(!listPromoAttachToDelete.isEmpty() && listPromoAttachToDelete.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
                if (listPromoAttachToDelete[0].getSObjectType().getDescribe().isDeletable()){
                    Database.delete(listPromoAttachToDelete, false);
                }else{
                    throw new InsufficientPriviledgesToDeleteAttachmentException('Insufficient privileges');
                }
        }
    }

     /**This method is for any finish block processing
     * deleting all the invalid records from store that is product assortment not in valid range
     * @name processFinish
     * @param empty
     * @return void
     */
    global void processFinish() {

    }

    public class InsufficientPriviledgesToDeleteAttachmentException extends Exception{
    }

}