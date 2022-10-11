/**  PROGRAM NAME : PicklistAttributesCleanupInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     *  This class returns all the Picklist Repository records
     * @see    PicklistAttributesCleanupBatch
     * @version  1.0
     * @Created Date 2018-03-19
*/
public class PicklistAttributesCleanupInputView {
  
    private static final string ns = AddOnConstants.NAMESPACEPREFIX; 
        
    @TestVisible
    private static String query ='SELECT Id,Name,{0}Object__c,{0}Field__c,{0}Sales_Org__c,{0}Picklist_Value__c'
                                +' FROM {0}Picklist_Repository__c';                              
    
    public Database.QueryLocator getObjectDataReader(){
        query = String.format(query, new List<String>{ns}); 
        system.debug('Query**'+query);        
        return Database.getQueryLocator(query);
    }
}