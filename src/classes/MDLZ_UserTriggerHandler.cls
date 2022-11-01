/***************************************************************
Name: MDLZ_UserTriggerHandler
======================================================
Purpose:
a. Apex handler class for user trigger
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL                 Description
1.0         Vaidehi Heda               24/02/2022   Initial Development  
1.1         Vaidehi Heda               30/03/2022   Making changes  to insert package assignment if any active user is
                                                    inserted and removing assignment if any user is deactivated.
***************************************************************/ 
public class MDLZ_UserTriggerHandler implements MDLZ_ITrigger {
    
    private static Boolean TriggerDisabled ; 
    private static Id pkgId = getPackageID(MDLZ_ConstantHelper.PACKAGENAMESPACEPREFIX);
    //public static Set<Id>adminIdSet = getAdminProfileSet();
    public static Set<Id>adminWOOpsIdSet = getIntSysAdminProId();
    private static MDLZ_ErrorExceptionHandler ex = new MDLZ_ErrorExceptionHandler();
    MDLZ_ErrorExceptionHandler exc;     
    
    //Constructor for usertrigger handler class
    public MDLZ_UserTriggerHandler() {
        exc = new MDLZ_ErrorExceptionHandler();
        TriggerDisabled = false;
    }
    
    
    //method to check trigger is disabled or not from custom setting
    public Boolean isDisabled(){
        MDLZ_Trigger_Switch__c switchVar = MDLZ_Trigger_Switch__c.getInstance('MDLZ_UserTrigger');
        if(switchVar != NULL && !switchVar.MDLZ_Active__c){ 
            TriggerDisabled=  true; }
        return TriggerDisabled;
    }
    
    //This method is called on before insert for user object
    public static void beforeInsert(List<User> newUserList){
        try{ For(User usr : newUserList){
            If(adminWOOpsIdSet.contains(usr.profileId)){
                //This condition will check for user profile and then it will update the isrolechanged picklist value
                usr.MDLZ_isRoleChanged__c = MDLZ_ConstantHelper.INTEGRATIONADMIN;
            }}}catch(Exception ex){
                MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHanler.beforeInsert()',
                                                                  ex.getMessage(),ex.getLineNumber(),ex.getTypeName());
            }
    }
    
    
    //This method is called on before update
    public static void beforeUpdate(Map<Id,sObject>newMap, Map<Id,sObject>oldMap) {
        Map<Id, User>oldUserMap = (Map<Id, User>)oldMap;
        Map<Id, User>newUserMap = (Map<Id, User>)newMap;
        try{
            For(User usr : newUserMap.values()){
                //This condition will check for user profile and then it will update the isrolechanged picklist value
                If(adminWOOpsIdSet.contains(usr.profileId) && usr.MDLZ_isRoleChanged__c != MDLZ_ConstantHelper.INTEGRATIONADMIN){
                    usr.MDLZ_isRoleChanged__c = MDLZ_ConstantHelper.INTEGRATIONADMIN;
                }else If(usr.UserRoleId != oldUserMap.get(usr.id).UserRoleId && !(adminWOOpsIdSet.contains(usr.profileId))){
                    usr.MDLZ_isRoleChanged__c =MDLZ_ConstantHelper.RoleChanged;
                }}}catch(Exception ex){
                    MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHanler.beforeUpdate()',
                                                                      ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
                }
    }
    
    //This method will be called on after insert
    public static  void afterInsert(Map<Id, sObject> newMap){
        Map<Id, User>newUserMap = (Map<Id, User>)newMap;
        Set<Id>userIdSet = new Set<Id>();
        try{for(User us : newUserMap.values()){
            if(us.isactive && !adminWOOpsIdSet.contains(us.profileId)){
                userIdSet.add(us.Id);//adding active userids to set
            }}
            if(userIdSet.size()>0){
                createUserPackageLicense(userIdSet);  
            }}catch(Exception ex){
                MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHanler.afterInsert()',
                                                                  ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
            }
    }
    //This method will be called on after update
    public static void afterUpdate(Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        Set<Id>actUserIdSet = new Set<Id>();
        Set<Id>inactUserIdSet = new Set<Id>();
        Map<Id, User>oldUserMap = (Map<Id, User>)oldMap;
        Map<Id, User>newUserMap = (Map<Id, User>)newMap;
        try{ for(User us : newUserMap.values()){
            if(us.isactive != oldUserMap.get(us.id).isactive && !adminWOOpsIdSet.contains(us.profileId)){
                if(us.isactive){
                    actUserIdSet.add(us.Id);//adding active user ids to set 
                }else if(!us.isactive){
                    inactUserIdSet.add(us.Id); //adding inactive user ids to set
                }}}
            if(actUserIdSet.size()>0){
                createUserPackageLicense(actUserIdSet);  
            }if(inactUserIdSet.size()>0){
                deleteUserPackageLicense(inactUserIdSet);
            }}catch(Exception ex){
                MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHanler.afterUpdate()',
                                                                  ex.getMessage(),ex.getLineNumber(),ex.getTypeName());    
            }
    }  
    
    
    
    //This method will return set of Admin Profile Id  and the profile names are added in metadata
   /* public static Set<Id> getAdminProfileSet(){
        Set<string> profNameSet =new Set<string>();
        Set<Id>proIdSet = new Set<Id>();
        profNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance(MDLZ_ConstantHelper.intUser).Profile_API_Name__c);
        profNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance(MDLZ_ConstantHelper.opsAdmin).Profile_API_Name__c);
        profNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance(MDLZ_ConstantHelper.sysAdmin).Profile_API_Name__c);        
        proIdSet.addall(new Map<Id, Profile>([SELECT id FROM Profile WHERE Name IN: profNameSet]).keySet());
        return proIdSet;
    }*/
    
    //added this as we need id for admin and integration user profile only
    //in earlier method we are fetching ids for 3 profiles sys admin, integration user and ops admin
    public static Set<Id> getIntSysAdminProId(){
        Set<string> profNameSet =new Set<string>();
        Set<Id>proIdSet = new Set<Id>();
        profNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance(MDLZ_ConstantHelper.sysAdmin).Profile_API_Name__c);
        profNameSet.add(MDLZ_Admin_Profiles__mdt.getInstance(MDLZ_ConstantHelper.intUser).Profile_API_Name__c);
        proIdSet.addall(new Map<Id, Profile>([SELECT id FROM Profile WHERE Name IN: profNameSet]).keySet());
        return proIdSet;
    }
    
    
    //Method for Package assignment for active users
    public static void createUserPackageLicense(Set<Id>userIdSet){
	List<UserPackageLicense> inspkgLicenseList = new List<UserPackageLicense>();
        try{for(Id usId :userIdSet) {
            inspkgLicenseList.add(new UserPackageLicense(UserId = usId, PackageLicenseId = pkgId));}
            if(inspkgLicenseList.size()>0){
                database.insert(inspkgLicenseList, false);           
            }}catch(Exception e){
                MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHandler.createUserPackageLicense()',
                                                                  e.getMessage(),e.getLineNumber(),e.getTypeName());  
            }
    }
    
    //Method for removing Package assignment for inactive users
    public static void deleteUserPackageLicense(Set<Id>userIdSet){
	 List<UserPackageLicense> delPkgLicenseList = new List<UserPackageLicense>();
        try{ delPkgLicenseList = [SELECT id FROM UserPackageLicense WHERE userid IN: userIdSet];
            if(delPkgLicenseList.size()>0){
               database.delete(delPkgLicenseList ,false);
            } }catch(Exception e){
                MDLZ_ErrorExceptionHandler.insertFutureExceptions('MDLZ_UserTriggerHandler.deleteUserPackageLicense()',
                                                                  e.getMessage(),e.getLineNumber(),e.getTypeName());  
            }
    }
    
    private static Id getPackageID(String namespace){
        Id pkgId = null;
        pkgId = [SELECT Id FROM PackageLicense WHERE NamespacePrefix =: namespace LIMIT 1].Id;
        return pkgId;
    }
    
    
    //Delete and undelete is not applicable for User object
    //This method will be called after delete
    public static void afterDelete(Map<Id, sObject> oldItems) {} 
    //This method will be called after undelete
    public static void afterUndelete(Map<Id, SObject> oldItems) {} 
    //This method will be called on before delete
    public static void beforeDelete(Map<Id, sObject> oldItems) {}
}