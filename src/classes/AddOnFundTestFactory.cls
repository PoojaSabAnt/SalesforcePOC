@isTest
public with sharing class AddOnFundTestFactory {
  /* InsertFundList method which builds list of fund records and inserts into DB.
   Parameters passed  to this method are anchorCustomerExtension,listProduct,fundTemplate,status,validFrom,validThru*/
  public static List<ACCL__Fund__c> insertFundList(
    ACCL__Account_Extension__c anchorCustomerExtension,
    List<ACCL__Product__c> listProduct,
    ACCL__Fund_Template__c fundTemplate,
    String status,
    Date validFrom,
    Date validThru
  ) {
    List<ACCL__Fund__c> listFundBuild = buildFundList(
      anchorCustomerExtension,
      listProduct,
      fundTemplate,
      status,
      validFrom,
      validThru
    );
    insert listFundBuild;
    return listFundBuild;
  }

  /* buildFundList method which builds list of fund records but do not insert into DB.
   Parameters passed  to this method are anchorCustomerExtension,listProduct,fundTemplate,status,validFrom,validThru*/
  public static List<ACCL__Fund__c> buildFundList(
    ACCL__Account_Extension__c anchorCustomerExtension,
    List<ACCL__Product__C> listProduct,
    ACCL__Fund_Template__c fundTemplate,
    String status,
    Date validFrom,
    Date validThru
  ) {
    List<ACCL__Fund__c> listFundBuild = new List<ACCL__Fund__c>();
    for (Integer i = 0; i < listProduct.size(); i++) {
      listFundBuild.add(
        buildFund(
          anchorCustomerExtension,
          listProduct[i],
          fundTemplate,
          status,
          validFrom.addDays(i),
          validFrom.addDays(i + 1)
        )
      );
    }
    return listFundBuild;
  }

  /* buildFund method which creates the fund record but does not insert into DB.
   Parameters passed  to this method are anchorCustomerExtension,anchorProduct,fundTemplate,status,validFrom,validThru*/
  public static ACCL__Fund__c buildFund(
    ACCL__Account_Extension__c anchorCustomerExtension,
    ACCL__Product__c anchorProduct,
    ACCL__Fund_Template__c fundTemplate,
    String status,
    Date validFrom,
    Date validThru
  ) {
    return buildFund(
      anchorCustomerExtension.ACCL__Account__c,
      anchorProduct,
      fundTemplate,
      status,
      validFrom,
      validThru
    );
  }
  public static ACCL__Fund__c buildFund(
    Id anchorCustomerId,
    ACCL__Product__c anchorProduct,
    ACCL__Fund_Template__c fundTemplate,
    String status,
    Date validFrom,
    Date validThru
  ) {
    ACCL__Fund__c fundRecord = new ACCL__Fund__c();
    fundRecord.ACCL__Anchor_Account__c = anchorCustomerId;
    if (anchorProduct != null) {
      fundRecord.ACCL__Anchor_Product__c = anchorProduct.id;
    }
    fundRecord.ACCL__Fund_Template__c = fundTemplate.id;
    fundRecord.ACCL__Status__c = status;
    fundRecord.ACCL__Valid_From__c = validFrom;
    fundRecord.ACCL__Valid_Thru__c = validThru;
    return fundRecord;
  }
}