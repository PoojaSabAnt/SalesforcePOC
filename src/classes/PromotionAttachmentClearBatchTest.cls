/**
 * Class that to test the batch PromotionAttachmentClearBatch
 * @see PromotionAttachmentClearBatch
 */
@isTest
public class PromotionAttachmentClearBatchTest {

    private static final string ns = AddOnConstants.NAMESPACEPREFIX;    
    public static testMethod void deleteNoPromotionAttachments(){
        
        //Customer creation 
        SObject customer = PromotionAttachmentClearBatchTestFactory.getDefaultAccount(); // Account
        
        //Promotion template creation    
        SObject promotionTemplate = PromotionAttachmentClearBatchTestFactory.insertPromotionTemplate(1);  //Promotion_Template__c    
        
        //Promotion creation
        SObject promotion = PromotionAttachmentClearBatchTestFactory.insertPromotion(1, promotionTemplate, customer,'New'); //Promotion__c
        
        SObject promoAttFirst = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachment(1);
        SObject promoAttScnd = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachment(2);
 
        List<SObject> listPromoAttachment = new List<SObject>();
        listPromoAttachment.add(promoAttFirst);
        listPromoAttachment.add(promoAttScnd);
        
        List<Attachment> listAttachment = new List<Attachment>();
        for (SObject promoAtt: listPromoAttachment) {
            Attachment attachment = PromotionAttachmentClearBatchTestFactory.buildAttachment(promoAtt.Id);
            listAttachment.add(attachment);   
            
            Attachment attachmentPrev = PromotionAttachmentClearBatchTestFactory.buildAttachment(promoAtt.Id);
            attachmentPrev.Description = '#Preview#';  
            listAttachment.add(attachmentPrev);   
        }
        insert listAttachment;
        
        
        //Creation of the Promotion Attachment Link that links the Promotion Attachment and the Promotion (only 1st Promotion Attachment linked)
        SObject promoLink = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachmentLink(promotion, listPromoAttachment[0]); //Promotion_Attachment_Link__c
        
        Test.startTest();
        
        //Execution of the batch.
        Database.executeBatch(new PromotionAttachmentClearBatch(), 200);
        
        Test.stopTest();
        
        // This scheduler & batch class is used to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
        String squery ='select id from {0}Promotion_Attachment__c';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);

        System.assertEquals(2, sobjList.size());


        // This scheduler & batch class is used to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
        System.assertEquals(4, [select id from Attachment].size());
        
    }        
    
    public static testMethod void deleteAllPromotionAttachments(){
        
        //Customer creation
        SObject customer = PromotionAttachmentClearBatchTestFactory.getDefaultAccount(); //Account
        
        //Promotion template creation    
        SObject promotionTemplate = PromotionAttachmentClearBatchTestFactory.insertPromotionTemplate(1);   //Promotion_Template__c     
        
        //Promotion creation
        SObject promotion = PromotionAttachmentClearBatchTestFactory.insertPromotion(1, promotionTemplate, customer,'New'); //Promotion__c
        
        SObject promoAttFirst = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachment(1); //Promotion_attachment__c
        SObject promoAttScnd = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachment(2);  //Promotion_attachment__c
        //Set createddate to the day before yesterday to promoAttScnd
        Test.setCreatedDate(promoAttScnd.id, Datetime.now().addDays(-2));
        // Load the test data from a static resource since 
        List<SObject> listPromoAttachment = new List<SObject>();
        listPromoAttachment.add(promoAttFirst);
        listPromoAttachment.add(promoAttScnd);
        
        List<Attachment> listAttachment = new List<Attachment>();
        for (SObject promoAtt: listPromoAttachment) {
            Attachment attachment = PromotionAttachmentClearBatchTestFactory.buildAttachment(promoAtt.Id);
            listAttachment.add(attachment);   
            
            Attachment attachmentPrev = PromotionAttachmentClearBatchTestFactory.buildAttachment(promoAtt.Id);
            attachmentPrev.Description = '#Preview#';  
            listAttachment.add(attachmentPrev);   
        }
        insert listAttachment;
        
        
        //Creation of the Promotion Attachment Link that links the Promotion Attachment and the Promotion (only 1st Promotion Attachment linked)
        SObject promoLink = PromotionAttachmentClearBatchTestFactory.insertPromotionAttachmentLink(promotion, listPromoAttachment[0]); //Promotion_Attachment_Link__c
        
        Test.startTest();
        
        //Execution of the batch.
        Database.executeBatch(new PromotionAttachmentClearBatch(), 200);
        
        Test.stopTest();
        
        // This scheduler & batch class is used to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
        String squery ='select id from {0}Promotion_Attachment__c';
        squery = String.format(squery, new List<String>{ns});
        List<sObject> sobjList = Database.query(sQuery);
        System.assertEquals(1, sobjList.size());
        
        // This scheduler & batch class is used to reset/clear Promotion Attachments not used during the 24 hours after the creation itself
        System.assertEquals(2, [select id from Attachment].size());
        
    }
}