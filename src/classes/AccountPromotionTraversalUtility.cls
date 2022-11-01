/**  PROGRAM NAME : PromotionAccountTraversalUtility  
* This class is used for finding node level child accounts that is accounts having no child records 
* it goes maximum upto 7 level and if don't find node level account at the 7th level then it add those in final list

*/
public class AccountPromotionTraversalUtility {
    //private String txId;
    private static final Type classType = AccountPromotionTraversalUtility.class;
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    
    public AccountPromotionTraversalUtility() {         
    }
    
        
    /**Returning set of node account Ids for each Promotion record
*  @name getValidAccountID 
*  @param Promotion__c
*  @return Set<Id> accountIds
*/
    public Set<Id> getValidAccountID(sObject promotion) {
        Set<Id> finalAccountIdSet = new Set<Id>();
        //LogTrace traceHandle;
       try {
            //traceHandle = LoggerUtility.enterMethod(txId, classType, 'MethodName', LogTrace.SOURCETYPE.Others, new String[] { FormatLogResult.getResult(new List<Promotion__c>{promotion})});
            // get all available fields of Flatten_Account_Hierarchy__c
            Map<String, Schema.SObjectField> flattenAccountHierarchyFields = allObjMetaType.get('ACCL__Flatten_Account_Hierarchy__c').getDescribe().fields.getMap();
            Set<String> flattenAccountHierarchyFieldAPINames = flattenAccountHierarchyFields.keySet();
            List<String> fieldsList = new List<String>(flattenAccountHierarchyFieldAPINames);
            String query = 'SELECT ';
            for (Integer i = 0; i < fieldsList.size() - 1; i++) {
                query += fieldsList[i] + ', ';
            }
            query += fieldsList[fieldsList.size() - 1] + ' ';
            query += 'FROM '+ns+'Flatten_Account_Hierarchy__c ';
            String queryAnchorCond = 'WHERE '+ns+'Account__c = \'' + promotion.get(ns+'Anchor_Account__c') + '\' ';
            // get the Flatten_Account_Hierarchy__c records where anchor account == Account__c
			//Seond_Order_SOQL_SOSL_Injection - False Positive
			//The values are retrieved from sObject instance passed. Fields of sObject are retrieved using Metadata API within Salesforce server so no user interaction possible
            List<sObject> flattenAccountHierarchyAnchorList = Database.query(query + queryAnchorCond);
            if (flattenAccountHierarchyAnchorList.size() == 0) {
                finalAccountIdSet.add((ID)promotion.get(ns+'Anchor_Account__c'));
            }
            else {
                // get all Flatten_Account_Hierarchy__c records (children) where the anchor account is parent
                sObject flattenAccountHierarchyAnchorRecord = flattenAccountHierarchyAnchorList[0];
                String anchorAccountLevel;
                if ((Decimal)flattenAccountHierarchyAnchorRecord.get(ns+'Node_Level__c') < 10) {
                    anchorAccountLevel = ns+'Account_Level_0' + (Decimal)flattenAccountHierarchyAnchorRecord.get(ns+'Node_Level__c') + '__c';

                }
                else {
                    anchorAccountLevel = ns+'Account_Level_' + (Decimal)flattenAccountHierarchyAnchorRecord.get(ns+'Node_Level__c') + '__c';

                }
                String queryListCond = 'WHERE ' + anchorAccountLevel + ' = \'' + promotion.get(ns+'Anchor_Account__c') + '\' ';
                List<sObject> flattenAccountHierarchyList = Database.query(query + queryListCond);
                // only add accounts to the result set for which Result_Level__c contains the value 'Store'
                List<String> resultLevelList = new List<String>();
                for (sobject item : flattenAccountHierarchyList) {
                    //resultLevelList = String.valueof(item.get(ns+'Result_Level__c')).split(';');
                    string temp = (String)item.get(ns+'Result_Level__c');
                    resultLevelList = temp.split(';');
                    if (resultLevelList.contains('Store')) {
                        finalAccountIdSet.add((ID)item.get(ns+'Account__c'));
                    }
                }
            }
        
        }catch(Exception ex) {
           System.debug('Exception : '+ex);
        } 
        return finalAccountIdSet;
    }
}