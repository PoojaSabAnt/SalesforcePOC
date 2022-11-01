/**
* This class is always called by a time job and decides which batch should be triggered 
* base on the batch_process_configuration__c.
*/
global with sharing class AddOns_Scheduler implements Schedulable {
    
    private final static Date REFERENCE_DATE = Date.newInstance(1970, 1, 5); // Monday
    
    private Map<String, List<ACCL__Batch_Process_Configuration__c>> processConfigurationGroupedByClass;
    
    /**
    * Executes the logic to decided what batch has to be triggered base on its configuration.
    * @param SC Schedulable context.
    */
    global void execute(SchedulableContext SC) {
        
        prepare();
        execute();
        finalize();
    }
    
    private void prepare() {
        processConfigurationGroupedByClass = new Map<String, List<ACCL__Batch_Process_Configuration__c>>();
              Map<String, ACCL__Batch_Process_Configuration__c> processConfigurations = ACCL__Batch_Process_Configuration__c.getAll();
        
        for(ACCL__Batch_Process_Configuration__c processConfiguration : processConfigurations.values()) {
            
            if(qualifiesForScheduling(processConfiguration)) {
                if(isSchedulingDue(processConfiguration)) {
                    prepareConfigurationForScheduling(processConfiguration);
                }
            }
        }
    }
    
    private void execute() {
        for(String className : processConfigurationGroupedByClass.keySet()) {
            List<ACCL__Batch_Process_Configuration__c> processConfigurations = processConfigurationGroupedByClass.get(className);
            
            try {
                Object executable = Type.forName(className).newInstance();
                if(executable instanceof AddOns_SchedulerExecutable) {
                    executeSchedulableConfigurations((AddOns_SchedulerExecutable)executable, processConfigurations);
                } else {
                    handleNotSchedulableConfigurations(processConfigurations);
                }
                
            } catch(NullPointerException ex) {
                handleInvalidClassName(processConfigurations, ex);
            } catch(Exception ex) {
                System.debug(LoggingLevel.ERROR, 'An unexpected error occured: ' + ex.getMessage());
            }
        }
    }
    
    private void finalize() {
        List<ACCL__Batch_Process_Configuration__c> recordsToUpdate = new List<ACCL__Batch_Process_Configuration__c>();
        
        for(List<ACCL__Batch_Process_Configuration__c> processConfigurations : processConfigurationGroupedByClass.values()) {
            recordsToUpdate.addAll(processConfigurations);
        }
        
        update recordsToUpdate;
    }

    
    private Boolean qualifiesForScheduling(ACCL__Batch_Process_Configuration__c config) {
        Boolean schedulingQualified = false;
        
        if(!String.isBlank(config.ACCL__Sales_Org__c) && !String.isBlank(config.ACCL__Apex_Class__c)) {
            if(config.ACCL__Monday__c || config.ACCL__Tuesday__c || config.ACCL__Wednesday__c || config.ACCL__Thursday__c || config.ACCL__Friday__c || config.ACCL__Saturday__c || config.ACCL__Sunday__c) {
                schedulingQualified = true;
            } else {
                System.debug(LoggingLevel.INFO, 'The configuration "' + config.Name + '" has no Weekday assigned. Ignoring Record.');
            }
        } else {
            System.debug(LoggingLevel.DEBUG, 'The configuration "' + config.Name + '" has no ApexClass or SalesOrg specified. Ignoring Record.');
        }
        
        return schedulingQualified;
    }
    
    private Boolean isSchedulingDue(ACCL__Batch_Process_Configuration__c config) {
        Boolean schedulingIsDue = false;
        
        if(config.ACCL__Last_Run__c == null) {
            schedulingIsDue = true;
            System.debug(LoggingLevel.DEBUG, 'The configuration "' + config.Name + '" has never been executed or failed last time. Scheduling now.');
        } else {
            Datetime nextRunTime = determineNextRunTime(config);
            
            if(nextRunTime <= Datetime.now()) {
                schedulingIsDue = true;
                System.debug(LoggingLevel.DEBUG, 'The configuration "' + config.Name + '" has to run on ' + nextRunTime + '. Scheduling now.');
            } else {
                System.debug(LoggingLevel.DEBUG, 'The configuration "' + config.Name + '" has to be scheduled next on: ' + nextRunTime);
            }
        }
        
        return schedulingIsDue;
    }
    
    private DateTime determineNextRunTime(ACCL__Batch_Process_Configuration__c config) {
        Integer lastRunWeekDay = getWeekDay(config.ACCL__Last_Run__c);
        Integer daysUntilNextRun = 1;
        Boolean[] checkDays = new Boolean[]{config.ACCL__Monday__c, config.ACCL__Tuesday__c, config.ACCL__Wednesday__c, config.ACCL__Thursday__c, config.ACCL__Friday__c, config.ACCL__Saturday__c, config.ACCL__Sunday__c };
            
        for(Integer i = 0; i < 7; i++) {
            Integer nextWeekDay = Math.mod(lastRunWeekDay + daysUntilNextRun, 7);
            if(checkDays[nextWeekDay]) {
                break;
            } else {
                daysUntilNextRun++;
            }
        }
        
        DateTime nextRun = config.ACCL__Last_Run__c.addDays(daysUntilNextRun);
        
        Integer startTime = 0;
        if(!String.isBlank(config.ACCL__Start_Time__c) && config.ACCL__Start_Time__c.isNumeric() && Integer.valueOf(config.ACCL__Start_Time__c) <= 23 && Integer.valueOf(config.ACCL__Start_Time__c) >= 0 ) {
            startTime = Integer.valueOf(config.ACCL__Start_Time__c);
        }
        
        nextRun = Datetime.newInstanceGmt(nextRun.year(), nextRun.month(), nextRun.day(), startTime, 0, 0);
        
        return nextRun;
    }
    
    private Integer getWeekDay(DateTime d) {
        return Math.mod(REFERENCE_DATE.daysBetween(d.dateGmt()), 7);
    }
    
    private void prepareConfigurationForScheduling(ACCL__Batch_Process_Configuration__c config) {
        String uniqueClassName = config.ACCL__Apex_Class__c.capitalize();
        
        if(!processConfigurationGroupedByClass.containsKey(uniqueClassName)) {
            processConfigurationGroupedByClass.put(uniqueClassName, new List<ACCL__Batch_Process_Configuration__c>());
        }
        
        List<ACCL__Batch_Process_Configuration__c> processConfigurations = processConfigurationGroupedByClass.get(uniqueClassName);
        processConfigurations.add(config);
    }
    
    private void executeSchedulableConfigurations(AddOns_SchedulerExecutable executable, List<ACCL__Batch_Process_Configuration__c> processConfigurations) {
        
        try {
            executable.startProcess(processConfigurations);
            handleSuccessfullConfigurations(processConfigurations);
        } catch(Exception ex) {
            handelFailingConfigurations(processConfigurations, ex);
        }
    }
    
    private void handleSuccessfullConfigurations(List<ACCL__Batch_Process_Configuration__c> processConfigurations) {
        for(ACCL__Batch_Process_Configuration__c processConfiguration : processConfigurations) {
            processConfiguration.ACCL__Last_Run__c = Datetime.now();
            System.debug(LoggingLevel.INFO, 'Success: The Batch_Process_Configuration ' + processConfiguration.Name + '" has successfully been scheduled.');
        }
    }
    
    private void handleNotSchedulableConfigurations(List<ACCL__Batch_Process_Configuration__c> processConfigurations) {
        for(ACCL__Batch_Process_Configuration__c processConfiguration : processConfigurations) {
            processConfiguration.ACCL__Last_Run__c = null;
            System.debug(LoggingLevel.ERROR, 'The Batch_Process_Configuration ' + processConfiguration.Name + ' cannot be scheduled because the ApexClass "' + processConfiguration.ACCL__Apex_Class__c + '" does not inherit from "SchedulerExecutable"');
        }
    }
    
    private void handelFailingConfigurations(List<ACCL__Batch_Process_Configuration__c> processConfigurations, Exception ex) {
        for(ACCL__Batch_Process_Configuration__c processConfiguration : processConfigurations) {
            processConfiguration.ACCL__Last_Run__c = Datetime.now();
            System.debug(LoggingLevel.ERROR, 'Failure: The Batch_Process_Configuration ' + processConfiguration.Name + ' for the ApexClass "' + processConfiguration.ACCL__Apex_Class__c + '" and the SalesOrg "' + processConfiguration.ACCL__Sales_Org__c + '" could not been scheduled due to the following error:');
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
    
    private void handleInvalidClassName(List<ACCL__Batch_Process_Configuration__c> processConfigurations, NullPointerException ex) {
        for(ACCL__Batch_Process_Configuration__c processConfiguration : processConfigurations) {
            processConfiguration.ACCL__Last_Run__c = null;
            System.debug(LoggingLevel.ERROR, 'Failure: The Batch_Process_Configuration "' + processConfiguration.Name + '" could not been scheduled because the ApexClass does not exist');
        }
    }
}