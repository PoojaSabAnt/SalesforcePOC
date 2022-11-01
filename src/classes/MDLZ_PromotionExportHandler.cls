/***************************************************************
Name: MDLZ_PromotionExportHandler
======================================================
Purpose: this batch process will create Ad-break date,Week start , Week End for Promotion export records.
o New process will create those promotion export records whose Promotion is active.
o New process will take into consideration Week Start as Sunday and week end as End date.Developed as
part of JIRA MRELKXIW-4366.
o Example: Promotion Start date = 1st July 2022 , Promotion End Date = 31st July 2022. Batch executes on 3rd July 2022,
On Account , Ad-Break Day = Wednesday.Then following will be populated by Batch on Promotion Store record,
Week Start = 3rd July , Week End = 9th July , Ad- break day = 6th July.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Jinal Desai                    07/01/2022     Initial Development    

***************************************************************/

public class MDLZ_PromotionExportHandler {
    
    public static Map<Id,Date> promoIdToWeekStartDate = new Map<Id,Date>();
    public static Map<Id,Date> promoIdToWeekEndDate = new Map<Id,Date>();
    public static String FandD  = MDLZ_ConstantHelper.Template_FandD;
    public static String SCRIPTED = MDLZ_ConstantHelper.Template_Scripted;
    public static String NON = MDLZ_ConstantHelper.Template_Non;
    
    public static void createPromoExportRecord(List<MDLZ_Promotion_Store__c> promotionStoreList,MDLZ_Promotion_Export_AdBreak__mdt adbreakMetadata){
        
        Set<Id> promotionIdSet = new Set<Id>();
        Date weekStartDate,weekEndDate;
        Map<Id,Set<String>> promotionToTacticProductMap = new Map<Id,Set<String>>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        
        List<MDLZ_Promotion_Store__c> validPromoStoreList = new List<MDLZ_Promotion_Store__c>();
        Map<Id,Date> accIdToAdBreakDateMap = new Map<Id,Date>();
        List<MDLZ_Promotion_Export__c> createPromoExportList = new List<MDLZ_Promotion_Export__c>();
        Map<Id,String> accIdToL4AccountName = new Map<Id,String>();
        Set<Id> accIdSet = new Set<Id>();
        
        try{
            
            for(MDLZ_Promotion_Store__c promoStore : promotionStoreList){
                promotionIdSet.add(promoStore.Promotion__c);
            
                // calculates Week start date for Promotion Store record by adding no of days to batch execution day.
                weekStartDate = Date.today().addDays(Integer.valueOf(adbreakMetadata.Week_Start_Sun__c));
                promoIdToWeekStartDate.put(promoStore.Promotion__c,weekStartDate); 
                     
                // calculates Week End date for Promotion Store record by adding no of days to batch execution day.
                weekEndDate = Date.today().addDays(Integer.valueOf(adbreakMetadata.Week_End_Sat__c)); 
                promoIdToWeekEndDate.put(promoStore.Promotion__c,weekEndDate);
            
                Integer weekNum;
                Boolean isvalidAdBreakDate = false;
                Date adbreakDate;
            
                //Calculate Ad-break date for each Account        
                if(String.valueOf(promoStore.Store__r.MDLZ_Ad_Break_Day__c) != null){
                    weekNum = getWeekday(String.valueOf(promoStore.Store__r.MDLZ_Ad_Break_Day__c),adbreakMetadata);
                    adbreakDate = weekStartDate.addDays(weekNum);
                
                    // check if Ad break Date is within Week Start Date, Week End Date and Promotion End Date.
                    isvalidAdBreakDate = checkValidAdbreakDate(promoStore.Promotion__r.ACCL__Date_From__c,promoStore.Promotion__r.ACCL__Date_Thru__c,
                                                       weekStartDate,weekEndDate,adbreakDate);
                                                       
                }
            
                //Consider only those Promotion Store records whose Ad break date falls within our criteria 
                if(isvalidAdBreakDate){
                    validPromoStoreList.add(promoStore);
                    accIdToAdBreakDateMap.put(promoStore.Store__c,adbreakDate);
                    accIdSet.add(promoStore.Store__c);
                }
            }// end-of for
        
            // Get all Tactic Products with PPG , Sub ppg combinations related to Promotions.
            if(promotionIdSet.size() > 0){
                promotionToTacticProductMap = getTacticProductMap(promotionIdSet);
            }
            
			// Fetch Account Hierarchy records to get Level 4 Account. Account Level 4 is required to populate Activity Description field
			// on Promotion Export Record.
            if(accIdSet.size() > 0){
                for(ACCL__Flatten_Account_Hierarchy__c rec : [Select Id , ACCL__Account__c ,
                                                             ACCL__Account_Level_04__c , ACCL__Account_Level_04__r.Name
                                                             from ACCL__Flatten_Account_Hierarchy__c
                                                             where ACCL__Account__c IN :accIdSet]){
                                                                
                       accIdToL4AccountName.put(rec.ACCL__Account__c, String.valueof(rec.ACCL__Account_Level_04__r.Name));                  
                    
                }
            }
        
            // Creation of Promotion Export records.
            if(validPromoStoreList.size() > 0){
            for(MDLZ_Promotion_Store__c promoStore : validPromoStoreList){
                
                String storeEccNum;
                
                String activityDescription;
                
                if(!accIdToAdBreakDateMap.containsKey(promoStore.Store__c)){
                    continue;
                }
                
                if(String.valueOf(promoStore.Store__r.ACCL__Account_Number__c) != null){
                    storeEccNum = String.ValueOf(promoStore.Store__r.ACCL__Account_Number__c);
                    storeEccNum = storeEccNum.replaceFirst('^0+', '');
                }
                
                if(accIdToL4AccountName != null && accIdToL4AccountName.size()>0
                  && accIdToL4AccountName.containsKey(promoStore.Store__c)){
                    activityDescription = accIdToL4AccountName.get(promoStore.Store__c);
                }
                
                if(promotionToTacticProductMap.containsKey(promoStore.Promotion__c) && accIdToAdBreakDateMap.containsKey(promoStore.Store__c)){
                    for(String tacticProduct : promotionToTacticProductMap.get(promoStore.Promotion__c)){
                        List<String> tacticProductString = tacticProduct.split('\\+');
                        //Create Promotion Export record if Promotion Template contains F&D
                        if(String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(FandD)){
                            MDLZ_Promotion_Export__c newPromoExport = new MDLZ_Promotion_Export__c();
                            newPromoExport.MDLZ_Activity_Type__c = FandD;
                            newPromoExport.MDLZ_Store__c = promoStore.Store__c;
                            newPromoExport.MDLZ_Activity_ID__c = promoStore.Promotion__c;
                            newPromoExport.MDLZ_Activity_Task_Description__c = tacticProductString[0];
                            newPromoExport.MDLZ_Activity_Task_ID__c = tacticProductString[1];
							newPromoExport.MDLZ_Activity_Description__c = activityDescription;
                            /*if(promoStore.Promotion__r.ACCL__Anchor_Account__r.Name != null){
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account__r.Name;
                            }else{
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account_Set__r.ACCL__Description__c;
                            }*/
                            newPromoExport.MDLZ_Activity_Start_Date__c = promoStore.Promotion__r.ACCL__Date_From__c;
                            newPromoExport.MDLZ_Activity_End_Date__c = promoStore.Promotion__r.ACCL__Date_Thru__c;
                            newPromoExport.MDLZ_Activity_Ad_Break_Date__c = accIdToAdBreakDateMap.get(promoStore.Store__c);
                            newPromoExport.MDLZ_StoreECC__c = storeEccNum;
                            createPromoExportList.add(newPromoExport);
                        } // end of F&D 
                        
                        //Create Promotion Export record if Promotion Template contains only 'Scripted'
                        if(String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(SCRIPTED)
                        && !String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(NON)){

                            MDLZ_Promotion_Export__c newPromoExport = new MDLZ_Promotion_Export__c();
                            newPromoExport.MDLZ_Activity_Type__c = SCRIPTED;
                            newPromoExport.MDLZ_Store__c = promoStore.Store__c;
                            newPromoExport.MDLZ_Activity_ID__c = promoStore.Promotion__c;
                            newPromoExport.MDLZ_Activity_Task_Description__c = tacticProductString[0];
                            newPromoExport.MDLZ_Activity_Task_ID__c = tacticProductString[1];
							newPromoExport.MDLZ_Activity_Description__c = activityDescription;
                            /*if(promoStore.Promotion__r.ACCL__Anchor_Account__r.Name != null){
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account__r.Name;
                            }else{
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account_Set__r.ACCL__Description__c;
                            }*/
                            newPromoExport.MDLZ_Activity_Start_Date__c = promoStore.Promotion__r.ACCL__Date_From__c;
                            newPromoExport.MDLZ_Activity_End_Date__c = promoStore.Promotion__r.ACCL__Date_Thru__c;
                            newPromoExport.MDLZ_Activity_Ad_Break_Date__c = accIdToAdBreakDateMap.get(promoStore.Store__c);
                            newPromoExport.MDLZ_StoreECC__c = storeEccNum;
                            createPromoExportList.add(newPromoExport);      
                                
                        }// end of scripted
                        
                        //Create Promotion Export record when Promotion Template other than 'F&D' , 'Scripted'
                        if(!String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(SCRIPTED)
                            && !String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(NON)
                            && !String.ValueOf(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c).contains(FandD)){

                            MDLZ_Promotion_Export__c newPromoExport = new MDLZ_Promotion_Export__c();
                            newPromoExport.MDLZ_Activity_Type__c = String.Valueof(promoStore.Promotion__r.ACCL__Promotion_Template_Description__c);
                            newPromoExport.MDLZ_Store__c = promoStore.Store__c;
                            newPromoExport.MDLZ_Activity_ID__c = promoStore.Promotion__c;
                            newPromoExport.MDLZ_Activity_Task_Description__c = tacticProductString[0];
                            newPromoExport.MDLZ_Activity_Task_ID__c = tacticProductString[1];
							newPromoExport.MDLZ_Activity_Description__c = activityDescription;
                            /*if(promoStore.Promotion__r.ACCL__Anchor_Account__r.Name != null){
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account__r.Name;
                            }else{
                                newPromoExport.MDLZ_Activity_Description__c = activityDescription + ' ' +promoStore.Promotion__r.ACCL__Anchor_Account_Set__r.ACCL__Description__c;
                            }*/
                            newPromoExport.MDLZ_Activity_Start_Date__c = promoStore.Promotion__r.ACCL__Date_From__c;
                            newPromoExport.MDLZ_Activity_End_Date__c = promoStore.Promotion__r.ACCL__Date_Thru__c;
                            newPromoExport.MDLZ_Activity_Ad_Break_Date__c = accIdToAdBreakDateMap.get(promoStore.Store__c);
                            newPromoExport.MDLZ_StoreECC__c = storeEccNum;
                            createPromoExportList.add(newPromoExport);
                                
                        }

                    }
                    
                }   
                
            }// end-of for
            
        } //end-of if
        
        if(createPromoExportList.size() > 0){
            srList = Database.Insert(createPromoExportList,false);
            exc.saveResultErrors(srList,createPromoExportList,'MDLZ_PromotionExportHandler().createPromoExportRecord','MDLZ_Promotion_Export__c','MDLZ_Store__c');
        }
            
        }catch(Exception E){
            exc.insertExceptions('MDLZ_PromotionExportHandler()',e.getMessage(),e.getLineNumber(),e.getTypeName());
        }
        
        
        
    }
    
    /* Metadata record and Ad-Break day week from Account passed as parameters
     * Based on Weekday , no of days from metadata will be fetched to calculate final ad-break date
     * Example , Ad break day on Account = Thursday , then '4' will be fetched from custom metadata
     * and logic will add 4 days to Week Start Date.
    */
    
    public static Integer getWeekday(String weekday,MDLZ_Promotion_Export_AdBreak__mdt selectedBatchMetadata){
       Integer weekNum = 0;
        switch on weekday{
            when 'Monday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Monday__c);
            }
            when 'Tuesday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Tuesday__c);
            }
            when 'Wednesday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Wednesday__c);
            }
            when 'Thursday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Thursday__c);
            }
            when 'Friday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Friday__c);
            }
            when 'Saturday' {
                weekNum = Integer.valueof(selectedBatchMetadata.Saturday__c);
            }
            when 'Sunday' {
                weekNum = Integer.valueOf(selectedBatchMetadata.Sunday__c);
            }
            
        }
        
        return weekNum;
        
    }
    
    public static Boolean checkValidAdbreakDate(Date promotionStartDate,Date promotionEndDate,
                                               Date weekStartDate , Date weekEndDate , Date adbreakDate){
                                                   
        Boolean isValidAdBreakDate = false;
                                                  
        if(adbreakDate >= weekStartDate && adbreakDate <= weekEndDate
           && adbreakDate <= promotionEndDate){
              isValidAdBreakDate = true;                                         
        }
        
        return isValidAdBreakDate;
    }

    //Method to get all the ppg and subppg combinations from tactic products related to Promtions
    public static Map<Id,Set<String>> getTacticProductMap(Set<Id> promoIdSet){
        Map<Id,Set<String>> promotionToTacticProductMap = new Map<Id,Set<String>>();
        for(ACCL__Tactic_Product__c tactic : [SELECT Id,  MDLZ_Location__c, MDLZ_SubPPG__c, MDLZ_PPG__c, Name, ACCL__Tactic__c, ACCL__Tactic__r.ACCL__Promotion__c  FROM ACCL__Tactic_Product__c WHERE ACCL__Tactic__r.ACCL__Promotion__c IN :promoIdSet]){
            if(promotionToTacticProductMap.containsKey(tactic.ACCL__Tactic__r.ACCL__Promotion__c)){
                String tacticProductString;
                if(tactic.MDLZ_SubPPG__c != null && tactic.MDLZ_SubPPG__c != ''){
                    tacticProductString = tactic.MDLZ_SubPPG__c + '+' + tactic.ACCL__Tactic__c;
                } else {
                    tacticProductString = tactic.MDLZ_PPG__c + '+' + tactic.ACCL__Tactic__c;
                }
                promotionToTacticProductMap.get(tactic.ACCL__Tactic__r.ACCL__Promotion__c).add(tacticProductString);
            } else {
                String tacticProductString;
                if(tactic.MDLZ_SubPPG__c != null && tactic.MDLZ_SubPPG__c != ''){
                    tacticProductString = tactic.MDLZ_SubPPG__c + '+' + tactic.ACCL__Tactic__c;
                } else {
                    tacticProductString = tactic.MDLZ_PPG__c + '+' + tactic.ACCL__Tactic__c;
                }
                promotionToTacticProductMap.put(tactic.ACCL__Tactic__r.ACCL__Promotion__c, new Set<String>{tacticProductString});
            }
        }
        return promotionToTacticProductMap;
    }

    public class tacticProductWrapper{
        public string ppgSubppg;
        public string tacticId;
    }

}