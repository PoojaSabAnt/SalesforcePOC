/***************************************************************
Name: MDLZ_ProductUnitFlagChange
======================================================
Purpose:
a.Update the UOM for each product as an interim fix for SAP issue
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi         		  22/09/2021     Initial Development    
1.1      Priya Tubachi    Abir Ghosh  07/01/2022     
***************************************************************/
public with sharing class MDLZ_ProductUnitFlagChange {
    
    public static Boolean isTriggered = MDLZ_ConstantHelper.isTrue;
    
    public void ConsumerSalesUnitChange(List<ACCL__Unit_of_Measure__c> uomList){
          MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<ACCL__Unit_of_Measure__c> updDBList = new List<ACCL__Unit_of_Measure__c>();
        try{ 
            //loop through the list of products to update the unit of measure
            for(ACCL__Unit_of_Measure__c uom : uomList ){
                ACCL__Unit_of_Measure__c dbUOM = new ACCL__Unit_of_Measure__c();
                
                //update the consumer unit flags
                if (uom.ACCL__Unit_Type__c == System.Label.MDLZ_ConsumerUnit){
                    dbUOM.Id = uom.Id;
                    //change made to set price unit = false for consumer unit as per JIRA 2116
                    dbUOM.ACCL__Is_Price_Unit__c = MDLZ_ConstantHelper.isFalse;
                    dbUOM.ACCL__Is_Consumer_Unit__c = MDLZ_ConstantHelper.isTrue;
                    dbUOM.ACCL__Is_Order_Unit__c = MDLZ_ConstantHelper.isFalse;
                    dbUOM.ACCL__Order_Ability__c = MDLZ_ConstantHelper.isTrue;
                }else if(uom.ACCL__Unit_Type__c == System.Label.MDLZ_SalesUnit){
                    
                    //change made to set price unit = true for salesunit as per JIRA 2116
                    dbUOM.ACCL__Is_Price_Unit__c = MDLZ_ConstantHelper.isTrue;
                    dbUOM.Id = uom.Id;
                    dbUOM.ACCL__Is_Consumer_Unit__c = MDLZ_ConstantHelper.isFalse;
                    dbUOM.ACCL__Is_Order_Unit__c = MDLZ_ConstantHelper.isTrue;
                    dbUOM.ACCL__Order_Ability__c = MDLZ_ConstantHelper.isTrue;
                }
                updDBList.add(dbUOM);
            }
            
            //DML statement to update the records in the db
           // ExceptionLog__c errorlog = new ExceptionLog__c();
           
            system.debug('size of the db list to be updated '+updDBList.size());
            Database.SaveResult[] srList =   database.update(updDBList,false);
            exc.saveResultErrors(srList,updDBList,'MDLZ_ProductUnitFlagChange()','ACCL__Unit_of_Measure__c', 'Id');
            
            
        }catch(exception e){
            system.debug('An exception has occurred');
            exc.insertExceptions('MDLZ_ProductUnitFlagChange',e.getMessage(),e.getLineNumber(),e.getTypeName());
        } 
        
    }
}