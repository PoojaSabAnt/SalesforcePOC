/**
 * Migrate the filtercriteria field set as a series of system settings.
 * Each record will have:
 * - Names like Product_FilterCriteria_1, Product_FilterCriteria_2,
 * Product_FilterCriteria_0001_1, Product_FilterCriteria_0001_2, ...
 * - Value as the list of fields separated by ,
 * - A maximum of 150 characters
 *
 * The migration is executed as SystemSettingsFieldSetFilterCriteria.createProductFilterSettings
 */
public class SystemSettingsFieldSetFilterCriteria {
    private static final String BASE_OBJ = 'Product';
    private static final String BASE_FIELD = 'FilterCriteria';

    public static void createProductFilterSettings() {

        Map<String, FieldSet> fieldSets = ACCL__Product__c.sObjectType.getDescribe().fieldSets.getMap();
        Map<String, List<List<String>>> fieldSetsFields = new Map<String, List<List<String>>>();

        SystemSettingsFieldSet records = new SystemSettingsFieldSet(BASE_OBJ, BASE_FIELD);
        // Get all the FilterCriteria fieldsets
        for (String fieldSetName: fieldSets.keySet()) {
            System.debug('FieldSetName: ' + fieldSetName);
            if (fieldSetName.startsWithIgnoreCase('filtercriteria') || fieldSetName.containsIgnoreCase('_filtercriteria')) {
                System.debug('Accepted: '  + fieldSetName);

                FieldSet fieldSet = fieldSets.get(fieldSetName);
                String salesOrg = getSalesOrgFromFieldSetName(fieldSetName);

                for (Schema.FieldSetMember field : fieldSet.getFields()) {
                    String fieldPath = field.getFieldPath();
                    System.debug('fieldPath: ' + fieldPath);

                    // Fields have to be of the object.
                    // Paths over references are not allowed at the moment
                    if (fieldPath.contains('.')) {
                        continue;
                    }

                    System.debug(String.format('Adding {1} to sales org {0}', new List<String> {salesOrg, fieldPath}));
                    records.addField(salesOrg, fieldPath);
                }
            }
        }

        insertProductFilterSettings(records, records.getPrefix());
    }

    private static void insertProductFilterSettings(SystemSettingsFieldSet records, String prefix) {
        System.debug('Insert ProductFilterSettings');
        Savepoint saveProductFilterSettings = Database.setSavepoint();

        try {
            String likeString = prefix + '%';
            List<ACCL__System_Setting__c> existingSystemSettings = [SELECT Id FROM ACCL__System_Setting__c WHERE Name LIKE :likeString];

            // Clean existing settings
            Database.delete(existingSystemSettings);
            Database.insert(records.toSystemSettings());
        } catch (DMLException ex) {
            System.debug(LoggingLevel.ERROR, ex);
            Database.rollback(saveProductFilterSettings);
        }
    }

    private static String getSalesOrgFromFieldSetName(String fieldSetName) {
        return fieldSetName.toLowerCase().substringAfterLast(BASE_FIELD.toLowerCase() + '_');
    }
}