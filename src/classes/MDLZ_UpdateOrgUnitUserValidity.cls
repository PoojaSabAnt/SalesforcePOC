/***************************************************************
Name: MDLZ_UpdateOrgUnitUserValidity
======================================================
Purpose: this is the pre-processing batch process will be created for Org Unit User Clean-up
o New process will run before the current Org Unit User process runs
o New process will identify all users that have updates and deactivate all Org Unit User records (Today - 1) and then unset the new "update" flag
o Existing process will then run and expand the existing District and Team Org Unit User records from the top down (G4->G5 and G5->G6)
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE                DETAIL              Description
1.0      Priya Tubachi                 03/30/2022     Initial Development    

***************************************************************/

Public with sharing class MDLZ_UpdateOrgUnitUserValidity {
    
    //method called from the batch class
    public void updateUserValidity(List<User> userIDs ){
        try {
            
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
            List<ACCL__Org_Unit_User__c>  updateOrgUnitUserList = new List<ACCL__Org_Unit_User__c>();
            List<User>  updateUserList = new List<User>();
            Integer validThru = Integer.valueOf(System.Label.MDLZ_OrgUnitUser_ValidThruDate);
            
            //For each user – get the OrgUnitUser object records and check the isOrgUnitChanged flag. 
            for (ACCL__Org_Unit_User__c orgUser : [Select ACCL__User__c, MDLZ_isOrgUnitChanged__c, ACCL__Valid_Thru__c from ACCL__Org_Unit_User__c where ACCL__User__c  IN: userIDs and ACCL__Valid_Thru__c>= Today  order by ACCL__User__c ] ){
                
                If(String.isEmpty(orgUser.MDLZ_isOrgUnitChanged__c) || orgUser.MDLZ_isOrgUnitChanged__c != MDLZ_ConstantHelper.IntUpdated){
                    
                    orgUser.ACCL__Valid_Thru__c =System.Today() - validThru ; 
                    //Batch leaves the ipaas updated records(int updated) as is. So RDR and Team Territory batches can use this flag.
                    orgUser.MDLZ_isOrgUnitChanged__c = MDLZ_ConstantHelper.BatchProcessed;
                }
                              
                updateOrgUnitUserList.add(orgUser);
            }  
            
            if(updateOrgUnitUserList.size()> 0){
                List<Database.SaveResult>  srList =  database.update(updateOrgUnitUserList,false); 
                exc.saveResultErrors(srList,updateOrgUnitUserList,'MDLZ_UpdateOrgUnitUserValidity().OrgUnitUser','ACCL__Org_Unit_User__c', 'Id');
                
                for(User us : userIDs){
                    us.MDLZ_isChanged__c = MDLZ_ConstantHelper.BatchProcessed;
                    updateUserList.add(us);
                }
                List<Database.SaveResult>  srList2 =  database.update(updateUserList,false); 
                exc.saveResultErrors(srList2,updateUserList,'MDLZ_UpdateOrgUnitUserValidity().UserUpdate','User', 'Id');   
            }    
        }catch(Exception e){   
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
            exc.insertExceptions('MDLZ_UpdateOrgUnitUserValidity()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
            
        } 
    }     
    
}