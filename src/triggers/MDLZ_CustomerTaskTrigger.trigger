/***************************************************************
Name: MDLZ_CustomerTaskTrigger
History

VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Namitha Francis   Vaidehi      07/06/2021     Initial Development    
***************************************************************/

trigger MDLZ_CustomerTaskTrigger on ACCL__Account_Task__c (before insert, after delete){
    
    MDLZ_TriggerDispatcher.Run(new MDLZ_CustomerTaskTriggerHandler());   
	
}