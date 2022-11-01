/***************************************************************
Name: MDLZ_ErrorExceptionHandler
======================================================
Purpose:
Factory for handling errors and exceptions in the classes
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                07/01/2022     Initial Development    
1.1      Vaidehi Heda                 01/03/2022     Added deleteResultErrors(),to log the error for deleteResult method
which is refrrred in MDLZ_UserPermissionSetAssignment class.
***************************************************************/

public class MDLZ_ErrorExceptionHandler {
    
    //common method to insert exceptions from batches
    public  void insertExceptions(String methodName, String message,integer lineNumber,String typeName){
        try{
            ExceptionLog__c errorlog = new ExceptionLog__c();
            errorlog.MethodName__c = methodName;
            errorlog.ExceptionDetails__c = message;
            errorlog.Error_Line_Number__c = lineNumber;
            errorlog.ExceptionCode__c = typeName;
            insert errorlog;
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
    }
    
    //common method to insert exceptions from batches
    public  void  insertExceptions( List<ExceptionLog__c> exceptionList){
        
        if(exceptionList.size()>0){
            insert exceptionList;
        }
    }
    
    //common method to insert exceptions in future for user triggerhandler 
    //to avoid Mixed DML
    @future
    public static void insertFutureExceptions(String methodName, String message,integer lineNumber,String typeName){
        try{
            ExceptionLog__c errorlog = new ExceptionLog__c();
            errorlog.MethodName__c = methodName;
            errorlog.ExceptionDetails__c = message;
            errorlog.Error_Line_Number__c = lineNumber;
            errorlog.ExceptionCode__c = typeName;
            insert errorlog;
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
    }
    
    
    //common method to insert errors from batches
    public void upsertResultErrors(List<database.UpsertResult> srList,List<sObject> dbList,String methodName,String obj){
        //public void upsertResultErrors(List<database.UpsertResult> srList,String methodName,List<sObject> dbList){
        List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();
        Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
        sObject pasObj = allObjMetaType.get(obj).newSObject();
        try{for(Integer i=0;  i<srList.size();  i++){
            if (srList.get(i).isSuccess()){
                srList.get(i).getId();
            }else if(!srList.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = srList.get(i).getErrors().get(0);
                ExceptionLog__c errorlog = new ExceptionLog__c();
                errorlog.MethodName__c=methodName; 
                pasObj = dbList.get(i);
                //String test =Schema.getGlobalDescribe().get(dbList.get(i)).getDescribe().fields.getMap().get(fieldName);
                errorlog.ExceptionDetails__c ='Error occurred for record '+pasObj;
                errorlog.ExceptionCode__c = error.getMessage();
                expctlog.add(errorlog);                
            }    } 
            database.insert(expctlog, false); 
           }catch(Exception ex){
               insertExceptions('MDLZ_ErrorExceptionHandler.upsertResultErrors()', ex.getMessage(),ex.getLineNumber(),ex.getTypeName());
           }
    }
    
    //common method to insert errors from batches
    public void saveResultErrors(List<database.SaveResult> srList,List<sObject> dbList,String methodName,String obj, string fName){
        //public void upsertResultErrors(List<database.UpsertResult> srList,String methodName,List<sObject> dbList){
        List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();        
        Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
        sObject pasObj = allObjMetaType.get(obj).newSObject();
        try{ for(Integer i=0;  i<srList.size();  i++){
            if (srList.get(i).isSuccess()){
                srList.get(i).getId();
            }else if(!srList.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = srList.get(i).getErrors().get(0);
                ExceptionLog__c errorlog = new ExceptionLog__c();
                errorlog.MethodName__c=methodName; 
                pasObj = dbList.get(i);
                if(fName != null){
                    errorlog.ExceptionDetails__c ='Error occurred for record '+pasObj.get(fName);
                }else{errorlog.ExceptionDetails__c ='Error occurred for record '+pasObj.get('Id');}
                errorlog.ExceptionCode__c = error.getMessage();
                expctlog.add(errorlog);             
            }      } 
            database.insert(expctlog, false); 
           }catch(Exception ex){
               insertExceptions('MDLZ_ErrorExceptionHandler.saveResultErrors()', ex.getMessage(),ex.getLineNumber(),ex.getTypeName());
           }}
    
    
    //common method to insert errors from batches for DeleteResult
    public void deleteResultErrors(List<database.DeleteResult> srList,List<sObject> dbList,String methodName,String obj, string fName){
        //public void upsertResultErrors(List<database.UpsertResult> srList,String methodName,List<sObject> dbList){
        List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();
        Map<String, Schema.SObjectType> allObjMetaType = AddOnConstants.allObjectMetadataTypes;
        sObject pasObj = allObjMetaType.get(obj).newSObject();
        try{ for(Integer i=0;  i<srList.size();  i++){
            if (srList.get(i).isSuccess()){
                // srList.get(i).getId();
            }else if(!srList.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = srList.get(i).getErrors().get(0);
                ExceptionLog__c errorlog = new ExceptionLog__c();
                errorlog.MethodName__c=methodName; 
                pasObj = dbList.get(i);
                system.debug(pasObj);
                if(fName != null){
                    errorlog.ExceptionDetails__c ='Error occurred for record '+pasObj.get(fName);
                }else{errorlog.ExceptionDetails__c ='Error occurred for record '+pasObj.get('Id');}
                errorlog.ExceptionCode__c = error.getMessage();
                expctlog.add(errorlog);  }   } 
            database.insert(expctlog, false); 
           }catch(Exception ex){
               insertExceptions('MDLZ_ErrorExceptionHandler.deleteResultErrors()', ex.getMessage(),ex.getLineNumber(),ex.getTypeName());
           }      }
    
}