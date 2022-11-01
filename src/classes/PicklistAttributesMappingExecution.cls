/**  PROGRAM NAME : PicklistAttributesMappingExecution  
     * This class is execution class for PicklistAttributesMappingBatch 
       processing the Picklist Toggle Mapping records with batch size 200 
     * @see    PicklistAttributesMappingBatch
     * @version  1.0
*/
public class PicklistAttributesMappingExecution  {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    public static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes; 
    public List<SelectOption> lstVal = new List<SelectOption>();
    /**Processing picklist toggle mapping records with batch size 200 
     * @name process 
     * @param List<sObject>
     * @return void     
     */
    public void process(List<SObject> PicklistToggMappingList ) {         
        List<wrapperPicklistToggle> lstWrapper = new List<wrapperPicklistToggle>();        
        getSalesOrgValues();         
        List<sObject> toRemove = new List<sObject>();         
        List<sObject> listToInsert = new List<sObject>();
        List<sObject> listToUpdate = new List<sObject>();
        if(!PicklistToggMappingList.isEmpty()) {             
            for(sObject allRemaining : PicklistToggMappingList) {
                if(allRemaining.get(ns+'CASDomain__c') != null) {
                    for(Integer i=0; i< lstVal.size();i++) {
                        lstWrapper.add(new wrapperPicklistToggle(allRemaining,lstVal[i].getValue()));    
                    }
                }
                else {
                    toRemove.add(allRemaining);
                    
                }
            }             
        }
        removeFromPicklistRepository(toRemove);
        Map<String, String> existingRecords = fillExistingRecordMap();
        Map<String, Schema.SObjectType> objMetaType = allObjMetaType; 
        Set<String> extensionKey = new Set<String>();      
        String newId = 'NEWID';
        Set<Id> uniqueSetRepositoryId = new Set<Id>();
        Set<String> uniqueSetRepositoryWithoutId = new Set<String>();
        String extentionQuery = 'SELECT Id,{0}Picklist_Value__c, {0}ShortText_Language_1__c, {0}ShortText_Language_2__c, {0}ShortText_Language_3__c,' +
                                '{0}ShortText_Language_4__c, {0}ValidationCode__c, {0}ImageId__c, {0}CasCode__c, {0}parentPicklist__c, {0}Sales_Org__c, {0}parentPicklist__r.{0}Object__c,'+ 
                                '{0}parentPicklist__r.{0}Field__c, {0}parentPicklist__r.{0}CASDomain__c, {0}parentPicklist__r.{0}Has_Empty_Item__c,' +
                                '{0}Text_Language_1__c, {0}Text_Language_2__c, {0}Text_Language_3__c, {0}Text_Language_4__c, {0}Sort__c ' +
                                'FROM {0}Picklist_Toggle_Mapping_Extension__c WHERE {0}Ignore_for_Mobility__c = false';
       
        extentionQuery = String.format(extentionQuery, new List<String>{ns});
        List<sObject> picklistExtentionList = Database.query(extentionQuery);         
        /***************************************************************************************************************/         
        for (sObject extension : picklistExtentionList ) {         
            Schema.SObjectType objType = objMetaType.get((String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Object__c'));
            if(objType != null) {             
                Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
                Schema.DescribeFieldResult describeFieldResult = fieldMap.get((String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c')).getDescribe();
                Schema.DisplayType fieldType = describeFieldResult.GetType();                 
                sObject picklistRepositoryItem = objMetaType.get(ns+'Picklist_Repository__c').newSObject() ; 

                String concatKey = (String)objType.getDescribe().getName() + (String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c') + (String)extension.get(ns+'Picklist_Value__c') + (String)extension.get(ns+'Sales_Org__c');                     
                extensionKey.add(concatKey);
               
                if (existingRecords.containsKey(concatKey)) {
                    String existingRecordId = existingRecords.get(concatKey); 
                    if(existingRecordId != newId) { //added check for filtering new records without Id
						// FLS Create,FLS Update,FLS Update Partial,FLS Create Partial - False Positve
                        // FLS check not required. Part of a Batch, will run in System Mode.
                        picklistRepositoryItem.Id = existingRecordId;  
                     }                     
                }
                else{
                    existingRecords.put(concatKey, newId);                        
                }
                Map<String, String> picklistValues = getPickListValues((String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Object__c'), (String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c'));
                if (fieldType == Schema.DisplayType.Picklist) {                      
                    picklistRepositoryItem.put(ns+'Object__c',objType.getDescribe().getName());
                    picklistRepositoryItem.put(ns+'Field__c',(String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c'));
                    picklistRepositoryItem.put(ns+'CASDomain__c',(String)extension.getSObject(ns+'ParentPicklist__r').get(ns+'CASDomain__c'));
                    picklistRepositoryItem.put(ns+'Has_Empty_Item__c',(Boolean)extension.getSObject(ns+'ParentPicklist__r').get(ns+'Has_Empty_Item__c'));
                    picklistRepositoryItem.put(ns+'Picklist_Value__c', extension.get(ns+'Picklist_Value__c'));
                    picklistRepositoryItem.put(ns+'ValidationCode__c', extension.get(ns+'ValidationCode__c'));
                    picklistRepositoryItem.put(ns+'ImageId__c', extension.get(ns+'ImageId__c'));
                    picklistRepositoryItem.put(ns+'CasCode__c', extension.get(ns+'CasCode__c'));
                    picklistRepositoryItem.put(ns+'Sales_Org__c', extension.get(ns+'Sales_Org__c'));
                    picklistRepositoryItem.put(ns+'Sort__c', extension.get(ns+'Sort__c'));
                    if(extension.get(ns+'ShortText_Language_1__c') != null) {
                        picklistRepositoryItem.put(ns+'ShortText_Language_1__c', extension.get(ns+'ShortText_Language_1__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'ShortText_Language_1__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'ShortText_Language_2__c') != null) {
                        picklistRepositoryItem.put(ns+'ShortText_Language_2__c', extension.get(ns+'ShortText_Language_2__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'ShortText_Language_2__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'ShortText_Language_3__c') != null) {
                        picklistRepositoryItem.put(ns+'ShortText_Language_3__c', extension.get(ns+'ShortText_Language_3__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'ShortText_Language_3__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                          
                    }
                    if(extension.get(ns+'ShortText_Language_4__c') != null) {
                        picklistRepositoryItem.put(ns+'ShortText_Language_4__c', extension.get(ns+'ShortText_Language_4__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'ShortText_Language_4__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'Text_Language_1__c') != null) {
                        picklistRepositoryItem.put(ns+'Text_Language_1__c', extension.get(ns+'Text_Language_1__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'Text_Language_1__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'Text_Language_2__c') != null) {
                        picklistRepositoryItem.put(ns+'Text_Language_2__c', extension.get(ns+'Text_Language_2__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'Text_Language_2__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'Text_Language_3__c') != null) {
                        picklistRepositoryItem.put(ns+'Text_Language_3__c', extension.get(ns+'Text_Language_3__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'Text_Language_3__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    if(extension.get(ns+'Text_Language_4__c') != null) {
                        picklistRepositoryItem.put(ns+'Text_Language_1__c', extension.get(ns+'Text_Language_1__c'));                             
                    }
                    else {
                        picklistRepositoryItem.put(ns+'Text_Language_4__c', picklistValues.get((String)extension.get(ns+'Picklist_Value__c')));
                           
                    }
                    //Using set for avoiding duplicate records
                    if(picklistRepositoryItem.Id != null && !uniqueSetRepositoryId.contains(picklistRepositoryItem.Id)) {
                        uniqueSetRepositoryId.add(picklistRepositoryItem.Id);
                        listToUpdate.add(picklistRepositoryItem); 
                     }
                     else if(picklistRepositoryItem.Id == null) {
                         if(!uniqueSetRepositoryWithoutId.contains((String)picklistRepositoryItem.get(ns+'Object__c') + (String)picklistRepositoryItem.get(ns+'Field__c') + (String)picklistRepositoryItem.get(ns+'Picklist_Value__c') + (String)picklistRepositoryItem.get(ns+'Sales_Org__c'))) {
                             uniqueSetRepositoryWithoutId.add((String)picklistRepositoryItem.get(ns+'Object__c') + (String)picklistRepositoryItem.get(ns+'Field__c') + (String)picklistRepositoryItem.get(ns+'Picklist_Value__c') + (String)picklistRepositoryItem.get(ns+'Sales_Org__c'));
                             listToInsert.add(picklistRepositoryItem);
                         }    
                     }
                }
            }             
        }
                                                               
        /*******************************************************************************************************************/
		//Start of PTME check
        String extentionQueryCheck = 'SELECT Id,{0}Picklist_Value__c, {0}ShortText_Language_1__c, {0}ShortText_Language_2__c, {0}ShortText_Language_3__c,' +
                                '{0}ShortText_Language_4__c, {0}ValidationCode__c, {0}ImageId__c, {0}CasCode__c, {0}parentPicklist__c, {0}Sales_Org__c, {0}parentPicklist__r.{0}Object__c,'+ 
                                '{0}parentPicklist__r.{0}Field__c, {0}parentPicklist__r.{0}CASDomain__c, {0}parentPicklist__r.{0}Has_Empty_Item__c,' +
                                '{0}Text_Language_1__c, {0}Text_Language_2__c, {0}Text_Language_3__c, {0}Text_Language_4__c, {0}Sort__c ' +
                                'FROM {0}Picklist_Toggle_Mapping_Extension__c WHERE {0}Ignore_for_Mobility__c = true';
        extentionQueryCheck = String.format(extentionQueryCheck, new List<String>{ns});
        List<sObject> PTMEList = Database.query(extentionQueryCheck); 
        Map<String, sObject> mapPTME = new Map<String, sObject>();
        for(sObject ext : PTMEList) {
            String key = (String)ext.getSObject(ns+'ParentPicklist__r').get(ns+'Object__c') + (String)ext.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c') + (String)ext.get(ns+'Picklist_Value__c') + (String)ext.get(ns+'Sales_Org__c');
			mapPTME.put(key, ext);
        }
        // Stop of PTME check
        for(wrapperPicklistToggle wr : lstWrapper) {             
            Map<String, String> picklistValues = getPickListValues((String)wr.picklistTogglemap.get(ns+'Object__c'), (String)wr.picklistTogglemap.get(ns+'Field__c'));
            for(String value : picklistValues.keySet()) {                              
                sObject picklistRepositoryItem = allObjMetaType.get(ns+'Picklist_Repository__c').newSObject() ;   
                String concatKey = (String)wr.picklistTogglemap.get(ns+'Object__c') + (String)wr.picklistTogglemap.get(ns+'Field__c') + value + wr.salesOrg;  
                if (existingRecords.containsKey(concatKey)) {                  
                    String existingRecordId = existingRecords.get(concatKey);
                    if (existingRecordId != newId ) {                            
                        picklistRepositoryItem.Id = existingRecordId;            
                    }
                    else{
                        continue;
                    }
                }                 
                if(!extensionKey.contains(concatKey)) {                                     
                    picklistRepositoryItem.put(ns+'Object__c',wr.picklistTogglemap.get(ns+'Object__c'));
                    picklistRepositoryItem.put(ns+'Field__c',wr.picklistTogglemap.get(ns+'Field__c'));
                    picklistRepositoryItem.put(ns+'CASDomain__c',wr.picklistTogglemap.get(ns+'CASDomain__c'));
                    picklistRepositoryItem.put(ns+'Has_Empty_Item__c',wr.picklistTogglemap.get(ns+'Has_Empty_Item__c'));    
                    picklistRepositoryItem.put(ns+'Picklist_Value__c',value); 
                    picklistRepositoryItem.put(ns+'Sales_org__c',wr.salesOrg);             
                    picklistRepositoryItem.put(ns+'Text_Language_1__c',picklistValues.get(value)); 
                    picklistRepositoryItem.put(ns+'Text_Language_2__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'Text_Language_3__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'Text_Language_4__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'ShortText_Language_1__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'ShortText_Language_2__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'ShortText_Language_3__c',picklistValues.get(value));
                    picklistRepositoryItem.put(ns+'ShortText_Language_4__c',picklistValues.get(value)); 
                    if(picklistRepositoryItem.Id != null && !uniqueSetRepositoryId.contains(picklistRepositoryItem.Id)) {
                        uniqueSetRepositoryId.add(picklistRepositoryItem.Id);
						// Check so no new Picklist Repository record should be created if Ignore_for_Mobility is true
                        if(!mapPTME.keySet().contains(concatKey)) {
                            listToUpdate.add(picklistRepositoryItem); 
                        }
                    }
                    else if(picklistRepositoryItem.Id == null) {
						// Check so No new Picklist Repository record should be created if Ignore_for_Mobility is true
                        if(!mapPTME.keySet().contains(concatKey)) {
                            listToInsert.add(picklistRepositoryItem);
                        }  
                    }
                   
                } 
            }  
        }                
        if(!listToInsert.isEmpty() && listToInsert.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
            try {
                 Database.insert(listToInsert,false);
            }
            catch(Exception ex) {
                    System.debug('The following exception has occurred while executing : ' + ex.getMessage());
            }
        }
        if(!listToUpdate.isEmpty() && listToUpdate.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
            try {
                 Database.update(listToUpdate,false);
            }
            catch(Exception ex) {
                    System.debug('The following exception has occurred while executing : ' + ex.getMessage());
            }
        }
        
    }
    private Map<String, String> fillExistingRecordMap() { 
        Map<String, String> compareMap = new Map<String, String>();
        String squery1 ='SELECT Id,{0}Object__c,{0}Field__c,{0}Picklist_Value__c,{0}Sales_Org__c '
                        +'FROM {0}Picklist_Repository__c';
        squery1 = String.format(squery1, new List<String>{ns});
        List<sObject> picklistRepositiryList = Database.query(sQuery1);
        for(sObject pic : picklistRepositiryList) {
            compareMap.put(((String)(pic.get(ns+'Object__c')) + (String)(pic.get(ns+'Field__c')) + (String)(pic.get(ns+'Picklist_Value__c')) + (String)(pic.get(ns+'Sales_Org__c'))),pic.Id);                 
        }         
        return compareMap;
    }
    private List<SelectOption> getSalesOrgValues() {
        if(lstVal.isEmpty()) {                      
            Schema.DescribeSObjectResult objectDescribeResult = allObjMetaType.get(ns+'Picklist_Toggle_Mapping_Extension__c').getDescribe();
            Schema.DescribeFieldResult salesOrgFieldDescription = objectDescribeResult.Fields.getMap().get(ns +'Sales_Org__c').getDescribe();
            for (Schema.Picklistentry picklistEntry : salesOrgFieldDescription.getPicklistValues()) {
                lstVal.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
            }
        }
        return lstVal ;
    }
    private Map<String, String> getPickListValues(String obj, String field) {
        Map<String, String> toReturn = new Map<String, String>();
        if(!String.isBlank(obj) && !String.isBlank(field)) {
            Schema.SObjectType objType = allObjMetaType.get(obj);
            Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult describeFieldResult = fieldMap.get(field).getDescribe();
            
            Schema.DisplayType fieldType = describeFieldResult.GetType(); //get field type
            if (fieldType == Schema.DisplayType.Picklist) { 
            
                List<Schema.PicklistEntry> pickListValues = describeFieldResult.getPickListValues();
                for (Schema.PicklistEntry value : pickListValues) {
                    toReturn.put(value.getValue(), value.getLabel());
                } 
            }
        }
        return toReturn;
                    
    }
    public class wrapperPicklistToggle {
        public sObject picklistTogglemap;
        public string salesOrg;
        
        public wrapperPicklistToggle(sObject picklistTogglemap,String salesOrg) {
            this.picklistTogglemap = picklistTogglemap;
            this.salesOrg = salesOrg;
        }
        
    
    }
    private void removeFromPicklistRepository(List<sObject> toRemove) {
        Set<String> field = new Set<String>();
        Set<String> obj = new Set<String>();        
        for (sObject itemToRemove : toRemove) {
            if (!field.contains((String)itemToRemove.get(ns+'Field__c'))) {
                field.add((String)itemToRemove.get(ns+'Field__c'));
            }
            if (!obj.contains((String)itemToRemove.get(ns+'Object__c'))) {
                obj.add((String)itemToRemove.get(ns+'Object__c'));
            }
        }         
        String squery2 = 'SELECT Id,{0}Field__c,{0}Object__c FROM {0}Picklist_Repository__c WHERE {0}Field__c IN :field AND {0}Object__c IN :obj';
        squery2 = String.format(squery2 , new List<String>{ns});
        List<sObject> toDelete = Database.query(squery2 );
        if(!toDelete.isEmpty() && toDelete.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
            try {
                      //CRUD Delete False Positive
        	         //This class is a Batch Execution logic class and needs to run in System Context.
                     Database.delete(toDelete ,false);
            }
            catch(Exception ex) {
                    System.debug('The following exception has occurred while executing : ' + ex.getMessage());
            }
        }         
    }    
    /**This method is for any finish block processing
     * @name processFinish 
     * @param empty
     * @return void
     */
    public void processFinish() {
    }
}