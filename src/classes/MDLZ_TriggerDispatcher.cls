/***************************************************************
Name: MDLZ_TriggerDispatcher 
Created Date: 24/02/2022
***************************************************************/
public class MDLZ_TriggerDispatcher {

    public static void Run(MDLZ_ITrigger handler) {
        if (handler.isDisabled())
            return;
        if (Trigger.IsBefore ){
            if (Trigger.IsInsert){
                handler.beforeInsert(trigger.new);}
            else if (Trigger.IsUpdate){
                handler.beforeUpdate(trigger.newMap, trigger.oldMap); }
           else  if (Trigger.IsDelete){
                handler.beforeDelete(trigger.oldMap);}
        }         
        // After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert){
                handler.afterInsert(Trigger.newMap);}
            else if (Trigger.IsUpdate){
                handler.afterUpdate(trigger.newMap, trigger.oldMap);}
            else if (trigger.IsDelete){
                handler.afterDelete(trigger.oldMap);}
            else if (trigger.isUndelete){
                handler.afterUndelete(trigger.oldMap);}
        }
    }   
}