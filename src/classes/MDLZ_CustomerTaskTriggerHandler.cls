/***************************************************************
Name: MDLZ_CustomerTaskTriggerHandler
History
a.If the parent customer task is deleted, then due date of child customer task should be yesterday
b.After creation of all customer task, the sales org should be US01
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Namitha Francis   			      07/06/2021     Initial Development    
***************************************************************/
public class MDLZ_CustomerTaskTriggerHandler implements MDLZ_ITrigger{
    
    private static MDLZ_ErrorExceptionHandler exc ; 
    private static Boolean TriggerDisabled = false; 
    
    //Constructor for CustomerTaskTriggerHandler class
    public MDLZ_CustomerTaskTriggerHandler() {       
        exc = new MDLZ_ErrorExceptionHandler(); 
    }
    
        //method to check is trigger disabled or not
    public Boolean isDisabled(){
        MDLZ_Trigger_Switch__c switchVar = MDLZ_Trigger_Switch__c.getInstance('MDLZ_CustomerTaskTrigger');
        
        if(switchVar != NULL && !switchVar.MDLZ_Active__c){ 
            TriggerDisabled=  true;
        }
        return TriggerDisabled;
    }
    //This method will be called on before insert
    public void beforeInsert(List<ACCL__Account_Task__c> customerTaskList) {
        try{
        for(ACCL__Account_Task__c newCustomerTaskList :customerTaskList){
            
            newCustomerTaskList.ACCL__Sales_Org__c = MDLZ_ConstantHelper.US01;
        	}
        }catch(Exception ex){
                exc.insertExceptions('MDLZ_CustomerTaskTriggerHandler.beforeInsert()', ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
            }
        
    }
    //This method will be called on after delete action
    public void afterDelete(Map<Id, sObject> oldItems) {
        
        // Collecting all child tasks related to deleted masters
        List<ACCL__Account_Task__c> listChildTasks = [ SELECT Id,ACCL__Due_Date__c FROM ACCL__Account_Task__c WHERE MDLZ_Parent_RecordId__c IN : oldItems.keySet()];        
    
        List<ACCL__Account_Task__c> listChildToupdate = new List<ACCL__Account_Task__c>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        // For the above children, updating the  ACCL__Due_Date__c to yesterday
        try{
        for( ACCL__Account_Task__c child : listChildTasks ) {       
            child.ACCL__Due_Date__c = System.Today() - 1;
            listChildToupdate.add(child);        
        }        
        // Updating the above children
        srList = Database.update(listChildToupdate,false);
        exc.saveResultErrors(srList,listChildToupdate,'MDLZ_ErrorExceptionHandler().saveErrorResults','ACCL__Account_Task__c', 'Id');

        }catch(Exception ex){
                exc.insertExceptions('MDLZ_CustomerTaskTriggerHandler.afterDelete()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
            }      
    }
    //This method is called on after insert
    public void afterInsert(Map<Id, SObject> newRecord){}
    //This method will be called on before delete action
    public void beforeDelete(Map<Id, sObject> oldItems) {}
    //This method will be called on after update action
    public void afterUpdate(Map<Id, sObject> newTaskMap, Map<Id, sObject> oldTaskMap) {}
    //This method will be called on before update action
    public void beforeUpdate(Map<Id, sObject> newItems, Map<Id, sObject> oldItems) {} 
    //This method will be called on after undelete action
    public void afterUndelete(Map<Id, SObject> oldItems) {}
}