/**  PROGRAM NAME : PicklistAttributesMappingInputView 
     * This class is used for preparing the query locator that will determine the scope of the batch.
     *  This class returns all the Picklist Toggle Mapping records where CASDomain__c is not equals to null
     * @see    PicklistAttributesMappingBatch
     * @version  1.0
     * @Created Date 2018-02-20 
*/
public class PicklistAttributesMappingInputView {
  
    private static final string ns = AddOnConstants.NAMESPACEPREFIX; 
        
    @TestVisible
    private static String query ='SELECT Id,Name,{0}Object__c,{0}Field__c,{0}CASDomain__c,{0}Has_Empty_Item__c'
                                +' FROM {0}Picklist_Toggle_Mapping__c';
                               // +' WHERE {0}CASDomain__c != NULL LIMIT 1';
    //system.debug('Query**'+ query);
    public Database.QueryLocator getObjectDataReader(){
        query = String.format(query, new List<String>{ns}); 
        system.debug('Query**'+query);        
        return Database.getQueryLocator(query);
    }
}