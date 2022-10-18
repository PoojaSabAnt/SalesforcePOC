/**  PROGRAM NAME : AccountManagerOrgUnitBasedExecution  
 * This class is execution class for AccountManagerCreationBatch
 * @see    AccountManagerBatch
 * @version  1.0 
 */
public class AccountManagerOrgUnitBasedExecution {
    private static String guid = ACCL.BatchRunStatusUtil.generateGUID();
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    private static final Type classType = AccountManagerOrgUnitBasedExecution.class;
    //Batch created account managers
    Map < Id, List < sObject >> mapAccountManagers = new Map < Id, List < sObject >> ();
    // Store the existing account managers manually created
    Map < Id, List < sObject >> mapStaticAccountManagers = new Map < Id, List < sObject >> ();
    private static final String SUBSTITUTION = AddOnConstants.SUBSTITUTION;
    Map < Id, List < sObject >> mapDiffOrgUnitAccountManagers = new Map < Id, List < sObject >> ();
    private Map < String, List < AccountOrgUnitCalculation >> mapControlOverlappings = new Map < String, List < AccountOrgUnitCalculation >> ();
    List < sObject > lInsertAccountManager = new List < sObject > ();
    Set < sObject > setAccManToDelete = new Set < sObject > ();
    public Map < Id, List < MainAccountManagerWrapper >> mapMainAccountManagerWrapper = new Map < Id, List < MainAccountManagerWrapper >> ();
    List <String > errorLogForManuallyCreatedRecords = new List<String>();
    List <String > errorLogRecords = new List<String>();
	public static Map<String,Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    public Sobjecttype accountManagerSobjecttype = allObjMetaType.get(ns+'Account_Manager__c');
     /**Processing Account Manager record with batch size 200 
     * @name process 
     * @param List<sObject>
     * @return void     
     */
	  public void process(List<SObject> orgUnitsListProcess) {
    	ACCL.LogTrace logTraceHandle; 
    	try{
	        logTraceHandle = ACCL.LoggerUtility.enterMethod(guid, classType, 'process', ACCL.LogTrace.SOURCETYPE.Batch, new String[] {String.join(orgUnitsListProcess,';')});
	        // Load required data
	        // List to populate records that will be inserted
	        if (!orgUnitsListProcess.isEmpty() && !(orgUnitsListProcess.size() > Limits.getLimitDMLRows())) {
	            //Get a map of id as key and org units wrapper as value
	            Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper = getMapOrgUnitsWrapper(orgUnitsListProcess);
                //Get all Org Unit Users related to org units processed in batch run
	            getOrgUnitUsers(mapOrgUnitsWrapper);
                //Get all Account Managers related to org units processed in batch run
	            getAccountManagers(getAccountOrgUnit(mapOrgUnitsWrapper), mapOrgUnitsWrapper.keySet());
	            for (List < sObject > l: mapAccountManagers.values()) {
	                // Ignore org units not processed in the current batch!
	                // This situation happends when several account managers are created from an account from different org units
	                for (sObject am: l) {
	                    if (!mapOrgUnitsWrapper.containsKey((Id) am.get(ns + 'Org_Unit__c'))) {
	                        continue;
	                    }
	                    mapAccountManagers.remove((Id) am.get('Id'));
	                }
	            }
	            for (OrgUnitWrapper ouw: mapOrgUnitsWrapper.values()) {
                    // Calculate Org Unit User - Account Org Unit combination
	                calculateOrgUnitWrapper(ouw);
	            }
                // Find account managers to be deleted or inserted
	            deltaDetermination(mapOrgUnitsWrapper, lInsertAccountManager, setAccManToDelete);
	            if (!setAccManToDelete.isEmpty()) {
                     //CRUD Delete False Positive
        			//This class is a Batch Execution logic class and needs to run in System Context.
	                delete New List < sObject > (setAccManToDelete);
	            }
	            if (!lInsertAccountManager.isEmpty()) {
	                insert(lInsertAccountManager); //False positive: Bulkify Apex Methods Using Collections In Methods
	            }
	        }
    	}
    	catch(Exception ex) {
            ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', 'Internal Server Error', new Map<String, Object> {'Exception' => ex});
        } finally {
            ACCL.LoggerUtility.leaveMethod(logTraceHandle, ACCL.FormatLogResult.getResult(orgUnitsListProcess));
        }    
    }
	/**
	* Method to create new customer managers based on customer and users related to an org unit.
	* @param OrgUnitWrapper ouw - org unit wrapper to be processed.
	* @return void
	*/
    public void calculateOrgUnitWrapper(OrgUnitWrapper ouw) {
        if (ouw.listOrgUnitUsersWrapper == null || ouw.listAccountOrgUnits == null) {
            // No data to evaluate
            return;
        }
        List< String> overlapFoundError = new List<String> ();
		List< String> overlapFoundErrorWithinBatch = new List<String> ();
        for (OrgUnitUserWrapper ouuw: ouw.listOrgUnitUsersWrapper) {
            for (sObject aou: ouw.listAccountOrgUnits) {
                // Calculate most restrictive date from Org Unit User - Account Org Unit combination
                Date dateFrom = maxDate((date) ouuw.orgUnitUser.get(ns + 'Valid_From__c'),
                    (date) aou.get(ns + 'Valid_From__c'));
                Date dateThru = minDate((date) ouuw.orgUnitUser.get(ns + 'Valid_Thru__c'),
                    (date) aou.get(ns + 'Valid_Thru__c'));
                if (dateFrom > dateThru) {
                    continue;
                }
                if (dateThru < System.today()) {
                    /* If Valid Thru is < date of batch run, check if any there is any Account - User - Org Unit combination existing in system.
                     Such records are not added for any misconfiguration checks*/
                    sobject perfectMatch = findOrgUnitAccManMatch((id) ouuw.orgUnitUser.get(ns + 'User__c'),
                        (id) aou.get(ns + 'Account__c'), (id) aou.get(ns + 'Org_Unit__c'));
                    if (perfectMatch == null) {
                        continue;
                    }
                }
				List < sObject > ListAccountManager = mapStaticAccountManagers.get((Id) aou.get(ns + 'Account__c'));
                // Find out manually created account managers for given Account and user combination
                List < sObject > manualCreatedAccountManagers = getAccountManagersByUser(ListAccountManager,
                    											(id) ouuw.orgUnitUser.get(ns + 'User__c'));
                // As we have a valid period, no manual records must exist.
                if (!(Boolean) aou.get(ns + 'Active__c')) {
                    // If Account org unit is not active, all related account managers are deleted if perfect manager is found
                    List<sObject> perfectMatch= findInactiveAccManPerfectMatch((id) aou.get(ns + 'Account__c'), (id) aou.get(ns + 'Org_Unit__c'));
                    if (perfectMatch != null && perfectMatch.size()>0) {
                        setAccManToDelete.addAll(perfectMatch);
                    }
                    continue;
                }
                /* Check for overlapping dates of current org unit user - account org unit combination
                 with existing account managers for given account*/
                datesOverlapped(dateFrom, dateThru, ListAccountManager,
                    (id) ouuw.orgUnitUser.get(ns + 'User__c'),
                    (id) aou.get(ns + 'Account__c'),
                    (id) aou.get(ns + 'Org_Unit__c'),(Boolean) ouuw.orgUnitUser.get(ns + 'Main__c'));
                AccountOrgUnitCalculation c = new AccountOrgUnitCalculation();
                c.accountOrgUnit = aou;
                c.dateFrom = dateFrom;
                c.dateThru = dateThru;
                c.isInValidRecord = false;
                c.isMainRecord = false;
				/* Check for overlapping dates of current org unit user - account org unit combination
                 with existing account managers(previously created batch records) for given account but different than given org units.*/
                List < sObject > diffOrgUnitAccountManagers = getAccountManagersByUser(mapDiffOrgUnitAccountManagers.get((Id) aou.get(ns + 'Account__c')),
                    										 (id) ouuw.orgUnitUser.get(ns + 'User__c'));

                List < sObject > overlappedRecords = getOverlappedRecords(dateFrom, dateThru, diffOrgUnitAccountManagers);
                if (!overlappedRecords.isEmpty()) {
                    // Delete records with overlapping

                    for (sObject existingOverlappedRecords: overlappedRecords) {
                        String errorString = 'User with Id '+ (id) ouuw.orgUnitUser.get(ns + 'User__c') +
    ' and Account ' + (Id) aou.get(ns + 'Account__C') + 
    ' having Org unit ' +  (id) existingOverlappedRecords.get(ns + 'Org_Unit__c') +
    ' is deleted as there is an overlap with Org Unit - User - Account Combination '+ (Id) aou.get(ns + 'Org_Unit__c') + ' +'+
                             (id) ouuw.orgUnitUser.get(ns + 'User__c') + ' '+  (Id) aou.get(ns + 'Account__c');
							ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'Existing Overlapped Record' => existingOverlappedRecords});
                        	overlapFoundError.add(errorString);
                    }

                    setAccManToDelete.addAll(overlappedRecords);
                    c.isOverlappedByDiffOrgUnit = true;
                }
                // Finding out perfect account manager to skip it from deletion/ updation
                c.perfectAccManMatch = findOrgUnitAccManPerfectMatch((id) ouuw.orgUnitUser.get(ns + 'User__c'),
                    (id) aou.get(ns + 'Account__c'), (id) aou.get(ns + 'Org_Unit__c'),
                    dateFrom, dateThru, (Boolean) aou.get(ns + 'Active__c'),
                    (Boolean) ouuw.orgUnitUser.get(ns + 'Main__c'),
                    (String) ouuw.orgUnitUser.get(ns + 'Management_Type__c'));
                String key = ouuw.orgUnitUser.get(ns + 'User__c') + '#' + aou.get(ns + 'Account__c');
                Id mainKey = (Id) aou.get(ns + 'Account__c');
                List < AccountOrgUnitCalculation > listCalculations = mapControlOverlappings.get(key);
                /* To find misconfiguration within current batch.Whenever there is any misconfiguration found, previous 
				record from batch is marked as invalid and new record is considered*/
                if (listCalculations != null) {
                    boolean overlapFound = false;
                    for (AccountOrgUnitCalculation alreadyCalculated: listCalculations) {
                        if (overlappedDates(dateFrom, dateThru,
                                alreadyCalculated.dateFrom, alreadyCalculated.dateThru) &&
                            !alreadyCalculated.isInValidRecord) {
                            overlapFound = true;
                            alreadyCalculated.isInValidRecord = true;
                             String errorString =  'User with Id '+ (id) ouuw.orgUnitUser.get(ns + 'User__c') +
    ' and Account ' + (Id) aou.get(ns + 'Account__C') + 
    ' having Org unit ' +  alreadyCalculated.accountOrgUnit.get(ns + 'Org_Unit__c')  +
    ' is marked as invalid as there is an overlap with Org Unit - User - Account Combination '+ (Id) aou.get(ns + 'Org_Unit__c') + ' +'+
                             (id) ouuw.orgUnitUser.get(ns + 'User__c') + ' '+  (Id) aou.get(ns + 'Account__c');
							ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'AccountOrgUnitCalculation' => alreadyCalculated});
                            overlapFoundErrorWithinBatch.add(errorString);
                        }
                    }
                    listCalculations.add(c);
                    mapControlOverlappings.put(key, listCalculations);

                } else {

                    listCalculations = new List < AccountOrgUnitCalculation > ();
                    listCalculations.add(c);
                    mapControlOverlappings.put(key, listCalculations);
                }
                /* To find misconfiguration for main records within batch. For main records, if there is any overlap found within batch
				previous record is deleted and latest record is marked as main record*/
				if ((Boolean) ouuw.orgUnitUser.get(ns + 'Main__c')) {
                        c.isMainRecord = true;
                        if (mapMainAccountManagerWrapper.containsKey(mainKey)) {
                            Boolean checkOveralappingForMainRecord = false;
                            for (MainAccountManagerWrapper checkMain: mapMainAccountManagerWrapper.get(mainKey)) {
                                if (overlappedDates(dateFrom, dateThru, checkMain.dateFrom, checkMain.dateThru)) {
                                    checkOveralappingForMainRecord = true;
                                    checkMain.dateFrom = dateFrom;
                                    checkMain.dateThru = dateThru;
                                    checkMain.orgUnit = (Id) ouuw.orgUnitUser.get(ns + 'Org_Unit__c');
                                    checkMain.User = (Id) ouuw.orgUnitUser.get(ns + 'User__c');

                                }
                            }
                            if(!checkOveralappingForMainRecord){
                                MainAccountManagerWrapper newWrapperEntry = new MainAccountManagerWrapper();
                            newWrapperEntry.dateFrom = dateFrom;
                            newWrapperEntry.dateThru = dateThru;
                            newWrapperEntry.isMain = true;
                            newWrapperEntry.orgUnit = (Id) ouuw.orgUnitUser.get(ns + 'Org_Unit__c');
                            newWrapperEntry.User = (Id) ouuw.orgUnitUser.get(ns + 'User__c');
                            List < MainAccountManagerWrapper > listWrapper = mapMainAccountManagerWrapper.get(mainKey);
                            listWrapper.add(newWrapperEntry);
                            mapMainAccountManagerWrapper.put(mainKey, listWrapper);
                            }

                        } 
                        else {
                            MainAccountManagerWrapper newWrapperEntry = new MainAccountManagerWrapper();
                            newWrapperEntry.dateFrom = dateFrom;
                            newWrapperEntry.dateThru = dateThru;
                            newWrapperEntry.isMain = true;
                            newWrapperEntry.orgUnit = (Id) ouuw.orgUnitUser.get(ns + 'Org_Unit__c');
                            newWrapperEntry.User = (Id) ouuw.orgUnitUser.get(ns + 'User__c');
                            List < MainAccountManagerWrapper > listWrapper = new List < MainAccountManagerWrapper > ();
                            listWrapper.add(newWrapperEntry);
                            mapMainAccountManagerWrapper.put(mainKey, listWrapper);
                        }
                    }
                ouuw.addAccountOrgUnitCalculation(c);
            }
        }
        // Log details in transaction and debug logs
       if(errorLogRecords != null && errorLogRecords.size()>0){
           ACCL.LoggerUtility.log(guid, LoggingLevel.WARN, 'ACCM0005', 'Overlap is detected with existing manually created records.', new Map<String, Object> {'errorLogRecords' => errorLogRecords});
       }
       if(overlapFoundError != null && overlapFoundError.size()>0){
           ACCL.LoggerUtility.log(guid, LoggingLevel.WARN, 'ACCM0001', 'Overlap is detected with existing batch records. ', new Map<String, Object> {'overlapFoundError' => overlapFoundError});
        }
        if(overlapFoundErrorWithinBatch != null && overlapFoundErrorWithinBatch.size()>0){
            ACCL.LoggerUtility.log(guid, LoggingLevel.WARN, 'ACCM0002', 'Overlap is detected within batch. ', new Map<String, Object> {'overlapFoundErrorWithinBatch' => overlapFoundErrorWithinBatch});
        }
        if(errorLogForManuallyCreatedRecords != null && errorLogForManuallyCreatedRecords.size()>0){
            ACCL.LoggerUtility.log(guid, LoggingLevel.WARN, 'ACCM0004', 'Overlap is detected with existing manually created records.', new Map<String, Object> {'errorLogForManuallyCreatedRecords' => errorLogForManuallyCreatedRecords});
        }
    }
    /**
	* Method to find  account manager matching with current customer-user-Org unit combination.
	* @param Id userId, Id accountId, Id orgUnitId
	* @return sObject - Existing matching customer maanger
	*/
    public sObject findOrgUnitAccManMatch(Id userId, Id accountId, Id orgUnitId) {
        List < sObject > lAccountManager = mapAccountManagers.get(accountId);
        if (lAccountManager == null) {
            return null;
        }
        for (sObject am: lAccountManager) {
            if (am.get(ns + 'Org_Unit__c') == orgUnitId &&
                am.get(ns + 'User__c') == userId) {
                return am;
            }
        }
        return null;
    }
	/**
	* Method to find which records to be inserted and which to be deleted.
	Also it finds a perfect account manager match so that it will not be deleted.
	* @param Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper, List < sObject > insertList,
        Set < sObject > deleteSet 
	* @return void
	*/
    public void deltaDetermination(Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper, List < sObject > insertList,
        Set < sObject > deleteSet) {
		List< String > errorLog = new List <String>();
        List < sObject > accountManagersFromCurrentOUnits = new List < sObject > ();
        for (List < sObject > l: mapAccountManagers.values()) {
            accountManagersFromCurrentOUnits.addAll(l);
        }
        for (OrgUnitWrapper ouw: mapOrgUnitsWrapper.values()) {
            if (ouw.listOrgUnitUsersWrapper == null) {
                continue;
            }
            for (OrgUnitUserWrapper ouuw: ouw.listOrgUnitUsersWrapper) {
                if (ouuw.calculations == null) {
                    continue;
                }
                Boolean doInsert;
                //Iteration over all valid accountOrgUnitCalculations
                for (AccountOrgUnitCalculation c: ouuw.calculations) {
                    doInsert = true;
                    // If perfect match is found: No insert & no delete
                    if (c.perfectAccManMatch != null && !c.isInvalidRecord) {
                        // The perfect match is removed from basket to consider.
                        Integer index = accountManagersFromCurrentOUnits.indexOf(c.perfectAccManMatch);
                        if (index > -1) {
                            doInsert = false;
                            accountManagersFromCurrentOUnits.remove(index);
                        }
                    }
                    //if record is invalid, dont insert the record
                    if (c.isInvalidRecord) {
                        doInsert = false;
                    }
                    Boolean checkMainRecord = false;
                    if (c.isMainRecord) {
                        // If main record is found,check if it is the latest main record for given account 
                        for (MainAccountManagerWrapper currentRecord: mapMainAccountManagerWrapper.get((Id) c.accountOrgUnit.get(ns + 'Account__c'))) {
                            if (
                                currentRecord.orgUnit == (Id) c.accountOrgUnit.get(ns + 'Org_Unit__c') &&
                                currentRecord.user == (Id) ouuw.orgUnitUser.get(ns + 'User__c') &&
                                overlappedDates(currentRecord.dateFrom, currentRecord.dateThru, c.dateFrom, c.dateThru)
                            ) {
                                checkMainRecord = true;
                            }
                        }
                        if (!checkMainRecord) {
                            doInsert = false;
                            if (c.perfectAccManMatch != null && !c.isInvalidRecord) { 
								String errorString = 'Current record is marked invalid as there exist another main record in overlapping timeframe. ' + 
                                ' Org Unit ID : ' +  c.accountOrgUnit.get(ns + 'Org_Unit__c') +
                                ' Customer ID : ' +  c.accountOrgUnit.get(ns + 'Account__c') +
                                ' User ID : ' + ouuw.orgUnitUser.get(ns + 'User__c');
								errorLog.add(errorString);
								ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'AccountOrgUnitCalculation' => c});
                                accountManagersFromCurrentOUnits.add(c.perfectAccManMatch);
                            }
                        }
                    }
                    if (doInsert) {
                        // CREATE ACCOUNT MANAGER
                        sObject am = accountManagerSobjecttype.newSObject();
                        am.put(ns + 'Account__c', c.accountOrgUnit.get(ns + 'Account__c'));
                        am.put(ns + 'Active__c', true);
                        am.put(ns + 'User__c', ouuw.orgUnitUser.get(ns + 'User__c'));
                        am.put(ns + 'Valid_From__c', c.dateFrom);
                        am.put(ns + 'Valid_Thru__c', c.dateThru);
                        am.put(ns + 'Org_Unit__c', ouw.orgUnit.get('Id'));
                        am.put(ns + 'Main__c', ouuw.orgUnitUser.get(ns + 'Main__c'));
                        am.put(ns + 'Management_Type__c', ouuw.orgUnitUser.get(ns + 'Management_Type__c'));
                        insertList.add(am);
                    }
                }
            }
        } //
        if(errorLog != null && errorLog.size()>0){
            ACCL.LoggerUtility.log(guid, LoggingLevel.WARN, 'ACCM0003', 'Overlap is detected.', new Map<String, Object> {'errorLog' => errorLog});
        }
        deleteSet.addAll(accountManagersFromCurrentOUnits);
    }
	/**
	* Method to find exact account manager matching with current customer-user combination.
	If current customer- user combination is inactive and there exists an customer managers record, list of all such records will be returned.
	* @param Id accountId, Id orgUnitId
	* @return List<sObject> - Existing matching customer maanger
	*/
    public List<sObject > findInactiveAccManPerfectMatch(Id accountId, Id orgUnitId) {
        List < sObject > lAccountManager = mapAccountManagers.get(accountId);
		List<sObject > inactiveAccountmanagers = new List<sObject>();
        if (lAccountManager == null) {
            return null;
        }
        for (sObject am: lAccountManager) {
            if (am.get(ns + 'Org_Unit__c') == orgUnitId ) {
                inactiveAccountmanagers.add(am);
            }
        }
		if(inactiveAccountmanagers != null && inactiveAccountmanagers.size()>0){
			return inactiveAccountmanagers;
		}
        return null;
    }
	/**
	* Method to find exact account manager matching with current customer-user combination.
	* @param Id userId, Id accountId, Id accountOrgUnitId, Date dateFrom, date dateThru,
        	 Boolean isActive, Boolean isMain, String managementType
	* @return sObject - Existing matching customer maanger
	*/
    public sObject findOrgUnitAccManPerfectMatch(Id userId, Id accountId, Id accountOrgUnitId, Date dateFrom, date dateThru,
        Boolean isActive, Boolean isMain, String managementType) {
        List < sObject > lAccountManager = mapAccountManagers.get(accountId);
        if (lAccountManager == null) {
            return null;
        }
        for (sObject am: lAccountManager) {
            if (am.get(ns + 'Account__c') == accountId &&
                am.get(ns + 'Org_Unit__c') == accountOrgUnitId &&
                am.get(ns + 'User__c') == userId &&
                am.get(ns + 'Valid_From__c') == dateFrom &&
                am.get(ns + 'Valid_Thru__c') == dateThru &&
                am.get(ns + 'Active__c') == isActive &&
                am.get(ns + 'Main__c') == isMain &&
                am.get(ns + 'Management_Type__c') == managementType) {
                return am;
            }
        }
        return null;
    }
    /**
	* Method to find if manually created  account manager is overlapping with newly created customer manager from batch.
	 This process takes list of account manager matching with current account and user combination.
	 If such manager is found, it is added to the setAccManToDelete which deletes the account managers from system and make 
	an entry in debug logs.
	* @param Date dateFrom, Date dateThru, List < sObject > lAccountManager,
                                          Id userId,Id accountId, Id orgUnitId
	* @return void
	*/
    public void datesOverlapped(Date dateFrom, Date dateThru, List < sObject > lAccountManager, Id userId,
        Id accountId, Id orgUnitId,Boolean isCurrentRecordMain) {
        if (lAccountManager != null) {
            for (sObject accountManagerRec: lAccountManager) 
			{
				if (overlappedDates(dateFrom, dateThru, (Date) accountManagerRec.get(ns + 'Valid_From__c'),
					(Date) accountManagerRec.get(ns + 'Valid_Thru__c')) )
				{
					if(userId == (Id) accountManagerRec.get(ns + 'User__c') )
					{
						setAccManToDelete.add(accountManagerRec);
						String errorString = 'Existing manually created record is deleted as there exists overlapping entry for same Account - User combination ' + 'CustomerId ' + accountId +
							' and UserID ' + userId + ' is an invalid entry due to Same Account- user combination with org unit '+ orgUnitId;
						ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'accountManagerRecord' => accountManagerRec});
						errorLogRecords.add(errorString);
					}
					if(isCurrentRecordMain && (Boolean)accountManagerRec.get(ns + 'Main__c'))
					{
						setAccManToDelete.add(accountManagerRec);
						String errorString = 'Existing manually created main record is deleted as there exists overlapping entry for same Account - User combination . ' + 'CustomerId ' + accountId +
							' and UserID ' + userId + ' is an invalid entry due to Same Account- user combination with org unit '+orgUnitId;
						ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'accountManagerRecord' => accountManagerRec});
						errorLogForManuallyCreatedRecords.add(errorString);
					}
				}
			}
		}
    }
    /**
	* Method to find if manually created Main account manager is overlapping with newly created customer manager from batch.
	 This process takes list of account manager matching with current account.
	 If such manager is found, it is added to the setAccManToDelete which deletes the account managers from system and make 
	an entry in debug logs.
	* @param Date dateFrom, Date dateThru, List < sObject > lAccountManager,
                                          Id userId,Id accountId, Id orgUnitId
	* @return void
	*/
    public void datesOverlappedMainRecord(Date dateFrom, Date dateThru, List < sObject > lAccountManager,
                                          Id userId,Id accountId, Id orgUnitId) {
        if (lAccountManager != null) {
            for (sObject accountManagerRec: lAccountManager) {
                if (overlappedDates(dateFrom, dateThru, (Date) accountManagerRec.get(ns + 'Valid_From__c'),
                        (Date) accountManagerRec.get(ns + 'Valid_Thru__c')) && (Boolean)accountManagerRec.get(ns + 'Main__c')) {
                    setAccManToDelete.add(accountManagerRec);
					String errorString = 'Existing manually created main record is deleted as there exists overlapping entry for same Account - User combination . ' + 'CustomerId ' + accountId +
                        ' and UserID ' + userId + ' is an invalid entry due to Same Account- user combination with org unit '+orgUnitId;
					ACCL.LoggerUtility.log(guid, LoggingLevel.ERROR, 'ACN_CLOUD_INTERNAL', errorString, new Map<String, Object> {'accountManagerRecord' => accountManagerRec});
                    errorLogForManuallyCreatedRecords.add(errorString);
                }
            }
        }

    }
	 /**
	* Wrapper class OrgUnitWrapper
	* Attributes- Org_Unit__c orgUnit,List<Account_Org_Unit__c> listAccountOrgUnits ,List < OrgUnitUserWrapper >
	*/
    public class OrgUnitWrapper {
        public sObject orgUnit = allObjMetaType.get(ns+'Org_Unit__c').newSobject();
        List < SObject > listAccountOrgUnits = new List < sObject > ();
        List < OrgUnitUserWrapper > listOrgUnitUsersWrapper = new List < OrgUnitUserWrapper > ();

        public void addOrgUnitUserWrapper(OrgUnitUserWrapper ouuw) {
            if (listOrgUnitUsersWrapper == null) {
                listOrgUnitUsersWrapper = new List < OrgUnitUserWrapper > ();
            }
            listOrgUnitUsersWrapper.add(ouuw);
        }

        public void addAccountOrgUnit(Sobject aou) {
            if (listAccountOrgUnits == null) {
                listAccountOrgUnits = new List < SObject > ();
            }
            listAccountOrgUnits.add(aou);
        }
    }
    /**
	* Wrapper class MainAccountManagerWrapper
	* Attributes- Date dateFrom,Date dateThru,Boolean isMain,Id orgUnit,Id user
	*/
    public class MainAccountManagerWrapper {
        public Date dateFrom;
        public Date dateThru;
        public Boolean isMain;
        public Id orgUnit;
        public Id user;
    }
    /**
	* Wrapper class AccountOrgUnitCalculation
	* Attributes- Account_Org_Unit__c accountOrgUnit, Date dateFrom, Date dateThru , Boolean isOverlappedByDiffOrgUnit
	* sObject perfectAccManMatch, Boolean isInValidRecord ,Boolean isMainRecord
	*/	
    class AccountOrgUnitCalculation {
        public sObject accountOrgUnit;
        public Date dateFrom;
        public Date dateThru;
        public Boolean isOverlappedByDiffOrgUnit; // Do we need it?
        public sObject perfectAccManMatch;
        public Boolean isInValidRecord;
        public Boolean isMainRecord;
    }
    /**
	* Wrapper class OrgUnitUserWrapper
	* Attributes- Org_Unit_User__c and List of Wrapper AccountOrgUnitCalculation
	*/	
    public class OrgUnitUserWrapper {
        public sObject orgUnitUser = allObjMetaType.get(ns+'Org_Unit_User__c').newSobject();
        List < AccountOrgUnitCalculation > calculations;

        public void addAccountOrgUnitCalculation(AccountOrgUnitCalculation aouc) {
            if (calculations == null) {
                calculations = new List < AccountOrgUnitCalculation > ();
            }
            calculations.add(aouc);
        }
    }
	/**
	* Method to get map of Id as key and OrgUnitWrapper as wrapper
	* @param List < sObject > list of sObjects to be processed in current batch
	* @return Map < Id, OrgUnitWrapper >
	*/	
    public Map < Id, OrgUnitWrapper > getMapOrgUnitsWrapper(List < sObject > orgUnitsList) {
        Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper = new Map < Id, OrgUnitWrapper > ();
        for (sObject ou: orgUnitsList) {
            OrgUnitWrapper ouWrapper = new OrgUnitWrapper();
            ouWrapper.orgUnit = ou;
            mapOrgUnitsWrapper.put(ou.Id, ouWrapper);
        }
        return mapOrgUnitsWrapper;
    }
	/**
	* Method to get the Org_Unit_User__c records related to the Org Units that are
    in the map (argument).
	* @param Map < Id, OrgUnitWrapper > map of Org Units wrapper
	* @return void
	*/	
    public void getOrgUnitUsers(Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper) {
        Set < Id > setId = new Set < Id > ();
        setId = mapOrgUnitsWrapper.keySet();
        Date dateOfRef = system.today();
        String squery2 = 'SELECT Id,{0}Valid_From__c,{0}Valid_Thru__c,{0}User__c,{0}Management_Type__c,{0}Org_Unit__c,{0}Main__c ' +
            'FROM {0}Org_Unit_User__c WHERE {0}Org_Unit__c IN : setId';
        squery2 = String.format(squery2, new List < String > {
            ns
        });
        List < sObject > listOrgUnitUser = Database.query(sQuery2);
        for (sObject userRecord: listOrgUnitUser) {
            OrgUnitUserWrapper uWrapper = new OrgUnitUserWrapper();
            uWrapper.orgUnitUser = userRecord;
            mapOrgUnitsWrapper.get((Id) userRecord.get(ns + 'Org_Unit__c')).addOrgUnitUserWrapper(uWrapper);
        }
        listOrgUnitUser = null;
    }
    /**
	* Method to get the Account_Org_Unit__c records related to the Org Units that
    are in the map (argument).
	* @param Map < Id, OrgUnitWrapper > map of Org Units wrapper
	* @return Set <Id> return list of account ids related to all the org units to be processed in the batch.
	*/	
    public Set < Id > getAccountOrgUnit(Map < Id, OrgUnitWrapper > mapOrgUnitsWrapper) {
        Set < Id > accountIds = new Set < Id > ();
        Set < Id > setId = new Set < Id > ();
        setId = mapOrgUnitsWrapper.keySet();
        String squery2 = 'SELECT Id,{0}Org_Unit__c,{0}Account__c,{0}Active__c,{0}Valid_From__c,{0}Valid_Thru__c FROM {0}Account_Org_Unit__c WHERE ' +
            			 '{0}Org_Unit__c IN :setId';
        squery2 = String.format(squery2, new List < String > {ns});
        List < sObject > listAccountOrgUnit = Database.query(sQuery2);
		for (sObject aou: listAccountOrgUnit) {
            accountIds.add((Id) aou.get(ns + 'Account__c'));
            mapOrgUnitsWrapper.get((Id) aou.get(ns + 'Org_Unit__c')).addAccountOrgUnit(aou);
        }
        listAccountOrgUnit = null;
        return accountIds;
    }
	/**
	* Method to get the Account_Manager__C records related to the Org Units that
    are in the map (argument).
	* @param Set < Id > accountIds, Set < Id > orgUnitIds -Set of org unit Ids and Account ids related to those org units
	* @return void
	*/	
    public void getAccountManagers(Set < Id > accountIds, Set < Id > orgUnitIds) {
        // We are also retrieving account managers from org units not processed in the current batch.
        String squery2 = 'SELECT Id,{0}Valid_Thru__c,{0}Valid_From__c,{0}User__c,{0}Management_Type__c,{0}Main__c,{0}Active__c,{0}Account__c,{0}Org_Unit__c ' +
            'FROM {0}Account_Manager__c WHERE ' +
            '{0}Account__c IN :accountIds and {0}Management_Type__c !=: SUBSTITUTION and {0}Active__c = true';
        squery2 = String.format(squery2, new List < String > {ns});
        List < sObject > listAccountManagers = Database.query(sQuery2);
		List < sObject > lAccountManager;
        Map < Id, List < sObject >> mapReference;
		for (sObject am: listAccountManagers) 
        {
            if ((Id) am.get(ns + 'Org_Unit__c') == null) {
                mapReference = mapStaticAccountManagers;
            } else if (!orgUnitIds.contains((Id) am.get(ns + 'Org_Unit__c'))) {
                // If org unit is not processed in current batch, add it to this batch
                mapReference = mapDiffOrgUnitAccountManagers;
            } else {
                /* If org unit is processed in current batch, add it to this batch. 
                mapAccountManagers will contain all managers having org unit reference processed in current batch */
                mapReference = mapAccountManagers;
            }
            lAccountManager = mapReference.get((Id) am.get(ns + 'Account__c'));
            if (lAccountManager == null) {
                mapReference.put((Id) am.get(ns + 'Account__c'), new List < sObject > {am});
            } 
            else {
                lAccountManager.add(am);
            }
        }
        listAccountManagers = null;
    }
   	/**
	* Method to return the max date instance from the two used arguments.
	* @param Date d1, Date d2 - Two dates to be compared to find out the max date
	* @return Date - Maximum date of the two dates compared.
	*/	
    public static Date maxDate(Date d1, Date d2) {
        if (d1 >= d2) {
            return d1;
        }
        return d2;
    }
    /**
	* Method to get the list of account managers records which are overlapping with the date from and date thru processed in current batch record.
	* @param Date dateFrom, Date dateThru,List < sObject > lAccountManager - dateFrom and dateThru of current Customer-User combination and
	lAccountManager which is list of existing customer managers related to current Customer-User combination
	* @return List < sObject > list of account managers which are overlapping
	*/	
    public List < sObject > getOverlappedRecords(Date dateFrom, Date dateThru, List < sObject > lAccountManager) {
        List < sObject > tmp = new List < sObject > ();
        if (lAccountManager == null) {
            return tmp;
        }
        for (sObject am: lAccountManager) {
            if (overlappedDates(dateFrom, dateThru, (Date) am.get(ns + 'Valid_From__c'),
                    (Date) am.get(ns + 'Valid_Thru__c'))) {
                tmp.add(am);
            }
        }
        return tmp;
    }
    /**
	* Method to return the min date instance from the two used arguments.
	* @param Date d1, Date d2 - Two dates to be compared to find out the min date
	* @return Date - Minimum date of the two dates compared.
	*/	
    public static Date minDate(Date d1, Date d2) {
        if (d1 <= d2) {
            return d1;
        }
        return d2;
    }
    /**
	* Method to check if two periods are overlapping.
	* @param Date d1From, Date d1Thru, Date d2From, Date d2Thru- Two dates to be compared.
	* @return boolean - Return if dates are overlapping
	*/
    public static boolean overlappedDates(Date d1From, Date d1Thru, Date d2From, Date d2Thru) {
        return ((d1From <= d2Thru) && (d1Thru >= d2From));
    }
	/**
	* Method to find list of account managers based on user.This method will fetch all account managers for a given account and given user.
	* @param List < sObject > accountManager, Id userId- List of account managers for account in consideration and user in consideration.
	* @return List < sObject > - List of account managers which are relavent to customer user combination in process
	*/
    public List < sObject > getAccountManagersByUser(List < sObject > accountManager, Id userId) {
        List < sObject > tmp = new List < sObject > ();
        if (accountManager == null) {
            return tmp;
        }
        for (sObject am: accountManager) {
            if ((id) am.get(ns + 'User__c') == userId) {
                tmp.add(am);
            }
        }
        return tmp;
    }
}