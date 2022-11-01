@isTest
public class AddOnAccountExtensionTestFactory {
      public static ACCL__Account_Extension__c buildAccountExtension(
    Account account,
    Date fundValidFrom,
    Date fundValidThru,
    Date billToValidFrom,
    Date billToValidThru,
    Date brokerRoleValidFrom,
    Date brokerRoleValidThru,
    Date customerValidFrom,
    Date customerValidThru,
    Date deliveryRoleValidFrom,
    Date deliveryRoleValidThru,
    Date orderRoleValidFrom,
    Date orderRoleValidThru,
    Date payerRoleValidFrom,
    Date payerRoleValidThru,
    Date storeRoleValidFrom,
    Date storeRoleValidThru,
    Date promotionValidFrom,
    Date promotionValidThru
  ) {
    ACCL__Account_Extension__c accountExtensionRecord = new ACCL__Account_Extension__c();
    accountExtensionRecord.ACCL__Account__c = account.id;
    accountExtensionRecord.ACCL__Fund_Role_Valid_From__c = fundValidFrom;
    accountExtensionRecord.ACCL__Fund_Role_Valid_Thru__c = fundValidThru;
    accountExtensionRecord.ACCL__Bill_To_Role_Valid_From__c = billToValidFrom;
    accountExtensionRecord.ACCL__Bill_To_Role_Valid_Thru__c = billToValidThru;
    accountExtensionRecord.ACCL__Broker_Role_Valid_From__c = brokerRoleValidFrom;
    accountExtensionRecord.ACCL__Broker_Role_Valid_Thru__c = brokerRoleValidThru;
    accountExtensionRecord.ACCL__Customer_Role_Valid_From__c = customerValidFrom;
    accountExtensionRecord.ACCL__Customer_Role_Valid_Thru__c = customerValidThru;
    accountExtensionRecord.ACCL__Delivery_Role_Valid_From__c = deliveryRoleValidFrom;
    accountExtensionRecord.ACCL__Delivery_Role_Valid_Thru__c = deliveryRoleValidThru;
    accountExtensionRecord.ACCL__Order_Role_Valid_From__c = orderRoleValidFrom;
    accountExtensionRecord.ACCL__Order_Role_Valid_Thru__c = orderRoleValidThru;
    accountExtensionRecord.ACCL__Payer_Role_Valid_From__c = payerRoleValidFrom;
    accountExtensionRecord.ACCL__Payer_Role_Valid_Thru__c = payerRoleValidThru;
    accountExtensionRecord.ACCL__Promotion_Valid_From__c = promotionValidFrom;
    accountExtensionRecord.ACCL__Promotion_Valid_Thru__c = promotionValidThru;
    accountExtensionRecord.ACCL__Store_Role_Valid_From__c = storeRoleValidFrom;
    accountExtensionRecord.ACCL__Store_Role_Valid_Thru__c = storeRoleValidThru;

    return accountExtensionRecord;
  }

}