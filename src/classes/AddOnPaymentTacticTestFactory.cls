@isTest
public with sharing class AddOnPaymentTacticTestFactory {
	private static ACCL__Payment_Tactic__c defaultPaymentTactic;
    
    public static ACCL__Payment_Tactic__c buildPaymentTactic(ACCL__Payment__c payment, ACCL__Tactic__c tactic){
        ACCL__Payment_Tactic__c paymentTacticRecord = new ACCL__Payment_Tactic__c();
        paymentTacticRecord.ACCL__Payment_Name__c=payment.Id;
        paymentTacticRecord.ACCL__Tactic__c=tactic.Id;
        return paymentTacticRecord;
    }
    
    // Commenting out until PaymentTestFactory re-factored
    /*public static Payment_Tactic__c buildDefaultPaymentTactic() {
        return buildPaymentTactic(PaymentTestFactory.getDefaultPayment(), TacticTestFactory.getDefaultTactic());
    }*/
    
    public static ACCL__Payment_Tactic__c insertPaymentTactic(ACCL__Payment__c payment, ACCL__Tactic__c tactic) {
        ACCL__Payment_Tactic__c paymentTacticRecord = buildPaymentTactic(payment, tactic);
        insert paymentTacticRecord;
        return paymentTacticRecord;
    }
    
    // Commenting out until PaymentTestFactory re-factored
    /*public static Payment_Tactic__c getDefaultPaymentTactic() {
        if(defaultPaymentTactic == null){
            defaultPaymentTactic = insertPaymentTactic(PaymentTestFactory.getDefaultPayment(), TacticTestFactory.getDefaultTactic());
        }
        return defaultPaymentTactic;
    }*/
    
    public static List<ACCL__Payment_Tactic__c> buildPaymentTacticList(List<ACCL__Payment__c> listPayment, List<ACCL__Tactic__c> listTactic) {
        List<ACCL__Payment_Tactic__c> listPaymentTactic = new List<ACCL__Payment_Tactic__c>();
        if(listPayment.size() >= listTactic.size()){
            for(Integer i=0;i<listTactic.size();i++){
                ACCL__Payment__c payment=listPayment.get(i);
                ACCL__Tactic__c tactic=listTactic.get(i);
                listPaymentTactic.add(buildPaymentTactic(payment, tactic));
            }
        }else{
            for(Integer i=0;i<listPayment.size();i++){
                ACCL__Payment__c payment=listPayment.get(i);
                ACCL__Tactic__c tactic=listTactic.get(i);
                listPaymentTactic.add(buildPaymentTactic(payment, tactic));
            }
        }
        return listPaymentTactic;
    }
    
    public static List<ACCL__Payment_Tactic__c> insertPaymentTacticList(List<ACCL__Payment__c> listPayment, List<ACCL__Tactic__c> listTactic) {
        List<ACCL__Payment_Tactic__c> listPaymentTactic = buildPaymentTacticList(listPayment, listTactic);
        insert listPaymentTactic;
        return listPaymentTactic;
    }
}