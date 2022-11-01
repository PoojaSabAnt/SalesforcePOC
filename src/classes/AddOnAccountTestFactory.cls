//FLS_Create, FLS_Create_Partial, FLS_Update, FLS_Update_Partial - False Positive
//This is a test data generation class and must be accessed in system context. No CRUD permission check is required.
@isTest
public class AddOnAccountTestFactory {
    public static Account defaultAccount;
    public static Account defaultAccountWithSaleOrg;
    public static Account defaultAccountWithSaleOrgQueried;
    
    public static Account buildAccount(Integer nameSuffix) {
        Account account = new Account();
        account.ACCL__City__c = 'Test City';
        account.ACCL__Street__c = 'Test Street';
        account.Name = AddOnConstants.Name+nameSuffix; 
        account.ACCL__Name_2__c = 'testX'+nameSuffix;
        account.ACCL__ExternalId__c = 'ExtID_' + nameSuffix + '_' + Crypto.getRandomInteger();
        return account;
    }

    public static Account insertAccount(Integer nameSuffix){
        Account account = buildAccount(nameSuffix);
        insert account;
        return account;
    }
    
    public static Account buildAccount(Integer nameSuffix,ACCL__Account_Template__c accTemp) {
        Account account = buildAccount(nameSuffix);
        account.ACCL__Account_Template__c = accTemp.Id;
        return account;
    }

    public static Account getDefaultAccount() {
        if( defaultAccount == null ){
            defaultAccount = insertAccount( -1 );
        }
        return defaultAccount;
    }

    public static Account getAccountWithSalesOrg(
        ACCL__Account_Template__c accTemp,
        Integer nameSuffix
    ) {
        Account account = buildAccount(nameSuffix, accTemp);
        insert Account;
        return account;
    }

}