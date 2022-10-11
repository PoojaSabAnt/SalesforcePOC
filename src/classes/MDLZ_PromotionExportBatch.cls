/***************************************************************
Name: MDLZ_PromotionExportBatch
======================================================
Purpose: this batch process will update Ad-break date,Week start , Week End for Promotion Store records.
o New process will create those promotion Export records whose Promotion is active.
o New process will take into consideration Week Start as Sunday and week end as End date.Developed as
part of JIRA MRELKXIW-4366.
o Example: Promotion Start date = 1st July 2022 , Promotion End Date = 31st July 2022. Batch executes on 3rd July 2022,
On Account , Ad-Break Day = Wednesday.Then following will be populated by Batch on Promotion Export record,
Week Start = 3rd July , Week End = 9th July , Ad- break day = 6th July.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Jinal Desai                  07/01/2022     Initial Development    

***************************************************************/

global class MDLZ_PromotionExportBatch implements Database.Batchable<sObject>{
    
    public static MDLZ_Promotion_Export_AdBreak__mdt adbreakMetadata = getMetadataRecord();
    
    global Database.QueryLocator start(Database.BatchableContext bCtx){
        
        String query = 'Select Id , Name , Promotion__c,Store__c,Store__r.ACCL__Account_Number__c, '+
            			+'Store__r.MDLZ_Ad_Break_Day__c, Promotion__r.ACCL__Date_From__c,Promotion__r.ACCL__Date_Thru__c, '+
            			+'Promotion__r.ACCL__Anchor_Account__r.Name , Promotion__r.ACCL__Anchor_Account_Set__r.ACCL__Description__c, '+
            			+'Promotion__r.ACCL__Promotion_Template_Description__c'
            			+' from MDLZ_Promotion_Store__c';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        
        MDLZ_PromotionExportHandler.createPromoExportRecord(scope,adbreakMetadata);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /**
     * Custom metadata 'MDLZ_Promotion_Export_AdBreak__mdt' is created,
     * This custom metadata will store 'no of days' to be added to Batch execution Date,
	 * so that we can calculate Week Start , Week End date ,Ad break date.
	 * getMetadataRecord() method will pick up matadata record based on day on which batch is executed.
	 * Example: If batch is executed on Friday , matadata record name 'Friday' will be fetched and 
	 * accordingly calculations will be done.
    **/ 
    public static MDLZ_Promotion_Export_AdBreak__mdt getMetadataRecord(){
        Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String dayOfWeek=dt.format('EEEE');
        System.debug('###### Day : ' + dayOfWeek);
        
        MDLZ_Promotion_Export_AdBreak__mdt metadataRec = [Select Id , Label, Week_Start_Sun__c,Week_End_Sat__c,
                                                          Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,
                                                          Saturday__c,Sunday__c,Batch_Size__c
                                                          from MDLZ_Promotion_Export_AdBreak__mdt 
                                                          where Label = :dayOfWeek limit 1];
        
        return metadataRec;
        
    }
    
}