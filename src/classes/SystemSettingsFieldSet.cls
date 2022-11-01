/**
 * This class is able to transform the fieldsets of some product into sets of system
 * settings.
 *
 * @see SystemSettingsFieldSetFilterCriteria
 */

public class SystemSettingsFieldSet {
    private static final Integer MAX_LENGTH = 150;

    private String prefix;
    private Map<String, List<String>> fieldSetRecords = new Map<String, List<String>>();

    public SystemSettingsFieldSet(String baseClass, String fieldSetRoot) {
        this.prefix = baseClass + '_' + fieldSetRoot + '_';
    }

    private Integer getSalesOrgLength(String salesorg) {
        List<String> fieldSetRecord = this.fieldSetRecords.get(salesorg);
        return fieldSetRecord != null ? fieldSetRecord.size() : -1;
    }

    private List<String> getFieldSetRecordsForSalesOrg(String salesOrg, Boolean insertMissing) {
        List<String> fieldSetRecordsForSalesOrg = this.fieldSetRecords.get(salesorg);
        if (fieldSetRecordsForSalesOrg == null) {
            fieldSetRecordsForSalesOrg = new List<String>();
            if (insertMissing) {
                fieldSetRecordsForSalesOrg.add('');
            }
            fieldSetRecords.put(salesOrg, fieldSetRecordsForSalesOrg);
        }

        return fieldSetRecordsForSalesOrg;
    }

    public void addField(String salesOrg, String field) {
        if (salesOrg == null) {
            salesOrg = '';
        }

        List<String> recordsForSalesOrg = this.getFieldSetRecordsForSalesOrg(salesOrg, true);
        Integer lastRecordIndex = recordsForSalesOrg.size() - 1;
        if (recordsForSalesOrg[lastRecordIndex].length() + field.length() + 1 < MAX_LENGTH) {
            recordsForSalesOrg[lastRecordIndex] = recordsForSalesOrg[lastRecordIndex] + field + ',';
        } else {
            recordsForSalesOrg.add(field + ',');
        }
    }

    public List<ACCL__System_Setting__c> toSystemSettings() {
        List<ACCL__System_Setting__c> records = new List<ACCL__System_Setting__c>();

        for (String salesOrg : this.fieldSetRecords.keySet()) {
            List <String> recordsForSalesOrg = this.getFieldSetRecordsForSalesOrg(salesOrg, false);
            for (Integer i = 0; i < recordsForSalesOrg.size(); i++) {
                String name = this.prefix +
                    (String.isEmpty(salesOrg) ? '' : salesOrg + '_') +
                    (i + 1);

                String value = recordsForSalesOrg[i];
                // remove last comma
                if (i == recordsForSalesOrg.size() - 1) {
                    value = value.left(value.length() - 1);
                }

                records.add(new ACCL__System_Setting__c(Name = name, ACCL__Description__c = name, ACCL__Value__c = value));
            }
        }

        return records;
    }

    public String getPrefix() {
        return this.prefix;
    }
}