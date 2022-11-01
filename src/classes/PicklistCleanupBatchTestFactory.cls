/**  PROGRAM NAME : PicklistCleanupBatchTestFactory 
     * This class is to create test data for batch class.
     * @version  1.0
*/

@isTest
public class PicklistCleanupBatchTestFactory {
    private static string ns = AddOnConstants.NAMESPACEPREFIX;
    public static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    /*********** Data creation for Objects****************/
    
    /**This function is for inserting Picklist Toggle Mapping related Data
    *  @name insertPicklistTogglemapping
    *  @param null
    *  @return sObject(Picklist_Toggle_Mapping__c)
    */     
    public static sObject getDefaultPicklistToggleMapping() {
        sObject sObj = allObjMetaType.get(ns+'Picklist_Toggle_Mapping__c').newSObject() ;
        sObj.put(ns+'CASDomain__c','DomCssFilterType');
        sObj.put(ns+'Field__c','TestValue');
        sObj.put(ns+'Object__c','Account');  
        sObj.put(ns+'HasChildren__c',false);     
        return sObj;
    }
    /**This function is for inserting Picklist Toggle Mapping related Data
    *  @name getDefaultPicklistRepository
    *  @param null
    *  @return sObject(Picklist_Repository__c)
    */     
    public static sObject getDefaultPicklistRepository() {
        sObject sObj = allObjMetaType.get(ns+'Picklist_Repository__c').newSObject() ;
        sObj.put(ns+'CASDomain__c','DomCssFilterType');
        sObj.put(ns+'Field__c','TestField');
        sObj.put(ns+'Object__c','Account');  
            
        return sObj;
    }
    /**This function is for inserting Picklist Toggle Mapping related Data
    *  @name insertPicklistTogglemapping
    *  @param null
    *  @return sObject(Picklist_Toggle_Mapping__c)
    */     
    public static sObject getDefaulPicklistToggleMappingExt(String shortText1, String casCode, sObject parentMapping,  String picklistValue) {        
        sObject sObj = allObjMetaType.get(ns+'Picklist_Toggle_Mapping_Extension__c').newSObject() ;
        sObj.put(ns+'ShortText_Language_1__c',shortText1);
        sObj.put(ns+'CasCode__c',casCode);
        sObj.put(ns+'ParentPicklist__c',parentMapping.Id);  
        sObj.put(ns+'Picklist_Value__c',picklistValue);     
        return sObj;
    }
    /**************** Data creation for custom settings***********************/
    /**This function is for inserting Batch Process configuration Data
    *  @name insertBatchProcessConfig
    *  @param null
    *  @return sObject(Batch_Process_Configuration__c)
    */  
    public static sObject insertBatchProcessConfig() {
        sObject sObj = allObjMetaType.get(ns+'Batch_Process_Configuration__c').newSObject();
        sObj.put('Name',AddOnConstants.PICKLIST_ATTRIBUTES_CLEANUP);
        sObj.put(ns+'Batch_Size__c',100);
        insert sObj;
        return sObj;
    }
   
}