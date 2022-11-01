public class AddOnRecordTypeTestUtil {

    public static RecordType getRecordType(String sobjectName, String developerName) {

		//Replacing all the objects with ACCL__ commented below one
        //if (sobjectName.countMatches('__') == 1) {
        //    sobjectName = NamespaceHandler.getNameSpaceWithUnderscore() + sobjectName;
        //}
        RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :sobjectName
                AND DeveloperName = :developerName
                LIMIT 1
        ];

        return rt;
    }
}