/***************************************************************
Name: MDLZ_TeamTerritoryUserAssignment
======================================================
Purpose:
Org unit users creation
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL             
1.0      Priya Tubachi                05/09/2021     Initial Development    
1.1		 Priya Tubachi	  Abir Ghosh  07/01/2022

***************************************************************/
public with sharing class MDLZ_TeamTerritoryUserAssignment {
    //method called from MDLZ_TeamTerritoryUserAssignmentBatch and MDLZ_RDRTeamUserAssignBatch
    public void assignUsers(List<ACCL__Org_Unit__c> teamList ){
        
        MDLZ_ErrorExceptionHandler exc = new MDLZ_ErrorExceptionHandler();
        List<ACCL__Org_Unit_User__c> teamTerrUsersList = new List<ACCL__Org_Unit_User__c>();
        
        //MAP1 - create map to hold territory as a key and team as value
        //Assumption - one territory will always be mapped to one team and not multiple teams.
        Map<Id,Id> terrTeamMap = new Map<Id,Id>();
        List<id> terrList = new List<id>();//list of territories
        Map<id,String> terrNameMap = new Map<id,String>();
        
        //Map2 - create map for team/territory and its users as a list
        Map<id,List<id>> teamTerrUsersMap = new Map<id,List<id>>();
        Id team;
        
        //Map3 - hold key = team/terr|user and value = user details
        Map<String,ACCL__Org_Unit_User__c> userDetails = new Map<String,ACCL__Org_Unit_User__c>();
        
        //create a list users to add to the map
        List<id> userList = new List<id>();
        
        //create a list to add records to db
        List<ACCL__Org_Unit_User__c> updDBList = new List<ACCL__Org_Unit_User__c>();
        
        system.debug('team list size '+teamList.size());
        try{
            //get territory list for each team ordered by team
            if(!teamList.isEmpty()){
                
                for(ACCL__Org_Unit_Hierarchy__c listItem :[select id,ACCL__Child_Org_Unit__c,ACCL__Child_Org_Unit__r.name, ACCL__Parent_Org_Unit__c  
                                                           from ACCL__Org_Unit_Hierarchy__c where ACCL__Parent_Org_Unit__c in: teamList order by ACCL__Parent_Org_Unit__c]){
                                                               
                                                               terrTeamMap.put(listItem.ACCL__Child_Org_Unit__c,listItem.ACCL__Parent_Org_Unit__c);
                                                               terrNameMap.put(listItem.ACCL__Child_Org_Unit__c,listItem.ACCL__Child_Org_Unit__r.name);
                                                               terrList.add(listItem.ACCL__Child_Org_Unit__c);
                                                           }  
                //creating one list for team and territory
                terrList.addAll((new Map<Id,ACCL__Org_Unit__c>(teamList)).keySet());
                
                //get Team and territory users from DB as one list
                teamTerrUsersList = [select id,ACCL__User__c,ACCL__User__r.IsActive,ACCL__User__r.MDLZ_SharpId__c,MDLZ_isOrgUnitChanged__c,ACCL__Valid_Thru__c, ACCL__Org_Unit__c, 
                                     ACCL__Org_Unit__r.ACCL__Org_Level__c from ACCL__Org_Unit_User__c where ACCL__Org_Unit__r.id in: terrList order by ACCL__Org_Unit__c];
                
            }else{
                system.debug('No records to be inserted/updated');
            }
            
            if(teamTerrUsersList != null && !teamTerrUsersList.isEmpty()){
                integer lstItemSize = teamTerrUsersList.size();
                
                for(ACCL__Org_Unit_User__c lstItem : teamTerrUsersList ){
                    lstItemSize --;
                    userDetails.put((lstItem.ACCL__Org_Unit__c+'|'+lstItem.ACCL__User__c),lstItem);
                    
                    if(team == null){
                        team = lstItem.ACCL__Org_Unit__c;
                    }
                    
                    if(team == lstItem.ACCL__Org_Unit__c){
                        userList.add(lstItem.ACCL__User__c);
                        
                    }else{
                        List<id> userListFinal = new List<id>();
                        userListFinal.addAll(userList);
                        teamTerrUsersMap.put(team,userListFinal);
                        team = lstItem.ACCL__Org_Unit__c;
                        userList.clear();
                        userList.add(lstItem.ACCL__User__c);
                        
                    }
                    
                    if(lstItemSize == 0 ){
                        teamTerrUsersMap.put(team,userList);
                    }
                }
            }else{
                system.debug('There are no team/territory users assigned');
            }
            
            if(teamTerrUsersMap.size()>0){
                //compare team and terr users and create a list of territory users to add to db
                for(id terr:terrTeamMap.keyset()){
                    //retrieve the team from map
                    id teams =  terrTeamMap.get(terr);
                    
                    //get the list of team and territory users from Map2
                    List<id> tmUsrList = teamTerrUsersMap.get(teams);
                    List<id> terrUsrList = teamTerrUsersMap.get(terr);
                    
                    if(tmUsrList != null && !tmUsrList.isEmpty()){
                        //loop through team users to check if the user is present in territory user list
                        for(id tmUserId:tmUsrList){
                            
                            //get team user details from map3
                            ACCL__Org_Unit_User__c tmUser = userDetails.get(teams+'|'+tmUserId);
                            
                            if(terrUsrList != null && !terrUsrList.isEmpty() && terrUsrList.contains(tmUserId) ){ 
                                //get territory user details from map3
                                ACCL__Org_Unit_User__c terrUser = userDetails.get(terr+'|'+tmUserId);
                                system.debug('user active '+tmUser.ACCL__User__r.IsActive);
                                //end the validity if the usr has been deactivated
                                if(!tmUser.ACCL__User__r.IsActive){
                                    terrUser.ACCL__Valid_Thru__c = System.today();
                                    tmUser.ACCL__Valid_Thru__c = System.today();
                                    //Setting to batch processed to resolve MRELKXIW-4127
                                    //terrUser.MDLZ_isOrgUnitChanged__c = updateOrgUnitUserFlag(tmUser);
                                    terrUser.MDLZ_isOrgUnitChanged__c = MDLZ_ConstantHelper.BatchProcessed; 
                                    updDBList.add(terrUser);
                                    if(!updDBList.contains(tmUser)){
                                        updDBList.add(tmUser);    
                                    }
                                    
                                }else{
                                    if(tmUser.ACCL__Valid_Thru__c != terrUser.ACCL__Valid_Thru__c){
                                        system.debug('User '+tmUserId+ 'valid thru does not match');
                                        //skip the ïnt Updated/RDR Processed/TTProcessed'records from end dating the valid thru
                                        if(terrUser.MDLZ_isOrgUnitChanged__c == MDLZ_ConstantHelper.BatchProcessed || String.isEmpty(terrUser.MDLZ_isOrgUnitChanged__c)){
                                            terrUser.ACCL__Valid_Thru__c = tmUser.ACCL__Valid_Thru__c;
                                            //UV batch should have marked it as Batch Processed already, 
                                            //however this is an additional safeguard in case it is not marked.
                                            terrUser.MDLZ_isOrgUnitChanged__c = MDLZ_ConstantHelper.BatchProcessed;
                                        }else{
                                            //any record that came from integration(Int Updated), 
                                            //not updating valid thru dates, but updating the flag based on the org level
                                            terrUser.MDLZ_isOrgUnitChanged__c = updateOrgUnitUserFlag(tmUser);
                                            
                                        }
                                        
                                        updDBList.add(terrUser);
                                    }
                                }
                            }else{
                                system.debug('User '+tmUserId+ 'is not mapped to the territory '+terr);
                                ACCL__Org_Unit_User__c userDB = new ACCL__Org_Unit_User__c();
                                userDB.ACCL__User__c = tmUser.ACCL__User__c;
                                userDB.ACCL__Management_Type__c = 'Sales'; 
                                userDB.ACCL__Org_Unit__c = terr;
                                userDB.ACCL__Valid_From__c = System.today();
                                userDB.ACCL__Valid_Thru__c = tmUser.ACCL__Valid_Thru__c;
                                userDB.MDLZ_ExternalId__c = MDLZ_ConstantHelper.US01+terrNameMap.get(terr)+'_'+tmUser.ACCL__User__r.MDLZ_SharpId__c;
                             	userDB.MDLZ_isOrgUnitChanged__c = updateOrgUnitUserFlag(tmUser);
                                updDBList.add(userDB);
                            }
                            

                            tmUser.MDLZ_isOrgUnitChanged__c = updateOrgUnitUserFlag(tmUser);
                            if(!updDBList.contains(tmUser)){
                                updDBList.add(tmUser);    
                            }
                            
                        }
                    }else{
                        system.debug('Team '+teams+ ' has no users assigned');
                    }
                }
            }else{
                system.debug('The team/territory map is empty');
            }
            
            //upsertting the team territory assignments to DB
            system.debug('Inserting data into db of size '+updDBList.size());
            if(updDBList.size() > 0){
                
                List<Database.UpsertResult>  srList =  database.upsert(updDBList,false);
                if(srList.size()>0){
                    exc.upsertResultErrors(srList,updDBList,'MDLZ_TeamTerritoryUserAssignment()','ACCL__Org_Unit_User__c');
                    //exc.upsertResultErrors(srList,'MDLZ_ProdAssortment_ByCustBranch()',prodAssortDBList); 
                }
                
            }else{
                system.debug('No records to be updated');
            } 
        }catch(exception e){
            //not re throwing the exceptions but handling in a different method.
            exc.insertExceptions('MDLZ_RedesignTeamTerritory()',e.getStackTraceString(),e.getLineNumber(),e.getTypeName()); 
        } 
        
    }
    
    //checks the org level of team and sets TT Processed /RDR Processed flag for the user record.
    public string updateOrgUnitUserFlag(ACCL__Org_Unit_User__c teamUser){
        
        String flag = '';
        
        if(teamUser.ACCL__Org_Unit__r.ACCL__Org_Level__c == MDLZ_ConstantHelper.Team){
            flag = MDLZ_ConstantHelper.TTProcessed;
        }else{
            flag = MDLZ_ConstantHelper.RDRProcessed;
        }
        
        return flag;
    }
}