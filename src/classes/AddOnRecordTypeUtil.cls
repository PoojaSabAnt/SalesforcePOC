public class AddOnRecordTypeUtil {

    private static Map<Schema.SObjectType,Map<String,Id>> recordTypesCache;

    static {
        recordTypesCache = new Map<Schema.SObjectType,Map<String,Id>>();
    }
    
    public static Id getRecordTypeId(Schema.SObjectType sObjectType, String developerName) {
        Map<String, Id> recordTypeIdCollection = getRecordTypeIdsByDeveloperName(sObjectType);
        
        if(recordTypeIdCollection.containsKey(developerName)) {
            return recordTypeIdCollection.get(developerName);
        } else {
            System.debug(LoggingLevel.WARN, 'For the Object ' + sObjectType + ' the recordTypeId for the recordType "' + developerName + '" could not be found!');
            return null;
        }
    }

    public static Map<String, Id> getRecordTypeIdsByDeveloperName( Schema.SObjectType token ) {
        Map<String, Id> developerNameToRecordTypeIdMap = recordTypesCache.get(token);
        
        if (developerNameToRecordTypeIdMap == null) {
            developerNameToRecordTypeIdMap = new Map<String, Id>();
            recordTypesCache.put(token, developerNameToRecordTypeIdMap);

        } else {
           return developerNameToRecordTypeIdMap;
        }

        Schema.DescribeSObjectResult objectDescribeResult = token.getDescribe();

        List<SObject> recordTypesForSObjectToken = getAllActiveRecordTypesForAGivenSObjectTypeToken( objectDescribeResult );

        filterOutRecordTypesUnavailableForTheRunningUser(developerNameToRecordTypeIdMap, recordTypesForSObjectToken, objectDescribeResult );

        return developerNameToRecordTypeIdMap;
    }
     /**When user is trying to get all recordtypes for Sobject(including recordtypes which are not available to user),this method will be called.
     *  @name getRecordTypeIdsByDeveloperNameWithAllAvailableTypes 
     *  @param Schema.SObjectType
     *  @return Map<String, Id> --This will contain the Developer name of recordtype and its corresponding recordtypeId for Sobject passed in Parameter.
     *  @throws Standard exceptions
     *  @author ankita.tukaram.parab@accenture.com
     */
    public static Map<String, Id> getRecordTypeIdsByDeveloperNameWithAllAvailableTypes( Schema.SObjectType token ) {
        Map<String, Id> developerNameToRecordTypeIdMap = recordTypesCache.get(token);
        
        if (developerNameToRecordTypeIdMap == null) {
            developerNameToRecordTypeIdMap = new Map<String, Id>();
            recordTypesCache.put(token, developerNameToRecordTypeIdMap);

        } else {
           return developerNameToRecordTypeIdMap;
        }

        Schema.DescribeSObjectResult objectDescribeResult = token.getDescribe();

        List<SObject> recordTypesForSObjectToken = getAllActiveRecordTypesForAGivenSObjectTypeToken( objectDescribeResult );

        for (SObject rt : recordTypesForSObjectToken) {  
                developerNameToRecordTypeIdMap.put(String.valueOf(rt.get(AddOnConstants.DEVELOPERNAME)),rt.Id);
            }
        return developerNameToRecordTypeIdMap;
    }
    private static List<SObject> getAllActiveRecordTypesForAGivenSObjectTypeToken(Schema.DescribeSObjectResult objectDescribeResult){
        List<SObject> results;
        // No CRUD/FLS as on RecordType object
        // further filter at later stage to remove RecordTypes not accessible to running user.
        try {
            results = [SELECT Id, Name, DeveloperName 
                        FROM RecordType WHERE SObjectType = :objectDescribeResult.getName() 
                            AND IsActive = TRUE];
        } catch (Exception ex) {
            results = new List<SObject>();
        }
        return results;
    }

    private static void filterOutRecordTypesUnavailableForTheRunningUser(Map<String, Id> developerNameToRecordTypeIdMap,  List<SObject> recordTypesForSObjectToken, Schema.DescribeSObjectResult objectDescribeResult ){
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = objectDescribeResult.getRecordTypeInfosByID();
        for (SObject rt : recordTypesForSObjectToken) {  
            if (recordTypeInfos.get(rt.Id).isAvailable()) {

                developerNameToRecordTypeIdMap.put(String.valueOf(rt.get('DeveloperName')),rt.Id);

            }
        }
    }

}