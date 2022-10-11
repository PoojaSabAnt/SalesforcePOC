/***************************************************************
Name: MDLZ_AddCustomerSetToCustomerTask
======================================================
Purpose:
a.Fetch all the customer set Description and add to custom multiselect picklist datatype
b.Select the picklist value 
c.Create a record and add customers of the selected customerset into the Customer Task
d.Child customer task should be created for all customers in the assigned customer customer set
e.If new customer set is added to the parent account then it should change the due date of old child customer task
as today.
======================================================
History
-------
VERSION     AUTHOR         		REVIEWER      		DATE           DETAIL                 Description
1.0         Namitha_Francis     			       07/06/2021     Initial Development    
***************************************************************/
Public with sharing class MDLZ_AddCustomerSetToCustomerTask {  
    
    
    Public List<String> selectedPicklistValues {get;set;}//Customer set Selected Value from picklist
    Public id currentRecordId {get;set;}//Current Record Id where customer set is to be assigned
    
    //Constructor to get current recordid 
    Public MDLZ_AddCustomerSetToCustomerTask(ApexPages.StandardController controller){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); 
    } 
    
    //Fetching the customersets to display in the picklist
    Public List<SelectOption>  getCustomerSets(){
        List<SelectOption>  customerSets = new List<SelectOption>();
        try{  for( ACCL__Account_Set__c customer : [SELECT  Id, Name,ACCL__Description__c,ACCL__Sales_Org__c FROM ACCL__Account_Set__c LIMIT 900 ] ) {
            customerSets.add( new SelectOption( customer.ACCL__Description__c, customer.ACCL__Description__c ));
        }
            
           }catch(Exception e){
               
               system.debug('An exception has occurred');
               MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
               exc.insertExceptions('MDLZ_AddCustomerSetToCustomerTask.getCustomerSets()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
           } 
        return customerSets;  
    }
    
    //Executed on click of save button
    //Creates customerTask record for each customer in the selected customer sets

    Public void save(){ 
        
        set<string> setCustomer = new set<string>();
        set<string> customerSetNames = new set<string>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        new List<ExceptionLog__c>();
        ACCL__Account_Task__c customerTask = new ACCL__Account_Task__c();
        List<ACCL__Account_Task__c> customerSetInsert = new List<ACCL__Account_Task__c>();
        Map<String,String> m2 = new Map<String,String>();
        Map<String,String> m3 = new Map<String,String>();
        try {
            //get the customerTask details of the current record where customer set is being assigned
            customerTask = [Select  Id, ACCL__Account__c, RecordTypeId, MDLZ_Customer_Sets__c, MDLZ_Master_Record__c, 
                            MDLZ_Parent_RecordId__c, ACCL__Due_Date__c, ACCL__Priority__c, ACCL__Account_Task_Template__c, 
                            ACCL__Description_Language_1__c, ACCL__Sales_Org__c From ACCL__Account_Task__c Where Id =: currentRecordId LIMIT 1]; 
            	
			customerTask.ACCL__Sales_Org__c = MDLZ_ConstantHelper.US01;
            String singlePicklistValue = '';
            Boolean start = true;
            
            //create a string of selected customer sets to display in the details page.
            if(!selectedPicklistValues.isEmpty()) {          
                for(String str : selectedPicklistValues) { 
                    if(start) {
                        singlePicklistValue = str;
                        start = false;
                    }else{              
                        singlePicklistValue = singlePicklistValue + ' '+';'+' ' + str;                        
                    }
                    
                    customerTask.MDLZ_Customer_Sets__c = singlePicklistValue;
                    customerTask.MDLZ_Master_Record__c =MDLZ_ConstantHelper.CustomerPicklist;                    
                }
                
                list<ACCL__Account_Set_Account__c> l =  [Select Id,Name,ACCL__Account_Set__r.Id,
                                                       ACCL__Account_Set_Account__r.Name,
                                                       ACCL__Account_Set__r.Name,ACCL__Account_Set__r.ACCL__Description__c From 
                                                       ACCL__Account_Set_Account__c  Where  
                                                       ACCL__Account_Set__r.ACCL__Description__c IN:selectedPicklistValues ];
                                                       
                
                for(ACCL__Account_Set_Account__c prm: [Select Id,Name,ACCL__Account_Set__r.Id,
                                                       ACCL__Account_Set_Account__r.Name,
                                                       ACCL__Account_Set__r.Name,ACCL__Account_Set__r.ACCL__Description__c From 
                                                       ACCL__Account_Set_Account__c  Where  
                                                       ACCL__Account_Set__r.ACCL__Description__c IN:selectedPicklistValues ]){
                                                       
                                                           m2.put(prm.ACCL__Account_Set_Account__r.Name, prm.ACCL__Account_Set_Account__r.Id);
                                                           setCustomer.add(prm.ACCL__Account_Set_Account__c);
                                                           customerSetNames.add(prm.Name);
                                                           
                                                           if(customerTask.ACCL__Account__c!=prm.ACCL__Account_Set_Account__c ){
                                                            
                                                               ACCL__Account_Task__c customerTasknew = new ACCL__Account_Task__c(); 
                                                               customerTasknew.ACCL__Account__c =(String)prm.get('ACCL__Account_Set_Account__c');
                                                               customerTasknew.ACCL__Account_Task_Template__c=customerTask.ACCL__Account_Task_Template__c;
                                                               customerTasknew.ACCL__Description_Language_1__c= customerTask.ACCL__Description_Language_1__c;
                                                               customerTasknew.ACCL__Sales_Org__c =customerTask.ACCL__Sales_Org__c;
                                                               customerTasknew.ACCL__Priority__c = customerTask.ACCL__Priority__c;
                                                               customerTasknew.MDLZ_Customer_Sets__c =customerTask.MDLZ_Customer_Sets__c;
                                                               customerTasknew.MDLZ_Parent_RecordId__c =customerTask.Id;
                                                               customerTasknew.ACCL__Due_Date__c = customerTask.ACCL__Due_Date__c;
                                                               customerTasknew.RecordTypeId = customerTask.RecordTypeId;
                                                               
                                                               customerSetInsert.add(customerTasknew);
                                                           }    
                                                       }  
                for(ACCL__Account_Task__c excustomerTask: [Select Id, Name,ACCL__Account__c From ACCL__Account_Task__c
                                                          Where MDLZ_Parent_RecordId__c =:customerTask.Id ]){
                                                              m3.put(excustomerTask.ACCL__Account__c, excustomerTask.Id);
                                                              excustomerTask.ACCL__Due_Date__c = Date.today();
                                                              customerSetInsert.add(excustomerTask);
                                                             
                                                          }
                
            }
                
                if(customerSetInsert.size()>0){
                    List<Database.UpsertResult>  srList =  database.upsert(customerSetInsert,false);
                    
                    exc.upsertResultErrors(srList,customerSetInsert,'MDLZ_AddCustomerSetToCustomerTask().Save','ACCL__Account_Task__c');
                    
                }else{
                    system.debug('No records to be updated');
                }            
            
            //Success Message for updating Customersets into customerTask
            
            If(!selectedPicklistValues.isEmpty()  && m2.values()!=null ){
                database.update(customerTask,false);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfully Added Customer Sets'));
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Customer Set'));   
            }
            
        }catch(Exception e){   
        system.debug('any ex?');
            exc.insertExceptions('MDLZ_AddCustomerSetToCustomerTask()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
            
        } 
        
        
    }

    Public string getmyID(){
        if(currentRecordId==null)
            return'';

        else
            return currentRecordId;
    }
    //Redirect to previous page  
    Public PageReference doFinish(){
        PageReference pr = new PageReference('/'+ getmyID()); 
        pr.setRedirect(true);
        return pr;  
        
    }  
    Public void reset(){
        selectedPicklistValues.clear();
        
    } 
}