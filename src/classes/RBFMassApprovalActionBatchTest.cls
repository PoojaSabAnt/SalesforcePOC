/**
 * Created by Jose Corona Cardenas on 30/JAN/2019.
 */

@isTest
public class RBFMassApprovalActionBatchTest {
    
    @TestSetup
    static void testSetup(){
        
        
        
        User u = RBFMassApprovalTestFactory.buildUser(5);
        u.ACCL__Sales_Org__c = RBFMassApprovalTestFactory.getDefaultSalesOrg().Name;
        insert u;
        
        RBFMassApprovalTestFactory.insertUserPermissionset(u,'RBF_Admin');
        
        System.runAs(u) {
            
            Group testGroup = new Group();
            testGroup.Name = 'RBF PreApproval Queue';
            testGroup.DeveloperName = 'JCC';
            testGroup.Type = 'Queue'; 
            insert testGroup;
            
            QueueSobject mappingObject = new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Lead');
            
            insert mappingObject;
            ACCL__Rate_Based_Funding__c rbf = RBFMassApprovalTestFactory.getDefaultRbf();
            rbf.OwnerId = testGroup.Id;
            insert rbf;
            
            List<ACCL__RBF_Product__c> RBFproducts = new List<ACCL__RBF_Product__c>();
            ACCL__RBF_Product__c prod = new ACCL__RBF_Product__c();
            prod.ACCL__Rate_based_Funding__c = rbf.Id;
            prod.ACCL__Edit_Time__c = DateTime.now();
            prod.ACCL__Measure_Code__c = 'ABCD';
            prod.ACCL__External_Id__c = 'alsdfjl';
            RBFproducts.add(prod);
            
            prod = new ACCL__RBF_Product__c();
            prod.ACCL__Rate_based_Funding__c = rbf.Id;
            prod.ACCL__Edit_Time__c = DateTime.now();
            prod.ACCL__Measure_Code__c = 'ABCE';
            prod.ACCL__External_Id__c = 'zqwer';
            RBFproducts.add(prod);
            
            insert RBFproducts;
            
            ACCL__Product_Template__c productTemplate = RBFMassApprovalTestFactory.getDefaultProductTemplate();
            List<ACCL__Product__c> products = new List<ACCL__Product__c>();
            products.add(RBFMassApprovalTestFactory.buildProduct(3, productTemplate));
            products.add(RBFMassApprovalTestFactory.buildProduct(2, productTemplate));
            products[0].ACCL__Product_Level__c = 'Brand';
            products[1].ACCL__Product_Level__c = 'Category';
            insert products;
            
            List<ACCL__RateBasedFunding_Product__c> rateBasedFundingProducts = new List<ACCL__RateBasedFunding_Product__c>();
            rateBasedFundingProducts.add(new ACCL__RateBasedFunding_Product__c(
                ACCL__Rate_Based_Funding__c = rbf.id,
                ACCL__Product__c = products[0].Id                
            ));
            rateBasedFundingProducts.add(new ACCL__RateBasedFunding_Product__c(
                ACCL__Rate_Based_Funding__c = rbf.id,
                ACCL__Product__c = products[1].Id
            ));
            
            insert rateBasedFundingProducts;
        }
    }
    
    @isTest
    static void testRBFMassApprovalActionBatch() {
        
        for(ACCL__Rate_Based_Funding__c prueba : [SELECT Id, Owner.Type, Owner.Name, ACCL__Rate_Based_Funding_Template__c FROM ACCL__Rate_Based_Funding__c]){
            System.debug(prueba);
        }
        
        Test.startTest();    
        Id jobid = Database.executeBatch(new RBFMassApprovalActionBatch('RBF PreApproval Queue'));
        System.assert(jobid != null);
        Test.stopTest();
    }
}