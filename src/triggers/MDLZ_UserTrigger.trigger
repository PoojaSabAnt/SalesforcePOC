/***************************************************************
Name: MDLZ_UserTrigger
Created Date: 24/02/2022
***************************************************************/
trigger MDLZ_UserTrigger on User(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
     MDLZ_TriggerDispatcher.Run(new MDLZ_UserTriggerHandler());
}