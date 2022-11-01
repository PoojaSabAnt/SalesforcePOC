/***************************************************************
Name: MDLZ_PromotionExportHandler
======================================================
Purpose: This class is for the bulkification of batch jobs, for DML operation more than 10k records in a
single batch. It will process the the first 10k records, then enqueue the job again for next subsequent
10k records.

History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Gaurav Gupta                  09/12/2022     Initial Development    

***************************************************************/
global class MDLZ_Queueable_Batch_DML implements Queueable { 
    //global enum Operation { INS, UPD, DEL }
    global Integer BatchSize = 10000;
    private String operation;
    private List<SObject> recordList;
    private MDLZ_Queueable_Batch_DML followupJob;
    
    global MDLZ_Queueable_Batch_DML(String operation, List<SObject> recordList) {
        // specifying the operation if insert, update or Delete and specifying the records.
        this.operation = operation;
        this.recordList = recordList;
    }
    
    // Process the records
    global void execute(QueueableContext context) {    
        //If no records are left     
        if (recordList == null || recordList.isEmpty()) { return; }
    
        Integer size = this.recordList.size();      
        Schema.SObjectType sObjectType = recordList.getSObjectType();
    
        List<SObject> activeBatch = (List<SObject>)Type.forName('List<' + sObjectType + '>').newInstance();
        System.debug('MDLZ_Queueable_Batch_DML for ' + size + ' ' + sObjectType + ' records.');
    
        if (size > BatchSize) {
            // take the last <BatchSize> records from the top and put the rest in the next queueable
            for (Integer i = size-1; i >= size-BatchSize; i--) {
                activeBatch.add(this.recordList.remove(i));
            }
            followupJob = new MDLZ_Queueable_Batch_DML(this.operation, this.recordList);
    
        } else {
            activeBatch = this.recordList;
        }
    
        switch on this.operation {
            when 'INS' {
                MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
                //List<Database.SaveResult> srList = new List<Database.SaveResult>();
                System.debug(LoggingLevel.INFO, 'Inserting ' + activeBatch.size() + ' ' + sObjectType + ' records.');
                //Insert activeBatch;
                //srList = Database.Insert(activeBatch,false);
                //Creating logs for all the errors
                exc.saveResultErrors(Database.Insert(activeBatch,false),activeBatch,'MDLZ_PromotionExportHandler().createPromoExportRecord.MDLZ_Queueable_Batch_DML','MDLZ_Promotion_Export__c','MDLZ_Store__c');
            }
            when 'UPD' {
                System.debug(LoggingLevel.INFO, 'Updating ' + activeBatch.size() + ' ' + sObjectType + ' records.');
                update activeBatch;
            }
            when 'DEL' {
                System.debug(LoggingLevel.INFO, 'Deleting ' + activeBatch.size() + ' ' + sObjectType + ' records.');
                delete activeBatch;
            }
        }
    
        if (followupJob != null) {
            //enqueue the next job
            if(!Test.isRunningTest()) {                        
                System.enqueueJob(followupJob);
            }
        }
    }
}