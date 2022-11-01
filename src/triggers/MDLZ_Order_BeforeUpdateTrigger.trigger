/***************************************************************
Name: MDLZ_Order_BeforeUpdateTrigger
======================================================
Purpose:
a. Standard trigger class to provide implementation for before update
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL  Description
1.0                                      10/08/2021       Initial Development  
1.1       Vaidehi Heda                   03/08/2022       Added logFieldChanges() method in After Update condition
1.2       Vaidehi Heda                   29/08/2022       Added method condition for before insert
***************************************************************/ 
//Cmt: fixing defects: MRELKXIW-1925, MRELKXIW-1912 & MRELKXIW-1918
trigger MDLZ_Order_BeforeUpdateTrigger on ACCL__Order__c (before insert,after insert, before update, after update) {
    
    MDLZ_Trigger_Switch__c switchVar = MDLZ_Trigger_Switch__c.getInstance('MDLZ_Order_BeforeUpdateTrigger');
    if(switchVar != NULL && 'false'.equalsIgnorecase(String.valueOf(switchVar.MDLZ_Active__c))){ 
        return;
    }   
    MDLZ_OrderTriggerHandler handler = new MDLZ_OrderTriggerHandler();
    if(trigger.isBefore && trigger.isInsert){ 
        MDLZ_OrderTriggerHandler.beforeInsert(Trigger.new);
    } else if(trigger.isBefore && trigger.isUpdate){ 
        handler.ResetIsChanged(Trigger.new);
        MDLZ_OrderTriggerHandler.sapErrBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }  else if(trigger.isAfter && trigger.isInsert ){ 
        MDLZ_OrderTriggerHandler.afterInsert(Trigger.newMap);
    } else if(trigger.isAfter && trigger.isUpdate){ 
        MDLZ_OrderTriggerHandler.afterUpdate(Trigger.newMap);
        //call method to log the order fields
        //Logging Can be turned off using the custom switch - MDLZ_Object_Logging__c instance = Order
        MDLZ_Object_Logging__c logObject = MDLZ_Object_Logging__c.getInstance('Order');        
        if(logObject != NULL && logObject.MDLZ_isActive__c)   {
            handler.logFieldChanges(Trigger.new);
        } 
    } 
    
}