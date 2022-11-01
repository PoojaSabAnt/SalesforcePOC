/**  PROGRAM NAME : CallOrderDistributionBatchTestFactory
     * This class is to create test data for batch class.       
     * @version  1.0
     * @Created Date 2017-01-16
*/
@isTest
public class CallOrderDistributionBatchTestFactory {
    private static String ns = AddOnConstants.NAMESPACEPREFIX;
    public static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    /*********** Data creation for Objects****************/

    /**This function is for inserting Account Template related Data
    *  @name insertAccountTemplate
    *  @param null
    *  @return sObject(Account_Template__c)
    */
    public static sObject insertAccountTemplate() {
        Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get('ACCL__Account_Template__c').getDescribe();         
        Id recordTypeIDCustomer = [Select Id from RecordType where sObjectType=:objectDescribeResult.getName()
                     and DeveloperName=:AddOnConstants.CUSTOMER_RECORD_TYPE].Id;       
        sObject sObj = allObjMetaType.get('ACCL__Account_Template__c').newSObject() ;
        sObj.put('Name','123');
        sObj.put('ACCL__Initial_Roles__c','123');
        sObj.put('RecordTypeId',recordTypeIDCustomer); 
        sObj.put('ACCL__Description_Language_1__c','test');
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
    /**This function is for building Account Data
    *  @name buildAccount
    *  @param Integer nameSuffix,sObject accountTemplate
    *  @return Account
    */ 
     public static Account buildAccount(Integer nameSuffix,sObject accountTemplate){
        Account account = new Account();
        account.put('ACCL__City__c','Test City');
        account.put('ACCL__Street__c','Test Street'); 
        account.put('ACCL__Name_2__c','testX'+nameSuffix);        
        account.Name = 'TEST'+nameSuffix;
        account.put('ACCL__Account_Template__c', accountTemplate.Id);
        return account;
    }
    /**This function is for inserting List of Account Data
    *  @name insertAccounts
    *  @param Integer numberOfAccounts,sObject accountTemplate
    *  @return List<Account>
    */
     public static List<Account> insertAccounts( Integer numberOfAccounts,sObject accountTemplate) {
        List<Account> accounts = new List<Account>();
        for(Integer i=0 ; i < numberOfAccounts ; i++){
            accounts.add(buildAccount(i,accountTemplate));
        }
        insert accounts;
        return accounts;
    }
    /**This function is for inserting order Template Data
    *  @name insertOrderTemplate
    *  @param Integer nameSuffix,Date validFrom,Date validThru
    *  @return sObject(Order_Template__c)
    */
     public static sObject insertOrderTemplate(Integer nameSuffix,Date validFrom,Date validThru) {
        sObject sObj = allObjMetaType.get('ACCL__Order_Template__c').newSObject() ;
        sObj.put('Name','Test'+nameSuffix);
        sObj.put('ACCL__Active__c',True);
        sObj.put('ACCL__Valid_From__c',validFrom);
        sObj.put('ACCL__Valid_Thru__c',validThru);
        sObj.put('ACCL__Description_Language_1__c','English');
        sObj.put('ACCL__Creation_Platform__c','Both');
        sObj.put('ACCL__Consider_Listing__c','2');
        sObj.put('ACCL__Consider_Promotion__c','2');
        sObj.put('ACCL__Add_Former_Items__c',True);
        sObj.put('ACCL__Use_Built_In_Pricing__c','yes');
        sObj.put('ACCL__Consider_Field_Availability__c',True);
        sObj.put('ACCL__User_Roles__c','ACSF_Supervisor');
        sObj.put('ACCL__Quantity_Rounding__c','RoundingDefaultOn');
         sObj.put('RE_Order_Template_ExternalID__c','EDI_US01');
        insert sObj;
        return sObj;
    }
    /**This function is for inserting call Template Data
    *  @name insertJCallTemplate
    *  @param Integer nameSuffix
    *  @return sObject(Call_Template__c)
    */
     public static sObject insertJCallTemplate(Integer nameSuffix) {
        sObject sObj = allObjMetaType.get('ACCL__Call_Template__c').newSObject();
        sObj.put('Name','Test'+nameSuffix);
        sObj.put('ACCL__Description_Language_1__c','English');
        sObj.put('ACCL__Active__c',True);
        sObj.put('ACCL__Default_Duration__c',15);
        sObj.put('ACCL__Company_Required__c','Mandatory');
        sObj.put('ACCL__Creation_Platform__c','Both');        
        insert sObj;
        return sObj;
    }
    /**This function is for building Order Data
    *  @name buildOrderRecWithOnlyOrderTemplateAndAccount
    *  @param Account customer,Date referenceDate,sObject orderTemplate
    *  @return sObject(Order__c)
    */
     public static sObject buildOrderRecWithOnlyOrderTemplateAndAccount(Account customer,Date referenceDate,sObject orderTemplate) {
        sObject sObj = allObjMetaType.get('ACCL__Order__c').newSObject(); 
        sObj.put('ACCL__Order_Account__c',customer.id);
        sObj.put('ACCL__Order_Template__c',orderTemplate.id);
        sObj.put('ACCL__Delivery_Date__c',referenceDate);
        sObj.put('ACCL__Phase__c','Initial');
        sObj.put('ACCL__Delivery_Recipient__c', customer.id);
        return sObj;
    }
    /**This function is for building call Data
    *  @name buildCall
    *  @param sObject template, Account account
    *  @return sObject(Call__c)
    */
    public static sObject buildCall( sObject template, Account account) {
        sObject sObj = allObjMetaType.get('ACCL__Call__c').newSObject(); 
        sObj.put('ACCL__Subject__c','Test_Subject');
        sObj.put('ACCL__Creation_Mode__c','Manually');
        sObj.put('ACCL__Account__c',account.Id);
        sObj.put('ACCL__Start_Date_Time__c',System.now());
        if(template != null ){
          sObj.put('ACCL__Call_Template__c',template.Id);
          sObj.put('ACCL__End_Date_Time__c',System.now().addMinutes(Integer.valueOf(template.get('ACCL__Default_Duration__c'))));
        }
        sObj.put('ACCL__Responsible__c',UserInfo.getUserId());
        sObj.put('ACCL__Status__c','Plan');
        return sObj;
    }
    /**************** Data creation for custom settings***********************/
    /**This function is for inserting Batch Process configuration Data
    *  @name insertBatchProcessConfig
    *  @param null
    *  @return sObject(Batch_Process_Configuration__c)
    */  
    public static sObject insertBatchProcessConfig() {
        sObject sObj = allObjMetaType.get('ACCL__Batch_Process_Configuration__c').newSObject();
        sObj.put('Name','CallOrderDistributionReorganization');
        sObj.put('ACCL__Batch_Size__c',1);
        insert sObj;
        return sObj;
    }
    /**This function is for inserting Call related customizable setting for Distribution Relevant attribute
    *  @name createCustomSettingDataForCall
    *  @param null
    *  @return Call_Order_Distribution_Reorganisation__c
    */  
    public static Distribution_Reorganisation__c createCustomSettingDataForCall(Integer rCount,Integer cutOffDate){
        Distribution_Reorganisation__c sCall = new Distribution_Reorganisation__c (
                                              name = AddOnConstants.CALL_DISTRIBUTION_SETTING,
                                              Distribution_Relevant_Count__c = rCount,
                                              Distribution_Relevant_CutOff_Date__c = cutOffDate);
        insert scall;
        return scall;
    }
    /**This function is for inserting Order related customizable setting for Distribution Relevant attribute
    *  @name createCustomSettingDataForOrder
    *  @param null
    *  @return Call_Order_Distribution_Reorganisation__c
    */
    public static Distribution_Reorganisation__c createCustomSettingDataForOrder(Integer rCount,Integer cutOffDate){
        Distribution_Reorganisation__c sOrder = new Distribution_Reorganisation__c (
                                              name = AddOnConstants.ORDER_DISTRIBUTION_SETTING,
                                              Distribution_Relevant_Count__c = rCount,
                                              Distribution_Relevant_CutOff_Date__c = cutOffDate);
        insert sOrder;
        return sOrder;
    }
    /**This function is for inserting Account Template related Data
    *  @name insertAccountTemplate
    *  @param null
    *  @return sObject(Account_Template__c)
    */
    public static sObject insertAccountTemplateWithSalesOrg(String salesOrg) {
        Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get('ACCL__Account_Template__c').getDescribe();         
        Id recordTypeIDCustomer = [Select Id from RecordType where sObjectType=:objectDescribeResult.getName()
                     and DeveloperName=:AddOnConstants.CUSTOMER_RECORD_TYPE].Id;       
        sObject sObj = allObjMetaType.get('ACCL__Account_Template__c').newSObject() ;
        sObj.put('Name','123');
        sObj.put('ACCL__Initial_Roles__c','123');
        sObj.put('RecordTypeId',recordTypeIDCustomer); 
        sObj.put('ACCL__Description_Language_1__c','test');
        sObj.put('ACCL__Sales_Org__c',salesOrg);
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
  /**This function is for inserting Asset Template related Data
    *  @name insertAssetTemplate
    *  @param null
    *  @return sObject(Asset_Template__c)
    */
    public static sObject insertAssetTemplate(Integer nameSuffix,String salesOrg) {
        sObject sObj = allObjMetaType.get('ACCL__Asset_Template__c').newSObject() ;
        sObj.put('Name','TestTemp - '+nameSuffix);
        sObj.put('ACCL__Active__c',true);
        sObj.put('ACCL__Meta_Type__c','Cooler'); 
        sObj.put('ACCL__Location_Type__c','INT');
        sObj.put('ACCL__Sales_Org__c',salesOrg);
        sObj.put('ACCL__Description_Language_1__c','TestTemp - '+nameSuffix);
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
  /**This function is for inserting Product Template related Data
    *  @name insertAssetTemplate
    *  @param null
    *  @return sObject(Product_Template__c)
    */
    public static sObject insertProductTemplate(Integer nameSuffix,String salesOrg) {
        sObject sObj = allObjMetaType.get('ACCL__Product_Template__c').newSObject() ;
        sObj.put('Name','TestTemp - '+nameSuffix);
        sObj.put('ACCL__Active__c',true);
        sObj.put('ACCL__Price_Required__c',true); 
        sObj.put('ACCL__Sales_Org__c','0001');
        sObj.put('ACCL__Description_Language_1__c','TestTemp - '+nameSuffix);
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
  /**This function is for inserting Product related Data
    *  @name insertProduct
    *  @param Product_Template__c
    *  @return sObject(Product__c)
    */
    public static sObject insertProduct(sObject productTemplate,sobject assetTemplate) {
        sObject sObj = allObjMetaType.get('ACCL__Product__c').newSObject() ;
        sObj.put('Name','TestTemp - '+1);
        sObj.put('ACCL__Product_Template__c',productTemplate.id);
        sObj.put('ACCL__Product_type__c','AssetType');
        sObj.put('ACCL__Asset_Template__c',assetTemplate.id);
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
    /**This function is for inserting call Template Data
    *  @name insertJCallTemplate
    *  @param Integer nameSuffix
    *  @return sObject(Call_Template__c)
    */
     public static sObject insertJCallTemplateWithSalesOrg(Integer nameSuffix,String salesOrg) {
        sObject sObj = allObjMetaType.get('ACCL__Call_Template__c').newSObject();
        sObj.put('Name','Test'+nameSuffix);
        sObj.put('ACCL__Description_Language_1__c','English');
        sObj.put('ACCL__Active__c',True);
        sObj.put('ACCL__Default_Duration__c',15);
        sObj.put('ACCL__Company_Required__c','Mandatory');
        sObj.put('ACCL__Creation_Platform__c','Both');
        sObj.put('ACCL__Sales_Org__c',salesOrg);
        insert sObj;
        return sObj;
    }
  /**This function is for inserting Asset  related Data
    *  @name insertAsset
    *  @param Asset assetRecord
    *  @return sObject(Asset)
    */
    public static sObject insertAsset() {      
        sObject sObj = allObjMetaType.get('Asset').newSObject() ;
        Account acc = buildAccount(1,insertAccountTemplateWithSalesOrg('0001'));
        insert acc;
        sObject callSobject = buildCall(insertJCallTemplateWithSalesOrg(1,'0001'),acc);
        insert callSobject;
        sobject assetTemplate = insertAssetTemplate(1,'0001');
        sobject productRecord = insertProduct(insertProductTemplate(1,'0001'),assetTemplate);
        sObj.put('Name','TestAsset- '+1);
        sObj.put('AccountId',acc.id);
        sObj.put('SerialNumber',' '+1);
        sObj.put('ACCL__Valid_From__c',System.Today());
        sObj.put('ACCL__Valid_Thru__c',Date.newInstance(2999,12,31)); 
        sObj.put('Status','Active');
        sObj.put('ACCL__Description_Language_1__c','TestAsset- '+'1'); 
        sObj.put('ACCL__Sales_Org__c','0001'); 
        sObj.put('ACCL__Asset_type__c',productRecord.id); 
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
    /**This function is for inserting Asset Audit related Data
    *  @name insertAssetAudit
    *  @param Asset assetRecord
    *  @return sObject(Asset_Audit__c)
    */
    public static sObject buildAssetAudit(Asset asset) {      
        sObject sObj = allObjMetaType.get('ACCL__Asset_Audit__c').newSObject() ;
        sObj.put('ACCL__Account__c',asset.AccountId);
        sObj.put('ACCL__Asset__c',asset.id);
        sObj.put('ACCL__Sales_Org__c','0001'); 
        sObj.put('ACCL__Sighted__c',false);
        system.debug('***-->'+sObj);
        return sObj;
    }
   /**This function is for inserting Asset Audit related Data
    *  @name insertAssetAudit
    *  @param Asset assetRecord
    *  @return sObject(Asset_Audit__c)
    */
    //Test Methods With No Assert -This method creates test factory data, Assert Is Not needed - False Positive
    public static sObject insertAssetAudit(Asset asset) {      
        sObject sObj = allObjMetaType.get('ACCL__Asset_Audit__c').newSObject() ;
        sObj.put('ACCL__Account__c',asset.Account);
        sObj.put('ACCL__Asset__c',asset.id);
        sObj.put('ACCL__Sales_Org__c','0001'); 
        sObj.put('ACCL__Sighted__c',false);
        insert sObj;
        system.debug('***-->'+sObj);
        return sObj;
    }
  /**This function is for building Asset Audit list related Data
    *  @name buildAssetAuditList
    *  @param Integer no of Asset Audits to be created,Asset assetRecord
    *  @return List<sObject>(Asset_Audit__c)
    */
  //Test Methods With No Assert -This method creates test factory data, Assert Is Not needed - False Positive
  public static List<sObject> buildAssetAuditList(Integer noOfAssetAudits,Asset asset) {
        List<sObject> assetAuditList = new List<sObject>();
        for(Integer i=0;i<noOfAssetAudits;i++)
        {
            assetAuditList.add(buildAssetAudit(asset));
        }
        return assetAuditList;
    }
  /**This function is for inserting Asset Audit List related Data
    *  @name insertAssetAuditList
    *  @param Asset assetRecord
    *  @return List<sObject>(Asset_Audit__c)
    */
    public static List<sObject> insertAssetAuditList(Integer noOfAssetAudits,Asset asset) {
        List<sObject> assetAuditList = new List<sObject>();
        for(Integer i=0;i<noOfAssetAudits;i++)
        {
            assetAuditList.add(buildAssetAudit(asset));
        }
        insert assetAuditList;
        return assetAuditList;
    }
}