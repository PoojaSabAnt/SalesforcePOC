@isTest
public class AddOnPaymentTestFactory {

    private static ACCL__KPI_Definition__c defaultKPIDef = null;
    private static ACCL__KPI_Set__c defaultKPISet = null;
    private static ACCL__Payment_Template__c defaultPaymentTemplate = null;
    
    public static void accountHierarchySetup(){
        
        ACCL__Account_Template__c accountTemplate = new ACCL__Account_Template__c(Name='Kroger Template', ACCL__Active__c=True, ACCL__Description_Language_1__c='Kroger', ACCL__Sales_Org__c='0001');
        insert accountTemplate;
        
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='Kroger HQ', ACCL__Account_Number__c='001', ACCL__Account_Template__c=accountTemplate.Id));
        accounts.add(new Account(Name='Kroger Atlanta', ACCL__Account_Number__c='002', ACCL__Account_Template__c=accountTemplate.Id));
        accounts.add(new Account(Name='Kroger New York', ACCL__Account_Number__c='003', ACCL__Account_Template__c=accountTemplate.Id));
		accounts.add(new Account(Name='Kroger 201', ACCL__Account_Number__c='004', ACCL__Account_Template__c=accountTemplate.Id));
        accounts.add(new Account(Name='Kroger 201a', ACCL__Account_Number__c='005', ACCL__Account_Template__c=accountTemplate.Id));
        accounts.add(new Account(Name='Kroger 205', ACCL__Account_Number__c='006', ACCL__Account_Template__c=accountTemplate.Id));		// No hierarchy
        accounts.add(new Account(Name='Kroger 501', ACCL__Account_Number__c='007', ACCL__Account_Template__c=accountTemplate.Id));		// No extension
        accounts.add(new Account(Name='Kroger 502', ACCL__Account_Number__c='008', ACCL__Account_Template__c=accountTemplate.Id));
        insert accounts;
        
        accounts.get(3).ParentId=accounts.get(1).Id;
        update accounts;
        
        List<ACCL__Account_Extension__c> accountExtensions = new List<ACCL__Account_Extension__c>();
        accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(1).Id, ACCL__Account_Plan_Type__c='Plan', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1));
        accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(2).Id, ACCL__Account_Plan_Type__c='Plan', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1));
        accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(3).Id, ACCL__Account_Plan_Type__c='', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1,
                                                      														   ACCL__Store_Role_Valid_From__c=Date.today()-1, ACCL__Store_Role_Valid_Thru__c=Date.today()+1));
        accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(4).Id, ACCL__Account_Plan_Type__c='', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1));
        accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(5).Id, ACCL__Account_Plan_Type__c='', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1));
		accountExtensions.add(new ACCL__Account_Extension__c(ACCL__Account__c=accounts.get(7).Id, ACCL__Account_Plan_Type__c='', ACCL__Promotion_Valid_From__c=Date.today()-1, ACCL__Promotion_Valid_Thru__c=Date.today()+1));
		insert accountExtensions;
        
        List<ACCL__Account_Trade_Org_Hierarchy__c> accountHierarchies = new List<ACCL__Account_Trade_Org_Hierarchy__c>();
        accountHierarchies.add(new ACCL__Account_Trade_Org_Hierarchy__c(ACCL__Child_Account__c=accounts.get(1).Id, ACCL__Parent_Account__c=accounts.get(0).Id,
                                                                        ACCL__Valid_From__c=Date.today()-1, ACCL__Valid_Thru__c=Date.today()+1));
        accountHierarchies.add(new ACCL__Account_Trade_Org_Hierarchy__c(ACCL__Child_Account__c=accounts.get(3).Id, ACCL__Parent_Account__c=accounts.get(1).id,
                                                                        ACCL__Valid_From__c=Date.today()-1, ACCL__Valid_Thru__c=Date.today()+1));
        accountHierarchies.add(new ACCL__Account_Trade_Org_Hierarchy__c(ACCL__Child_Account__c=accounts.get(4).Id, ACCL__Parent_Account__c=accounts.get(3).id,
                                                                        ACCL__Valid_From__c=Date.today()-1, ACCL__Valid_Thru__c=Date.today()+1));
        accountHierarchies.add(new ACCL__Account_Trade_Org_Hierarchy__c(ACCL__Child_Account__c=accounts.get(6).Id, ACCL__Parent_Account__c=accounts.get(2).id,
                                                                        ACCL__Valid_From__c=Date.today()-1, ACCL__Valid_Thru__c=Date.today()+1));
        accountHierarchies.add(new ACCL__Account_Trade_Org_Hierarchy__c(ACCL__Child_Account__c=accounts.get(7).Id, ACCL__Parent_Account__c=accounts.get(2).id,
                                                                        ACCL__Valid_From__c=Date.today()-1, ACCL__Valid_Thru__c=Date.today()+1));
        insert accountHierarchies;
        
    }
     private static String getKPIConfig() {
        return '{"measures":[{"valuetype":"Money","type":"editable","totalcalculation":{"rule":"avg"},"storageoptions":{"writeback":false,"storagelevels":["Product"]},"name":"RBFRatePerCase","editable":{"storagelevel":"inputlevel","enablepastweeks":false,"editmode":"total","code":"RBFR"},"distribution":{"timehierarchydisttype":"copy","planhierarchydisttype":"copy","distributionorder":"PlanThenTime"},"display":{"subsets":["Planning"],"round":2,"enabled":true},"aggregation":{"timerule":"aggregate","skippeddimensions":["Tactic"],"rule":"avg"}},{"valuetype":"Volume","type":"read","totalcalculation":{"rule":"sum"},"storageoptions":{"writeback":false},"name":"PlanBaseVolume","display":{"subsets":["Planning"],"round":0,"enabled":true},"datasource":{"weekoffset":0,"tablename":"weeklymeasureint","measurecode":"BSL","aggregationmode":"standard"},"aggregation":{"timerule":"aggregate","skippeddimensions":["Tactic"],"rule":"sum"}},{"valuetype":"None","type":"calculated","totalcalculation":{"rule":"sum","cumulative":"off"},"storageoptions":{"writeback":false,"storagelevels":["Product"]},"name":"RBFBaseFunding","formula":"(RBFRatePerCase,PlanBaseVolume) => {return RBFRatePerCase* PlanBaseVolume;}","display":{"subsets":["Planning"],"round":2,"enabled":true},"aggregation":{"timerule":"formula","skippeddimensions":["Tactic"],"rule":"sum"}},{"valuetype":"Volume","type":"read","totalcalculation":{"rule":"sum"},"storageoptions":{"writeback":false},"name":"PYShipment","display":{"subsets":["Planning"],"round":0,"enabled":true},"datasource":{"weekoffset":52,"tablename":"dailymeasurereal","measurecode":"SHIP","aggregationmode":"standard"},"aggregation":{"timerule":"aggregate","skippeddimensions":["Tactic"],"rule":"sum"}},{"valuetype":"None","type":"calculated","totalcalculation":{"rule":"sum","cumulative":"off"},"storageoptions":{"writeback":false,"storagelevels":["Product"]},"name":"RBFPYFunding","formula":"(RBFRatePerCase,PYShipment) => {return RBFRatePerCase* PYShipment;}","display":{"subsets":["Planning"],"round":2,"enabled":true},"aggregation":{"timerule":"formula","skippeddimensions":["Tactic"],"rule":"sum"}}],"axis":{"y":["measures","Tactic","Product"],"x":"Week"}}}';
    }
    public static void paymentTemplateSetup(){   
        
        ACCL__KPI_Set__c kpiSet = new ACCL__KPI_Set__c(ACCL__Usage__c = 'Payment');
        kpiSet.ACCL__Configuration__c = getKPIConfig();
        insert kpiSet;

        RecordType recordType = AddOnRecordTypeTestUtil.getRecordType('ACCL__KPI_DEFINITION__c', 'read');

        ACCL__KPI_Definition__c kpiDefinition = new ACCL__KPI_Definition__c(Name = 'TestKPIDefinition',
                                                                            ACCL__Description_Language_1__c = 'Test KPI Definition',
                                                                            ACCL__Aggregation_Rule__c = 'Sum',
                                                                            ACCL__Total_Calculation_Rule__c = 'Sum',
                                                                            ACCL__Data_Source_Aggregation_Mode__c = 'Standard',
                                                                            ACCL__Data_Source_Measure_Code__c = 'KPI2',
                                                                            ACCL__Data_Source_Table_Name__c = 'accountmeasure',
                                                                            ACCL__Data_Source_Monthly_Table_Name__c = 'accountmeasure',
                                                                            RecordTypeId = recordType.Id);
        insert kpiDefinition;
        
        // Creating junction object to validate KPI Definition is part of KPI set
        ACCL__KPI_Set_KPI_Definition__c kpiSetDefinition = new ACCL__KPI_Set_KPI_Definition__c(ACCL__KPI_Set__c = kpiSet.Id,
                                                                                               ACCL__KPI_Definition__c = kpiDefinition.Id,
                                                                                               ACCL__Sort__c = 1);
        insert kpiSetDefinition;
        
        Integer currentCount = getCurrentPaymentTemplateCount(); //This is necessary to ensure that all created payment templates in tests are unique.
        List<ACCL__Payment_Template__c> paymentTemplates = new List<ACCL__Payment_Template__c>();
        for(Integer i=0; i<5; i++){
            paymentTemplates.add(new ACCL__Payment_Template__c(Name = 'Deduction',
                                                         ACCL__Payment_Type__c = 'Deduction',
                                                         ACCL__Description_Language_1__c = 'Deduction Description',
                                                         ACCL__Short_Code__c = 'T10'+ (i + currentCount),
                                                         ACCL__Sales_Org__c = AddOnSalesOrgTestFactory.getDefaultSalesOrg().Id,
                                                         ACCL__Sort__c = 1000+i,
                                                         ACCL__KPI_Set__c = kpiSet.Id,
                                                         ACCL__Tactic_Payout_KPI_Definition__c = kpiDefinition.Id));
        }
        for(Integer i=0; i<5; i++){
            paymentTemplates.add(new ACCL__Payment_Template__c(Name = 'Check Request',
                                                         ACCL__Payment_Type__c = 'Check Request',
                                                         ACCL__Description_Language_1__c = 'Check Request Description',
                                                         ACCL__Short_Code__c = 'T20'+ (i + currentCount),
                                                         ACCL__Sales_Org__c = AddOnSalesOrgTestFactory.getDefaultSalesOrg().Id,
                                                         ACCL__Sort__c = 2000+i,
                                                         ACCL__KPI_Set__c = kpiSet.Id,
                                                         ACCL__Tactic_Payout_KPI_Definition__c = kpiDefinition.Id));
        }
        insert paymentTemplates;
        
    }
    
    public static List<ACCL__Payment__c> paymentSetup(){
        
        paymentTemplateSetup();
        accountHierarchySetup();

        ACCL__Payment_Template__c paymentTemplate = [SELECT Id, ACCL__Sales_Org__c, ACCL__Sales_Org__r.Name FROM ACCL__Payment_Template__c LIMIT 1];
        ACCL__Sales_Organization__c salesOrg = [SELECT Id, ACCL__Currency__c FROM ACCL__Sales_Organization__c WHERE Name =:paymentTemplate.ACCL__Sales_Org__r.Name];
        RecordType recordTypeManual = [Select Id From RecordType Where SobjectType = :ACCL__Payment__c.class.getName() AND DeveloperName='Manual' LIMIT 1];
        RecordType recordTypeParent = [Select Id From RecordType Where SobjectType = :ACCL__Payment__c.class.getName() AND DeveloperName='Parent' LIMIT 1];
        Account KrogerAtlanta = [SELECT Id FROM Account WHERE Name='Kroger Atlanta' LIMIT 1];
        Account KrogerNewYork = [SELECT Id FROM Account WHERE Name='Kroger New York' LIMIT 1];
        Account Kroger201 = [SELECT Id FROM Account WHERE Name='Kroger 201' LIMIT 1];
        
        List<ACCL__Payment__c> payments = new List<ACCL__Payment__c>();
		
        User u = AddOnUserTestFactory.buildUser(1);
        u.ACCL__sales_org__c = AddOnUserTestFactory.getSalesOrg()[0];
        
        insert u;
        AddOnUserTestFactory.insertUserPermissionset(u, 'ACSF_Payment_User');
        
        system.runAs(u){
		// Parent Payment
		payments.add(new ACCL__Payment__c(ACCL__Payment_Template__c = paymentTemplate.Id,
                                    ACCL__Payment_Anchor__c = KrogerAtlanta.Id,
                                    ACCL__Reference_Date__c = Date.today(),
                                    ACCL__Payment_Amount__c = 0,
                                    ACCL__Payment_Status__c = 'Initial',
                                    RecordTypeId = recordTypeParent.Id));
        
        // Planning-level Payments
        for(Integer i=0; i<5; i++){
            payments.add(new ACCL__Payment__c(ACCL__Payment_Template__c = paymentTemplate.Id,
                                        ACCL__Payment_Anchor__c = KrogerAtlanta.Id,
                                        ACCL__Reference_Date__c = Date.today(),
                                        ACCL__Payment_Amount__c = i*100+100,
                                        ACCL__Payment_Status__c = 'Initial',
                                        RecordTypeId = recordTypeManual.Id));
        }
        for(Integer i=0; i<5; i++){
            payments.add(new ACCL__Payment__c(ACCL__Payment_Template__c = paymentTemplate.Id,
                                        ACCL__Payment_Anchor__c = KrogerNewYork.Id,
                                        ACCL__Reference_Date__c = Date.today(),
                                        ACCL__Payment_Amount__c = i*100+200,
                                        ACCL__Payment_Status__c = 'Initial',
                                        RecordTypeId = recordTypeManual.Id));
        }
        
        // Store-level Payments
        for(Integer i=0; i<10; i++){
            payments.add(new ACCL__Payment__c(ACCL__Payment_Template__c = paymentTemplate.Id,
                                        ACCL__Payment_Anchor__c = Kroger201.Id,
                                        ACCL__Reference_Date__c = Date.today(),
                                        ACCL__Payment_Amount__c = i*200+200,
                                        ACCL__Payment_Status__c = 'Initial',
                                        RecordTypeId = recordTypeManual.Id));
        }
        
        insert payments;
        }
        return payments;
        
    }
    
    public static ACCL__Payment_Template__c getDefaultPaymentTemplate(){
        if(AddOnPaymentTestFactory.defaultPaymentTemplate == null){
           
            // Creating junction object to validate KPI Definition is part of KPI set
            ACCL__KPI_Set_KPI_Definition__c kpiSetDefinition = new ACCL__KPI_Set_KPI_Definition__c(ACCL__KPI_Set__c = AddOnPaymentTestFactory.getDefaultKPISet().Id,
                                                                                                   ACCL__KPI_Definition__c = AddOnPaymentTestFactory.getDefaultKPIDefinition().Id,
                                                                                                   ACCL__Sort__c = 1);
            insert kpiSetDefinition;
            
            AddOnPaymentTestFactory.defaultPaymentTemplate = new ACCL__Payment_Template__c(Name = 'Deduction Name',
                                                                                ACCL__Short_Code__c='PT99999', 
                                                                                ACCL__KPI_Set__c = AddOnPaymentTestFactory.getDefaultKPISet().Id, 
                                                                                ACCL__Tactic_Payout_KPI_Definition__c = AddOnPaymentTestFactory.getDefaultKPIDefinition().Id,
                                                                                ACCL__Sales_Org__c= AddOnSalesOrgTestFactory.getDefaultSalesOrg().Id,
                                                                                ACCL__Description_Language_1__c='Default Payment Template Description',
                                                                                ACCL__Sort__c=9999,
                                                                                ACCL__Payment_Type__c = 'Deduction'
                                                                               );
            insert AddOnPaymentTestFactory.defaultPaymentTemplate;
        }
        return AddOnPaymentTestFactory.defaultPaymentTemplate;
    }
    
    public static ACCL__KPI_Set__c getDefaultKPISet(){
        if(AddOnPaymentTestFactory.defaultKPISet == null){
            AddOnPaymentTestFactory.defaultKPISet = new ACCL__KPI_Set__c();
            AddOnPaymentTestFactory.defaultKPISet.ACCL__Usage__c = 'Payment';
            insert AddOnPaymentTestFactory.defaultKPISet;
        }
        return AddOnPaymentTestFactory.defaultKPISet;
    }

    public static ACCL__KPI_Definition__c getDefaultKPIDefinition(){
        if(AddOnPaymentTestFactory.defaultKPIDef == null){
            AddOnPaymentTestFactory.defaultKPIDef = new ACCL__KPI_Definition__c();
            RecordType rt = AddOnRecordTypeTestUtil.getRecordType(ACCL__KPI_DEFINITION__c.SObjectType.getDescribe().getName(), 'read');
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Description_Language_1__c = 'Test KPI Definition';
            AddOnPaymentTestFactory.defaultKPIDef.Name = 'Test KPI Definition';
            AddOnPaymentTestFactory.defaultKPIDef.RecordTypeId = rt.Id;
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Aggregation_Rule__c = 'Sum';
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Total_Calculation_Rule__c = 'Sum';
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Data_Source_Aggregation_Mode__c = 'Standard';
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Data_Source_Measure_Code__c = 'KDEF';
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Data_Source_Table_Name__c = 'accountmeasure';
            AddOnPaymentTestFactory.defaultKPIDef.ACCL__Data_Source_Monthly_Table_Name__c = 'accountmeasure';
            insert AddOnPaymentTestFactory.defaultKPIDef;
        }
        return AddOnPaymentTestFactory.defaultKPIDef;
    }
    
    private static Integer getCurrentPaymentTemplateCount(){
        AggregateResult[] groupedResults = [SELECT COUNT(Id) ptcount FROM ACCL__Payment_Template__c];
		Object avgAmount = groupedResults[0].get('ptcount');
        return Integer.valueOf(avgAmount);
    }
}