/***************************************************************
Name: MDLZ_TestDataFactory
======================================================
Purpose:
Test Factory for creating test data for all related objects
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Vaidehi Heda               18/04/2022     Initial Development    
1.1      Namitha Francis            15/07/2022     Modification 		Inserted data for customer task and customer set   
***************************************************************/
@isTest
public class MDLZ_TestDataFactory {
    private static ACCL__Order_Template__c ordertempEdi = insertOrdTemplate();
    private static Account acct = insertAccount();
    private static List<ACCL__Order__c> ordList; 
    private static List<ACCL__Order_Item__c> ordItemList;
    private static List<ACCL__Org_Unit_User__c> orgUserList;
    private static User usrList; 
    private static ACCL__Org_Unit__c orgList;
    private static ACCL__Order_Template__c wrapperOrderTemplateId =insertWrapperOrdTemplate();
    //declare variables locally
	
	public static Account getAccount(){
        return acct;
    }
    
    public MDLZ_TestDataFactory(){
        
    }
    public static User getUser(string ProfileName){
        Profile pro = [select Id from Profile  where Name =:ProfileName];
        User usr = new User(alias = 'mdlz', email='test123@noemail.com',
                            emailencodingkey='UTF-8', lastname='01 Inbound AltREXwedcxss', languagelocalekey='en_US',
                            IsActive=true,localesidkey='en_US', profileid = pro.Id, country='United States',
                            timezonesidkey='America/Los_Angeles', username='test022al1@noemail.com',
                            ACCL__Sales_Org__c='US01'); 
        
        return usr;
    }   
    
   
    public static Account insertAccount(){
        acct= new Account();
        acct.Name ='Mondelez Test Account';
        acct.ACCL__Account_Number__c='Demo Unique123'+Integer.valueOf(Math.random() * 10) ;
        acct.Description ='Test Description';  
		acct.ACCL__Account_Template__c = insertAccountTemplate().id;
        insert acct;
        return acct;
    }
    
    public static ACCL__Order_Template__c insertOrdTemplate(){        
        ordertempEdi = new ACCL__Order_Template__c(Name ='EDI',RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                   ACCL__Document_Type__c='Order Entry',ACCL__Valid_Thru__c=system.today()+365,
                                                   ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='EDI_US0100'+Integer.valueOf(Math.random() * 10) ,
                                                   ACCL__Sales_Org__c='US01',ACCL__Active__c=true);
        
        insert ordertempEdi;
        return ordertempEdi;
    }
    
    public static ACCL__Order_Template__c insertWrapperOrdTemplate(){        
       ACCL__Order_Template__c wrapperORder = new ACCL__Order_Template__c(Name ='Order Wrapper',RecordTypeId =Schema.SObjectType.ACCL__Order_Template__c.getRecordTypeInfosByName().get('Order Entry').getRecordTypeId(),
                                                   ACCL__Document_Type__c='Order Entry1',ACCL__Valid_Thru__c=system.today()+365,
                                                   ACCL__Valid_From__c=system.today(),RE_Order_Template_ExternalID__c='WRAP_US010'+Integer.valueOf(Math.random() * 10) ,
                                                   ACCL__Sales_Org__c='US01',ACCL__Active__c=true, MDLZ_IsOrderWrapper__c = true);
        
        insert wrapperORder;
        return wrapperORder;
    }
    
    public static list<ACCL__Order__c> insertOrder(Integer numOrd ,Boolean doInsert){
        ordList = new List<ACCL__Order__c>();
        for(Integer i=0;i<numOrd;i++) {
            ACCL__Order__c ord = new ACCL__Order__c();
            ord.MDLZ_LastSavedByUser__c = system.today() - 10;
            ord.MDLZ_LastupdatedbySAP__c = system.today();
            ord.ACCL__Phase__c ='Cancelled';
            ord.ACCL__Delivery_Date__c =System.today()+363;
            ord.ACCL__Order_Account__c =acct.Id;
            ord.ACCL__Order_Template__c =ordertempEdi.Id;
            ord.MDLZ_isChanged__c='True';
            ord.MDLZ_isOrderAccepted__c =true;
            ord.MDLZ_Item_Switch__c ='Yes';
            ord.ACCL__Customer_Order_Id__c ='99'+'ff'+Integer.valueOf(Math.random()*100);
            ordList.add(ord);            
        }        
        if(doInsert){
            insert ordList;
        }        
        return ordList;        
    }
    
    public static list<ACCL__Order__c> insertOrder2(Integer numOrd ,Boolean doInsert){
        ordList = new List<ACCL__Order__c>();       
        for(Integer i=0;i<numOrd;i++) {
            ACCL__Order__c ord = new ACCL__Order__c();
            ord.MDLZ_LastSavedByUser__c = system.today() - 10;
            ord.ACCL__Phase__c ='Received By SAP';
            ord.ACCL__Delivery_Date__c =System.today()+363;
            ord.ACCL__Order_Account__c =acct.Id;
            ord.ACCL__Order_Template__c =ordertempEdi.Id;
            ord.MDLZ_isChanged__c='True';
            ord.MDLZ_isOrderAccepted__c =true;
            ord.MDLZ_Item_Switch__c ='No';
            ord.MDLZ_IsSFAutoGenerated__c =true;
            ord.ACCL__Order_Id__c ='OW12344e';
            ord.ACCL__Customer_Order_Id__c ='12345678';
            system.debug(ord);
            ordList.add(ord);            
        }        
        if(doInsert){
            insert ordList;
        }        
        return ordList;        
    }
    public static list<ACCL__Order_Item__c> insertOrderLineItem(Integer numlineI ,Boolean doInsert){  
        ordItemList = new List<ACCL__Order_Item__c>();
        ordList = insertOrder(1, True);
        for(Integer i=0;i<numlineI;i++) {
            ACCL__Order_Item__c ordItem = new ACCL__Order_Item__c();
            ordItem.ACCL__Order__c = ordList[0].id;
            ordItem.MDLZ_ItemStatus__c = 'A';
            
            ordItemList.add(ordItem);
        }        
        if(doInsert){
            insert ordItemList;
        }        
        return ordItemList;         
    }

     public static list<ACCL__Order__c> insertWrapperOrder(Integer numOrd ,Boolean doInsert){
        ordList = new List<ACCL__Order__c>();

        for(Integer i=0;i<numOrd;i++) {
            ACCL__Order__c ord = new ACCL__Order__c();
            ord.MDLZ_LastSavedByUser__c = system.today() - 10;
            ord.MDLZ_LastupdatedbySAP__c = system.today();
            ord.ACCL__Phase__c ='Cancelled';
            ord.ACCL__Delivery_Date__c =System.today()+363;
            ord.ACCL__Order_Account__c =acct.Id;
            ord.ACCL__Order_Template__c =wrapperOrderTemplateId.id;
            ord.MDLZ_isChanged__c='True';
            ord.MDLZ_isOrderAccepted__c =true;
            ord.MDLZ_Item_Switch__c ='Yes';
            ord.ACCL__Customer_Order_Id__c ='99'+'ff'+Integer.valueOf(Math.random()*100);
            ordList.add(ord);            
        }        
        if(doInsert){
            insert ordList;
        }        
        return ordList;        
    }
    
    public static ACCL__Org_Unit__c insertOrgUnit(){
        ACCL__Org_Unit__c  ou = new ACCL__Org_Unit__c();
        ou.ACCL__Org_Level__c = 'Territory';
        ou.ACCL__Sales_Org__c ='US01';
        ou.MDLZ_ExternalId__c = 'US01_G600001';
        ou.Name = 'G600001';
        insert ou;
        return ou;
    }
    
    public static List<ACCL__Account_Manager__c> createAccountManagerValidRecords(Integer count,Account acc,ACCL__Org_Unit__c orgUnit,user u){
        
        List<ACCL__Account_Manager__c> accList = new List<ACCL__Account_Manager__c>();
        
        for(integer i=0;i<count;i++){
            ACCL__Account_Manager__c accnt = new ACCL__Account_Manager__c();
            accnt.ACCL__Account__c=acc.id;
            accnt.ACCL__Org_Unit__c=orgUnit.id;
            accnt.ACCL__User__c= u.id;
            accnt.ACCL__Valid_From__c= System.today();
            accnt.ACCL__Valid_Thru__c= System.today()+360;
            accList.add(accnt);
        }
        
        insert accList; 
        return accList;
        
    }
    
    public static List<ACCL__Account_Manager__c> createAccountManagerInValidRecords(Integer count,Account acc,ACCL__Org_Unit__c orgUnit,user u){
        
        List<ACCL__Account_Manager__c> accList = new List<ACCL__Account_Manager__c>();
        
        for(integer i=0;i<count;i++){
            ACCL__Account_Manager__c accnt = new ACCL__Account_Manager__c();
            accnt.ACCL__Account__c=acc.id;
            accnt.ACCL__Org_Unit__c=orgUnit.id;
            accnt.ACCL__User__c=u.id;
            accnt.ACCL__Valid_From__c= System.today()-360;
            accnt.ACCL__Valid_Thru__c= System.today()-1;
            accList.add(accnt);
        }
        
        insert accList; 
        return accList;
        
    }
    public static ACCL__Promotion_Template__c insertPromotionTemplate(){
        ACCL__Promotion_Template__c promoTemplate= new ACCL__Promotion_Template__c(Name='Sellable Promotion - Customer', ACCL__Promotion_Type__c='SellablePromotion',
                                                                                   ACCL__Sales_Org__c='US01',ACCL__Description_Language_1__c='Sellable Promotion - Customer - US01',
                                                                                   ACCL__Product_Definition_Level__c='Tactic' ,ACCL__UI_Type__c='StandardUI');
        insert promoTemplate;
        return promoTemplate;
    }
    public static ACCL__Promotion__c insertPromotion(){
        ACCL__Promotion_Template__c promoTemplate = insertPromotionTemplate();
         ACCL__Promotion__c promo = new ACCL__Promotion__c();
         promo.ACCL__Promotion_Template__c = promoTemplate.id;
         promo.ACCL__Date_From__c= System.today();
         promo.ACCL__Date_Thru__c= System.today()+360;
         promo.ACCL__Anchor_Account__c = acct.Id;
         promo.ACCL__Slogan_Language_1__c='Test Promotion';
         promo.ACCL__Active__c=false;
        insert promo;
        return promo;
    }
    public static ACCL__Tactic__c insertTactic(){
        ACCL__Promotion__c promo= insertPromotion();
         ACCL__Tactic__c tactic = new ACCL__Tactic__c();
         tactic.ACCL__Promotion__c=promo.id;
         tactic.ACCL__Date_From__c= System.today(); 
         tactic.ACCL__Date_Thru__c= System.today()+360;
        insert tactic;
        return tactic;
      
    }
    public static ACCL__Product__c insertProduct(){
        ACCL__Product__c product = new ACCL__Product__c(Name='Test Product');
        insert product;
        return product;
}

    public static List<ACCL__Tactic_Product__c> insertTacticProducts(Integer numTactic ,Boolean doInsert){
        List<ACCL__Tactic_Product__c> tatcProdList = new List<ACCL__Tactic_Product__c>();

        ACCL__Tactic__c tactic = insertTactic();
        ACCL__Product__c product = insertProduct();
        for(Integer i=0;i<numTactic;i++) {
           ACCL__Tactic_Product__c tatcProd = new ACCL__Tactic_Product__c();
           tatcProd.MDLZ_Price__c = 5;
           tatcProd.MDLZ_Location__c='xff'; 
           tatcProd.MDLZ_SubPPG__c='1Big Bags';
           tatcProd.MDLZ_PPG__c ='1Big Bags'; 
           tatcProd.ACCL__Tactic__c=tactic.id; 
           tatcProd.ACCL__Included__c=true;
           tatcProd.ACCL__Product__c =product.id;
           tatcProdList.add(tatcProd);
        }
        if(doInsert){
            insert tatcProdList;
        }
        return tatcProdList;
    }

    public static List<ACCL__Product__c> createProductRecords(Integer count){
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        for(Integer i=0; i<count; i++) {
            ACCL__Product__c product = new ACCL__Product__c(Name='Test Product' + i);
			product.ACCL__State__c = '4';
            product.MDLZ_SubPPG__c= i + 'Big Bags';
            product.MDLZ_PPG__c ='Big Bags';
            productList.add(product);
         }
        insert productList;
        return productList;
    }

    public static List<ACCL__Org_Unit_User__c> createOrgUnitUserRecords(Integer count, String isOrgUnitChanged, ACCL__Org_Unit__c orgUnit, user u){
        List<ACCL__Org_Unit_User__c> orgUnitUserList = new List<ACCL__Org_Unit_User__c>();

        for(integer i=0;i<count;i++){
            ACCL__Org_Unit_User__c orgUnitUser = new ACCL__Org_Unit_User__c();
            orgUnitUser.MDLZ_isOrgUnitChanged__c=isOrgUnitChanged;
            orgUnitUser.ACCL__Org_Unit__c=orgUnit.id;
            orgUnitUser.ACCL__User__c=u.Id;
            orgUnitUser.ACCL__Valid_From__c= System.today()-360;
            orgUnitUser.ACCL__Valid_Thru__c= System.today()-1;
            orgUnitUserList.add(orgUnitUser);
        }

        insert orgUnitUserList; 
        return orgUnitUserList;
    }
    
    public static list<Account> insertAccount(Integer numOrd ,Boolean doInsert){
        List<Account> accountList = new List<Account>();
		ID accountTemplateId = insertAccountTemplate().id;
        
        for(Integer i=0;i<numOrd;i++) {
            Account newAcct = new Account();
            newAcct.Name = 'Test Account '+i;
            newAcct.ACCL__Account_Number__c=i+'Demo Unique123'+Integer.valueOf(Math.random() * 10)+i;
            newAcct.Description ='Test Description '+i;
			newAcct.ACCL__Account_Template__c = accountTemplateId;
            accountList.add(newAcct);            
        }        
        if(doInsert){
            insert accountList;
        }        
        return accountList;        
    }

    public static ACCL__Account_Task_Template__c insertCustomerTaskTemplate(){
        ACCL__Account_Task_Template__c custTaskTemplate= new ACCL__Account_Task_Template__c(Name='Customer Task', ACCL__Description_Language_1__c='Test Description',
                                                                                   ACCL__Sales_Org__c='US01', ACCL__Active__c = true);
        insert custTaskTemplate;
        return custTaskTemplate;
    }
    public static ACCL__Account_Template__c insertAccountTemplate(){
        ACCL__Account_Template__c accountTemplate= new ACCL__Account_Template__c(Name='Customer Template', ACCL__Description_Language_1__c = 'Test Data', ACCL__Initial_Roles__c='Customer',
                                                                                   ACCL__Sales_Org__c='US01', ACCL__Active__c = true, RecordTypeId =Schema.SObjectType.ACCL__Account_Template__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert accountTemplate;
        return accountTemplate;
    }
    
    public static ACCL__Account_Set__c insertCustomerSet(){
        ACCL__Account_Set__c customerSet= new ACCL__Account_Set__c(ACCL__Description_Language_1__c ='Mondelez Description', ACCL__Sales_Org__c=acct.ACCL__Sales_Org__c);
        insert customerSet;
        return customerSet;
    }
    
    public static ACCL__Account_Set_Account__c insertCustomerSetCust(){
        
        ACCL__Account_Set__c custSet = insertCustomerSet();
        
        ACCL__Account_Set_Account__c customerSetCust = new ACCL__Account_Set_Account__c();
        customerSetCust.ACCL__Account_Set_Account__c = acct.id;
        customerSetCust.ACCL__Account_Set__c = custSet.id;
        insert customerSetCust;
        return customerSetCust;
    }
    
    public static ACCL__Account_Task__c insertCustomerTask(){
        
        ACCL__Account_Set__c custSet = insertCustomerSet();
        ACCL__Account_Task_Template__c custTaskTemp = insertCustomerTaskTemplate();
        
            ACCL__Account_Task__c custTask = new ACCL__Account_Task__c();
            custTask.ACCL__Account_Task_Template__c=custTaskTemp.Id;
        	custTask.ACCL__Description_Language_1__c ='Test Demo';
        	custTask.ACCL__Sales_Org__c='US01';
        	custTask.ACCL__Due_Date__c=system.today()+5;
        	custTask.ACCL__Account__c =acct.id;
        	custTask.ACCL__Priority__c ='A';
        	custTask.MDLZ_Customer_Sets__c=custSet.Id;
        insert custTask;
        return custTask;

    }
    
     public static List<ACCL__Account_Set__c> insertCustomerSetList(Integer numCustomerSet ,Boolean doInsert){

        List<ACCL__Account_Set__c> customerSetList = new List<ACCL__Account_Set__c>();
        
        for(Integer i=0;i<numCustomerSet;i++) {
            ACCL__Account_Set__c customerSet= new ACCL__Account_Set__c();
            customerSet.ACCL__Description_Language_1__c ='Mondelez Description';
            customerSet.ACCL__Sales_Org__c='US01';
            customerSetList.add(customerSet);
        
        }
        if(doInsert){
            insert customerSetList;
        }
        return customerSetList;
    }
    public static List<ACCL__Account_Task__c> insertCustomerTask(Integer numCustomerTask ,Boolean doInsert){
        
        ACCL__Account_Task_Template__c custTaskTemp = insertCustomerTaskTemplate();
        ACCL__Account_Set__c custSet = insertCustomerSet();

        List<ACCL__Account_Task__c> customerTaskList = new List<ACCL__Account_Task__c>();
        
        for(Integer i=0;i<numCustomerTask;i++) {
            
            ACCL__Account_Task__c custTask = new ACCL__Account_Task__c();
            custTask.ACCL__Account_Task_Template__c=custTaskTemp.Id;
        	custTask.ACCL__Description_Language_1__c ='Test Demo';
        	custTask.ACCL__Sales_Org__c='US01';
        	custTask.ACCL__Due_Date__c=system.today()+5;
        	custTask.ACCL__Account__c =acct.id;
        	custTask.ACCL__Priority__c ='A';
        	custTask.MDLZ_Customer_Sets__c=custSet.Id;
            customerTaskList.add(custTask);
        }
        if(doInsert){
            insert customerTaskList;
        }
        return customerTaskList;
    }
	
	public static List<ACCL__Fund__c> insertFundRecords(Integer numOfFunds ,Boolean doInsert){
        ACCL__Fund_Template__c fundTemplate = insertFundTemplate();
        List<ACCL__Fund__c> fundList = new List<ACCL__Fund__c>();
        
        for(Integer i=0;i<numOfFunds;i++) {
            
            ACCL__Fund__c fund = new ACCL__Fund__c();
            fund.ACCL__Fund_Template__c = fundTemplate.Id;
        	fund.ACCL__Description_Language_1__c ='Test Lang';
            fund.ACCL__Valid_From__c = System.today()-360;
            fund.ACCL__Valid_Thru__c = System.today()-1;
        	fund.ACCL__Status__c = 'Initial';
        	fund.ACCL__Anchor_Account__c = acct.id;
        	fund.ACCL__Fund_Template__c = fundTemplate.Id;
            fundList.add(fund);
        }
        if(doInsert){
            insert fundList;
        }
        return fundList;
    }

    public static ACCL__Fund_Template__c insertFundTemplate(){

        ACCL__Fund_Template__c fundTemplate = new ACCL__Fund_Template__c();
            
        fundTemplate.ACCL__Description_Language_1__c = 'Test Lang';
        fundTemplate.ACCL__Active__c = true;
        fundTemplate.ACCL__Sales_Org__c = 'US01';
        fundTemplate.ACCL__Anchor_Type__c = 'Customer';
        fundTemplate.ACCL__Currency__c = 'USD';
        fundTemplate.Name = 'Test Template';
        fundTemplate.ACCL__KPI_Set__c = insertKPISet().id;

        insert fundTemplate;
        return fundTemplate;
    }

    public static ACCL__KPI_Set__c insertKPISet(){

        ACCL__KPI_Set__c kpiSet = new ACCL__KPI_Set__c();
            
        kpiSet.Name = 'Test KPI';
        kpiSet.ACCL__Usage__c = 'Funding';
        kpiSet.ACCL__Description_Language_1__c = 'Test Lang';

        insert kpiSet;
        return kpiSet;
    }

    public static List<ACCL__Fund__c> updateFundRecords(List<ACCL__Fund__c> fundList ,Boolean doUpdate){
        
        for(ACCL__Fund__c fund : fundList){
        	fund.ACCL__Status__c = 'Active';
        }
        if(doUpdate){
            Update fundList;
        }
        return fundList;
    }
        
    public static List<ACCL__Product__c> insertDiffLevelProducts(Integer numOfProducts ,Boolean doInsert){
        List<String> levelList = new List<String>{'Category', 'SubCategory', 'Brand', 'Flavor', 'Package'};
        List<ACCL__Product__c> productList = new List<ACCL__Product__c>();
        
        for(Integer i=0;i<numOfProducts;i++) {
            
            ACCL__Product__c product = new ACCL__Product__c(Name='Test Product' + i);
            if(i < levelList.size()){
                product.ACCL__Product_Level__c = levelList[i];
            } else {
                product.ACCL__Product_Level__c = levelList[0];
            }
        	product.ACCL__Product_Template__c = insertProductTemplate().Id;
            productList.add(product);
        }
        if(doInsert){
            insert productList;
        }
        return productList;
    }

    public static ACCL__Product_Template__c insertProductTemplate(){

        ACCL__Product_Template__c productTemplate = new ACCL__Product_Template__c();
            
        productTemplate.ACCL__Description_Language_1__c = 'Test Lang';
        productTemplate.ACCL__Sales_Org__c = 'US01';
        productTemplate.Name = 'Test template';

        insert productTemplate;
        return productTemplate;
    }
	
	public static MDLZ_KPIData__c insertKPIDataRecords(){

        MDLZ_KPIData__c kpiRecord = new MDLZ_KPIData__c();
        User runningUser = [Select Id from user where id = :UserInfo.getUserId()];
        kpiRecord.MDLZ_Mobility_Relevant__c = 'No';
        kpiRecord.MDLZ_TerritoryId__c = insertOrgUnit().Id;
        kpiRecord.MDLZ_UserId__c = runningUser.Id;
        kpiRecord.name = 'test';
        kpiRecord.MDLZ_KPIGroup__c = MDLZ_ConstantHelper.KPIGroup;

        insert kpiRecord;
        return kpiRecord;
    }
        
}