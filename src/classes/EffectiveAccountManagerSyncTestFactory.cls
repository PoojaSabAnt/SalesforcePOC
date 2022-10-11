@isTest
/**  PROGRAM NAME : EffectiveAccountManagerSyncTestFactory 
     * This class is a test factory class to provide data setup to be refered in EffectiveAccountManagerSyncBatchTest class.
     * @see    EffectiveAccountManagerSyncBatchTest
     * @version  1.0
     * @Created Date 2018-10-12 
*/
public class EffectiveAccountManagerSyncTestFactory {
    /** Private Variables */
	private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    /**
     *  @description This method creates a record in the Batch_Process_Configuration__c custom setting to determine default batch size.
     *  @param None
     *  @return None
     *  @throws None
     */
    public static void insertAccountEffectiveManagerSyncBatchCustomSetting(){
        sObject sObj = allObjMetaType.get('ACCL__Batch_Process_Configuration__c').newSObject();
        sObj.put('Name', AddOnConstants.EFFECTIVE_ACCOUNT_MANAGER_SYNC_BATCH);
        sObj.put('ACCL__Batch_Size__c', 200);
        insert sObj;
    }
    
    /**
     *  @description This method inserts Account records in Bulk.
     *  @param Integer noOfAcc
     *  @return List<sObject>
     *  @throws None
     */
    public static List<sObject> insertBulkAccounts(Integer noOfAcc) {
        List<sObject> accList = new List<sObject>();
        for(Integer i=0; i<noOfAcc; i++) {
            sObject acc = allObjMetaType.get('Account').newSObject();
            acc.put('ACCL__City__c', 'Test City');
            acc.put('ACCL__Street__c', 'Test Street');
            acc.put('Name', 'Test'+i); 
            acc.put('ACCL__Name_2__c', 'testX'+i);
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
    
    /**
     *  @description This method inserts a default User record.
     *  @param None
     *  @return User record
     *  @throws None
     */
    public static User getDefaultUser() {
        Profile pro = [SELECT Id FROM profile WHERE Name='System Administrator' LIMIT 1];
        User loggedInUser = [SELECT TimeZoneSidKey FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        User u = new User();
        u.FirstName = 'Joan';
        u.LastName = 'Of Arc';
        u.Email = 'joan@arc.com';
        u.Alias = 'arcjoan';
        u.Username = 'joanarc@france.com';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = loggedInUser.TimeZoneSidKey;
        u.ProfileID = pro.Id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        return u;
    }
    
    /**
     *  @description This method inserts Account Manager record.
     *  @param : sObject account, Id userId, Date fromDate, Date toDate, String managementType
     *  @return sObject
     *  @throws None
     */
    public static sobject insertAccountManager(sObject account, Id userId, Date fromDate, Date toDate, String managementType) {
        sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
        accMan.put('ACCL__Account__c', account.Id);
        accMan.put('ACCL__User__c', userId);
        accMan.put('ACCL__Management_Type__c', managementType);
        accMan.put('ACCL__Active__c', true);
        accMan.put('ACCL__Valid_From__c', fromDate);
        accMan.put('ACCL__Valid_Thru__c', toDate);
        insert accMan;
        return accMan;
    }
    
    /**
     *  @description This method inserts Account Manager records in Bulk.
     *  @param : List<Account> listOfAcc
     *  @return List<sObject>
     *  @throws None
     */
    public static List<sObject> insertAccountManagerList(List<Account> listOfAcc) {
        List<sobject> accManList = new List<sobject>();
        for(Account acc : listOfAcc) {
            sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
            accMan.put('ACCL__Account__c', acc.Id);
            accMan.put('ACCL__User__c', UserInfo.getUserId());
            accMan.put('ACCL__Management_Type__c', 'Sales');
            accMan.put('ACCL__Active__c', true);
            accMan.put('ACCL__Valid_From__c', System.today());
            accMan.put('ACCL__Valid_Thru__c', System.today().addDays(50));
            accManList.add(accMan);
        }
        insert accManList;
        return accManList;
    }
    
    /**
     *  @description This method inserts Account Manager records in Bulk.
     *  @param : List<Account> listOfAcc, Id userId, Date fromDate, Date toDate, String managementType
     *  @return List<sObject>
     *  @throws None
     */
    public static List<sObject> insertAccountManagerList(List<Account> listOfAcc, Id userId, Date fromDate, Date toDate, String managementType) {
        List<sobject> accManList = new List<sobject>();
        for(Account acc : listOfAcc) {
            sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
            accMan.put('ACCL__Account__c', acc.Id);
            accMan.put('ACCL__User__c', userId);
            accMan.put('ACCL__Management_Type__c', managementType);
            accMan.put('ACCL__Active__c', true);
            accMan.put('ACCL__Valid_From__c', fromDate);

            accManList.add(accMan);
        }
        insert accManList;
        return accManList;
    }
}