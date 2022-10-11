public class AccountClearEffectiveParentExecution {

    /**Processing Account record with batch size 200 
     * @name process 
     * @param List<sObject>
     * @return void     
     */
    public void process(List<sObject> accountList) {
        List<sObject> accountsToUpdate = new List<sObject>();
        for(sObject ac : accountList) {
            if(ac.getSObjects('ACCL__Account_Extensions__r') != null) {
                //FLS_Update,FLS_Update_Partial - False Positive
                //This batch class will be executed in system mode,hence no FLS check required.
                ac.put('ParentID',null);
                accountsToUpdate.add(ac);
            }             
        }
        if(!accountsToUpdate.isEmpty() && accountsToUpdate.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
            Database.update(accountsToUpdate,false);
        }
    }
}