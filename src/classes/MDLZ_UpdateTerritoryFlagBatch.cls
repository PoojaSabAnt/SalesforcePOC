/***************************************************************
Name: MDLZ_UpdateTerritoryFlagBatch
======================================================
Purpose:
Updates the org unit changed Flag for orphaned territories from Int Updated to Batch Processed
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                05/04/2021     Initial Development    

***************************************************************/
global class MDLZ_UpdateTerritoryFlagBatch implements Database.Batchable<sObject>,Schedulable{  
    
    //Defining the Scheduled Batch Size thru custom label
    public integer defaultChildBatchSize;
      
    
    global MDLZ_UpdateTerritoryFlagBatch(integer childBatchSize){
        defaultChildBatchSize = childBatchSize;
    }
    
    //query locator for the batch to retrieve records
    global Database.QueryLocator start(Database.BatchableContext BC)    
    {
        String intUpdated = MDLZ_ConstantHelper.IntUpdated;
        String territory = MDLZ_ConstantHelper.Territory;
        String query ;
        query = 'select id from ACCL__Org_Unit_User__c where MDLZ_isOrgUnitChanged__c =: intUpdated and ACCL__Org_Unit__r.ACCL__Org_Level__c =: territory ';
        if(test.isRunningTest()){
            query = 'select id from ACCL__Org_Unit_User__c where MDLZ_isOrgUnitChanged__c =: intUpdated and ACCL__Org_Unit__r.ACCL__Org_Level__c =: territory Limit 1';
        }
        return Database.getQueryLocator(query);
        
    }
    
    //execute method of the batch class
    global void execute(Database.BatchableContext BC, List<sobject> scope)
    {
        
        system.debug('Size of records to be cleaned up '+scope.size());
        List<sObject> orgUnitUserDbList = new List<sObject>();
        List<ExceptionLog__c> errorList = new List<ExceptionLog__c>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        
        try{
            for(sObject orgUnit: scope){
                
                orgUnit.put('MDLZ_isOrgUnitChanged__c',MDLZ_ConstantHelper.BatchProcessed);
                orgUnitUserDbList.add(orgUnit);
            }
            
            if(orgUnitUserDbList.size()> 0){
                List<Database.SaveResult>  srList =  database.update(orgUnitUserDbList,false); 
                exc.saveResultErrors(srList,orgUnitUserDbList,'MDLZ_UpdateTerritoryFlagBatch()','ACCL__Org_Unit_User__c', 'Id');
                
            }
        }catch(Exception e){   
            errorList.add( new ExceptionLog__c(MethodName__c = 'MDLZ_UpdateTerritoryFlagBatch()',ExceptionDetails__c = e.getMessage(),Error_Line_Number__c = e.getLineNumber(),
                                               ExceptionCode__c = e.getTypeName()) );
           
        }
       
        if(errorList.size() > 0){
            exc.insertExceptions(errorList); 
        }
        
    }
    
    //schedulable execute method for the batch class
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, defaultChildBatchSize); 
    } 
    
    //finish method of the batch class
    global void finish(Database.BatchableContext BC)
    {
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob details = [SELECT Id, Status,ExtendedStatus,MethodName, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email 
                                FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        System.debug('Batch Process Details' +details);        
    }
}