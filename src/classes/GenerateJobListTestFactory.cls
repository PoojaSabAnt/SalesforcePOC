@isTest
/**  PROGRAM NAME : GenerateJobListTestFactory 
     * This class is a test factory class to provide data setup to be refered in GenerateJobListBatchTest class.
     * @see    GenerateJobListBatchTest
     * @version  1.0
     * @Created Date 2018-10-18
*/
public class GenerateJobListTestFactory {
	/** Private Variables */
    private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    private static final string PROCESS_NAME = 'JobListGeneration';
    private final Static String CUSTOMER_RECORD_TYPE = 'Customer';
    private final Static String CUSTOMER_TEMPLATE_OBJECT = 'ACCL__Account_Template__c';
    private final Static String CALL_CREATION_MODE_MANUALLY = 'Manually';
    private final Static String CALL_STATUS_PLANNED = 'Plan';
    
    /**
     *  @description This method creates a record in the Batch_Process_Configuration__c custom setting to determine default batch size.
     *  @param None
     *  @return None
     *  @throws None
     */
    public static void createCustomSettingData() {
        sObject sObj = allObjMetaType.get('ACCL__Batch_Process_Configuration__c').newSObject();
        sObj.put('Name', PROCESS_NAME);
        sObj.put('ACCL__Batch_Size__c', 1);
        insert sObj;
    }  
    
    /**
     *  @description This method inserts Account Template record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sobject getDefaultAccountTemplateWithSalesOrg() {
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType=:CUSTOMER_TEMPLATE_OBJECT AND DeveloperName=:CUSTOMER_RECORD_TYPE];
        sObject accTemp = allObjMetaType.get('ACCL__Account_Template__c').newSObject();
        accTemp.put('Name', 'TestName');
        accTemp.put('ACCL__Initial_Roles__c', 'customer');
        accTemp.put('ACCL__Active__c', true);
        accTemp.put('RecordTypeId', rt.Id);
        accTemp.put('ACCL__Description_Language_1__c', 'TestName');
        // accTemp.put('ACCL__Sales_Org__c', 'US01');
        insert accTemp;
        return accTemp;
    }
    
    /**
     *  @description This method insert Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sobject getDefaultAccountWithSalesOrg() {
        sObject acc = allObjMetaType.get('Account').newSObject();
        acc.put('Name', 'testName');
        acc.put('ACCL__City__c', 'testCity');
        acc.put('ACCL__Street__c', 'testStreet');
        acc.put('ACCL__Name_2__c', 'testName2');
        acc.put('ACCL__Account_Template__c', getDefaultAccountTemplateWithSalesOrg().Id);
        insert acc;
        return acc;
    }

    /**
     *  @description This method insert Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sobject getDefaultAccount() {
        sObject acc = allObjMetaType.get('Account').newSObject();
        acc.put('Name', 'testName');
        acc.put('ACCL__City__c', 'testCity');
        acc.put('ACCL__Street__c', 'testStreet');
        acc.put('ACCL__Name_2__c', 'testName2');
        acc.put('ACCL__Name_2__c', 'testName2');
        // acc.put('ACCL__Account_Template__c', 'a0Y4C00000AUyCCUA1'); //Test Fix - Pooja - 10 Sep
        insert acc;
        return acc;
    }
    
    /**
     *  @description This method insert Account record in Bulk.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static List<sobject> insertBulkAccounts(Integer noOfAcc) {
        List<sObject> accList = new List<sObject>();
        for(Integer i=0; i<noOfAcc; i++) {
            sObject acc = allObjMetaType.get('Account').newSObject();
            acc.put('Name', 'testName'+i);
            acc.put('ACCL__City__c', 'testCity');
            acc.put('ACCL__Street__c', 'testStreet');
            acc.put('ACCL__Name_2__c', 'testName2'+i);
            // acc.put('ACCL__Account_Template__c', 'a0Y4C00000AUyCCUA1'); //Test Fix - Pooja - 10 Sep
            accList.add(acc);
        }
        insert accList;
        return accList;
    }

    /**
     *  @description This method insert Account Manager record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultAccountManager() {
        sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
        accMan.put('ACCL__Account__c', getDefaultAccount().Id);
        accMan.put('ACCL__User__c', UserInfo.getUserId());
        accMan.put('ACCL__Management_Type__c', 'Sales');
        accMan.put('ACCL__Active__c', true);
        accMan.put('ACCL__Valid_From__c', System.today());
        accMan.put('ACCL__Valid_Thru__c', System.today().addDays(50));
        insert accMan;
        return accMan;
    }
    
    /**
     *  @description This method insert Account Manager record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultAccountManager(sObject acc) {
        sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
        accMan.put('ACCL__Account__c', acc.Id);
        accMan.put('ACCL__User__c', UserInfo.getUserId());
        accMan.put('ACCL__Management_Type__c', 'Sales');
        accMan.put('ACCL__Active__c', true);
        accMan.put('ACCL__Valid_From__c', System.today());
        accMan.put('ACCL__Valid_Thru__c', System.today().addDays(50));
        insert accMan;
        return accMan;
    }
    
    /**
     *  @description This method insert Account Manager record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultAccountManagerWithSalesOrg() {
        sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
        accMan.put('ACCL__Account__c', getDefaultAccountWithSalesOrg().Id);
        accMan.put('ACCL__User__c', UserInfo.getUserId());
        accMan.put('ACCL__Management_Type__c', 'Sales');
        accMan.put('ACCL__Active__c', true);
        accMan.put('ACCL__Valid_From__c', System.today());
        accMan.put('ACCL__Valid_Thru__c', System.today().addDays(50));
        insert accMan;
        return accMan;
    }
    
    /**
     *  @description This method insert Account Manager record in Bulk.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static List<sObject> insertAccountManagersWithDifferentDates(List<sObject> acc, Date Frm, Date Thru, String managementType, Boolean isMain) {
        List<sObject> accManList = new List<sObject>();
        for(sObject a : acc) {
            sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
            accMan.put('ACCL__Account__c', a.Id);
            accMan.put('ACCL__User__c', UserInfo.getUserId());
            accMan.put('ACCL__Management_Type__c', managementType);
            accMan.put('ACCL__Active__c', true);
            accMan.put('ACCL__Valid_From__c', Frm);
            accMan.put('ACCL__Valid_Thru__c', Thru);
            accMan.put('ACCL__Main__c', isMain);
            accManList.add(accMan);
        }
        insert accManList;
        return accManList;
    }
    
    /**
     *  @description This method insert Account Manager record in Bulk.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static List<sObject> insertAccountManagersWithDifferentDates(List<sObject> acc, sObject Usr, Date Frm, Date Thru, String managementType, Boolean isMain) {
        List<sObject> accManList = new List<sObject>();
        for(sObject a : acc) {
            sObject accMan = allObjMetaType.get('ACCL__Account_Manager__c').newSObject();
            accMan.put('ACCL__Account__c', a.Id);
            accMan.put('ACCL__User__c', Usr.Id);
            accMan.put('ACCL__Management_Type__c', managementType);
            accMan.put('ACCL__Active__c', true);
            accMan.put('ACCL__Valid_From__c', Frm);
            accMan.put('ACCL__Valid_Thru__c', Thru);
            accMan.put('ACCL__Main__c', isMain);
            accManList.add(accMan);
        }
        insert accManList;
        return accManList;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List_Template record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionListTemplate_NonStandard() {
        sObject jdlt = allObjMetaType.get('ACCL__Job_Definition_List_Template__c').newSObject();
        jdlt.put('ACCL__Description_Language_1__c', 'NonStandard');
        jdlt.put('ACCL__Consider_Account__c', true);
        jdlt.put('ACCL__Standard_Jobs__c', false);
        // jdlt.put('ACCL__Sales_Org__c', 'US01');
        jdlt.put('ACCL__Active__c', true);
        insert jdlt;
        return jdlt;
    }
    
    /**
     *  @description This method insert a Call_Template record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultCallTemplate() {
        sObject ct = allObjMetaType.get('ACCL__Call_Template__c').newSObject();
        ct.put('Name', 'test Call Temp');
        ct.put('ACCL__Description_Language_1__c', 'test desc');
        ct.put('ACCL__Active__c', true);
        ct.put('ACCL__Default_Duration__c', 15);
        ct.put('ACCL__Company_Required__c', 'Mandatory');
        ct.put('ACCL__Creation_Platform__c', 'Both');
        // ct.put('RE_CallTemplate_ExternalID__c', 'TestTemplate_US01');
        // ct.put('ACCL__Sales_Org__c', 'US01');
        insert ct;
        return ct;
    }
        
    /**
     *  @description This method insert a Call record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultCall(sObject ct, sObject acc) {
        sObject c = allObjMetaType.get('ACCL__Call__c').newSObject();
        c.put('ACCL__Subject__c', acc.get('Name')+'-'+ct.get('ACCL__Description__c'));
        c.put('ACCL__Creation_Mode__c', CALL_CREATION_MODE_MANUALLY);
        //c.put('ACCL__Call_Template__c', ct.Id);
        c.put('ACCL__Account__c', acc.Id);
        c.put('ACCL__Start_Date_Time__c', System.now());
        if(ct != null ){
            c.put('ACCL__Call_Template__c', ct.Id);
            c.put('ACCL__End_Date_Time__c', System.now().addMinutes(Integer.valueOf(ct.get('ACCL__Default_Duration__c'))));
        }
        c.put('ACCL__Responsible__c', UserInfo.getUserId());
        c.put('ACCL__Status__c', CALL_STATUS_PLANNED);
        insert c;
        return c;
    }
    
    /**
     *  @description This method insert a Call record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultCall() {
        sObject c = allObjMetaType.get('ACCL__Call__c').newSObject();
        c.put('ACCL__Subject__c', 'test Subject');
        c.put('ACCL__Creation_Mode__c', CALL_CREATION_MODE_MANUALLY);
        c.put('ACCL__Call_Template__c', getDefaultCallTemplate().Id);
        c.put('ACCL__Account__c', getDefaultAccount().Id);
        c.put('ACCL__Start_Date_Time__c', System.now());
        c.put('ACCL__End_Date_Time__c', System.now().addMinutes(Integer.valueOf(getDefaultCallTemplate().get('ACCL__Default_Duration__c'))));
        c.put('ACCL__Responsible__c', UserInfo.getUserId());
        c.put('ACCL__Status__c', CALL_STATUS_PLANNED);
        insert c;
        return c;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionList_NonStandard() {
        sObject jdl = allObjMetaType.get('ACCL__Job_Definition_List__c').newSObject();
        jdl.put('Name', 'test jdl');
        jdl.put('ACCL__Description_Language_1__c', 'test desc');
        jdl.put('ACCL__Active__c', true);
        jdl.put('ACCL__Valid_From__c', Date.today());
        jdl.put('ACCL__Valid_Thru__c', Date.today().addDays(3));
        jdl.put('ACCL__Job_Definition_List_Template__c', getDefaultJobDefinitionListTemplate_NonStandard().Id);
        jdl.put('ACCL__Call_Template__c', getDefaultCallTemplate().Id);
        jdl.put('ACCL__Default_Management_Type__c', 'Sales');
        jdl.put('ACCL__User_Policy__c', 'All');
        insert jdl;
        return jdl;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionList_NonStandard(sObject jdlt, sObject ct) {
        sObject jdl = allObjMetaType.get('ACCL__Job_Definition_List__c').newSObject();
        jdl.put('Name', 'test jdl');
        jdl.put('ACCL__Description_Language_1__c', 'test desc');
        jdl.put('ACCL__Active__c', true);
        jdl.put('ACCL__Valid_From__c', Date.today());
        jdl.put('ACCL__Valid_Thru__c', Date.today().addDays(3));
        jdl.put('ACCL__Job_Definition_List_Template__c', jdlt.Id);
        jdl.put('ACCL__Call_Template__c', ct.Id);
        jdl.put('ACCL__Default_Management_Type__c', 'Sales');
        jdl.put('ACCL__User_Policy__c', 'All');
        insert jdl;
        return jdl;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List record in Bulk.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static List<sObject> insertJobDefinitionLists(Integer noOfObj, sObject ct, sObject jdlt, String defManagmentType, String defUserPolicy, Date dateFrom, Date dateTo) {
        List<sObject> jdlList = new List<sObject>();
        for(Integer i=0; i<noOfObj; i++) {
            sObject jdl = allObjMetaType.get('ACCL__Job_Definition_List__c').newSObject();
            jdl.put('Name', 'test jdl'+i);
            jdl.put('ACCL__Description_Language_1__c', 'test desc'+i);
            jdl.put('ACCL__Active__c', true);
            jdl.put('ACCL__Valid_From__c', dateFrom);
            jdl.put('ACCL__Valid_Thru__c', dateTo);
            jdl.put('ACCL__Job_Definition_List_Template__c', jdlt.Id);
            jdl.put('ACCL__Call_Template__c', ct.Id);
            jdl.put('ACCL__Default_Management_Type__c', defManagmentType);
            jdl.put('ACCL__User_Policy__c', defUserPolicy);
            // jdl.put('ACCL__Sales_Org__c', 'US01'); //test fix
            jdlList.add(jdl);
        }
        insert jdlList;
        return jdlList;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List_Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionListAccount_NonStandard() {
        sObject jdla = allObjMetaType.get('ACCL__Job_Definition_List_Account__c').newSObject();
        jdla.put('ACCL__Account__c', getDefaultAccount().Id);
        jdla.put('ACCL__Job_Definition_List__c', getDefaultJobDefinitionList_NonStandard().Id);
        // jdla.put('ACCL__Sales_Org__c', 'US01');
        insert jdla;
        return jdla;
    }
    
    /**
     *  @description This method insert a non standard Job_Definition_List_Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionListAccount_NonStandard(sObject acc, sObject jdl) {
        sObject jdla = allObjMetaType.get('ACCL__Job_Definition_List_Account__c').newSObject();
        jdla.put('ACCL__Account__c', acc.Id);
        jdla.put('ACCL__Job_Definition_List__c', jdl.Id);
        insert jdla;
        return jdla;
    }
    
    /**
     *  @description This method insert a non standard Job_List record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobList(sObject acc, sObject ct, sObject jdl) {
        sObject jl = allObjMetaType.get('ACCL__Job_List__c').newSObject();
        jl.put('ACCL__Manager__c', UserInfo.getUserId());
        jl.put('ACCL__Account__c', acc.Id);
        jl.put('ACCL__Call_Template__c', ct.Id);
        jl.put('ACCL__Job_Definition_List__c', jdl.Id);
        jl.put('ACCL__Valid_From__c', System.today());
        jl.put('ACCL__Valid_Thru__c', System.today());
        jl.put('ACCL__Done__c', '0');
        insert jl;
        return jl;
    }
    
    /**
     *  @description This method insert a Job_List record in Bulk.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static List<sObject> insertJobLists(List<sObject> managers, sObject ct, List<sObject> jdls, Date dateFrom, Date dateTo) {
        List<sObject> listOfJobList = new List<sObject>();
        for(sObject jdl : jdls ) {
            for(sObject manager : managers) {
                sObject jl = allObjMetaType.get('ACCL__Job_List__c').newSObject();
                jl.put('ACCL__Account__c', manager.get('ACCL__Account__c'));
                jl.put('ACCL__Call_Template__c', ct.Id);
                jl.put('ACCL__Job_Definition_List__c', jdl.Id);
                jl.put('ACCL__Done__c', '0');
                jl.put('ACCL__Valid_From__c', dateFrom);
                jl.put('ACCL__Valid_Thru__c', dateTo);
                jl.put('ACCL__Manager__c', manager.get('ACCL__User__c'));
                listOfJobList.add(jl);
            }
        }
        insert listOfJobList;
        return listOfJobList;
    }
    
    /**
     *  @description This method inserts a User record in Bulk.
     *  @param None
     *  @return User record
     *  @throws None
     */
    public static List<sObject> insertUsers(Integer noOfUser) {
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User loggedInUser = [SELECT TimeZoneSidKey FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        List<sObject> userList = new List<sObject>();
        for(Integer i=0; i<noOfUser; i++) {
            sObject u = allObjMetaType.get('User').newSObject();
            u.put('FirstName', 'Joan'+i);
            u.put('LastName', 'Of Arc'+i);
            u.put('Email', 'joan'+i+'@arc.com');
            u.put('Alias', 'arcjoan'+i);
            u.put('Username', 'joanarc'+i+'@france.com');
            u.put('LocaleSidKey', 'en_US');
            u.put('TimeZoneSidKey', loggedInUser.TimeZoneSidKey);
            u.put('ProfileID', pro.Id);
            u.put('LanguageLocaleKey', 'en_US');
            u.put('EmailEncodingKey', 'UTF-8');
            // u.put('ACCL__Sales_Org__c','US01'); //Test fix - Pooja - 10 Sep
            userList.add(u);
        }
        insert userList;
        return userList;
    }
    
    /**
     *  @description This method insert a Account_Set record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultAccountSet() {
        sObject accset = allObjMetaType.get('ACCL__Account_Set__c').newSObject();
        accset.put('ACCL__Description_Language_1__c', 'test Desc');
        insert accset;
        return accset;
    }
    
    /**
     *  @description This method insert a Account_Set_Account record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultAccountSetAccount(sObject accSet, sObject acc) {
        sObject accsetacc = allObjMetaType.get('ACCL__Account_Set_Account__c').newSObject();
        accsetacc.put('ACCL__Account_Set__c', accSet.Id);
        accsetacc.put('ACCL__Account_Set_Account__c', acc.Id);
        insert accsetacc;
        return accsetacc;
    }
    
    /**
     *  @description This method insert a Job_Definition_List_Account_Set record.
     *  @param None
     *  @return sObject
     *  @throws None
     */
    public static sObject getDefaultJobDefinitionListAccountSet(sObject jdl, sObject accSet) {
        sObject jdlas = allObjMetaType.get('ACCL__Job_Definition_List_Account_Set__c').newSObject();
        jdlas.put('ACCL__Account_Set__c', accSet.Id);
        jdlas.put('ACCL__Job_Definition_List__c', jdl.Id);
        insert jdlas;
        return jdlas;
    }
}