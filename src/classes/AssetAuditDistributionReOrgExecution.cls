/**  PROGRAM NAME : AssetAuditDistributionReOrgExecution 
     * This class contains the execution logic for identifying the Distribution Relevant Asset Audits
       Distribution Relavant false asset audits will not sync with Mobility. 
       @Scope of batchable context is Asset Audit
     * @version  1.0
     * @Created Date 2017-01-13 
*/
public class AssetAuditDistributionReOrgExecution {
     /*
     MethodName : process
     Note: Interface Method
     Input: List of sObject which defines the scope for the batch
     Output: None
     Purpose: Contains the business execution logic for the scope
     */
     private static final string ns = AddOnConstants.NAMESPACEPREFIX;
     public void process(List<SObject> listAssetAudit )
     {
        List<sObject> lstObjectToProcess = new List<sObject>();
        if(!listAssetAudit.isEmpty() && !(listAssetAudit.size() >Limits.getLimitDMLRows()) )
        {
            //All the Asset Audits records are processed and marked as Distribution Relevant- True/ false
            lstObjectToProcess.addAll(getAssetAuditsToUpdate(listAssetAudit));
            if(!lstObjectToProcess.isEmpty() && lstObjectToProcess.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows()))
            {
                try
                {                     
                    lstObjectToProcess.sort();
                    Database.update(lstObjectToProcess,false);
                }
                catch(Exception ex)
                {
                    System.debug('The following exception has occurred while executing CallOrderDistribution: ' + ex.getMessage());
                }
            }
        }
     }  
     /**This method is for any finish block processing
     * 
     * @name processFinish 
     * @param empty
     * @return void
     */
    public void processFinish() {
        //Send email
    }
    /************************Private Method for Internal Logic *********************************************/
      /*
     MethodName : getAssetAuditsToUpdate
     Input: List of Asset Audits to be processed for each asset
     Output: List of Asset Audits
     Purpose: Contains the business execution logic for the Asset Audit
                whether an Asset Audit can be marked as Distribution relevant true and false
     */
      private List<sObject> getAssetAuditsToUpdate(List<sObject> lstOfAssetAudit)
      {
        List<sObject> assetAuditToBeProcessed = new List<sObject>();
        Map<Id,List<sObject>> assetAuditRelevant = new Map<Id,List<sObject>>();
        for(sObject assetAudit : lstOfAssetAudit)
        {
            if(String.isBlank((Id)assetAudit.get('ACCL__Asset__c')))
            {
                if(assetAudit.get('ACCL__Distribution_Relevant__c') == true){
                    assetAudit.put('ACCL__Distribution_Relevant__c', false);
                    assetAuditToBeProcessed.add(assetAudit);    
                }
            }
            else
            {
                // Creating a map of all valid Asset Audit records with AssetId as key and list of related Asset records as value.
                if(assetAuditRelevant.containsKey((Id)assetAudit.get('ACCL__Asset__c')) ){
                    assetAuditRelevant.get((Id)assetAudit.get('ACCL__Asset__c')).add(assetAudit);
                }
                else
                {
                    assetAuditRelevant.put((Id)assetAudit.get('ACCL__Asset__c'), (List<sobject>) new List<sObject>{assetAudit});
                }
            }
        }
        for(List<sObject> sobjectList:assetAuditRelevant.values())
        {
            Boolean validAssetAuditFound = false;
            if(sobjectList != null && sobjectList.size()>0){
                for(sObject assetAuditRecord: sobjectList){
                    // if for any Asset Audit record, Sighted is true and asset audit is recently created, it is set as Distribution Relevant.
                    if(assetAuditRecord.get('ACCL__Sighted__c') == true && !validAssetAuditFound && 
                       (Date)assetAuditRecord.get('ACCL__Creation_Date__c') <= system.today())
                    {
                        if(assetAuditRecord.get('ACCL__Distribution_Relevant__c') == false){
                            assetAuditRecord.put('ACCL__Distribution_Relevant__c',true);
                            assetAuditToBeProcessed.add(assetAuditRecord);
                        }
                        validAssetAuditFound = true;
                    }
                    else{
                        if(assetAuditRecord.get('ACCL__Distribution_Relevant__c') == true){
                            assetAuditRecord.put('ACCL__Distribution_Relevant__c',false);
                            assetAuditToBeProcessed.add(assetAuditRecord);
                        }
                    }    
                }
            }
        }
        return assetAuditToBeProcessed;
      } 
    /****************************************************************************************************/
}