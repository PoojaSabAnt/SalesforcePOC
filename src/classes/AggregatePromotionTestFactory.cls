public class AggregatePromotionTestFactory {
 private static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
 private static String ns = AddOnConstants.NAMESPACEPREFIX;
 private final Static String PROMOTION_PHASE_COMMITTED = 'Committed';
 Date today = System.today();
 
 public static final String query = 'SELECT Id, ACCL__Anchor_Account__c FROM ACCL__Promotion__c WHERE ACCL__Date_From__c <=today AND ACCL__Date_Thru__c >= today AND ACCL__Active__c=true AND ACCL__Phase__c =:PROMOTION_PHASE_COMMITTED AND ACCL__Anchor_Account__c != NULL';
    
    public static sobject getDefaultAccount() {
        sObject acc = allObjMetaType.get('Account').newSObject();
        acc.put('Name', 'testName');
        acc.put('ACCL__City__c', 'testCity');
        acc.put('ACCL__Street__c', 'testStreet');
        acc.put('ACCL__Name_2__c', 'testName2');
        insert acc;
        return acc;
    }
    
    public static List<sobject> insertBulkAccounts(Integer noOfAcc) {
        List<sObject> accList = new List<sObject>();
        for(Integer i=0; i<noOfAcc; i++) {
            sObject acc = allObjMetaType.get('Account').newSObject();
            acc.put('Name', 'testName'+i);
            acc.put('ACCL__City__c', 'testCity');
            acc.put('ACCL__Street__c', 'testStreet');
            acc.put('ACCL__Name_2__c', 'testName2'+i);
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
    
    public static sobject getDefaultPromotionTemplate() {
        sObject promTemp = allObjMetaType.get('ACCL__Promotion_Template__c').newSObject();
        promTemp.put('Name', 'testName');
        promTemp.put('ACCL__Description_Language_1__c', 'testDesc');
        promTemp.put('ACCL__Active__c', true);
        promTemp.put('ACCL__Active_Policy__c', true);
        promTemp.put('ACCL__Consider_Listing__c', true);
        promTemp.put('ACCL__Creation_Platform__c', 'Laptop');
        promTemp.put('ACCL__Display_In_call__c', true);
        promTemp.put('ACCL__Mobility_Color__c', 'White');
        promTemp.put('ACCL__Sort__c', 1);
        promTemp.put('ACCL__Promotion_Type__c', 'Promotion');
        promTemp.put('ACCL__Product_Definition_Level__c', 'Tactic');
        promTemp.put('ACCL__Product_Definition_Policy__c', 'Dynamic');
        promTemp.put('ACCL__Is_Derivable__c', false);
        promTemp.put('ACCL__Anchor_Type__c', 'Customer');
        insert promTemp;
        return promTemp;
    }
    
    public static List<sobject> getDefaultPromotion(Integer noOfProm, sObject promTemp, sObject acc, String promPhase) {
        List<sObject> promList = new List<sObject>();
        Date dateFrom = System.today();
        Date dateThru = System.today().addYears(1);
        for(Integer i=0; i<noOfProm; i++) {
            sObject prom = allObjMetaType.get('ACCL__Promotion__c').newSObject();
            prom.put('ACCL__Active__c', true);
            prom.put('ACCL__Anchor_Account__c', acc != null ? acc.Id : null);
            prom.put('ACCL__Commit_Date__c', dateFrom);
            prom.put('ACCL__Promotion_Template__c', promTemp != null ? promTemp.Id : null);
            prom.put('ACCL__Date_From__c', dateFrom);
            prom.put('ACCL__Date_Thru__c', dateThru);
            prom.put('ACCL__Delivery_Date_From__c', dateFrom);
            prom.put('ACCL__Delivery_Date_Thru__c', dateFrom.addDays(30));
            prom.put('ACCL__Order_Date_From__c', dateFrom);
            prom.put('ACCL__Order_Date_Thru__c', dateThru);
            prom.put('ACCL__Placement_Date_From__c', dateFrom);
            prom.put('ACCL__Placement_Date_Thru__c', dateThru);
            prom.put('ACCL__Slogan_Language_1__c', 'testSlogan'+i);
            prom.put('ACCL__Phase__c', promPhase);
            prom.put('ACCL__Relevant_For_Account_Plan__c', true);
            promList.add(prom);
        }
        insert promList;
        return promList;
    }
    
    public static sobject getDefaultPromotion(sObject acc, Date dateFrom, Date dateThru, String promPhase) {
        sObject prom = allObjMetaType.get('ACCL__Promotion__c').newSObject();
        prom.put('ACCL__Active__c', true);
        prom.put('ACCL__Anchor_Account__c', acc != null ? acc.Id : null);
        prom.put('ACCL__Commit_Date__c', dateFrom);
        //prom.put('ACCL__Promotion_Template__c', promTemp != null ? promTemp.Id : null);
        prom.put('ACCL__Date_From__c', dateFrom);
        prom.put('ACCL__Date_Thru__c', dateThru);
        prom.put('ACCL__Delivery_Date_From__c', dateFrom);
        prom.put('ACCL__Delivery_Date_Thru__c', dateFrom.addDays(30));
        prom.put('ACCL__Order_Date_From__c', dateFrom);
        prom.put('ACCL__Order_Date_Thru__c', dateThru);
        prom.put('ACCL__Placement_Date_From__c', dateFrom);
        prom.put('ACCL__Placement_Date_Thru__c', dateThru);
        prom.put('ACCL__Slogan_Language_1__c', 'testSlogan');
        prom.put('ACCL__Phase__c', promPhase);
        prom.put('ACCL__Relevant_For_Account_Plan__c', true);
        insert prom;
        return prom;
    }
    
    public static sobject getDefaultPromotion(sObject acc, sObject promTemp, Date dateFrom, Date dateThru, String promPhase) {
        sObject prom = allObjMetaType.get('ACCL__Promotion__c').newSObject();
        prom.put('ACCL__Active__c', true);
        prom.put('ACCL__Anchor_Account__c', acc != null ? acc.Id : null);
        prom.put('ACCL__Commit_Date__c', dateFrom);
        prom.put('ACCL__Promotion_Template__c', promTemp.Id);
        prom.put('ACCL__Date_From__c', dateFrom);
        prom.put('ACCL__Date_Thru__c', dateThru);
        prom.put('ACCL__Delivery_Date_From__c', dateFrom);
        prom.put('ACCL__Delivery_Date_Thru__c', dateFrom.addDays(30));
        prom.put('ACCL__Order_Date_From__c', dateFrom);
        prom.put('ACCL__Order_Date_Thru__c', dateThru);
        prom.put('ACCL__Placement_Date_From__c', dateFrom);
        prom.put('ACCL__Placement_Date_Thru__c', dateThru);
        prom.put('ACCL__Slogan_Language_1__c', 'testSlogan');
        prom.put('ACCL__Phase__c', promPhase);
        prom.put('ACCL__Relevant_For_Account_Plan__c', true);
        insert prom;
        return prom;
    }
    
    public static sObject insertFlattenAccountHierarchy(sObject childAccount, sObject parentAccount) {
        sObject level1 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        level1.put('ACCL__Account__c', parentAccount.Id);
        level1.put('ACCL__Account_Level_01__c', parentAccount.Id);
        level1.put('ACCL__Node_Level__c', 1);
        level1.put('ACCL__Result_Level__c', 'Store;Trade Org');
        level1.put('ACCL__ExternalID__c', 'ExternalId');
        
        sObject level2 = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').newSObject();
        level2.put('ACCL__Account__c', childAccount.Id);
        level2.put('ACCL__Account_Level_01__c', parentAccount.Id);
        level2.put('ACCL__Account_Level_02__c', childAccount.Id);
        level2.put('ACCL__Node_Level__c', 2);
        level2.put('ACCL__Result_Level__c', 'Store');
        level2.put('ACCL__ExternalID__c', 'ExternalId');
        
        insert level1;
        insert level2;
        return level1;
    }
 
 }