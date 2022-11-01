/**  PROGRAM NAME : GenerateJobListExecution 
     * This class is execution class for GenerateJobListBatch class.
     * @see    GenerateJobListBatch
     * @version  1.0
     * @Created Date 2018-10-18
*/
public class GenerateJobListExecution {
	/** Private Variables */
    private static Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
    private static final String MANAGEMENT_TYPE_ALL = 'All';
    private static final String STATUS_PLAN = 'Plan';
    private static final String MANAGEMENT_TYPE_SUBSTITUTION = 'Substitution';
    public final Static String JOB_LIST_DONE_STATUS_CANCELLED = '2';
    Public final Static String JOB_LIST_DONE_STATUS_DONE = '1';
    Public final Static String JOB_LIST_DONE_STATUS_NOT_DONE = '0';
    
    Set<sObject> jobListsToBeCreatedOrUpdated;
    Set<sObject> jobListsToBeDeleted;
    ManagerWithTimeFrame mainManagerWithLongestTimeFrame;
    ManagerWithTimeFrame nonmainManagerWithLongestTimeFrame;
    Map<Id, Map<Id,sObject>> jdlaMapExcludedAccounts;
    Map<Id, sObject> toBeDeleted = new Map<Id, sObject>();

    /** 
    *  @description Processing Job_Definition_List records.
    *  @param List<sObject> jobDefinitionLists
    *  @return void 
    *  @throws  Standard exception
    */
    public void process(List<sObject> jobDefinitionLists) { 
        try {

            List<String> paramString = new List<String>();
            for(SObject s : jobDefinitionLists){
                paramString.add(String.valueOf(s));
            }
            jobListsToBeCreatedOrUpdated = new Set<sObject>();
            jobListsToBeDeleted = new Set<sObject>();

            List<sObject> jdls = (List<sObject>)jobDefinitionLists;
            Map<Id, sObject> jdlsMap = new Map<Id, sObject>(jdls); 
            Map<Id, Set<Id>> accountsToBeCheckedPerJDL = new Map<Id, Set<Id>>();

			Set<Id> jdlSetIDs = getSetWithEscapeSingleQuotes(jdlsMap.keySet());
            Set<Id> accountIds = getRelatedAccountIds(jdls, accountsToBeCheckedPerJDL);

            Map<Id, sObject> retreivedAcc = new Map<Id, sObject>([SELECT Id, (SELECT Id, ACCL__Account__c, ACCL__Responsible__c, ACCL__Call_Template__c, ACCL__Start_Date__c, ACCL__End_Date__c FROM ACCL__Calls__r WHERE ACCL__Status__c = :STATUS_PLAN ),
            													(SELECT Id, ACCL__Account__c, ACCL__Call__c, ACCL__Call__r.ACCL__Start_Date__c, ACCL__Call__r.ACCL__End_Date__c, ACCL__Call_Date__c, ACCL__Call_Template__c, ACCL__Done__c, ACCL__Manager__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c, ACCL__Job_Definition_List__c, ACCL__Description_JDL__c FROM ACCL__Job_Lists__r WHERE ACCL__Job_Definition_List__c IN :jdlSetIDs AND ACCL__Done__c=:JOB_LIST_DONE_STATUS_NOT_DONE ),
            													(SELECT ACCL__Active__c, ACCL__Main__c, ACCL__Account__c, ACCL__Management_Type__c, ACCL__User__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c FROM ACCL__Account_Managers__r WHERE ACCL__Active__c = true AND ACCL__Management_Type__c != :MANAGEMENT_TYPE_SUBSTITUTION )
            													FROM Account WHERE Id IN: accountIds]);
            jdlaMapExcludedAccounts = getExludedAccountFromJDL(jdlsMap); 
			for(sObject jdl : jdls) {
                for( Id accountId : accountsToBeCheckedPerJDL.get(jdl.Id) ){
                    iterateThroughManagersAndCreateOrUpdateJobLists( retreivedAcc.get(accountId), jdl ); 
                }
            }

			String jlQuery = 'SELECT Id, ACCL__Done__c, ACCL__Call__c, ACCL__Call__r.ACCL__Start_Date__c, ACCL__Call__r.ACCL__End_Date__c, ACCL__Job_Definition_List__c, '
                			+'ACCL__Description_JDL__c, ACCL__Account__c, ACCL__Call_Template__c, ACCL__Valid_From__c, ACCL__Valid_Thru__c FROM ACCL__Job_List__c '
                			+'WHERE ACCL__Job_Definition_List__c IN : jdlSetIDs AND ACCL__Account__c NOT IN:accountIds AND ACCL__Done__c =:JOB_LIST_DONE_STATUS_NOT_DONE';
            Set<sObject> jobsWithAccountsNotAttachedToProcessedJDLs = new Set<sObject>(Database.query(jlQuery)); 
            cancelOrDeleteJobLists(jobsWithAccountsNotAttachedToProcessedJDLs);
            cancelAllJLWithOutOfDateCallsAndCreateSubstitute();
            //Eliminate duplicate reference from this list: 
            //CRUD upsert False Positive
            //This class is a Batch Execution logic class and needs to run in System Context.
            List<sObject> tobeupserted = deduplicateCollection(jobListsToBeCreatedOrUpdated);

            // To upsert, type cast List<sObject> to List<ACCL__Job_List__c>, because upsert operation cant be perform on List<sObject>.
            String listType = 'List<' + 'ACCL__Job_List__c' + '>'; 
        	List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(tobeupserted);
            upsert castRecords;

            //CRUD Delete False Positive
            //This class is a Batch Execution logic class and needs to run in System Context.
            delete deduplicateCollection(jobListsToBeDeleted);
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
        }  
    } 

    /** 
    *  @description This method eliminates identical element from a Set i.e passed by reference.
    *  @param Set<sObject> dedupCollection
    *  @return List<sObject> 
    *  @throws  None
    */
    private List<sObject> deduplicateCollection(Set<sObject> dedupCollection)
    {
        Map<Id, sObject> mapj = new Map<Id, sObject>();
        for(sObject j : dedupCollection) {
            if(j.Id != null) {
                if(mapJ.containsKey(j.Id)) {
                    dedupCollection.remove(j);
                }
                else {
                    mapj.put(j.Id,j);
                }
            }            
        }
        return new List<sObject>(dedupCollection);
    }

    private Map<Id, Map<Id, sObject>> getExludedAccountFromJDL(Map<Id, sObject> jdlMapCheck) {
        Map<Id, Map<Id, sObject>> jdlaMapExcludedAccount = new Map<Id, Map<Id, sObject>>();
        Set<Id> jdlSetIDs = getSetWithEscapeSingleQuotes(jdlMapCheck.keySet());
        List<sObject> jdlaList = [SELECT Id, Name, ACCL__Account__c, ACCL__Account__r.Name, ACCL__Excluded__c, ACCL__Job_Definition_List__c FROM ACCL__Job_Definition_List_Account__c WHERE ACCL__Excluded__c = true  AND ACCL__Job_Definition_List__c IN :jdlSetIDs ORDER BY ACCL__Job_Definition_List__c];

        for (sObject jdla : jdlaList ) {
            if  (!jdlaMapExcludedAccount.containsKey((Id)jdla.get('ACCL__Job_Definition_List__c'))) {   
                Map<Id, sObject> accFromjdl = new Map<ID, sObject>();
                accFromjdl.put((Id)jdla.get('ACCL__Account__c'), jdla); 
                jdlaMapExcludedAccount.put((Id)jdla.get('ACCL__Job_Definition_List__c'), accFromjdl);
            }
            else{
                jdlaMapExcludedAccount.get((Id)jdla.get('ACCL__Job_Definition_List__c')).put((Id)jdla.get('ACCL__Account__c'), jdla); 
            }
        }
        return  jdlaMapExcludedAccount;
    }

    private Set<Id> getRelatedAccountIds(List<sObject> jdls, Map<Id ,Set<Id>> accountsToBeCheckedPerJDL){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> accountSetsIds = new Set<Id>();

        Map<Id, Set<Id>> jdlToAccountSetIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountSetIdToJDLId = new Map<Id, Set<Id>>();
        for( sObject jdl : jdls ) {
            List<sObject> listJDLA = new List<sObject>(jdl.getSObjects('ACCL__Job_Definition_List_Accounts__r')); 
            accountsToBeCheckedPerJDL = populateMap(accountsToBeCheckedPerJDL, jdl.Id, getSetOfIdsFromListOfSObjects('ACCL__Account__c', listJDLA)); 
            accountIds.addAll(getSetOfIdsFromListOfSObjects('ACCL__Account__c', listJDLA)); 
            List<sObject> listJDLAS = new List<sObject>(jdl.getSObjects('ACCL__Job_Definition_List_Account_Sets__r'));
            Set<Id> accountSets = getSetOfIdsFromListOfSObjects('ACCL__Account_Set__c', listJDLAS); 
            accountSetsIds.addAll(accountSets);
            jdlToAccountSetIds = populateMap(jdlToAccountSetIds, jdl.Id, accountSets);
            for(sObject accountSet :  listJDLAS ) {
                accountSetIdToJDLId = populateMap(accountSetIdToJDLId, (Id)accountSet.get('ACCL__Account_Set__c'), jdl.Id); 
            }

        }

        List<sObject> asaSOQL = [SELECT ACCL__Account_Set_Account__c, ACCL__Account_Set__c FROM ACCL__Account_Set_Account__c WHERE ACCL__Account_Set__c IN :accountSetsIds];
        for( sObject asa : asaSOQL ) {
            for ( Id jdlId : accountSetIdToJDLId.get((Id)asa.get('ACCL__Account_Set__c')) ) {  
                accountsToBeCheckedPerJDL = populateMap(accountsToBeCheckedPerJDL, jdlId , (Id)asa.get('ACCL__Account_Set_Account__c') );  
            }
            accountIds.add((Id)asa.get('ACCL__Account_Set_Account__c'));   
        }
        return accountIds;
    }

    private  Map<Id, Set<Id>> populateMap(Map<Id, Set<Id>> mapToBeProcessed, Id key, Set<Id> valuesToBeAdded ) {
        if( mapToBeProcessed.containsKey(key) ) {
                mapToBeProcessed.get(key).addAll( valuesToBeAdded );
            } else {
                mapToBeProcessed.put(key, valuesToBeAdded);
            }
        return mapToBeProcessed;
    }

    private  Map<Id, Set<Id>> populateMap(Map<Id, Set<Id>> mapToBeProcessed, Id key, Id valueToBeAdded ) {
        if( mapToBeProcessed.containsKey(key) ) {
                mapToBeProcessed.get(key).add( valueToBeAdded );
            } else {
                mapToBeProcessed.put(key, new Set<Id>{valueToBeAdded} );
            }
        return mapToBeProcessed;
    }

    private void iterateThroughManagersAndCreateOrUpdateJobLists(sObject currentAcc, sObject jdl) {
        List<sObject> ListOfJL = new List<sObject>(currentAcc.getSObjects('ACCL__Job_Lists__r')); 
        Set<sObject> existingNotYetProcessedJL = new Set<sObject>();
        for(sObject jobListRecord : ListOfJL){
            if(jobListRecord.get('ACCL__Job_Definition_List__c') == jdl.get('Id')){
                existingNotYetProcessedJL.add(jobListRecord);
            }
        } 
        List<sObject> ListOfCalls = new List<sObject>(currentAcc.getSObjects('ACCL__Calls__r')); 
		//Set<sObject> existingNotYetProcessedJL = new Set<sObject>(ListOfJL); 
        Set<sObject>  existingCallsWhichCouldBeMagnetized = new Set<sObject>(ListOfCalls); 
        mainManagerWithLongestTimeFrame = new ManagerWithTimeFrame();
        nonmainManagerWithLongestTimeFrame = new ManagerWithTimeFrame();
        List<sObject> ListOfAM = new List<sObject>(currentAcc.getSObjects('ACCL__Account_Managers__r'));  
        for( sObject manager : ListOfAM) {  

            if( checkIfManagerIsInvalidPeriodAndCorrectManagmentType(jdl, manager) ){
                //Exclude
                sObject currentJL = assignExistingJobListIfExistsForManager( existingNotYetProcessedJL, manager );

                if( currentJL == null) {
                    createOrUpdateJLAccordingToItsUserPolicy(currentJL, existingCallsWhichCouldBeMagnetized, jdl, manager);
                } else {
                    existingNotYetProcessedJL.remove(currentJL);
                    createOrUpdateJLAccordingToItsUserPolicy(currentJL, existingCallsWhichCouldBeMagnetized, jdl, manager);
                }
            }
        }

        cancelOrDeleteJobLists(existingNotYetProcessedJL);
        processManagersWithLongestTimeFrame(existingCallsWhichCouldBeMagnetized, jdl);
    }

    private void createOrUpdateJLAccordingToItsUserPolicy(sObject currentJL, Set<sObject> existingCallsWhichCouldBeMagnetized, sObject jdl, sObject manager ) {
        if( jdl.get('ACCL__User_Policy__c') == AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ALL ) { 
            if( isUpdateJobListAndChangedDates(currentJL, jdl, manager) ){
                currentJL = updateJobList(currentJL, manager , jdl);
            } else {
                currentJL = createJob( jdl, manager, currentJL );
            }
            magnetizeCallIfPossibe(existingCallsWhichCouldBeMagnetized, currentJL); 
            jobListsToBeCreatedOrUpdated.add(currentJL);

        } else if ( jdl.get('ACCL__User_Policy__c') == AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_ONLY_MAIN && (boolean)manager.get('ACCL__Main__c')) {  
            Integer daysManagerIsActiveOnJDL = getNumberOfDaysManagerIsActiveOnJDL(jdl, manager); 
            setJobListEvenWhenMainManagerIsNotToBeConsidered(currentJL);
            if(  daysManagerIsActiveOnJDL > mainManagerWithLongestTimeFrame.daysActiveOnJDL ){
                    mainManagerWithLongestTimeFrame.setNewValues(manager, daysManagerIsActiveOnJDL, currentJL);
            }
        } else if ( (String)jdl.get('ACCL__User_Policy__c') == AddOnConstants.JOB_DEFINITION_LIST_USER_POLICY_FIRST ){  
            Integer daysManagerIsActiveOnJDL = getNumberOfDaysManagerIsActiveOnJDL(jdl, manager); 
            if( (boolean)manager.get('ACCL__Main__c') ) {  
                setJobListEvenWhenMainManagerIsNotToBeConsidered(currentJL);
                if( daysManagerIsActiveOnJDL > mainManagerWithLongestTimeFrame.daysActiveOnJDL  ){
                    mainManagerWithLongestTimeFrame.setNewValues(manager, daysManagerIsActiveOnJDL, currentJL);
				} 
            } else {
                setJobListEvenIfNonMainManagerIsNotToBeConsidered(currentJL);
                if( daysManagerIsActiveOnJDL > nonmainManagerWithLongestTimeFrame.daysActiveOnJDL ) {
                    nonmainManagerWithLongestTimeFrame.setNewValues(manager, daysManagerIsActiveOnJDL, currentJL);
                }
            }
        }
    }

    private void cancelAllJLWithOutOfDateCallsAndCreateSubstitute() {
        List<sObject> toBeAdded = new List<sObject>();
        List<sObject> recreateDueToExcludability = new List<sObject>();
        for( sObject jl : jobListsToBeCreatedOrUpdated) {
            if(jl.Id != null && jl.get('ACCL__Call__c') != null && !isCallWithinJobListTimeFrame(jl, jl.getSObject('ACCL__Call__r')) && !excludeAccountList((Id)jl.get('ACCL__Job_Definition_List__c'), (Id)jl.get('ACCL__Account__c'))) {   
                jl.put('ACCL__Done__c', AddOnConstants.JOB_LIST_DONE_STATUS_CANCELLED); 
                sObject jlWithoutCall = jl.clone(false,true);
                jlWithoutCall.put('ACCL__Call__c', null); 

                jlWithoutCall.put('ACCL__Done__c', AddOnConstants.JOB_LIST_DONE_STATUS_NOT_DONE);  
                toBeAdded.add(jlWithoutCall);
                recreateDueToExcludability.add(jl);
            } 
            else if(jl.Id != null && excludeAccountList((Id)jl.get('ACCL__Job_Definition_List__c'), (Id)jl.get('ACCL__Account__c'))) {  
                jobListsToBeDeleted.add(jl);
            } else if (!excludeAccountList((Id)jl.get('ACCL__Job_Definition_List__c'), (Id)jl.get('ACCL__Account__c')) ) {  
              recreateDueToExcludability.add(jl);  
            } else {}
        }
        jobListsToBeCreatedOrUpdated = new Set<sObject>(recreateDueToExcludability); 
        jobListsToBeCreatedOrUpdated.addAll(toBeAdded);
    }

    private void processManagersWithLongestTimeFrame(Set<sObject> existingCallsWhichCouldBeMagnetized, sObject jdl){
        if( mainManagerWithLongestTimeFrame.manager != null ) {
            if( mainManagerWithLongestTimeFrame.jobList != null ) {
                jobListsToBeCreatedOrUpdated.add(magnetizeCallIfPossibe(existingCallsWhichCouldBeMagnetized, updateJobList(mainManagerWithLongestTimeFrame.jobList, mainManagerWithLongestTimeFrame.manager, jdl)));
            } else {
                jobListsToBeCreatedOrUpdated.add( magnetizeCallIfPossibe(existingCallsWhichCouldBeMagnetized,createJob(jdl,mainManagerWithLongestTimeFrame.manager, null)));
            }
        } else if(  nonmainManagerWithLongestTimeFrame.manager != null ) {
            if( nonmainManagerWithLongestTimeFrame.jobList != null ) {
                jobListsToBeCreatedOrUpdated.add(magnetizeCallIfPossibe(existingCallsWhichCouldBeMagnetized, updateJobList(nonmainManagerWithLongestTimeFrame.jobList, nonmainManagerWithLongestTimeFrame.manager, jdl)));
            } else {
                jobListsToBeCreatedOrUpdated.add( magnetizeCallIfPossibe(existingCallsWhichCouldBeMagnetized,createJob(jdl,nonmainManagerWithLongestTimeFrame.manager, null)));
            }
        }
    }

    private sObject assignExistingJobListIfExistsForManager(Set<sObject> existingNotYetProcessedJL, sObject manager) {
        for(sObject jl : existingNotYetProcessedJL ) {
            if( jl.get('ACCL__Manager__c') == manager.get('ACCL__User__c') ) { 
                return jl;
            }
        }
        return null;
    }

    private void cancelOrDeleteJobLists(Set<sObject> jls) {
        for(sObject jl: jls) {
            if( jl.get('ACCL__Call__c') != null ) {   
                //FLS Create.FLS Update False Positive
                //This class is a Batch Execution logic class and needs to run in System Context.
                jl.put('ACCL__Done__c', AddOnConstants.JOB_LIST_DONE_STATUS_CANCELLED);  
                jobListsToBeCreatedOrUpdated.add(jl);
            } else {
                jobListsToBeDeleted.add(jl); 
            }
        }
    }

    private boolean excludeAccountList(ID jdl, Id acc){
        if(jdlaMapExcludedAccounts.containsKey(jdl)){
            if(jdlaMapExcludedAccounts.get(jdl).containsKey(acc)){
                return true;
            }
            return false; 
        }
        return false;
    }

    private void setJobListEvenWhenMainManagerIsNotToBeConsidered(sObject currentJL) {
        if( currentJL != null ){
            mainManagerWithLongestTimeFrame.jobList =  currentJL;
        }
    }

    private void setJobListEvenIfNonMainManagerIsNotToBeConsidered(sObject currentJL) {
        if( currentJL != null ){
            mainManagerWithLongestTimeFrame.jobList =  currentJL;
        }
    }

    private sObject magnetizeCallIfPossibe(Set<sObject> existingCallsWhichCouldBeMagnetized, sObject currentJL) {
        sObject magnetizedCall = null;
        for(sObject call : existingCallsWhichCouldBeMagnetized) {
            if((currentJL.get('ACCL__Manager__c') == call.get('ACCL__Responsible__c')) && (currentJL.get('ACCL__Call_Template__c') == call.get('ACCL__Call_Template__c')) && isCallWithinJobListTimeFrame(currentJL, call) ) { 
                //FLS Create,FLS Update False Positive
                //This class is a Batch Execution logic class and needs to run in System Context.
                currentJL.put('ACCL__Call__c', call.Id);  
                //FLS Create,FLS Update False Positive
                //This class is a Batch Execution logic class and needs to run in System Context.
                currentJL.putSObject('ACCL__Call__r', call);  
                magnetizedCall = call;
                break;
            } 
        }
        if( magnetizedCall != null ){
            existingCallsWhichCouldBeMagnetized.remove(magnetizedCall);
        }
        return currentJL;
    }

    private Boolean isCallWithinJobListTimeFrame(sObject currentJL, sObject call){
         //Dereferenced_Field False Positive
        //This class is a Batch Execution logic class and needs to run in System Context.
        return ((Date)currentJL.get('ACCL__Valid_From__c') <= (Date)call.get('ACCL__Start_Date__c') && (Date)currentJL.get('ACCL__Valid_Thru__c') >= (Date)call.get('ACCL__End_Date__c'));
    }

    private Boolean isUpdateJobList(sObject currentJL){
        return currentJL != null && currentJL.Id != null;
    }

    private Boolean isUpdateJobListAndChangedDates(sObject currentJL, sObject jdl, sObject manager){
        //Dereferenced_Field False Positive
        //This class is a Batch Execution logic class and needs to run in System Context.
        return ( isUpdateJobList(currentJL) && ( (getOverlappingDateFrom(jdl, manager) != (Date)currentJL.get('ACCL__Valid_From__c')) || ((Date)currentJL.get('ACCL__Valid_Thru__c') != getOverlappingDateTo(jdl,manager))) );
    }

    //FLS Create,FLS Update False Positive
    //This class is a Batch Execution logic class and needs to run in System Context.
    private sObject updateJobList(sObject currentJL, sObject manager, sObject jdl) {
        currentJL.put('ACCL__Valid_From__c', getOverlappingDateFrom(jdl, manager));
        currentJL.put('ACCL__Valid_Thru__c', getOverlappingDateTo(jdl, manager));
        currentJL.put('ACCL__Manager__c', manager.get('ACCL__User__c')); 
        return currentJL;
    }

    private  sObject createJob(sObject jdl, sObject manager, sObject currentJL) {
        sObject jobListObj = allObjMetaType.get('ACCL__Job_List__c').newSObject();
        jobListObj.put('ACCL__Account__c', manager.get('ACCL__Account__c'));
        jobListObj.put('ACCL__Call_Template__c', jdl.get('ACCL__Call_Template__c'));
        jobListObj.put('ACCL__Job_Definition_List__c', jdl.Id);
        jobListObj.put('ACCL__Manager__c', manager.get('ACCL__User__c'));
        jobListObj.put('ACCL__Valid_From__c', getOverlappingDateFrom(jdl, manager));
        jobListObj.put('ACCL__Valid_Thru__c', getOverlappingDateTo(jdl, manager));
        jobListObj.put('Id', currentJL != null ? currentJL.Id : null);
        return jobListObj;
    }

    private Date getOverlappingDateFrom(sObject jdl, sObject manager ){        
        //Dereferenced_Field False Positive
        //This class is a Batch Execution logic class and needs to run in System Context.
        return (Date)jdl.get('ACCL__Valid_From__c') < (Date)manager.get('ACCL__Valid_From__c') ? (Date)manager.get('ACCL__Valid_From__c') : (Date)jdl.get('ACCL__Valid_From__c');
    }

    private Date getOverlappingDateTo( sObject jdl, sObject manager  ){
         //Dereferenced_Field False Positive
        //This class is a Batch Execution logic class and needs to run in System Context.
        return (Date)jdl.get('ACCL__Valid_Thru__c') > (Date)manager.get('ACCL__Valid_Thru__c') ? (Date)manager.get('ACCL__Valid_Thru__c') : (Date)jdl.get('ACCL__Valid_Thru__c');
    }
    
    private Integer getNumberOfDaysManagerIsActiveOnJDL(sObject jdl, sObject manager){
        Date validFrom = getOverlappingDateFrom(jdl, manager); 
        Date validTo =  getOverlappingDateTo(jdl, manager);
        return validFrom.daysBetween(validTo);
    }
    
    private  Boolean checkIfManagerIsInvalidPeriodAndCorrectManagmentType(sObject jdl, sObject manager ){
        //Dereferenced_Field False Positive
        //This class is a Batch Execution logic class and needs to run in System Context.
        return  ((Date)jdl.get('ACCL__Valid_From__c') <= (Date)manager.get('ACCL__Valid_Thru__c')  && (Date)jdl.get('ACCL__Valid_Thru__c') >= (Date)manager.get('ACCL__Valid_From__c')) && ( (String.isBlank((String)jdl.get('ACCL__Default_Management_Type__c'))) || (manager.get('ACCL__Management_Type__c') == jdl.get('ACCL__Default_Management_Type__c')) );
    }
    
    private class ManagerWithTimeFrame {
        
        public sObject manager {get; set;}
        public Integer daysActiveOnJDL { get; set;}
        public sObject jobList {get; set;}
        
        public ManagerWithTimeFrame(){
            this.daysActiveOnJDL = 0;
        }
        
        public void setNewValues(sObject manager, Integer daysActiveOnJDL, sObject jobList){
            this.manager = manager;
            this.daysActiveOnJDL = daysActiveOnJDL;
            this.jobList = joblist == null ? this.jobList : joblist;
        }
        
        public Boolean equals(Object obj){
            if(obj!= null && obj instanceOf ManagerWithTimeFrame){
                ManagerWithTimeFrame managerWithTimeFrame = (ManagerWithTimeFrame) obj;
                if((this.manager == managerWithTimeFrame.manager)&&(this.jobList == managerWithTimeFrame.jobList)){
                    return true;
                }else{
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    
    private Set<Id> getSetOfIdsFromListOfSObjects(String fieldNameOfTypeId, List<SObject> listToGetIdsFrom) {
        Set<Id> resultIds = new Set<Id>();
        for( SObject ob : listToGetIdsFrom) {
            Id id = (Id)ob.get(fieldNameOfTypeId);
            if(id != null) {
                resultIds.add(id);
            } 
        }
        return resultIds;
    }
    
    private Set<Id> getSetWithEscapeSingleQuotes(Set<Id> setWithoutSinglesQuotes) {
        Set<Id> setWithSinglesQuotes = new Set<Id>();
        for (String s : setWithoutSinglesQuotes) {
            setWithSinglesQuotes.add(getStringWithSingleQuotes(s));
        }
        return setWithSinglesQuotes;
    }
    
    private String getStringWithSingleQuotes(String stringWithoutSingleQuotes) {
        String result;
        if ( stringWithoutSingleQuotes != null) {
            result = String.escapeSingleQuotes(stringWithoutSingleQuotes);
        } else {
            result = null;
        }
        return result;
    }
}