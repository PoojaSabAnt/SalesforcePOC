/***************************************************************
Name: MDLZ_EffectiveAccountManagerSyncBatch
======================================================
Purpose:
Custom batch for the core batch - EffectiveAccountManagerSyncBatch. This was
rewritten to handle huge volume of data and the batch running for more than 6-8 hours
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi                05/30/2022     Initial Development    

***************************************************************/
global with sharing class MDLZ_EffectiveAccountManagerSync {
    
    public void addAccountTeamMember(List<ACCL__Account_Manager__c> scope){
        
        system.debug('Scope size '+scope.size());
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        set<id> accountIds = new set<id>();
        Map<String,AccountTeamMember> atmUserMap = new Map<String,AccountTeamMember>();
        List<AccountTeamMember> toInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> toDelete = new List<AccountTeamMember>();
        
        try{
            //create account list
            for(ACCL__Account_Manager__c acctMgr : scope){
                accountIds.add(acctMgr.ACCL__Account__c);
            }
            
            List<AccountTeamMember> atmList = [select id,AccountId, UserId from AccountTeamMember where AccountId in: accountIds];
            
            //create account team member map with id= account and value = teamMemberList
            for(AccountTeamMember atm : atmList){
                atmUserMap.put(atm.AccountId+'|'+atm.UserId,atm);
            }
            
            for(ACCL__Account_Manager__c accMgrRec: scope){
                
                String uniqueKey = accMgrRec.ACCL__Account__c+'|'+accMgrRec.ACCL__User__c;
                if(accMgrRec.ACCL__Valid_Thru__c <= system.today() && atmUserMap.containsKey(uniqueKey)){
                    toDelete.add(atmUserMap.get(uniqueKey));
                    
                }else if(accMgrRec.ACCL__Valid_Thru__c >= system.today() && !atmUserMap.containsKey(uniqueKey)){
                    AccountTeamMember atmDB = new AccountTeamMember();
                    atmDB.AccountId = accMgrRec.ACCL__Account__c;
                    atmDB.UserId = accMgrRec.ACCL__User__c;
                    atmDB.AccountAccessLevel = 'Edit';
                    atmDB.CaseAccessLevel = 'Edit';
                    atmDB.ContactAccessLevel = 'Edit';
                    atmDB.OpportunityAccessLevel = 'Edit';
                    atmDB.TeamMemberRole = 'AccountManager';
                    toInsert.add(atmDB);
                    
                }
            }
            
            //insert/delete the account team members
            
            if(toInsert.size() > 0){
                
                List<Database.SaveResult>  srList =  database.insert(toInsert,false);
                if(srList.size()>0){
                    exc.saveResultErrors(srList,toInsert,'MDLZ_EffectiveAccountManagerSync()','AccountTeamMember','UserId');
                }
                
            }else{
                system.debug('No records to be inserted');
            } 
            
            if(toDelete.size() > 0){
                
                List<Database.DeleteResult> srList =  database.Delete(toDelete);
                if(srList.size()>0){
                    exc.deleteResultErrors(srList,toDelete,'MDLZ_EffectiveAccountManagerSync()','AccountTeamMember','id');
                }
                
            }else{
                system.debug('No records to be deleted');
            }
            
        }catch(exception e){
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('MDLZ_EffectiveAccountManagerSync()',e.getStackTraceString(),e.getLineNumber(),e.getTypeName()); 
        } 
    }
}