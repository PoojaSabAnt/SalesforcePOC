/***************************************************************
Name: MDLZ_ProductUnitFlagChangeTrigger
======================================================
Purpose:
a.Update the UOM for each product as an interim fix for SAP issue
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Priya Tubachi         		 22/09/2021     Initial Development    

***************************************************************/

trigger MDLZ_ProductUnitFlagChangeTrigger on ACCL__Unit_of_Measure__c (after insert, after update) {
    //Mute Trigger using  Custom Setting 
    MDLZ_Trigger_Switch__c switchVar = MDLZ_Trigger_Switch__c.getInstance('MDLZ_ProductUnitFlagChangeTrigger');
    if(switchVar != NULL && 'false'.equalsIgnorecase(String.valueOf(switchVar.MDLZ_Active__c)))   { 
        return;
    }
    //Calling trigger after product is inserted or created in SF
    if(MDLZ_ProductUnitFlagChange.isTriggered ){
        MDLZ_ProductUnitFlagChange.isTriggered = false;
        
        if(trigger.isAfter){
            if(trigger.isUpdate || trigger.isInsert){ 
                MDLZ_ProductUnitFlagChange handler = new MDLZ_ProductUnitFlagChange();
                handler.ConsumerSalesUnitChange(Trigger.new);
            }
        }
    }
}