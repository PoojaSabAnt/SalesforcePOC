//Sharing_With_Controller - False positive
//Batch classes execute in system mode so sharing is not required
/** 
 * This scheduler & batch class is used to set ParentId field in Account object with the effective Trade Org Hierarchy parent on the day of batch run
 */
public class EffectiveAccountParentSyncBatch implements Schedulable,Database.Batchable<sObject>
{
    private static final Type classType = EffectiveAccountParentSyncBatch.class;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;       
    /** Success Count*/
    public Integer iSuccess = 0;
    /** Failure Count*/
    public Integer iFailure = 0;
     // Parent Account Sync Batch error file columes
    Public final Static String BATCH_ERROR_FILE_COLUMNS = 'ID,ParentID,Error';
     // Variable for New Line
    Public final Static String STRING_NEW_LINE = '\n';
     // Variable for Comma
    Public final Static String STRING_COMMA = ',';
    /** Error File Name*/
    public String errorFile = BATCH_ERROR_FILE_COLUMNS;

    public static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator result;
        try {
            Date today = System.today(); 
            String query ='SELECT {0}Child_Account__r.ParentID,{0}Child_Account__c,{0}Parent_Account__c FROM {0}Account_Trade_Org_Hierarchy__c WHERE {0}Valid_From__c <= :Today AND {0}Valid_Thru__c >=:Today AND {0}Parent_Account__c!=null';
            query = String.format(query, new List<String>{ns});
            result = Database.getQueryLocator(query);
            system.debug('result' +result);
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
        }
        return result;
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        //To remove duplicate child accounts incase any.
        try {
            Map<ID,sObject> childParentMap = new Map<ID,sObject>();
            List<Id> updatedAccountIds = new List<Id>();
            Boolean errorCheck = false;
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SobjectType oType = gd.get('ns+Account_Trade_Org_Hierarchy__c');
            for(sObject OrgHierarchy : scope )
            {    
                Id parentId = (Id)OrgHierarchy.getSObject(ns+'Child_Account__r').get('ParentID');
                System.debug('parentId' +parentId);
                // FLS_Update,FLS_Update_Partial - False Positive
                // This class will be executed in system mode,hence no FLS check required.
                if(parentId!= (ID)OrgHierarchy.get(ns+'Parent_Account__c'))
                {
                    Account toUpdate = new Account();
                    // FLS_Update,FLS_Update_Partial - False Positive
                    // This class will be executed in system mode,hence no FLS check required.
                    toUpdate.ID = (Id)OrgHierarchy.get(ns+'Child_Account__c');
                    toUpdate.ParentID = (ID)OrgHierarchy.get(ns+'Parent_Account__c');
                    childParentMap.put((ID)OrgHierarchy.get(ns+'Child_Account__c'),toUpdate);
                    system.debug('If1' +childParentMap);
                }
            }
            if( !childParentMap.isEmpty() )
            {
                List<Account> accountsToUpdate = childParentMap.values();  
                Database.SaveResult[] srList = Database.update(accountsToUpdate,false);
                system.debug('srList' +srList);
                for (integer i=0; i<srList.size();i++) {
                    if(!srList[i].isSuccess())
                    {
                        iFailure = iFailure + 1;
                        errorCheck = true;
                        errorFile = errorFile + STRING_NEW_LINE + accountsToUpdate[i].Id + STRING_COMMA+ accountsToUpdate[i].ParentID + STRING_COMMA ; 
                        for(Database.Error err : srList[i].getErrors())
                        {
                            errorFile = errorFile + err.getMessage() + '.';                    
                        }
                    }
                    else{
                        updatedAccountIds.add(accountsToUpdate[i].Id);
                        iSuccess = iSuccess + 1;
                    }
                }
                }
                
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
         } 
        
    }

    public void finish(Database.BatchableContext BC) {       
        
    }

    public void execute(SchedulableContext sc) {
        try {
            EffectiveAccountParentSyncBatch instanceAccountEffectiveParentSyncBatch = new EffectiveAccountParentSyncBatch(); 
            database.executebatch( instanceAccountEffectiveParentSyncBatch,1000 );
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
        } 
    }
}