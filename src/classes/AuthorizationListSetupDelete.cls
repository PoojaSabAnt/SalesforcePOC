/**  PROGRAM NAME : AuthorizationListSetupDelete 
* This class is for processing the deletion of the invalid Product_Assortment_Store records.
* @see    AuthorizationListSetupExecution
* @version  1.0
* @Created Date 2018-10-12 
*/
public class AuthorizationListSetupDelete {
    /** Private Variables */
    private List<Id> lstProdAssortStoreToDelete = new List<Id>();
    
    /** 
*  @description Query all the Product_Assortment_Store records which are invalid & return it.
*  @param None
*  @return List<Id> 
*  @throws  Standard exception
*/
    public List<Id> invalidProductAssortmentRecord() {
        try {
            Date today = System.today();
            List<sObject> listProdAssort = [SELECT Id FROM ACCL__Product_Assortment_Store__c WHERE ACCL__Assortment__r.ACCL__Valid_Thru__c < TODAY OR ACCL__Assortment__r.ACCL__Valid_From__c > TODAY LIMIT 10000];
            if(listProdAssort != null && listProdAssort.size()> 0) {
                for(sObject prodAssortStore : listProdAssort) {
                    lstProdAssortStoreToDelete.add(prodAssortStore.Id);      
                }
            }
        } catch(Exception ex) {
            System.debug('Exception : '+ex);
        }
        return lstProdAssortStoreToDelete;
    }
    
}