@isTest
public class AddOnKPIDefinitionTestFactory {
    public static ACCL__KPI_Definition__c buildKpiDefinitionNoInsert(Integer size) {

	ACCL__KPI_Definition__c kpi= new ACCL__KPI_Definition__c();
	Map<String, Id> mapProductTemplateRecordTypesByDeveloperName=AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);

	kpi.Name = 'KpiDefaultDefinition' + size;
	kpi.ACCL__Description_Language_1__c = 'KpiDefaultDescription' + size;
	kpi.ACCL__Display_Round__c= 2;
	kpi.RecordTypeId = mapProductTemplateRecordTypesByDeveloperName.get('calculated');
	kpi.ACCL__Storage_Options_Storage_Levels__c = 'Product';
	kpi.ACCL__Storage_Options_Measure_Code__c = 'C' + size;
	kpi.ACCL__Storage_Options_Writeback__c = true;
    kpi.ACCL__Storage_Options_Table_Name__c = 'weeklypromotionmeasureresult';
    kpi.ACCL__Storage_Options_Monthly_Table_Name__c = 'monthlypromotionmeasureresult';
	kpi.ACCL__Formula__c= 'Manual';
    kpi.ACCL__Scope__c = 'account';
    kpi.ACCL__Aggregation_Merge_Rule__c = 'sum';

    return kpi;
    }

    public static ACCL__KPI_Definition__c buildKpiDefinition(Integer size) {
        ACCL__KPI_Definition__c kpi = buildKpiDefinitionNoInsert(size);

	insert kpi;
	return kpi;
    }

    public static ACCL__KPI_Set__c insertdefaultKpiSetRecord(Integer nameSuffix, String Configuration, String Language, String Usage) {

        ACCL__KPI_Set__c kpisetField = new ACCL__KPI_Set__c();
        kpisetField.Name = 'test'+ nameSuffix;
        kpisetField.ACCL__Configuration__c = Configuration;
        kpisetField.ACCL__Description_Language_1__c = Language;
        kpisetField.ACCL__Usage__c = Usage;
        kpisetField.ACCL__Child_Object_Dependency__c = true;

        insert kpisetField;
        return kpisetField;
    }

    public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordCalculatedKPI() {

        ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();
        List<String> SkippedDimensions = new List<String>();
        SkippedDimensions.add('Tactic');

        String SkpDimension = String.join(SkippedDimensions, ';');

        List<String> StorageLevels = new List<String>();
        StorageLevels.add('Product');

        String StoreLevel = String.join(StorageLevels, ';');

        Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
        kpiDefRecord.RecordTypeId = RecordTYpeMap.get('calculated');
        kpiDefRecord.Name = 'testCalculateKPI2';
        kpiDefRecord.ACCL__Aggregation_Rule__c = 'formula';
        kpiDefRecord.ACCL__Description_Language_1__c = 'English';
        kpiDefRecord.ACCL__Display_Enabled__c = true;
        kpiDefRecord.ACCL__Formula__c = 'Cons*2';
        kpiDefRecord.ACCL__Editable_Measure_Code__c = 'SHIP';
        kpiDefRecord.ACCL__Storage_Options_Measure_Code__c = 'CALC';
        kpiDefRecord.ACCL__Display_Round__c = 2;
        kpiDefRecord.ACCL__Aggregation_Skipped_Dimensions__c = SkpDimension;
        kpiDefRecord.ACCL__Storage_Options_Storage_Levels__c = StoreLevel;
        kpiDefRecord.ACCL__Scope__c = 'account';
        kpiDefRecord.ACCL__Total_Calculation_Rule__c = 'formula';
        kpiDefRecord.ACCL__Storage_Options_Writeback__c = true;
        kpiDefRecord.ACCL__Storage_Options_Table_Name__c = 'weeklypromotionmeasureresult';
        kpiDefRecord.ACCL__Storage_Options_Monthly_Table_Name__c = 'monthlypromotionmeasureresult';

        insert kpiDefRecord;
        return kpiDefRecord;

    }

    public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordEditableKPI(String DistributionID) {
        ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();
        List<String> SkippedDimensions = new List<String>();
        SkippedDimensions.add('Tactic');

        String SkpDimension = String.join(SkippedDimensions, ';');

        List<String> StorageLevels =new List<String>();
        StorageLevels.add('Product');

        String StoreLevel = String.join(StorageLevels, ';');

        Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
        kpiDefRecord.RecordTypeId = RecordTYpeMap.get('editable');
        kpiDefRecord.Name = 'testEditableKPI';
        kpiDefRecord.ACCL__Aggregation_Rule__c = 'sum';
        kpiDefRecord.ACCL__Description_Language_1__c = 'English';
        kpiDefRecord.ACCL__Distribution_Plan_Hierarchy_Dist_Metric__c = DistributionID;
        kpiDefRecord.ACCL__Distribution_Time_Hierarchy_Dist_Metric__c = DistributionID;
        kpiDefRecord.ACCL__Display_Enabled__c = true;
        kpiDefRecord.ACCL__Editable_Enable_Past_Weeks__c = true;
        kpiDefRecord.ACCL__Editable_Measure_Code__c = 'SHIP';
        kpiDefRecord.ACCL__Storage_Options_Measure_Code__c = 'EDIT';
        kpiDefRecord.ACCL__Display_Round__c = 2;
        kpiDefRecord.ACCL__Scope__c = 'account';
        kpiDefRecord.ACCL__Aggregation_Skipped_Dimensions__c = SkpDimension;
        kpiDefRecord.ACCL__Storage_Options_Storage_Levels__c = StoreLevel;
        kpiDefRecord.ACCL__Total_Calculation_Rule__c = 'sum';
        kpiDefRecord.ACCL__Storage_Options_Writeback__c = true;
        kpiDefRecord.ACCL__Storage_Options_Table_Name__c = 'weeklypromotionmeasureresult';
        kpiDefRecord.ACCL__Storage_Options_Monthly_Table_Name__c = 'monthlypromotionmeasureresult';

        insert kpiDefRecord;
        return kpiDefRecord;

    }

    //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
    Public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordEditableCalculatedKPI(String DistributionID) {
        ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();
        List<String> SkippedDimensions = new List<String>();
        SkippedDimensions.add('Tactic');

        String SkpDimension = String.join(SkippedDimensions, ';');

        List<String> StorageLevels =new List<String>();
        StorageLevels.add('Product');

        String StoreLevel = String.join(StorageLevels, ';');

        Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
        kpiDefRecord.RecordTypeId = RecordTYpeMap.get('editable_calculated');
        kpiDefRecord.Name = 'testEditableCalculatedKPI';
        kpiDefRecord.ACCL__Aggregation_Rule__c = 'sum';
        kpiDefRecord.ACCL__Description_Language_1__c = 'English';
        kpiDefRecord.ACCL__Distribution_Plan_Hierarchy_Dist_Metric__c = DistributionID;
        kpiDefRecord.ACCL__Distribution_Time_Hierarchy_Dist_Metric__c = DistributionID;
        kpiDefRecord.ACCL__Display_Enabled__c = true;
        kpiDefRecord.ACCL__Editable_Enable_Past_Weeks__c = true;
        kpiDefRecord.ACCL__Editable_Measure_Code__c = 'SHIP';
        kpiDefRecord.ACCL__Storage_Options_Measure_Code__c = 'EDIT';
        kpiDefRecord.ACCL__Display_Round__c = 2;
        kpiDefRecord.ACCL__Scope__c = 'account';
        kpiDefRecord.ACCL__Aggregation_Skipped_Dimensions__c = SkpDimension;
        kpiDefRecord.ACCL__Storage_Options_Storage_Levels__c = StoreLevel;
        kpiDefRecord.ACCL__Total_Calculation_Rule__c = 'sum';
        kpiDefRecord.ACCL__Storage_Options_Writeback__c = true;
        kpiDefRecord.ACCL__Formula__c = 'formula';
        kpiDefRecord.ACCL__Storage_Options_Table_Name__c = 'weeklypromotionmeasureresult';
        kpiDefRecord.ACCL__Storage_Options_Monthly_Table_Name__c = 'monthlypromotionmeasureresult';

        insert kpiDefRecord;
        return kpiDefRecord;

    }
	private static ACCL__KPI_Definition__c defaultKpiDefRecReadKPI;
    public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordReadKPI() {
        if(defaultKpiDefRecReadKPI == null){
        
            ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();
            List<String> SkippedDimensions = new List<String>();
            SkippedDimensions.add('Tactic');
    
            String SkpDimension = String.join(SkippedDimensions, ';');
    
            List<String> StorageLevels = new List<String>();
            StorageLevels.add('Product');
    
            String StoreLevel = String.join(StorageLevels, ';');
    
            Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
            kpiDefRecord.RecordTypeId = RecordTYpeMap.get('read');
            kpiDefRecord.Name = 'testReadKPI';
            kpiDefRecord.ACCL__Data_Source_Table_Name__c = 'accountproductmeasure';
            kpiDefRecord.ACCL__Aggregation_Rule__c = 'sum';
            kpiDefRecord.ACCL__Data_Source_Aggregation_Mode__c = 'Standard';
            kpiDefRecord.ACCL__Description_Language_1__c = 'English';
            kpiDefRecord.ACCL__Display_Enabled__c = true;
            kpiDefRecord.ACCL__Storage_Options_Measure_Code__c = 'READ';
            kpiDefRecord.ACCL__Data_Source_Measure_Code__c = 'SIHP';
            kpiDefRecord.ACCL__Display_Round__c = 2;
            kpiDefRecord.ACCL__Scope__c = 'account';
            kpiDefRecord.ACCL__Aggregation_Skipped_Dimensions__c = SkpDimension;
            kpiDefRecord.ACCL__Storage_Options_Storage_Levels__c = StoreLevel;
            kpiDefRecord.ACCL__Total_Calculation_Rule__c = 'sum';
            kpiDefRecord.ACCL__Data_Source_Week_Offset__c = 0;
            kpiDefRecord.ACCL__Storage_Options_Writeback__c = true;
            kpiDefRecord.ACCL__Storage_Options_Table_Name__c = 'weeklyaccountmeasureresult';
            kpiDefRecord.ACCL__Storage_Options_Monthly_Table_Name__c = 'monthlyaccountmeasureresult';
            insert kpiDefRecord;
            defaultKpiDefRecReadKPI = kpiDefRecord;
        }
        return defaultKpiDefRecReadKPI;

    }

    //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
    public static List<ACCL__KPI_Definition__c> buildKpiDefinitionsListNoInsert(Integer size) {
        List<ACCL__KPI_Definition__c> kpiDefinitionRecords = new List<ACCL__KPI_Definition__c>();

        for(integer i=0; i < size; i++){
            kpiDefinitionRecords.add(buildKpiDefinitionNoInsert(i));
        }
        return kpiDefinitionRecords;
    }

    //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
    Public Static List<ACCL__KPI_Definition__c> buildKpiDefinitionsList(Integer size) {
        List<ACCL__KPI_Definition__c> kpiDefnitionRecords = New List<ACCL__KPI_Definition__c>();

        for(integer i=0; i < size; i++){
            kpiDefnitionRecords.add(buildKpiDefinition(i));
        }
        return kpiDefnitionRecords;
    }

    //Test Methods With No Assert - This method creates test factory data, Assert Is Not needed - False Positive
    Public Static List<ACCL__KPI_Set_KPI_Definition__c> buildKpiSetKpiDefinitionsList(ACCL__KPI_Set__c kpiSet, List<ACCL__KPI_Definition__c> lstKpiDefintion) {
        List<ACCL__KPI_Set_KPI_Definition__c> kpiSetKpiDefnitionRecords = New List<ACCL__KPI_Set_KPI_Definition__c>();

        for(integer i=0; i < lstKpiDefintion.size(); i++){
            kpiSetKpiDefnitionRecords.add(insertKPisetKPIDefinitionRecord(String.valueOf(lstKpiDefintion[i].Id), String.valueOf(kpiSet.Id), i));
        }
        return kpiSetKpiDefnitionRecords;
    }

    public static ACCL__KPI_Set_KPI_Definition__c insertKPisetKPIDefinitionRecord(String KPITempId, String KPISetID, Integer SortId) {

        ACCL__KPI_Set_KPI_Definition__c relatedlistRecord = new ACCL__KPI_Set_KPI_Definition__c();

        relatedlistRecord.ACCL__KPI_Definition__c = KPITempId;
        relatedlistRecord.ACCL__KPI_Set__c = KPISetID;
        relatedlistRecord.ACCL__Sort__c = SortId;

        insert relatedlistRecord;
        return relatedlistRecord;
    }

	public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordCompoundKPI() {

        ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();
        Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
        kpiDefRecord.RecordTypeId = RecordTYpeMap.get('compound');

        kpiDefRecord.Name = 'testCompoundKPI';
        kpiDefRecord.ACCL__Description_Language_1__c = 'testCompoundKPI';

        insert kpiDefRecord;
        return kpiDefRecord;
    }

    public static ACCL__KPI_Definition__c defaultKpiDefinitionRecordValidation() {
        ACCL__KPI_Definition__c kpiDefRecord = new ACCL__KPI_Definition__c();

	    Map<String, Id> RecordTYpeMap = AddOnRecordTypeUtil.getRecordTypeIdsByDeveloperNameWithAllAvailableTypes(ACCL__KPI_Definition__c.sObjectType);
	    kpiDefRecord.RecordTypeId = RecordTYpeMap.get('validation');
	    kpiDefRecord.Name = 'testValidationKPI1';
	    kpiDefRecord.ACCL__Description_Language_1__c = 'English';
	    kpiDefRecord.ACCL__Validation_Level__c = 'promotion';
	    kpiDefRecord.ACCL__Validation_Value_Type__c = 'total';
	    kpiDefRecord.ACCL__Validation_Error_Message__c = 'Error_Parsng';
	    kpiDefRecord.ACCL__Formula__c = '() => {return 1;}';

	    insert kpiDefRecord;
	    return kpiDefRecord;
    }
}