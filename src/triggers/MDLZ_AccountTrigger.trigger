/***************************************************************
Name: MDLZ_AccountTrigger
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Vaidehi                      08/03/2022     Initial Development    
***************************************************************/
trigger MDLZ_AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
     MDLZ_TriggerDispatcher.Run(new MDLZ_AccountTriggerHandler());
}