/**  PROGRAM NAME : KAMProductFindingExecution  
     * This class is execution class for KAMProductFindingBatch implementing ACSFBatchBLExecution
       processing the product record with batch size 200 
     * @see    KAMProductFindingBatch
     * @version  1.0
     * @Created Date 2017-02-06
*/
public class KAMProductFindingExecution {
    private static final string ns = AddOnConstants.NAMESPACEPREFIX;
    /**Processing product record with batch size 200 and update the KAM_Product field in Product
     * @name process 
     * @param List<sObject>
     * @return void
     */
    public void process(List<SObject> productListProcess ){
        List<sObject> listProductToUpdate = new List<sObject>();
        for(sObject product : productListProcess ) {
            if(product.get(ns+'Criterion_5_Product__c') != null &&
                product.getSObject(ns+'Criterion_5_Product__r').get(ns+'Product_Level__c') == AddOnConstants.PRODUCT_LEVEL_PACKAGE) {
                product.put(ns+'KAM_Product__c',product.get(ns+'Criterion_5_Product__c'));
            }
            listProductToUpdate.add(product);
        }
        try {
            //Check if List is empty or not
            if(!listProductToUpdate.isEmpty() && listProductToUpdate.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows())) {
                Database.update(listProductToUpdate); 
            }
        }
        catch(Exception ex) {
            throw ex;
        }
    }
    /**This method is for any finish block processing
     * @name processFinish 
     * @param empty
     * @return void
     */
    public void processFinish() {
    }
}