/***************************************************************
Name: MDLZ_NewUserSetup
======================================================
Purpose:
a.For all the users lastmodfied today, do below-
a. create a record in the sales org related list for each user. 
b. create a record in the user settings object for each user.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                05/09/2021     Initial Development    
1.1		 Priya Tubachi	  Abir Ghosh  18/01/2022
***************************************************************/
public with sharing class MDLZ_NewUserSetup {
    
    public void getNewUsers(List<User> newUsers){
        
        List<ACCL__User_Setting__c> nUserSetListdb = new List<ACCL__User_Setting__c>();
        List<ACCL__Sales_Organization_User__c> nSalesOrgUserdb = new List<ACCL__Sales_Organization_User__c>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        //get the sales org that is to be assigned to user. (default its US01)\
        try{
            List<ACCL__Sales_Organization__c> salesOrg = [select id from ACCL__Sales_Organization__c 
                                                          where ACCL__Sales_Org_Value__c =: MDLZ_ConstantHelper.US01 LIMIT 1];
            
            
            
            //for each user do the initial data set up for the user
            for(User nUser: newUsers){
                
                //create user settings for each user added
                ACCL__User_Setting__c tempUserSet = new ACCL__User_Setting__c();
                tempUserSet.ACCL__User__c = nUser.id;
                tempUserSet.ACCL__Default_Management_Type__c = MDLZ_ConstantHelper.Sales;
                tempUserSet.ACCL__Landing_Page__c = MDLZ_ConstantHelper.UserCockpit;
                tempUserSet.ACCL__Display_Weekend__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Monday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Tuesday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Wednesday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Thursday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Friday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Saturday__c = MDLZ_ConstantHelper.isTrue;
                tempUserSet.ACCL__Works_On_Sunday__c = MDLZ_ConstantHelper.isTrue;
                
                nUserSetListdb.add(tempUserSet);
                
                //add user to the related list of sales org
                ACCL__Sales_Organization_User__c sOrgUser = new ACCL__Sales_Organization_User__c();
                sOrgUser.ACCL__Sales_Organization__c = salesOrg[0].id;
                sOrgUser.ACCL__User__c = nUser.id;
                sOrgUser.ACCL__Works_On_Monday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Tuesday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Wednesday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Thursday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Friday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Saturday__c = MDLZ_ConstantHelper.isTrue;
                sOrgUser.ACCL__Works_On_Sunday__c = MDLZ_ConstantHelper.isTrue;
                
                nSalesOrgUserdb.add(sOrgUser);
            }
            
            //insert the User settings list to db
            system.debug('Entering user settings insert to DB '+nUserSetListdb.size());
            if(nUserSetListdb.size() >0){
                
                List<Database.SaveResult> srList =  database.insert(nUserSetListdb,false);
                
                exc.saveResultErrors(srList,nUserSetListdb,'MDLZ_NewUserSetup()','ACCL__User_Setting__c', 'ACCL__User__c');
                
            }else{
                system.debug('No records to be updated');
            }
            
            //insert the Sales Org settings list to db
            system.debug('Entering sales org insert to DB '+nSalesOrgUserdb.size());
            if(nSalesOrgUserdb.size()>0){
                List<Database.SaveResult> srList =  database.insert(nSalesOrgUserdb,false);
                exc.saveResultErrors(srList,nSalesOrgUserdb,'MDLZ_NewUserSetup()','ACCL__User_Setting__c', 'ACCL__User__c');
                
            }else{
                system.debug('No records to be updated');
            }
            
        } catch(exception e){
            system.debug('An exception has occurred');
            exc.insertExceptions('MDLZ_NewUserSetup()',e.getStackTraceString(),e.getLineNumber(),e.getTypeName()); 
        }   
        
    }
}