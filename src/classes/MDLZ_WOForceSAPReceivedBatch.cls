/***************************************************************
Name: MDLZ_WOForceSAPReceivedBatch
======================================================
Purpose:
a. Batch apex class that will force update as "Receiced by SAP" on the wrapper / shelf order
======================================================
History
-------
VERSION     AUTHOR         REVIWER      DATE             DETAIL              Description
1.0     Bharath Vikkurthi              08/10/2021                    Initial Development    

***************************************************************/
//Cmt: fixing defects: MRELKXIW-1925, MRELKXIW-1912, MRELKXIW-1918 & INC1062101

global class MDLZ_WOForceSAPReceivedBatch implements Database.Batchable<sObject>,Schedulable  {
    
    private integer defaultChildBatchSize;
    
    //Constructor for MDLZ_WOForceSAPReceivedBatch
    public MDLZ_WOForceSAPReceivedBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    //Fetching orders that have phase as 'SENT TO SAP' and Ischanged to false
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        
        //Cmt: 
        string sentToSap = MDLZ_ConstantHelper.PhaseSentToSAP;
        string changeFalse =  MDLZ_ConstantHelper.ChangeFalse;
        
        String query = ' SELECT ACCL__Phase__c, MDLZ_isChanged__c, LastModifiedDate, ACCL__Order_Account__c, ACCL__Delivery_Date__c'
           + ' FROM ACCL__Order__c WHERE '
            + ' ACCL__Phase__c = :sentToSap  AND ' 
            + '  MDLZ_isChanged__c = :changeFalse ';        
        return Database.getQueryLocator(query);
    }
    
    //Calling execute method
    global void execute(Database.BatchableContext BC, List<ACCL__Order__c> listOrders)
    { 
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        try{
            string sentToSAP = MDLZ_ConstantHelper.PhaseSentToSAP;
            string changeFalse =  MDLZ_ConstantHelper.ChangeFalse;
            string changeTrue = MDLZ_ConstantHelper.ChangeTrue;
            //MRELKXIW-3984 - AND MDLZ_isChanged__c = :changeTrue ';
            string relatedQuery = 'select count() from ACCL__Order__c  WHERE ' 
                + ' ACCL__Phase__c = :sentToSAP   ' 
                + ' AND MDLZ_isChanged__c = :changeTrue ';
            
            List<string> listWhereClause = new List<string>(); 
            string relatedCriteria, storeID;
            Date deliveryDate;
            id orderID;
            List<ACCL__Order__c> orderPhaseToUpd = new List<ACCL__Order__c>();
            
            //Cmt: stay below a few 1000 query size (10K soql query size limit)
            for(ACCL__Order__c odr:listOrders){
                storeID = odr.ACCL__Order_Account__c;
                deliveryDate = odr.ACCL__Delivery_Date__c;
                orderID = odr.id;
                relatedCriteria = ' AND ( ACCL__Order_Account__c = :storeID AND ACCL__Delivery_Date__c = :deliveryDate '
                    + ' AND id != :orderID )';
         
                
                integer relatedRecordCount = Database.countQuery(relatedQuery + relatedCriteria);
                system.debug('relatedRecordCount:' + relatedRecordCount);    
                if(relatedRecordCount == 0 )
                {
                    odr.ACCL__Phase__c = MDLZ_ConstantHelper.ReceivedBySAP;
                    orderPhaseToUpd.add(odr);
                }                
            }            
            List<Database.SaveResult> srList =  database.update(orderPhaseToUpd, false);            
            exc.saveResultErrors(srList,orderPhaseToUpd,'MDLZ_WOForceSAPReceivedBatch()','ACCL__Order__c', 'Name');
            
        }catch(exception e){           
            exc.insertExceptions('MDLZ_WOForceSAPReceivedBatch',e.getMessage(),e.getLineNumber(),e.getTypeName());
        }
    }
    
    //Executing the method using Database.executeBatch
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new MDLZ_WOForceSAPReceivedBatch(200), defaultChildBatchSize);   
    }   
    
    //Chaining CAO order Wrapper batch for EDI, execute after current batch is complete
    global void finish(Database.BatchableContext BC)
    {
         //  Id batchJobId = Database.executeBatch(new MDLZ_CreateWrapperEDIOrderBatch(200), defaultChildBatchSize);
        //  Database.executeBatch(new MDLZ_CreateWrapperEDIOrderBatch(200), defaultChildBatchSize);
		 Database.executeBatch(new MDLZ_CreateWrapperOrderBatch(200), defaultChildBatchSize);
    }
    
}