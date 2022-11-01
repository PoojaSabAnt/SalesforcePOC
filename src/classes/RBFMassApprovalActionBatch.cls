/**
 * Created by Jose Corona Cardenas on 30/JAN/2019.
 */

public without sharing class RBFMassApprovalActionBatch implements Database.Batchable<SObject>, Database.Stateful {
    private static List<String> approvedStatuses = new List<String>{'Approved','Processing','Processed'};
        private String queueName = null;
    
    public RBFMassApprovalActionBatch(String queueName){
        this.queueName = queueName;
    }
    
    public Database.QueryLocator start (Database.BatchableContext bc) {
        
        return Database.getQueryLocator([
            SELECT Id, ACCL__Rate_Based_Funding_Template__c, ACCL__Account__c, ACCL__Date_From__c, ACCL__Date_Thru__c FROM ACCL__Rate_Based_Funding__c
            WHERE Owner.Type = 'Queue' AND Owner.Name = :this.queueName
            AND ACCL__Status__c NOT IN :approvedStatuses
        ]);
    }
    
    //Retrieve all unapproved RBF from the Queue
    public static Map<Id,Set<Id>> constructRBFTemplateMapFromQueue (String queueName){
        Map<Id,Set<Id>> rbfTemplateMap = new Map<Id,Set<Id>>();
        for(ACCL__Rate_Based_Funding__c rbf: [
            SELECT Id, ACCL__Rate_Based_Funding_Template__c FROM ACCL__Rate_Based_Funding__c 
            WHERE Owner.Type = 'Queue' AND Owner.Name = :queueName
            AND ACCL__Status__c NOT IN :approvedStatuses            
        ]){
            if(rbf.ACCL__Rate_Based_Funding_Template__c != null){
                if(!rbfTemplateMap.containsKey(rbf.ACCL__Rate_Based_Funding_Template__c)){
                    rbfTemplateMap.put(rbf.ACCL__Rate_Based_Funding_Template__c,new Set<Id>());
                }
                rbfTemplateMap.get(rbf.ACCL__Rate_Based_Funding_Template__c).add(rbf.Id);
            }
        }        
        return rbfTemplateMap;
    }
    
    //Assumption : All rbf in this set belongs to the same RBF Template
    //Quick three dimension check - RBF Template, Account Id, and Timeframe (Date From and Date Thru)
    private Map<Boolean,Set<Id>> quickCheckForOverlappingTimeframePerRBFTemplate(Set<ACCL__Rate_Based_Funding__c> rbfs, Id rbfTemplateId){
        //Existing RBFs
        Map<Id,ACCL__Rate_Based_Funding__c> approvedRBFsMap = new Map<Id, ACCL__Rate_Based_Funding__c>();
        Map<Id,Set<ACCL__Rate_Based_Funding__c>> accountMap = new Map<Id,Set<ACCL__Rate_Based_Funding__c>>();
        for(ACCL__Rate_Based_Funding__c approvedRBF: [
            Select Id, ACCL__Date_From__c, ACCL__Date_Thru__c, ACCL__Account__c FROM ACCL__Rate_Based_Funding__c
            WHERE ACCL__Rate_Based_Funding_Template__c = :rbfTemplateId
            AND ACCL__Status__c IN :approvedStatuses
        ]){
            approvedRBFsMap.put(approvedRBF.Id, approvedRBF);
            if(!accountMap.containsKey(approvedRBF.ACCL__Account__c)){
                accountMap.put(approvedRBF.ACCL__Account__c, new Set<ACCL__Rate_Based_Funding__c>());  
            }
            accountMap.get(approvedRBF.ACCL__Account__c).add(approvedRBF);
        }
        
        
        Map<Boolean,Set<Id>> validationResults = new Map<Boolean,Set<Id>>();		
        validationResults.put(true, new Set<Id>());
        validationResults.put(false, new Set<Id>());
        
        for(ACCL__Rate_Based_Funding__c rbf:rbfs){
            Boolean overlap = false;
            if(accountMap.get(rbf.ACCL__Account__c) != null){
                for(ACCL__Rate_Based_Funding__c approvedRBF: accountMap.get(rbf.ACCL__Account__c)){
                    if( (rbf.ACCL__Date_From__c >= approvedRBF.ACCL__Date_From__c && rbf.ACCL__Date_From__c <= approvedRBF.ACCL__Date_Thru__c) 
                       || (rbf.ACCL__Date_Thru__c >= approvedRBF.ACCL__Date_From__c && rbf.ACCL__Date_Thru__c <= approvedRBF.ACCL__Date_Thru__c)){
                           overlap = true;
                           break;
                       }
                }
                
            }
            if(!overlap){
                if(!accountMap.containsKey(rbf.ACCL__Account__c)){
                    accountMap.put(rbf.ACCL__Account__c, new Set<ACCL__Rate_Based_Funding__c>());
                }
                accountMap.get(rbf.ACCL__Account__c).add(rbf);
            }
            validationResults.get(!overlap).add(rbf.Id); 
            
            
        }
        
        return validationResults;
    }
    
    
    
    public void execute(Database.BatchableContext bc, List<ACCL__Rate_Based_Funding__c> records) {
        
        Map<Id,Set<ACCL__Rate_Based_Funding__c>> rbfTemplateMap = new Map<Id,Set<ACCL__Rate_Based_Funding__c>>();
        for(ACCL__Rate_Based_Funding__c rbf: records){
            if(rbf.ACCL__Rate_Based_Funding_Template__c != null){
                if(!rbfTemplateMap.containsKey(rbf.ACCL__Rate_Based_Funding_Template__c)){
                    rbfTemplateMap.put(rbf.ACCL__Rate_Based_Funding_Template__c,new Set<ACCL__Rate_Based_Funding__c>());
                }
                rbfTemplateMap.get(rbf.ACCL__Rate_Based_Funding_Template__c).add(rbf);
            }
        }
        Set<Id> approvedIds = new Set<Id>();
        Set<Id> rejectedIds = new Set<Id>();
        for(Id rbfTemplateId : rbfTemplateMap.keySet()){
            Map<Boolean,Set<Id>> validationResults =  quickCheckForOverlappingTimeframePerRBFTemplate(rbfTemplateMap.get(rbfTemplateId),rbfTemplateId);
            approvedIds.addAll(validationResults.get(true));
            rejectedIds.addAll(validationResults.get(false));
        }
        RBFMassApprove(approvedIds);
        RBFMassReject(rejectedIds);
       System.debug('Approved: ' + approvedIds);
       System.debug('Rejected: ' + rejectedIds);
    }
    
    public void finish(Database.BatchableContext bc){
        
    } 
    
    private void RBFMassApprove(Set<Id> rbfids){
        Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
            ProcessInstance[] pi = [
                Select ID, Status, TargetObject.Name,
                (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance
                Where TargetObjectID IN :rbfids AND Status = 'Pending'
            ];
        
        for(ProcessInstance instance : pi){
            for(ProcessInstanceWorkItem workItem : instance.WorkItems){
                Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();
                prWkItem.setWorkItemID(workItem.id);
                prWkItem.setComments('Automatially PreApproved.');
                prWkItem.setAction('Approve');
                prWkItems.add(prWkItem);
            }
        }
        
        if(!prWkItems.isEmpty()){
            Approval.ProcessResult[] appResult = Approval.process(prWkItems);
        }
    }
    
    private void RBFMassReject(Set<Id> rbfids){
        Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
            ProcessInstance[] pi = [
                Select ID, Status, TargetObject.Name,
                (SELECT Id, ActorId, ProcessInstanceId FROM Workitems),
                (SELECT Id, StepStatus, Comments FROM Steps) From ProcessInstance
                Where TargetObjectID IN :rbfids AND Status = 'Pending'
            ];
        
        for(ProcessInstance instance : pi){
            for(ProcessInstanceWorkItem workItem : instance.WorkItems){
                Approval.ProcessWorkitemRequest prWkItem = new Approval.ProcessWorkitemRequest();
                prWkItem.setWorkItemID(workItem.id);
                prWkItem.setComments('Automatially Rejected.');
                prWkItem.setAction('Reject');
                prWkItems.add(prWkItem);
            }
        }
        
        if(!prWkItems.isEmpty()){
            Approval.ProcessResult[] appResult = Approval.process(prWkItems);
        }
    }
    
    
}