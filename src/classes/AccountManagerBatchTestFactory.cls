/**  PROGRAM NAME : AccountManagerBatchTestFactory
     * This class is to create test data for batch class.       
     * @version  1.0
*/
@isTest
public class AccountManagerBatchTestFactory {
    private static string ns = AddOnConstants.NAMESPACEPREFIX;
    private static sObject orgUnitRecord;
    private static sObject accountRecord;
	public static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    /*********** Data creation for Objects****************/
	/**This function is for building Account Data
    *  @name buildAccount
    *  @param String nameSuffix
    *  @return Account sobject
    */
    public static sObject buildAccount(Integer nameSuffix,Id accountTemplateId) {
        
        sObject accountRec = allObjMetaType.get('Account').newSObject() ;
        accountRec.put(ns+'City__c','Test City');
        accountRec.put(ns+'Street__c','Test Street');
        accountRec.put('Name','Test'+nameSuffix);
        accountRec.put(ns+'Name_2__c','Test2'+nameSuffix);         
        accountRec.put(ns+'Account_Template__c',accountTemplateId);         
        return accountRec;
    }
    public static List<sObject> buildAccounts( Integer numberOfAccounts ,Id accountTemplateId) {
        List<sObject> accounts = new List<sObject>();
        for(Integer i=0 ; i < numberOfAccounts ; i++){
            accounts.add(buildAccount(i,accountTemplateId));
        }
        return accounts;
    }
    public static List<sObject> insertBulkAccounts( Integer numberOfAccounts ,sObject AccountTemplate) {
        List<sObject> accounts = buildAccounts(numberOfAccounts, (Id)AccountTemplate.get('Id'));
        insert accounts;
        return accounts;
    }
    public static sObject getAccountTemplateWithSalesOrg(String salesOrg){
        Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get(ns+'Account_Template__c').getDescribe();         
        Id recordTypeIDCustomer = [Select Id from RecordType where sObjectType=:objectDescribeResult.getName()
                     and DeveloperName=:AddOnConstants.CUSTOMER_RECORD_TYPE].Id;         
        sObject sObj = allObjMetaType.get(ns+'Account_Template__c').newSObject() ;
        sObj.put('Name','123');
        sObj.put(ns+'Initial_Roles__c','123');
        sObj.put('RecordTypeId',recordTypeIDCustomer); 
        sObj.put(ns+'Sales_Org__c',salesOrg);
        sObj.put(ns+'Description_Language_1__c','test');
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
    /**This function is for inserting Account Data
    *  @name insertAccount
    *  @param String namespace
    *  @return Account
    */
    public static sObject insertAccount(String namespace) {
        accountRecord = allObjMetaType.get('Account').newSObject() ;
        accountRecord.put(ns+'City__c','Test City');
        accountRecord.put(ns+'Street__c','Test Street');
        accountRecord.put('Name','Test'+namespace);
        accountRecord.put(ns+'Name_2__c','Test2'+namespace);         
        insert accountRecord;
        return accountRecord;
    }
    /**This function is for getting default account data
    *  @name getDefaultAccount
    *  @param none
    *  @return sObject
    */
    public static sObject getDefaultAccount() {
        if(accountRecord == null){
            insertAccount('Test Account Manager Batch Account');
        }
        return accountRecord;
    }
    /**This function is for getting default account data
    *  @name getDefaultAccount
    *  @param none
    *  @return sObject
    */
    public static sObject getDefaultOrgUnit() {
        if(orgUnitRecord == null){
            insertOrgUnit('Test Account Manager Batch Org Unit');
        }
        return orgUnitRecord;
    }
    /**This function is for inserting Account Manager Data
    *  @name insertAccountManager
    *  @param String namespace
    *  @return sObject(Account_Manager__c)
    */
    public static sObject insertAccountManager(Id accountId, Id orgUnitId,Id userId ,Date validFrom,Date ValidThru) {
        
        Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get(ns+'Account_Manager__c').getDescribe();         
        sObject sObj = allObjMetaType.get(ns+'Account_Manager__c').newSObject() ;        
        sObj.put(ns+'Account__c',accountId);
        sObj.put(ns+'User__c',userId);
        sObj.put(ns+'Org_Unit__c',orgUnitId);
        sObj.put(ns+'Valid_From__c',validFrom);       
        sObj.put(ns+'Valid_From__c',validThru);       
        insert sObj;
        return sObj;
    }
    /**This function is for inserting Account Manager Data
    *  @name insertAccountManager
    *  @param String namespace
    *  @return sObject(Account_Manager__c)
    */
    public static sObject insertManualAccountManager(Id accountId,Id userId ,Date validFrom,Date ValidThru) {
        Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get(ns+'Account_Manager__c').getDescribe();         
        sObject sObj = allObjMetaType.get(ns+'Account_Manager__c').newSObject() ;   
        sObj.put(ns+'Account__c',accountId);
        sObj.put(ns+'User__c',userId);
        sObj.put(ns+'Valid_From__c',validFrom);       
        sObj.put(ns+'Valid_From__c',validThru);       
        insert sObj;
        return sObj;
        //inserted account manager ..
    }
	/**This function is for inserting Account Manager Data
    *  @name insertAccountManager
    *  @param String namespace
    *  @return sObject(Account_Manager__c)
    */
    public static sObject insertOrgUnit(String name) {         
        
        orgUnitRecord = allObjMetaType.get(ns+'Org_Unit__c').newSObject();
        orgUnitRecord.put('Name', name);
        orgUnitRecord.put(ns+ 'Description_Language_1__c', 'Account Manager Test Org');
        orgUnitRecord.put(ns + 'Org_Level__c', 'SalesOffice');
        orgUnitRecord.put(ns + 'Org_Type__c', 'Sales');
		insert orgUnitRecord;
        return orgUnitRecord;
        
    }
	/**This function is for inserting Account Org Unit Data
    *  @name insertAccountManager
    *  @param String namespace
    *  @return void(Account_Manager__c)
    */
    public static List<sObject> insertAccountOrgUnitList(Integer noOfAccountOrgUnit,Id accountId, Id orgUnitId) {
		List<sObject> orgUnitAccountList = new List<sObject>();
		for(integer i = 0; i < noOfAccountOrgUnit;i++)
		{
			sObject accountOrgUnitRecord = allObjMetaType.get(ns+'Account_Org_Unit__c').newSObject();
	        accountOrgUnitRecord.put(ns+'Org_Unit__c', orgUnitId); 
	        accountOrgUnitRecord.put(ns+ 'Account__c', accountId);
	        accountOrgUnitRecord.put(ns + 'Active__c' , true);
	        accountOrgUnitRecord.put(ns+ 'Valid_From__c' , System.today());
	        accountOrgUnitRecord.put(ns + 'Valid_Thru__c' ,System.today().addYears(1));
            orgUnitAccountList.add(accountOrgUnitRecord);
		}
        insert orgUnitAccountList;
        return orgUnitAccountList;
			
    }
	/**This function is for inserting Org Unit User Data
    *  @name insertAccountManager
    *  @param String namespace
    *  @return void(Account_Manager__c)
    */
    public static List<sObject> insertOrgUnitUser(List<sObject> userList,Id orgUnitId) {
	List<sObject> orgUnitUsersList = new List<sObject>();
		for(integer i = 0; i < userList.size();i++)
		{
			sObject orgUnitUserRecord = allObjMetaType.get(ns+'Org_Unit_User__C').newSObject();
	        orgUnitUserRecord.put(ns+'User__c', (Id)userList[i].get('Id'));
	        orgUnitUserRecord.put(ns + 'Org_Unit__c' ,orgUnitId);
	        orgUnitUserRecord.put(ns+ 'Valid_From__c' , System.today());
	        orgUnitUserRecord.put(ns + 'Valid_Thru__c' , System.today().addYears(1));
	        orgUnitUserRecord.put(ns + 'Management_Type__c' ,'Sales');
            orgUnitUserRecord.put('MDLZ_ExternalId__c' ,'US01_'+i);
        	orgUnitUsersList.add(orgUnitUserRecord);
		}
        insert orgUnitUsersList;
        return orgUnitUsersList;
		}

    
    	public static List<sObject> insertUserWithProfile(Integer count) {
		try
        {
            Profile p = [select id from profile where name='System Administrator' Limit 1];
            String strUserTimeZoneSidKey = getLoggedInUserTimeZoneSidKey();
            List<sObject> uList = new List<sObject>();
            for(Integer i= 0 ; i <count ;i ++){
                sObject u = allObjMetaType.get('User').newSObject();
                u.put('FirstName','TestClass_Testing' + i);
                u.put('LastName','of Arendelle') ;
                u.put('Email','elsa@disney.com');
                u.put('Alias','elsa' + i);
                u.put('Username','elsa' + i + '@disney.com');
                u.put('LocaleSidKey','en_US');
                u.put('TimeZoneSidKey',strUserTimeZoneSidKey);
                u.put('ProfileID',p.id);
                u.put('LanguageLocaleKey','en_US');
                u.put('EmailEncodingKey','UTF-8');
                uList.add(u) ;
            }
            
            insert uList;
            return uList;
        } catch (Exception e)
        {
            return null;
        }
    }
    public static String getLoggedInUserTimeZoneSidKey() {
        User loggedInUser = new User();
        loggedInUser = [select TimeZoneSidKey from User where id =: UserInfo.getUserId() limit 1];
        return loggedInUser.TimeZoneSidKey;
    }
    
}