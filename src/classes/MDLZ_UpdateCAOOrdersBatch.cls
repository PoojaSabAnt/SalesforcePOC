/***************************************************************
Name: MDLZ_UpdateCAOOrdersBatch
======================================================
Purpose:
a. batch2 to update CAO orders to Routed or cancelled 
refer conditions in confluence matrix.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi            	 25/09/2021     Initial Development 
1.1      Priya Tubachi               10/05/2022     Optimizing class for AMS issues
***************************************************************/
global with sharing class MDLZ_UpdateCAOOrdersBatch implements Database.Batchable< sObject >, Schedulable {
    
    /***** Private variables ********/
    private static Integer DEFAULTBATCHSIZE = 200;
    private Integer batchSize;
    private static final string PROCESS_NAME = MDLZ_ConstantHelper.UPDATE_CAO_ORDERS;
    
    /** Initializing the constructor for the batch class **/
     
    global MDLZ_UpdateCAOOrdersBatch() {
        String squery ='SELECT ACCL__Batch_Size__c FROM ACCL__Batch_Process_Configuration__c WHERE Name=:PROCESS_NAME';
        List<sObject> sobjList = Database.query(sQuery);
       
        if(!sobjList.isEmpty()) {
            batchSize = ((Decimal)sobjList[0].get('ACCL__Batch_Size__c')).intValue();  
        }
        else
        {
           batchSize = DEFAULTBATCHSIZE;
        } 
    }
    
    /** start method of Batch class for input query**/
    
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        
        //Retrieve list of orders with order template as EDI and NOS for the current day
        String query = 'SELECT ACCL__Delivery_Date__c,ACCL__Order_Account__c, ACCL__Order_Template__r.Name,ACCL__Phase__C,MDLZ_Total_Case_Quantity__c'
            +' FROM ACCL__Order__c WHERE ACCL__Customer_Order_Id__c = \'\' and ACCL__Delivery_Date__c >=today and ACCL__Delivery_Date__c <= tomorrow and'+
            ' ACCL__Order_Template__r.Name in (\'Order Wrapper\') and ACCL__Phase__c in (\'Received By SAP\')';
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<sobject> orderList)
    {
        new MDLZ_OrderConsolidation().updateCAOOrdersNew(orderList);
    }
    
    //schedulable method of the batch class
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, batchSize);
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                                CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);    
    }
}