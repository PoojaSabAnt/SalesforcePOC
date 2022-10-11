/**  PROGRAM NAME : EffectiveAccountManagerSyncExecute 
     * This class is used for processing all the returned query locator records that will determine the scope of the batch.
     * This class is execution class for EffectiveAccountManagerSyncBatch class.
     * @see    EffectiveAccountManagerSyncBatch
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class EffectiveAccountManagerSyncExecute {
	/** Private Variables */
    private Static final String ACCOUNT_MANAGER_TEAM_ROLE = AddOnConstants.ACCOUNT_MANAGER_TEAM_ROLE;
    private static final string PROCESS_NAME = AddOnConstants.EFFECTIVE_ACCOUNT_MANAGER_SYNC_BATCH;
    // Success Count
    public Integer iSuccess = 0;
    // Failure Count
    public Integer iFailure = 0;
    
    /** 
    *  @description Processing Account records for the Account Manager Sync.
    *  @param List<Account> accountsScope
    *  @return void 
    *  @throws  Standard exception
    */
    public void process(List<Account> accountsScope) {
        try {
            Date today = System.today();
            Set<Id> accScopeIds = new Set<Id>(new Map<Id, Account>((List<Account>)accountsScope).keySet());
            List<sObject> scope = [Select Id, (SELECT ACCL__User__c FROM ACCL__Account_Managers__r WHERE ACCL__Valid_From__c <= : Today AND ACCL__Valid_Thru__c >=: Today AND ACCL__Active__c = true AND ACCL__User__r.isActive = true)FROM Account where Id IN :accScopeIds];
            Set<Id> accountIDs = new Set<Id>();
            Boolean errorCheck = false;
            for (Account indAccount : (List<Account>) scope) {
                accountIDs.add(indAccount.ID);
            }

            if(!accountIDs.isEmpty()) {
                List<AccountTeamMember> accountTeamMembersToDelete = [SELECT Id FROM AccountTeamMember WHERE AccountID IN :accountIDs AND TeamMemberRole=:AddOnConstants.ACCOUNT_MANAGER_TEAM_ROLE LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!accountTeamMembersToDelete.isEmpty()) {
                    if (Schema.sObjectType.AccountTeamMember.isDeletable()) {
                        //CRUD_Delete - False Positive
                        //This is a batch class which will execute in system mode. so no CRUD check is required. 
                        Database.delete(accountTeamMembersToDelete, false);
                    } else {
                        System.debug('Insufficient Priviledge : Delete Permission not available on AccountTeamMember');
                    }
                }
            }
            List<AccountTeamMember> accountTeamMembersToInsert = new List<AccountTeamMember>();
            for (Account indAccount : (List<Account>) scope) {
                for (sObject AccountManager : indAccount.getSObjects('ACCL__Account_Managers__r'))
                {
                    AccountTeamMember toInsertATM = new AccountTeamMember();
                    // FLS_Create,FLS_Create_Partial - False Positive
                    //This is a Batch class and will be executed in system mode, so FLS_Create check is not required
                    toInsertATM.AccountID = indAccount.ID;
                    // FLS_Create,FLS_Create_Partial - False Positive
                    //This is a Batch class and will be executed in system mode, so FLS_Create check is not required
                    toInsertATM.UserId = (Id)AccountManager.get('ACCL__User__c');
                    // FLS_Create,FLS_Create_Partial - False Positive
                    //This is a Batch class and will be executed in system mode, so FLS_Create check is not required
                    toInsertATM.TeamMemberRole = AddOnConstants.ACCOUNT_MANAGER_TEAM_ROLE;
                    accountTeamMembersToInsert.add(toInsertATM);
                }
            }

            if(!accountTeamMembersToInsert.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(accountTeamMembersToInsert,false);
                List<AccountShare> newShare = new List<AccountShare>();

                Set<Id> insertedAccountIds = new Set<Id>();
                Set<Id> insertedUserIds = new Set<Id>();
                List<String> insertedAccountTeamMembers = new List<String>();
                String tmpErrorResults;

                for (integer i=0; i<srList.size();i++) {
                    if(!srList[i].isSuccess()) {
                        iFailure = iFailure + 1;
                        errorCheck = true;
                        
                        tmpErrorResults = AddOnConstants.STRING_NEW_LINE + accountTeamMembersToInsert[i].AccountId + AddOnConstants.STRING_COMMA+ accountTeamMembersToInsert[i].UserId + AddOnConstants.STRING_COMMA + accountTeamMembersToInsert[i].AccountAccessLevel + AddOnConstants.STRING_COMMA+ accountTeamMembersToInsert[i].TeamMemberRole + AddOnConstants.STRING_COMMA;
                        for(Database.Error err : srList[i].getErrors()) {
                            tmpErrorResults += err.getMessage() + '.';
                        }
                    }
                    else {
                        // removed -> AccountShare already exists, after insert of AccountTeamMember, but only with Access=Read Only
                        // and this code line didn't do anything.
                        // newShare.add(new AccountShare(UserOrGroupId=accountTeamMembersToInsert[i].UserId,AccountId=accountTeamMembersToInsert[i].Accountid,AccountAccessLevel=Constants.ACCOUNT_SHARE_EDIT));
                        
                        insertedAccountIds.add(accountTeamMembersToInsert[i].AccountId);
                        insertedUserIds.add(accountTeamMembersToInsert[i].UserId);
                        String insertedAccountTeamMember = 'Inserted AccountTeamMember Id ' + accountTeamMembersToInsert[i].Id + ' Related to Account '+ accountTeamMembersToInsert[i].AccountId;
                        insertedAccountTeamMembers.add(insertedAccountTeamMember);
                        iSuccess = iSuccess + 1;
                    }
                }
                                
                if(insertedAccountTeamMembers.size() != 0) {
                    System.debug('Inserted Account Team Members');
                }
                
                // Update account share records, which were created automatically during the insert of AccountTeamMember (accountTeamMembersToInsert)
                // in the step before (Access Account from "Read" to "Read/Write")
                if (insertedAccountIds.size()>0 && insertedUserIds.size()>0) {
                    List<AccountShare> affectedAcctShare = [SELECT Id FROM AccountShare WHERE AccountId IN :insertedAccountIds AND UserOrGroupId IN :insertedUserIds AND RowCause='Team'];
                    
                    for (AccountShare share : affectedAcctShare ) {
                        share.AccountAccessLevel = AddOnConstants.ACCOUNT_SHARE_EDIT;
                    }
                    
                    if (!affectedAcctShare.IsEmpty()) {
                        update affectedAcctShare;
                    }
                }
            }
            else {
                System.debug('No Valid Account Team Members found for insertion.');
            }
        }
        catch(Exception ex) {
            System.debug('Exception : '+ex);
        }
    }
}