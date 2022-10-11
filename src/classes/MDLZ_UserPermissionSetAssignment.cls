/***************************************************************
Name: MDLZ_UserPermissionSetAssignment
======================================================
Purpose:
a.Fetch all the new users lastmodified today and assigns the permission 
sets based on the role of the user.

======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              
1.0      Priya Tubachi                05/08/2021     Initial Development    
1.1      Priya Tubachi    Abir Ghosh  04/01/2022
1.2      Bharath/Vaidehi              01/03/2022     Added changes as per 2927, to delete existing permission set and 
assign new as per modified role.
1.3		Jinal Desai					  07/15/2022	 Added changes as per 3507 to include PermissionSetGroupId as part
of new permission set assignment
***************************************************************/

public with sharing class MDLZ_UserPermissionSetAssignment {    
    
    public void getUsersPermissionsSets(List<User> getUsers, List<ExceptionLog__c> logs){ 
        Map<Id, user> userMap = new Map<Id, User> (getUsers);
        Set<Id> assidSet = new Set<Id>();   
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();  
        List<PermissionSetAssignment> nPermAssigndb = new List<PermissionSetAssignment> ();
        List<PermissionSetAssignment> pSetList  =new  List<PermissionSetAssignment>();
        Map<String,Id> permSetIdMap = new Map<String,Id>(); 
        List<String> allPermSets = new List<String>();
        //initializing permission sets to be assigned based on each role        
        Map<String,String> roleCheck = new Map<String,String>();
        
        List<PermissionSetAssignment> psgList = new List<PermissionSetAssignment>();
        Map<String,Id> permSetGroupIdMap = new Map<String,Id>(); 
		List<PermissionSetAssignment> allPSList = new List<PermissionSetAssignment>();
        
        
        //get list of permission sets from Custom metadata in a list
        List<MDLZ_User_Custom_PermissionSet__mdt> mdtVal = MDLZ_User_Custom_PermissionSet__mdt.getAll().values();
        try{
            
            for(MDLZ_User_Custom_PermissionSet__mdt permSet : mdtVal){
                allPermSets.add(permSet.MDLZ_PermissionSets__c);
            }
            system.debug(allPermSets);
            //query db to get id's for all permission sets 
            for(PermissionSet ps : [select id,label from PermissionSet where label in:allPermSets 
                                    AND IsOwnedByProfile = false]){
                permSetIdMap.put(ps.label,ps.Id);
            }
            
             // Changes as per MRELKXIW-3507 - query to fetch all PermissionSetGroup
            for(PermissionSetGroup psg : [select id,MasterLabel,DeveloperName from PermissionSetGroup where DeveloperName in:allPermSets]){
                permSetGroupIdMap.put(psg.DeveloperName,psg.Id);
            }
            
            
            //Changes as per MRELKXIW-2927_________________START
            // Fetching the permissionsetassignment records for the given users and it will check for MDLZ permission sets only
            pSetList.addall([SELECT AssigneeId, PermissionSetId, permissionset.name FROM PermissionSetAssignment 
                             WHERE AssigneeId IN: getUsers and PermissionSetId IN: permSetIdMap.values()
                             AND PermissionSet.IsOwnedByProfile = false]);
            /* for(PermissionSetAssignment perm :[SELECT AssigneeId, PermissionSetId, permissionset.name FROM PermissionSetAssignment 
WHERE AssigneeId IN: getUsers and PermissionSetId IN: permSetIdMap.values()]){
pSetList.add(perm); 
}*/
            //Changes as per MRELKXIW-3507,
            //Fetching the permissionSetGroup records for the given users and it will check for MDLZ permissionGroupSets only
            if(permSetGroupIdMap != null && permSetGroupIdMap.size() > 0){
                psgList.addall([SELECT AssigneeId, PermissionSetGroupId,PermissionSetGroup.MasterLabel
                            FROM PermissionSetAssignment 
                             WHERE AssigneeId IN :getUsers and PermissionSetGroupId IN :permSetGroupIdMap.values()]);
            }
			
			allPSList.addAll([SELECT AssigneeId, PermissionSetId, permissionset.name FROM PermissionSetAssignment 
                             WHERE AssigneeId IN: getUsers AND PermissionSet.IsOwnedByProfile = false]);
			
			//Changes as per MRELKXIW-3507,this will delete the assigned/existing permission set assignments
			if(allPSList.size() > 0){
               List<Database.DeleteResult> dbList1 =database.Delete(allPSList);
                exc.deleteResultErrors(dbList1,allPSList,'MDLZ_UserPermissionSetAssignment()','PermissionSetAssignment','AssigneeId'); 
            }
            
			/*
            //this will delete the assigned/existing permission sets
            if(pSetList.size()>0){
                List<Database.DeleteResult> dbList1 =database.Delete(pSetList);
                exc.deleteResultErrors(dbList1,pSetList,'MDLZ_UserPermissionSetAssignment()','PermissionSetAssignment','AssigneeId');
            }
            //Changes as per MRELKXIW-2927_________________END
            
             //Changes as per MRELKXIW-3507,this will delete the assigned/existing permission group sets
            if(psgList.size() > 0){
                List<Database.DeleteResult> dbList2 =database.Delete(psgList);
                exc.deleteResultErrors(dbList2,psgList,'MDLZ_UserPermissionSetAssignment()','PermissionSetAssignment','AssigneeId');
            }*/
            
            /** Commenting old custom labels map , as we have new custom labels 
             * with new Permission Set Group for assignment
             
            //DSD_SalesRep_Merch
            roleCheck.put(MDLZ_ConstantHelper.UserPermSR , System.Label.MDLZ_PermsetSR);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSSRFT,System.Label.MDLZ_PermsetSSRFT);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSSR,System.Label.MDLZ_PermsetSSRFT_PT);
            roleCheck.put(MDLZ_ConstantHelper.UserPermVacation,System.Label.MDLZ_PermsetVacarep);
            // DSD_Managers
            roleCheck.put(MDLZ_ConstantHelper.UserPermDM,System.Label.MDLZ_PermsetDM);
            roleCheck.put(MDLZ_ConstantHelper.UserPermRMS,System.Label.MDLZ_PermsetRMS);
            roleCheck.put(MDLZ_ConstantHelper.UserPermREM ,System.Label.MDLZ_PermsetREM);
            roleCheck.put(MDLZ_ConstantHelper.UserPermRDR,System.Label.MDLZ_PermsetRDR);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSIM,System.Label.MDLZ_PermsetSIM);
            //System admin and Ops Admin
            roleCheck.put(MDLZ_ConstantHelper.UserPermSYSADM, System.Label.MDLZ_PermsetSysadm); 
            roleCheck.put(MDLZ_ConstantHelper.UserPermOPSADM, System.Label.MDLZ_PermsetOps);
             **/
           
            //DSD_SalesRep_Merch
            roleCheck.put(MDLZ_ConstantHelper.UserPermSR , System.Label.MDLZ_PermsetSR_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSSRFT,System.Label.MDLZ_PermsetSSRFTPT_FTOW_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSSR,System.Label.MDLZ_PermsetSSRFT_PT_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermVacation,System.Label.MDLZ_PermsetVacarep_New);
            
            // DSD_Managers
            roleCheck.put(MDLZ_ConstantHelper.UserPermDM,System.Label.MDLZ_PermsetDM_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermRMS,System.Label.MDLZ_PermsetRMS_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermREM ,System.Label.MDLZ_PermsetREM_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermRDR,System.Label.MDLZ_PermsetRDR_New);
            roleCheck.put(MDLZ_ConstantHelper.UserPermSIM,System.Label.MDLZ_PermsetSIM_New);
            
            //System admin and Ops Admin
            roleCheck.put(MDLZ_ConstantHelper.UserPermSYSADM, System.Label.MDLZ_PermsetSysadm); 
            roleCheck.put(MDLZ_ConstantHelper.UserPermOPSADM, System.Label.MDLZ_PermsetOps_New);
			roleCheck.put(MDLZ_ConstantHelper.UserPermRoleOPSADM, System.Label.MDLZ_PermsetOps_New);
            
            //CBT user
            roleCheck.put(MDLZ_ConstantHelper.UserPermCBT, System.Label.MDLZ_PermSet_CBT_new);
             
            
            if(permSetIdMap.size() > 0 ){
                //for each user do get the permissions to be assigned based on Role and assign
                for(User nUser: getUsers ){                    
                    //assign permissionsets based on the role of the user from the Map
                    if(nUser.UserRole.name != null || nUser.Profile.Name != null ){
                        String [] permissions = new String []{};
                            if(nUser.UserRole.name != null  && roleCheck.get(nUser.UserRole.Name) != null){
                                permissions =(roleCheck.get(nUser.UserRole.name)).split(',');
                            }   
                        else if(nUser.Profile.Name != null && roleCheck.get(nUser.Profile.Name) != null){
                            permissions =(roleCheck.get(nUser.Profile.Name)).split(',');   
                        }
                        
                        if(permissions != null && permissions.size() > 0){
                            for(String perm : permissions){
                                PermissionSetAssignment permAssign = new PermissionSetAssignment();
                                permAssign.AssigneeId =nUser.id;
                                //Changes as per MRELKXIW-3507, first PermissionSetGroupId will be assigned
                                 if(permSetGroupIdMap != null && permSetGroupIdMap.size() > 0
                                          && permSetGroupIdMap.containskey(perm)){
                                      permAssign.PermissionSetGroupId = permSetGroupIdMap.get(perm); 
                                  }else if(permSetIdMap != null && permSetIdMap.size() > 0
                                  && permSetIdMap.containsKey(perm)){
                                   permAssign.PermissionSetId = permSetIdMap.get(perm); 
                                  }
                                  
                                nPermAssigndb.add(permAssign);
                            }
                        }else{
                            system.debug('There are no permission sets defned for the role/profile of '+nUser.id);
                        }
                    }
                }}else{
                    system.debug('No permission sets are defined');
                }
            
            
            if(nPermAssigndb.size()>0){
                //ExceptionLog__c errorlog = new ExceptionLog__c();
                List<Database.SaveResult> dbList =   database.insert(nPermAssigndb,false);
				Set<Id> successId = new Set<Id>();
                for (Database.SaveResult sr : dbList) {
                    if (sr.isSuccess()) {
                        successId.add(sr.getId()); 
                    }else if(!sr.isSuccess()){
                        system.debug('Error creating PermissionSetAssignment Record is : '+sr.getErrors());
                    }
                }
                system.debug('Successfull permissionSetAssignment records created are : '+successId.size());
                //Changes as per MRELKXIW-2927_________________START
                //Assigning dbList to nPermAssigndbMap so that we can get assigneeId from success id
                Map<Id,PermissionSetAssignment> nPermAssigndbMap = new  Map<Id,PermissionSetAssignment>(nPermAssigndb);
                for (Database.SaveResult sr : dbList) {
                    if (sr.isSuccess()) {
                        assidSet.add(nPermAssigndbMap.get(sr.getId()).AssigneeId); 
                    }
                }
                exc.saveResultErrors(dbList,nPermAssigndb,'MDLZ_UserPermissionSetAssignment()','PermissionSetAssignment','AssigneeId');
            }  
            if(assidSet.size()>0){
                updateUserFlag(assidSet , userMap);     
            }}catch(exception e){
                //adding this to avoid mixed DML Exception 
                logs.add(new ExceptionLog__c(MethodName__c = 'MDLZ_UserPermissionSetAssignment',ExceptionDetails__c = e.getMessage(),
                                             Error_Line_Number__c = e.getLineNumber(),ExceptionCode__c = e.getTypeName()));
                // exc.insertExceptions('MDLZ_UserPermissionSetAssignment',e.getMessage(),e.getLineNumber(),e.getTypeName());
            }  
    }    
    //Changes as per MRELKXIW-2927_________________START
    public static void updateUserFlag(Set<Id>userIdSet, Map<Id, User>userMap){
        List<User> usrlists = new  List<User>();
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler(); 
        try{for(Id usr : userIdSet){
            User  u =  userMap.get(usr);
            u.MDLZ_isRoleChanged__c =MDLZ_ConstantHelper.BatchProcessed; 
            usrlists.add(u);
        }
            if(usrlists.size()>0){
                List<Database.SaveResult> dbList2 = database.update(usrlists, false);
                exc.saveResultErrors(dbList2,usrlists,'MDLZ_UserPermissionSetAssignment.updateUserFlag()','User','Id'); 
            }}catch(Exception ex){
                exc.insertExceptions('MDLZ_USerPemissionsetAssignment.updateUserFlag()',ex.getMessage(),ex.getLineNumber(),ex.getTypeName()); 
            }
        
    }
    
    //Changes as per MRELKXIW-2927_________________END
}