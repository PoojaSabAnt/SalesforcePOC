/**
 * Class that create test data to test the batch PromotionAttachmentClearBatch
 * @see PromotionAttachmentClearBatch
 */
public with sharing class PromotionAttachmentClearBatchTestFactory {

    private static final string ns = AddOnConstants.NAMESPACEPREFIX;

    /** Create a Default Account */
    public static SObject getDefaultAccount() {
    
        SObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        sObj.put('Name','TestClass_Testing');  
        sObj.put(ns+'City__c','Test City');     
        sObj.put(ns+'Street__c','Test Street'); 
        sObj.put(ns+'Name_2__c','testX');           

        return sObj;
    }

    /** Insert a Promotion_Template__c */
    public static SObject insertPromotionTemplate(Integer nameSuffix){
        SObject sObj = Schema.getGlobalDescribe().get(ns+'Promotion_Template__c').newSObject() ;
        sObj.put('Name','Test'+nameSuffix);         
        sObj.put(ns+'Description_Language_1__c','lan'+nameSuffix);
        sObj.put(ns+'Active__c',true);
        sObj.put(ns+'Active_Policy__c',true);
        sObj.put(ns+'Consider_Listing__c',true); 
        sObj.put(ns+'Creation_Platform__c','Laptop');
        sObj.put(ns+'Display_In_call__c', true);
        sObj.put(ns+'Mobility_Color__c','White');
        sObj.put(ns+'Sort__c',1);
        sObj.put(ns+'Promotion_Type__c', 'Promotion');
        sObj.put(ns+'Is_Derivable__c', false);
        sObj.put(ns+'Product_Definition_Level__c', 'Tactic');
        sObj.put(ns+'Product_Definition_Policy__c', 'Dynamic');
        sObj.put(ns+'Anchor_Type__c', 'Customer');        

        insert sObj;
        return sObj;
    }         

    /** Insert a Promotion__c */
    public static SObject insertPromotion(Integer i, SObject template, SObject account,String Phase){
        SObject sObj = Schema.getGlobalDescribe().get(ns+'Promotion__c').newSObject() ;

        sObj.put(ns+'Active__c',true);
        sObj.put(ns+'Anchor_Account__c',account.Id);
        sObj.put(ns+'Commit_Date__c',system.today());
        sObj.put(ns+'Promotion_Template__c',template.Id);
        sObj.put(ns+'Date_From__c',system.today());
        sObj.put(ns+'Date_Thru__c',system.today().addYears(1));
        sObj.put(ns+'Delivery_Date_From__c',system.today());
        sObj.put(ns+'Delivery_Date_Thru__c',system.today().addDays(30));
        sObj.put(ns+'Order_Date_From__c',system.today());
        sObj.put(ns+'Order_Date_Thru__c',system.today().addYears(1));
        sObj.put(ns+'Placement_Date_From__c',system.today());
        sObj.put(ns+'Placement_Date_Thru__c',system.today().addYears(1));
        sObj.put(ns+'Slogan_Language_1__c','slogan '+i);
        sObj.put(ns+'Phase__c',phase);
        insert sObj;
        return sObj;
    }    

    /** Insert a Promotion_Attachment_Link__c */
    public static SObject insertPromotionAttachmentLink(SObject promotion, SObject promotionAttachment){
        SObject sObj = Schema.getGlobalDescribe().get(ns+'Promotion_Attachment_Link__c').newSObject() ;

        sObj.put(ns+'Promotion__c',promotion.id);
        sObj.put(ns+'Promotion_Attachment__c',promotionAttachment.id);
        insert sObj;
        return sObj;
    }

    /** Insert a Promotion_Attachment__c */
    public static SObject insertPromotionAttachment(Integer nameSuffix){
        SObject sObj = Schema.getGlobalDescribe().get(ns+'Promotion_Attachment__c').newSObject() ;
        
        sObj.put(ns+'Description_Language_1__c',' Test ' + nameSuffix);
        insert sObj;
        return sObj;
    }

     /** Create a Attachment */
    public static Attachment buildAttachment(Id referenceId){
        
        Attachment attach=new Attachment();   
           
        attach.Name='Unit Test Attachment.txt'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.ContentType='text/plain';
        attach.body=bodyBlob;
         
        attach.parentId=referenceId; 
                
        return attach;
    }
}