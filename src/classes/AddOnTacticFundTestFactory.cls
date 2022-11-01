@isTest
public class AddOnTacticFundTestFactory {
    public static List<ACCL__Tactic_Fund__c> insertTacticFundList(
        List<ACCL__Tactic__c> listTactic,
        List<ACCL__Fund__c> listFund
    ) {
        List<ACCL__Tactic_Fund__c> listTacticFundBuild = buildTacticFundList(
            listTactic,
            listFund
        );
        insert listTacticFundBuild;
        return listTacticFundBuild;
    }
    
    public static List<ACCL__Tactic_Fund__c> buildTacticFundList(
        List<ACCL__Tactic__c> listTactic,
        List<ACCL__Fund__c> listFund
    ) {
        List<ACCL__Tactic_Fund__c> listTacticFundBuild = new List<ACCL__Tactic_Fund__c>();
        if (listTactic.size() >= listFund.size()) {
            for (Integer i = 0; i < listFund.size(); i++) {
                ACCL__Tactic__c tactic = listTactic.get(i);
                ACCL__Fund__c fund = listFund.get(i);
                listTacticFundBuild.add(buildTacticFund(tactic, fund));
            }
        } else {
            for (Integer i = 0; i < listTactic.size(); i++) {
                ACCL__Tactic__c tactic = listTactic.get(i);
                ACCL__Fund__c fund = listFund.get(i);
                listTacticFundBuild.add(buildTacticFund(tactic, fund));
            }
        }
        
        return listTacticFundBuild;
    }
    public static ACCL__Tactic_Fund__c buildTacticFund(ACCL__Tactic__c tactic, ACCL__Fund__c fund) {
        ACCL__Tactic_Fund__c tacticFundRecord = new ACCL__Tactic_Fund__c();
        tacticFundRecord.ACCL__Tactic__c = tactic.id;
        tacticFundRecord.ACCL__Fund__c = fund.id;
        return tacticFundRecord;
    }
}