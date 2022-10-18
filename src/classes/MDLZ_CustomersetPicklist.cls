/***************************************************************
Name: MDLZ_CustomersetPicklist
======================================================
Purpose:
a.Fetch all the customer set description and add to custom multiselect picklist datatype
b.Select the picklist value 
c.Create a record and add customers of the selected customerset along with Sellsheet
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0         Bharath_V                   07/06/2021     Initial Development    
1.1         Bharath_V     Abir Ghosh    01/02/2022     Initial Development 
***************************************************************/

Public with sharing class MDLZ_CustomersetPicklist {  
    
    
    Public List<String> selectedPicklistValues {get;set;}//Customer set Selected Value from picklist
    Public id currentRecordId {get;set;}//Current Record Id where customer set is to be assigned
    
    //Constructor to get current recordid 
    Public MDLZ_CustomersetPicklist(ApexPages.StandardController controller){
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); 
    } 
    
    //Fetching the customersets to display in the picklist
    Public List<SelectOption>  getCustomerSets(){
        List<SelectOption>  customerSets = new List<SelectOption>();
        try{  for( ACCL__Account_Set__c customer : [SELECT  Id, Name,ACCL__Description__c FROM ACCL__Account_Set__c LIMIT 900 ] ) {
            customerSets.add( new SelectOption( customer.ACCL__Description__c, customer.ACCL__Description__c ));
           
        }
            
           }catch(Exception e){
               
               system.debug('An exception has occurred');
               MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
               exc.insertExceptions('MDLZ_CustomersetPicklist.getCustomerSets()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
           } 
        return customerSets;  
    }
    
    //Executed on click of save button
    //Creates salesfolder record for each customer in the selected customer sets
    //Also assigns sell sheets to each sales folder created.
    Public void save(){ 
        
        set<string> setCustomer = new set<string>();
        set<string> customerSetNames = new set<string>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        //List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();
        new List<ExceptionLog__c>();
        ACCL__Sales_Folder__c salesfolder = new ACCL__Sales_Folder__c();
        List<ACCL__Sales_Folder__c> customersetcustinsert = new List<ACCL__Sales_Folder__c>();
        List<ACCL__Sales_Folder_Sell_Sheet__c> ssListDb = new List<ACCL__Sales_Folder_Sell_Sheet__c>();
        Map<String,String> m2 = new Map<String,String>();
        Map<String,String> m3 = new Map<String,String>();
        try {
            //get the salesfolder details of the current record where customer set is being assigned
            salesfolder = [Select  Id, Name,ACCL__Account__c,MDLZ_Customer_Sets__c,
                           MDLZ_Master_Record__c,MDLZ_Parent_RecordId__c,
                           ACCL__Sales_Folder_Template__c,ACCL__Description_Language_1__c,ACCL__Sales_Org__c,ACCL__Valid_From__c,ACCL__Valid_Thru__c
                           From ACCL__Sales_Folder__c Where Id =: currentRecordId And ACCL__Active__c=true LIMIT 1]; 
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
                    salesfolder.MDLZ_Customer_Sets__c = singlePicklistValue;
                    salesfolder.MDLZ_Master_Record__c =MDLZ_ConstantHelper.CustomerPicklist;                    
                }
                
                for(ACCL__Account_Set_Account__c prm: [Select Id,Name,ACCL__Account_Set__r.Id,
                                                       ACCL__Account_Set_Account__r.Name,
                                                       ACCL__Account_Set__r.Name,ACCL__Account_Set__r.ACCL__Description__c From 
                                                       ACCL__Account_Set_Account__c  Where  
                                                       ACCL__Account_Set__r.ACCL__Description__c IN:selectedPicklistValues ]){
                                                           m2.put(prm.ACCL__Account_Set_Account__r.Name, prm.ACCL__Account_Set_Account__r.Id);
                                                           setCustomer.add(prm.ACCL__Account_Set_Account__c);
                                                           customerSetNames.add(prm.Name);
                                                           if(salesfolder.ACCL__Account__c!=prm.ACCL__Account_Set_Account__c ){
                                                               ACCL__Sales_Folder__c salesfoldtemp = new ACCL__Sales_Folder__c(); 
                                                               salesfoldtemp.ACCL__Account__c =(String)prm.get('ACCL__Account_Set_Account__c');
                                                               salesfoldtemp.Name =salesfolder.Name ;
                                                               salesfoldtemp.ACCL__Active__c = true;
                                                               salesfoldtemp.ACCL__Sales_Folder_Template__c=salesfolder.ACCL__Sales_Folder_Template__c;
                                                               salesfoldtemp.ACCL__Description_Language_1__c= salesfolder.ACCL__Description_Language_1__c;
                                                               salesfoldtemp.ACCL__Sales_Org__c =salesfolder.ACCL__Sales_Org__c;
                                                               salesfoldtemp.ACCL__Valid_From__c =system.today();
                                                               salesfoldtemp.ACCL__Valid_Thru__c =Date.newInstance(2999, 12, 31);
                                                               salesfoldtemp.MDLZ_Customer_Sets__c =salesfolder.MDLZ_Customer_Sets__c;
                                                               salesfoldtemp.MDLZ_Parent_RecordId__c =salesfolder.Id;
                                                               salesfoldtemp.MDLZ_Unique_Name__c = (String)prm.get('Name');
                                                               
                                                               customersetcustinsert.add(salesfoldtemp);
                                                               
                                                               system.debug('salesfoldtemp :' +salesfoldtemp); 
                                                               
                                                           }    
                                                       }  
                for(ACCL__Sales_Folder__c exSalesfolder: [Select Id, Name,ACCL__Account__c From ACCL__Sales_Folder__c
                                                          Where MDLZ_Parent_RecordId__c =:salesfolder.Id ]){
                                                              m3.put(exSalesfolder.ACCL__Account__c, exSalesfolder.Id);
                                                              exSalesfolder.ACCL__Active__c = false;
                                                              exSalesfolder.ACCL__Valid_Thru__c = System.today(); 
                                                              customersetcustinsert.add(exSalesfolder);
                                                              
                                                          }
                
                if(customersetcustinsert.size()>0){
                    
                    List<Database.UpsertResult>  srList =  database.upsert(customersetcustinsert,false);
                    
                    exc.upsertResultErrors(srList,customersetcustinsert,'MDLZ_CustomersetPicklist().Save','ACCL__Sales_Folder__c');
                    
                }else{
                    system.debug('No records to be updated');
                }            
                
                //code to assign the sell sheets to newly created salesfolder records //Check with Abir 
                /* List<ACCL__Sales_Folder__c> childSFIds = [select id,ACCL__Sales_Org__c,MDLZ_Parent_RecordId__c from ACCL__Sales_Folder__c where
*  MDLZ_Parent_RecordId__c =: salesfolder.id AND ACCL__Active__c= true];
List<ACCL__Sales_Folder_Sell_Sheet__c> ssIds = [Select ACCL__Sell_Sheet__c from ACCL__Sales_Folder_Sell_Sheet__c 
where ACCL__Sales_Folder__c =: salesfolder.id];*/
                for(ACCL__Sales_Folder_Sell_Sheet__c sellSheet : [Select ACCL__Sell_Sheet__c from ACCL__Sales_Folder_Sell_Sheet__c 
                                                                  where ACCL__Sales_Folder__c =: salesfolder.id] ){
                    
                    for(ACCL__Sales_Folder__c childSF :[select id,ACCL__Sales_Org__c,MDLZ_Parent_RecordId__c
                                                        from ACCL__Sales_Folder__c where MDLZ_Parent_RecordId__c =: salesfolder.id
                                                        AND ACCL__Active__c= true]){
                                                            ACCL__Sales_Folder_Sell_Sheet__c ssLink = new ACCL__Sales_Folder_Sell_Sheet__c();   
                                                            ssLink.ACCL__Sell_Sheet__c =sellSheet.ACCL__Sell_Sheet__c;
                                                            ssLink.ACCL__Sales_Folder__c = childSF.id;
                                                            ssLink.ACCL__Sales_Org__c = childSF.ACCL__Sales_Org__c;
                                                            ssListDb.add(ssLink); 
                                                        }   
                }
                
                if(ssListDb.size()>0){
                    
                    List<Database.SaveResult> srList =   database.insert(ssListDb,false);
                    exc.saveResultErrors(srList,ssListDb,'MDLZ_CustomersetPicklist().Save','ACCL__Sales_Folder_Sell_Sheet__c', 'Name');
                    
                }
            }
            //Success Message for updating Customersets into salesfolder
            If(!selectedPicklistValues.isEmpty()  && m2.values()!=null ){
                database.update(salesfolder,false);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfully Added Customer Sets'));
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Customer Set'));   
            }
            
        }catch(Exception e){   
            exc.insertExceptions('MDLZ_CustomersetPicklist()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
            
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