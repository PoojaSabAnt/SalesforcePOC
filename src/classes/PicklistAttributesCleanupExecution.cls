/**  PROGRAM NAME : PicklistAttributesCleanupExecution  
     * This class is execution class for PicklistAttributesCleanupBatch 
       processing the Picklist Repository records with batch size 200 
     * @see    PicklistAttributesCleanupBatch 
     * @version  1.0 
*/
public class PicklistAttributesCleanupExecution {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final string STRING_SPLIT = AddOnConstants.STRING_SPLIT;
    public Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes; 
    private Set<String> objNameList = new Set<String>();
    private Set<String> fieldNameList = new Set<String>(); 
    private Set<String> uniqueSet = new Set<String>();

    /**Processing product record with batch size 200 
     * @name process 
     * @param List<sObject>
     * @return void    
     */
    public void process(List<SObject> PicklistRepositiryList ) {          
        Set<String> picklistSet = new Set<String>();
        Set<String> objList = new Set<String>();
        Set<String> fieldList = new Set<String>();        
        Set<String> picvalList = new Set<String>();               
        for(sObject sobj : PicklistRepositiryList )
        {    
            string objName = (String)sobj.get(ns+'Object__c');
            String fieldname = (String)sobj.get(ns+'Field__c');             
            String picklistKey = (String)sobj.get(ns+'Object__c') +STRING_SPLIT+ (String)sobj.get(ns+'Field__c') +STRING_SPLIT+ (String)sobj.get(ns+'Picklist_Value__c');
            picklistSet.add(picklistKey);
            getPicklistValues(objName,fieldname);           
        }        
        deleteFieldFromRepoAndToggMapping(objNameList,fieldNameList);        

        for(String pic : picklistSet) {
            if(!uniqueSet.contains(pic)) {
                system.debug('**pic'+pic);
                List<String> allPickVal = pic.split(STRING_SPLIT);
                objList.add(allPickVal[0]);
                fieldList.add(allPickVal[1]);
                picvalList.add(allPickVal[2]);
            }
        }
        deleteRecFromRepositoryAndExtention(objList,fieldList,picvalList);
		// Calling Method to delete the Records if Ignore_for_Mobility__c is checked.
		deleteInvalidForMobilityPicklistRepository(PicklistRepositiryList);
    }     
    private void getPicklistValues(String objectName, String fieldName) {         
        Schema.SObjectType objType = allObjMetaType.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        if(!fieldMap.containsKey(fieldName)) {
            objNameList.add(objectName);
            fieldNameList.add(fieldName); 
        }
        else if(fieldMap.containsKey(fieldName)) {
            Schema.DescribeFieldResult describeFieldResult = fieldMap.get(fieldName).getDescribe(); 
            Schema.DisplayType fieldType = describeFieldResult.GetType(); //get field type
            if (fieldType == Schema.DisplayType.Picklist) { 
                List<Schema.PicklistEntry> pickListValues = describeFieldResult.getPickListValues();
                for (Schema.PicklistEntry a : pickListValues) {
                     String uniqueCombination = objectName +STRING_SPLIT+ fieldName +STRING_SPLIT+ a.getValue();
                     uniqueSet.add(uniqueCombination);
                } 
            }
        }         
    }
    private void deleteFieldFromRepoAndToggMapping(Set<String> objNameList,Set<String> fieldNameList) {
        if(!objNameList.isEmpty() && !fieldNameList.isEmpty()) {
            system.debug('****objNameList'+objNameList+ 'fieldNameList'+fieldNameList);
            String squery1 ='SELECT Id FROM {0}Picklist_Repository__c' +
                        +' WHERE {0}Object__c IN :objNameList AND {0}Field__c IN :fieldNameList';
            squery1 = String.format(squery1, new List<String>{ns});
            List<sObject> picklistRepoList = Database.query(sQuery1);
            //CRUD_Delete False Positive
        	//This class is a Batch Execution logic class and needs to run in System Context.
            Database.delete(picklistRepoList);  
            /************Deletion from Picklist Toggle Mapping************/
            String squery2 ='SELECT Id FROM {0}Picklist_Toggle_Mapping__c' +
                        +' WHERE {0}Object__c IN :objNameList AND {0}Field__c IN :fieldNameList';
            squery2 = String.format(squery2, new List<String>{ns});
            List<sObject> picklistToggMap = Database.query(squery2);
            system.debug('***picklist Toggle Mapp'+picklistToggMap );
            //CRUD_Delete False Positive
        	//This class is a Batch Execution logic class and needs to run in System Context.
            Database.delete(picklistToggMap); 
        }
    } 
    private void deleteRecFromRepositoryAndExtention(Set<String> objList,Set<String> fieldList,Set<String> picvalList) {
        if(!objList.isEmpty() && !fieldList.isEmpty() && !picvalList.isEmpty()) {
            String squery1 ='SELECT Id FROM {0}Picklist_Repository__c' +
                        +' where {0}Object__c IN :objList AND {0}Field__c IN :fieldList AND {0}Picklist_Value__c IN :picvalList';
            squery1 = String.format(squery1, new List<String>{ns});
            List<sObject> picklistRepoList = Database.query(sQuery1);
            //CRUD_Delete False Positive
        	//This class is a Batch Execution logic class and needs to run in System Context.
            Database.delete(picklistRepoList); 

            /****************************************/
            String extentionQuery = 'SELECT Id FROM {0}Picklist_Toggle_Mapping_Extension__c '+ 
                                'WHERE {0}parentPicklist__r.{0}Object__c IN :objList AND ' +
                                '{0}parentPicklist__r.{0}Field__c IN :fieldList AND {0}Picklist_Value__c IN :picvalList'; 
            extentionQuery  = String.format(extentionQuery, new List<String>{ns});
            List<sObject> picklistExteList = Database.query(extentionQuery);
            system.debug('**picklistExteList '+picklistExteList );
            if(!picklistExteList.isEmpty()) {
                //CRUD_Delete False Positive
        	    //This class is a Batch Execution logic class and needs to run in System Context.
                Database.delete(picklistExteList); 
            }    
        }
    }
	// Method to delete the extension Records if Ignore_for_Mobility__c is checked.
    private void deleteInvalidForMobilityPicklistRepository(List<SObject> PicklistRepositiryList) {
		Map<String, sObject> mapPicklistRepository = new Map<String, sObject>();
		Map<String, sObject> mapPicklistMappingExtension = new Map<String, sObject>();
		List<sObject> extList = new List<sObject>();
		Set<sObject> toBeRemoved = new Set<sObject>();
        //List<sObject> toBeDeleted = new List<sObject>();
		for(sObject sobj : PicklistRepositiryList ) {
		  String objName = (String)sobj.get(ns+'Object__c');
		  String fieldname = (String)sobj.get(ns+'Field__c');
		  String pickVal = (String)sobj.get(ns+'Picklist_Value__c');
		  String salesOrg = (String)sobj.get(ns+'Sales_Org__c');
		  String Key = objName+fieldname+pickVal+salesOrg;
		  mapPicklistRepository.put(key, sobj);
		}
		String extQuery = 'SELECT Id, Name, {0}ParentPicklist__r.{0}Object__c,{0}ParentPicklist__r.{0}Field__c, '
				  +'{0}Picklist_Value__c, {0}Sales_Org__c FROM {0}Picklist_Toggle_Mapping_Extension__c '
				  +'WHERE {0}Ignore_for_Mobility__c = true';
		extQuery = String.format(extQuery, new List<String>{ns});
		extList = Database.query(extQuery);
		for(sObject sobj : extList) {
		  String objName = (String)sobj.getSObject(ns+'ParentPicklist__r').get(ns+'Object__c');
		  String fieldname = (String)sobj.getSObject(ns+'ParentPicklist__r').get(ns+'Field__c');
		  String pickVal = (String)sobj.get(ns+'Picklist_Value__c');
		  String salesOrg = (String)sobj.get(ns+'Sales_Org__c');
		  String Key = objName+fieldname+pickVal+salesOrg;
		  mapPicklistMappingExtension.put(key, sobj);
       }
		for(String s : mapPicklistMappingExtension.keySet() ) {
		  if(mapPicklistRepository.keySet().contains(s)) {
			toBeRemoved.add(mapPicklistRepository.get(s));
		  }
		}
        List<sObject> toBeDeleted = new List<sObject>(toBeRemoved);
        if(!toBeDeleted.isEmpty()) {
            //CRUD_Delete False Positive
            //This class is a Batch Execution logic class and needs to run in System Context.
            Database.delete(toBeDeleted);
        }
	}
}