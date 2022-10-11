public with sharing class ScheduleReorganization {
    private static final String JOB_NAME = 'Reorg';    
    private static final String REORG_ENDPOINT = '/ACSF/v1/Schedule/Reorganization';
    private static final String className = String.valueOf(ScheduleReorganization.class);
    
    public static String schedule(String txId, String salesOrg, String batchChain) {    
        ACCL.OffPlatformCallout request = new ACCL.OffPlatformCallout('SCHEDULE_REORGANIZATION', salesOrg);
        ACCL.OffplatformCalloutResponse response = request.execute(txId,new Map<String,String>() ,JSON.serialize(New ScheduleReorganizationRequest(JOB_NAME, salesOrg, batchChain)));
        return response.Result;
    }
    
    private class ScheduleReorganizationRequest {
        String jobname;
        String salesorg;
        String batchchain;
        public ScheduleReorganizationRequest( String jobName, String salesOrg, String batchChain) { 
            this.jobname = jobName;
            this.salesorg = salesOrg;
            this.batchchain = batchChain;

        }
    }
}