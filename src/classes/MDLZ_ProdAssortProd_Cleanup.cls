/***************************************************************
Name: MDLZ_ProdAssortProd_Cleanup
======================================================
Purpose:
Batch process  runs every day that identifies 
Product Assortment Products that have not been updated in the past X-weeks 
(X should be a configurable variable that can be changed but will have a default value of 2)
and deactivates these records. Deactivation sohuld include setting the Valid Thru date to the current date and setting the active flag to false.
======================================================
History
-------
VERSION     AUTHOR               REVIEWER      DATE             DETAIL                 Description
1.0         Bharath_Vikkurthi                             07/02/2022     Initial Development    

***************************************************************/
public with sharing  class MDLZ_ProdAssortProd_Cleanup {
    
     List<ACCL__Product_Assortment_Product__c> prodAssList2 = new List<ACCL__Product_Assortment_Product__c>();
        List<ExceptionLog__c> expctlog = new List<ExceptionLog__c>();
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
    public  void getLastModrec(List<ACCL__Product_Assortment_Product__c> prodAssList ){
      System.debug('prodAssList' + prodAssList);
        try{
            //deactivate the active flag and valid thru
            for (ACCL__Product_Assortment_Product__c prd : prodAssList ){
                
                prd.ACCL__Active__c = MDLZ_ConstantHelper.isFalse;
                prd.ACCL__Valid_Thru__c =System.today();
                
                prodAssList2.add(prd);
            }
            List<Database.SaveResult>  srList  =  database.update(prodAssList2, false);
            System.debug('srList Id' + srList);
            if(srList.size()>0){
                    exc.saveResultErrors(srList,prodAssList2,'MDLZ_ProdAssortProd_Cleanup()','ACCL__Product_Assortment_Product__c', null);
                    
                }else{
                system.debug('No records to be updated');
            }
            
        }catch(Exception e){   
            MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
            exc.insertExceptions('MDLZ_ProdAssortProd_Cleanup()',e.getMessage(),e.getLineNumber(),e.getTypeName()); 
            
        } 
    }
}