public class AddOnTestFactoryUtility {

    public static List<String> getFieldsOfObject(SObjectType objectType) {

        List<String> fieldNames = new List<String>();
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : objectFields.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if(fieldType != Schema.DisplayType.LOCATION && fieldType != Schema.DisplayType.ADDRESS) {
                fieldNames.add(fieldDescribe.getName());
            }
        }

        return fieldNames;
    }

    public static Map<String, Object> parseSObject(SObject objectToParse, Integer objectStatus) {

        return parseSObject(objectToParse.Id.getSObjectType(), objectToParse, objectStatus);
    }

    public static Map<String, Object> parseSObject(SObjectType objectType, SObject objectToParse, Integer objectStatus) {

        Map<String, Object> parseObject = new Map<String, Object>();

        for (String fieldName : getFieldsOfObject(objectType)) {
            Object value = objectToParse.get(fieldName);
            if (value != null) {
                parseObject.put(fieldName, value);
            }
        }

        if (objectStatus != null) {
            parseObject.put('__ObjectStatus', objectStatus);
        }

        return parseObject;
    }

    public static List<Map<String, Object>> parseListSObject(SObjectType objectType, List<SObject> objectsToParse, Integer objectStatus) {

        List<Map<String, Object>> parseObject = new List<Map<String, Object>>();

        for (SObject objectToParse: objectsToParse) {
            parseObject.add(parseSObject(objectType, objectToParse, objectStatus));
        }
        return parseObject;
    }

    public static List<Map<String, Object>> parseListSObject(List<SObject> objectsToParse, Integer objectStatus) {

        List<Map<String, Object>> parseObject = new List<Map<String, Object>>();

        for (SObject objectToParse: objectsToParse) {
            parseObject.add(parseSObject(objectToParse, objectStatus));
        }
        return parseObject;
    }

    public static Map<String, Object> parseLOFund(ACCL__Fund__c fund, List<ACCL__Tactic__c> tactics) {

        Map<String, Object> fundObj = new  Map<String, Object>();
        fundObj.put('Id', fund.Id);

        List<Map<String, Object>> tacticsFund = new List<Map<String, Object>>();
        for (ACCL__Tactic__c tactic: tactics) {
            Map<String, Object> tacticFundObj = new Map<String, Object>();
            tacticFundObj.put('tacticId', tactic.Id);
            tacticsFund.add(tacticFundObj);
        }
        fundObj.put('tactics', tacticsFund);

        return fundObj;
    }

    public static List<Map<String, Object>> parseLOExtPromotionCategoryShare(List<ACCL__Product__c> includedProducts, List<ACCL__Product__c> excludedProducts) {
        List<Map<String, Object>> loExtPromotionCategoryShare = new List<Map<String, Object>>();

        for (ACCL__Product__c includedProduct: includedProducts) {
            Map<String, Object> productObject = new Map<String, Object>();
            productObject.put('Id', includedProduct.Id);
            productObject.put('Selected', true);
            productObject.put('Enabled', true);
            productObject.put('Label', includedProduct.Name);
            loExtPromotionCategoryShare.add(productObject);
        }

        for (ACCL__Product__c excludedProduct: excludedProducts) {
            Map<String, Object> productObject = new Map<String, Object>();
            productObject.put('Id', excludedProduct.Id);
            productObject.put('Selected', true);
            productObject.put('Enabled', true);
            productObject.put('Label', excludedProduct.Name);
            loExtPromotionCategoryShare.add(productObject);
        }

        return loExtPromotionCategoryShare;
    }

    public static Map<String, Object> parseBOPromotion(ACCL__Promotion__c promotion, List<Map<String, Object>> loExtPromotionCategoryShare, List<Map<String, Object>> loExtPromotionAttachment,
                                                       List<Map<String, Object>> loTactic, List<Map<String, Object>> loFund, String target) {
        Map<String, Object> BOPromotion = new Map<String, Object>();

        Map<String, Object> promotionObject = new Map<String, Object>();
        promotionObject.putAll(parseSObject(promotion, null));

        if (loExtPromotionCategoryShare != null) {
            promotionObject.put('LOExtPromotionCategoryShare', loExtPromotionCategoryShare);
        } else {
            promotionObject.put('LOExtPromotionCategoryShare', new List<Map<String, Object>>());
        }

        if (loExtPromotionAttachment != null) {
            promotionObject.put('LOExtPromotionAttachment', loExtPromotionAttachment);
        } else {
            promotionObject.put('LOExtPromotionAttachment', new List<Map<String, Object>>());
        }

        if (loTactic != null) {
            promotionObject.put('LOTactic', loTactic);
        } else {
            promotionObject.put('LOTactic', new List<Map<String, Object>>());
        }

        if (loFund != null) {
            promotionObject.put('LOFund', loFund);
        } else {
            promotionObject.put('LOFund', new List<Map<String, Object>>());
        }

        BOPromotion.put('BOPromotion', promotionObject);
        BOPromotion.put('target', target);
        return BOPromotion;
    }
	//Bulkify_Apex_methods_Using_Collections_In_Methods - False Positive
	//This is a utility method designed to handle one sObject record at a time.
    public static SObject insertSObject(SObject objectInserted) {
       insert objectInserted;
       return readSObject(objectInserted);
    }

    public static List<SObject> insertBulkSObject(List<SObject> listObjects) {
        insert listObjects;
        return readBulkSObject(listObjects);
    }

    public static SObject readSObject(SObject objectInserted) {

        SObject queryResult;

        if (objectInserted!=null) {
            Id idObject = objectInserted.Id;
            SObjectType objectType = idObject.getSObjectType();
            String query = 'SELECT ' + string.join(getFieldsOfObject(objectType), ',') + ' FROM ' + objectType + ' WHERE Id = :idObject LIMIT 1 ';

            List<SObject> queryResults = Database.query(query);
            if (!queryResults.isEmpty()) {
                queryResult = queryResults[0];
            }
        }

        return queryResult;
    }

    public static List<SObject> readBulkSObject(List<SObject> listObjects) {

        List<SObject> queryResult = new List<SObject>();

        if (listObjects!= null && !listObjects.isEmpty()) {
            Set<SObjectType> objectTypes = new Set<SObjectType>();
            for (SObject obj: listObjects) {
                objectTypes.add(obj.Id.getSObjectType());
            }
            for (SObjectType objectType: objectTypes) {
                String query = 'SELECT ' + string.join(getFieldsOfObject(objectType), ',') + ' FROM ' + objectType + ' WHERE Id IN :listObjects';
                queryResult.addAll(Database.query(query));
            }

        }
        return queryResult;
    }
}