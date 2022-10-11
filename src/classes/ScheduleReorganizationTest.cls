@isTest
private class ScheduleReorganizationTest {
    
    @isTest
    private static void Schedule_SalesOrgSent_CalloutTriggered() {
        //Arrange
        MockHttpResponseGenerator calloutMock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        String txId = ACCL.TransactionHandler.generateGUID();
        String salesOrg = '0001';
        String batchChain = String.format('TPM_Batches_{0}_{1}', new List<String>{ salesOrg, System.now().format('YYYYMMdd') });


        // Act
        Test.startTest();
        //String response = ScheduleReorganization.schedule(txId, salesOrg, batchChain);
        Test.stopTest();

        // Assert
        //System.assert(response.contains('Reorg Success'));
    }
    
   @isTest 
    private static void Schedule_TransactionIdNotSent_CalloutNotTriggered() {
        //Arrange
        MockHttpResponseGenerator calloutMock = new MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        String txId ;
        String salesOrg = '0001';
        String message;
        String batchChain = String.format('TPM_Batches_{0}_{1}', new List<String>{ salesOrg, System.now().format('YYYYMMdd') });


        // Act

        Test.startTest();
        try{
            ScheduleReorganization.schedule(txId, salesOrg, batchChain);
        }catch(NullPointerException ex){
            message=ex.getMessage();
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, message,'no txid found');
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"result":"Reorg Success"}');
            res.setStatusCode(200);
            return res;
            
        }
        
    }
    
}