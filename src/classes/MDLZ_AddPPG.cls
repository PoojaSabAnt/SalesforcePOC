/***************************************************************
Name: MDLZ_AddPPG
======================================================
History
-------

VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0        Vaidehi Heda                              20/06/2022       For MDLZ_TacticsProductView LWC.For add PPG on promotion page
***************************************************************/ 
public with sharing class MDLZ_AddPPG {
    public MDLZ_AddPPG() {
        
    }
    
    //This method will get all the PPG  and sub PPG from Products
    //This will return multiple sub PPG for same PPGfrom all products
    //In LWC this will be shown as a dependent picklist
    @AuraEnabled(cacheable=true)
    public static Map<string,List<String>> getProducts() {
        Map<string,List<String>> prodMap = new  Map<string,List<String>>();
        for(ACCL__Product__c prd: [SELECT Id, MDLZ_PPG__c, MDLZ_SubPPG__c  FROM ACCL__Product__c  WHERE MDLZ_PPG__c!= null AND ACCL__State__c = '4' Order By MDLZ_PPG__c]){
            if(prodMap.containsKey(prd.MDLZ_PPG__c)){
                if(!prodMap.get(prd.MDLZ_PPG__c).contains(prd.MDLZ_SubPPG__c))
                    prodMap.get(prd.MDLZ_PPG__c).add(prd.MDLZ_SubPPG__c);
            } else {
                prodMap.put(prd.MDLZ_PPG__c, new List<String>{prd.MDLZ_SubPPG__c});
            }
        } system.debug(prodMap);
        return prodMap; 
    }
  
    
    //This method is used to get all tactic Product records on initial page load
    //for related Tactic
    @AuraEnabled
    public static List<ACCL__Tactic_Product__c> getTacticProducts(Id tacId) {
        Map<String, ACCL__Tactic_Product__c> prodMap = new Map<String, ACCL__Tactic_Product__c>();
        for(ACCL__Tactic_Product__c prod: [SELECT Id,MDLZ_Price__c,MDLZ_Location__c,MDLZ_SubPPG__c,MDLZ_PPG__c, Name,ACCL__Tactic__c, ACCL__Tactic__r.ACCL__Promotion__c,
                                           ACCL__Tactic__r.ACCL__Promotion__r.name,ACCL__Included__c, ACCL__Product__c  FROM ACCL__Tactic_Product__c WHERE ACCL__Tactic__c =:tacId
                                           ORDER BY MDLZ_PPG__c ASC]){
                                               if(!prodMap.containsKey(prod.MDLZ_PPG__c+'|'+prod.MDLZ_SubPPG__c)){
                                                   prodMap.put(prod.MDLZ_PPG__c+'|'+prod.MDLZ_SubPPG__c, prod);
                                               }
                                           }
        return prodMap.values();
    }
    
    //This will update tactic Product on click of save icon from LWC
    //and it will update all the related T Product based on PPG and Sub PPg combination for related Tactic
    @AuraEnabled
    public static  Map<String, String> updateTacticProd( ACCL__Tactic_Product__c tacRec, Object data , Id recordId) { 
        Map<String, String>mapToReturn = new Map<String, String>();  
        Map<Id,ACCL__Tactic_Product__c> tProMap ;
        List<ACCL__Tactic_Product__c> updatedList = new List<ACCL__Tactic_Product__c>();
        List <ACCL__Tactic_Product__c> prodsForUpdate = (List<ACCL__Tactic_Product__c>)JSON.deserialize(
            JSON.serialize(data),
            List <ACCL__Tactic_Product__c>.class
        );
        if(prodsForUpdate.size()>0){ 
            tProMap = new Map<Id,ACCL__Tactic_Product__c>(prodsForUpdate);
            updatedList =getAllPPGSubPPG(tacRec, tProMap , recordId);
            database.SaveResult[] srList = database.update(updatedList,true);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){                    
                    mapToReturn.put(MDLZ_ConstantHelper.ResultMap_KeySuccess,MDLZ_ConstantHelper.ResultMap_KeySuccess);
                }else if(!sr.isSuccess()){
                    for(Database.Error err: sr.getErrors()){
                        mapToReturn.put(MDLZ_ConstantHelper.ApexError, 'This PPG cannot be updated.');
                    }
                }
            }}     return mapToReturn;
    }
    
    //This method is used to insert tactic Products entered from LWC 
    //It will create multiple tactic Product records based on combination of PPG and Sub PPG for related tactic
    @AuraEnabled
    public static String  insertTProds(String jsonOfListOfTPRoducts) {
        Map<String, String>proMap = new Map<String, String>();
        Map<String, List<Id>> proIdMap = new Map<String, List<Id>>();
        Set<String> PPGSet = new Set<String>();
        Set<Id> tacticIds = new Set<Id>();
        List<ACCL__Tactic_Product__c>proList = new List<ACCL__Tactic_Product__c>();
        try{
            List<ACCL__Tactic_Product__c> listOfProds = (List<ACCL__Tactic_Product__c>) JSON.deserialize(jsonOfListOfTPRoducts, List<ACCL__Tactic_Product__c>.class);
            for(ACCL__Tactic_Product__c prod: listOfProds){
                if(!String.isBlank(prod.MDLZ_SubPPG__c) || prod.MDLZ_SubPPG__c != null){
                    string pKey =prod.MDLZ_PPG__c+'|'+prod.MDLZ_SubPPG__c ;
                    proMap.put(pKey,prod.MDLZ_SubPPG__c );
                } else {
                    string pKey =prod.MDLZ_PPG__c+'|blank' ;
                    proMap.put(pKey,'blank');
                }
                tacticIds.add(prod.ACCL__Tactic__c);
                PPGSet.add(prod.MDLZ_PPG__c);                
            }
            if(proMap.size()>0){
                proIdMap= getProdPPG(proMap, PPGSet, tacticIds);
            }
            if(proIdMap.size()>0){
                for(ACCL__Tactic_Product__c tPro :listOfProds){
                    string proKey;
                    if(!String.isBlank(tPro.MDLZ_SubPPG__c) || tPro.MDLZ_SubPPG__c != null){
                        proKey =tPro.MDLZ_PPG__c+'|'+tPro.MDLZ_SubPPG__c;
                    } else {
                        proKey =tPro.MDLZ_PPG__c+'|blank' ;
                    }
                    List<Id> IdList = proIdMap.get(proKey);
                    for(integer i=0; i<IdList.size() ; i++){
                        ACCL__Tactic_Product__c prodT = new ACCL__Tactic_Product__c();
                        prodT.ACCL__Product__c = IdList[i];
                        prodT.MDLZ_PPG__c= tPro.MDLZ_PPG__c ;
                        if(!String.isBlank(tPro.MDLZ_SubPPG__c) || tPro.MDLZ_SubPPG__c != null){
                            prodT.MDLZ_SubPPG__c= tPro.MDLZ_SubPPG__c ;
                        }
                        prodT.ACCL__Tactic__c= tPro.ACCL__Tactic__c ;
                        prodT.MDLZ_Price__c= tPro.MDLZ_Price__c ;
                        prodT.MDLZ_Location__c= tPro.MDLZ_Location__c ;
                        proList.add(prodT); 
                    }
                }
            }
            insert proList;
            return 'Success : Products updated successfully';
        }catch(Exception e){
            system.debug(e.getMessage() +'  '+e.getLineNumber());
            return 'Error :The following exception has occurred: ' + e.getMessage();
        }
    }
    
    
    public static Map<String, List<Id>> getProdPPG(Map<String, String> proMap, Set<String> PPGSet, Set<Id> tacticIds ) {
        Map<String, List<Id>> proIdMap = new Map<String,List<Id>>();
        //Added List of existing tactic Products to check for duplicate
        List<String> existingPpgSubPpgString = new List<String>();
        for(AggregateResult tacticProduct : [SELECT MDLZ_PPG__c, MDLZ_SubPPG__c, ACCL__Tactic__c FROM ACCL__Tactic_Product__c GROUP BY MDLZ_PPG__c, MDLZ_SubPPG__c, ACCL__Tactic__c HAVING ACCL__Tactic__c IN :tacticIds]){
            if(!String.isBlank(String.valueOf(tacticProduct.get('MDLZ_SubPPG__c'))) || String.valueOf(tacticProduct.get('MDLZ_SubPPG__c')) != null){
                existingPpgSubPpgString.add(String.valueOf(tacticProduct.get('MDLZ_PPG__c')) + '|' + String.valueOf(tacticProduct.get('MDLZ_SubPPG__c')));
            } else {
                existingPpgSubPpgString.add(String.valueOf(tacticProduct.get('MDLZ_PPG__c')) + '|blank');
            }
        }
        for(ACCL__PRoduct__c prod: [SELECT id , name, MDLZ_PPG__c, MDLZ_SubPPG__c FROM ACCL__PRoduct__c WHERE
                                    MDLZ_PPG__c IN: PPGSet AND ACCL__State__c = '4'] ){
                                        String PPGString =prod.MDLZ_PPG__c+'|'+ prod.MDLZ_SubPPG__c;
                                        String blankPPGString = prod.MDLZ_PPG__c+'|blank' ;
                                        if(proMap.get(PPGString) == prod.MDLZ_SubPPG__c && !existingPpgSubPpgString.contains(PPGString)){                                        
                                            if(proIdMap.containsKey(PPGString)){
                                                proIdMap.get(PPGString).add(prod.Id);
                                            } else {
                                                proIdMap.put(PPGString, new List<Id>{prod.Id});
                                            }
                                        } else if(proMap.get(blankPPGString) == 'blank' && !existingPpgSubPpgString.contains(blankPPGString)){
                                            if(proIdMap.containsKey(blankPPGString)){
                                                proIdMap.get(blankPPGString).add(prod.Id);
                                            } else {
                                                proIdMap.put(blankPPGString, new List<Id>{prod.Id});
                                            }
                                        }
                                    }system.debug(proIdMap);
        return proIdMap;
    }

    //Wrapper is created to accomodate the change as per story number MRELKXIW-4730
    public class ProdPPGWrapper{
        @AuraEnabled public List<String> subPPGList;
        @AuraEnabled public List<Id> prodIdList;
    }
    
    //This method will be called on click of delete icon 
    //for deleteing any Tactic Product record
    @AuraEnabled
    public static Map<String, String> deleteTacticProd( ACCL__Tactic_Product__c tacRec , Id recordId) { 
        Map<String, String>mapToReturn = new Map<String, String>(); 
        List <ACCL__Tactic_Product__c> updatedProdsForDelete = new  List <ACCL__Tactic_Product__c> ();
        if(tacRec != null){
            updatedProdsForDelete = getAllPPG(tacRec, recordId);
        }
        database.deleteResult[] srList = database.delete(updatedProdsForDelete,true);
        for(Database.deleteResult sr : srList){
            if(sr.isSuccess()){                    
                mapToReturn.put(MDLZ_ConstantHelper.ResultMap_KeySuccess,MDLZ_ConstantHelper.ResultMap_KeySuccess);
            }else if(!sr.isSuccess()){
                for(Database.Error err: sr.getErrors()){
                    mapToReturn.put(MDLZ_ConstantHelper.ApexError, 'This PPG cannot be deleted.');
                }
            }
        }     return mapToReturn;
    }
    
    
    
    public static  List<ACCL__Tactic_Product__c> getAllPPG(ACCL__Tactic_Product__c tacRec , Id tacId){        
        List <ACCL__Tactic_Product__c> updatedTProList = new List <ACCL__Tactic_Product__c>();
        for(ACCL__Tactic_Product__c pro : [SELECT id,MDLZ_PPG__c, MDLZ_SubPPG__c FROM ACCL__Tactic_Product__c WHERE ACCL__Tactic__c =:tacId
                                          AND MDLZ_PPG__c =:tacRec.MDLZ_PPG__c AND MDLZ_SubPPG__c =:tacRec.MDLZ_SubPPG__c] ){
           updatedTProList.add(pro);
        }    
        return updatedTProList;
    } 
    
    
    public static List<ACCL__Tactic_Product__c> getAllPPGSubPPG(ACCL__Tactic_Product__c tProduct, Map<Id, ACCL__Tactic_Product__c>tProMap ,Id tacId){
        List<ACCL__Tactic_Product__c> tProList = new List<ACCL__Tactic_Product__c>();
        for(ACCL__Tactic_Product__c pro: [SELECT Id,MDLZ_SubPPG__c,MDLZ_PPG__c FROM ACCL__Tactic_Product__c WHERE ACCL__Tactic__c =:tacId
                                        AND MDLZ_PPG__c=:tProduct.MDLZ_PPG__c AND MDLZ_SubPPG__c =:tProduct.MDLZ_SubPPG__c]){
                                            if(tProMap.get(tProduct.Id).MDLZ_Price__c!= null){
                                                pro.MDLZ_Price__c = tProMap.get(tProduct.Id).MDLZ_Price__c; 
                                            }if(tProMap.get(tProduct.Id).MDLZ_Location__c!= null){
                                                pro.MDLZ_Location__c = tProMap.get(tProduct.Id).MDLZ_Location__c; 
                                            }
                                            tProList.add(pro);
                                        }
    
        return tProList;
    }
    
    
    
}