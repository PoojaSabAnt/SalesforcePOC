@isTest
public with Sharing class AddOnSalesOrgTestFactory {
    //FLS_Create, FLS_Create_Partial - False Positive
    //This class is used for unit test data creation and is used in other test classes. It will be executed in System context, hence no FLS/CRUD check is required.
    //Default Sales_Organization__c
    public static ACCL__Sales_Organization__c defaultSalesOrg;
    public static ACCL__Sales_Organization__c defaultSalesOrganization;

    /**This function is for getting default SalesOrg Data 
    *  @name getDefaultSalesOrg
    *  @param No parameters
    *  @return Sales Org
    */
    public static ACCL__Sales_Organization__c getDefaultSalesOrg() {
        if( defaultSalesOrg == null ){
            defaultSalesOrg = insertSalesOrg();
        }
        return defaultSalesOrg;
    }

     /**This function is for inserting default SalesOrg Data 
    *  @name getDefaultSalesOrg
    *  @param No parameters
    *  @return Sales Org
    */
    public static ACCL__Sales_Organization__c insertSalesOrg()
    {
        ACCL__Sales_Organization__c sOrg = buildSalesOrg();
        insert sOrg;
        return sOrg;
    }

    /**This function is for building default SalesOrg Data 
    *  @name getDefaultSalesOrg
    *  @param No parameters
    *  @return Sales Org
    */
    public static ACCL__Sales_Organization__c buildSalesOrg() {
        return buildSalesOrgList()[0];
    }

    /**This function is for building List of Sales Org data
    *  @name buildSalesOrgList
    *  @param No parameters
    *  @return list of Sales Org
    */
    public static List<ACCL__Sales_Organization__c> buildSalesOrgList()
    {
        List<ACCL__Sales_Organization__c> listSalesOrg = new List<ACCL__Sales_Organization__c>();

        for(String salesOrg: AddOnUserTestFactory.getSalesOrg())
        {
            ACCL__Sales_Organization__c sOrg = new ACCL__Sales_Organization__c();
            sOrg.Name = salesOrg;
            sOrg.ACCL__Currency__c = 'USD';
            sOrg.ACCL__Default_Price_Type__c = 'Factory';
            sOrg.ACCL__Default_Price_List_Type__c = 'Direct Customers';
            sOrg.ACCL__Description_Language_1__c = salesOrg +  '(Engish)';

            //set the language using enums
            sOrg.ACCL__Language_1__c = AddOnConstants.LANGUAGE.en.name();
            sOrg.ACCL__Language_2__c = AddOnConstants.LANGUAGE.de.name();
            sOrg.ACCL__Language_3__c = AddOnConstants.LANGUAGE.es.name();
            sOrg.ACCL__Language_4__c = AddOnConstants.LANGUAGE.fr.name();
            
            //set Sales Org field value to pass validation 
            sOrg.ACCL__Sales_Org_Value__c = salesOrg;
            listSalesOrg.add(sOrg);
        }

        return listSalesOrg;
    }
     /**This function is for inserting List of Sales Org data
    *  @name buildSalesOrgList
    *  @param No parameters
    *  @return list of Sales Org
    */
    public static List<ACCL__Sales_Organization__c> insertSalesOrgList()
    {
        List<ACCL__Sales_Organization__c> listSalesOrg =  buildSalesOrgList();
        insert listSalesOrg;
        return listSalesOrg;
    }
     /**This function is for inserting Sales Org data for call planning
    *  @name insertSalesOrgData
    *  @param No parameters
    *  @return Sales Org
    */
    public static ACCL__Sales_Organization__c insertSaleOrgData(String firstDayOfWeek,String firstWeekOfYear ) {
        ACCL__Sales_Organization__c salesOrg = new ACCL__Sales_Organization__c();
        
        //commenting old name value and adding new Sales Organization name to pass the validation 
        //salesOrg.Name='global';
        salesOrg.Name= AddOnUserTestFactory.getSalesOrg()[0];
        salesOrg.ACCL__Sales_Org_Value__c = salesOrg.Name;
        
        salesOrg.ACCL__First_Day_Of_Week__c=firstDayOfWeek;
        salesOrg.ACCL__Description_Language_1__c='English';
        salesOrg.ACCL__First_Week_Of_Year__c=firstWeekOfYear;
        salesOrg.ACCL__Global_Sales_Org__c=true;
        insert salesOrg;
        return salesOrg;
    }
     /**This function is for inserting Sales Org data for call planning
    *  @name insertSalesOrgData
    *  @param No parameters
    *  @return Sales Org
    */
    //Test_Methods_With_No_Assert – False Positive
    //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
    public static ACCL__Sales_Organization__c insertSaleOrgData() {
        ACCL__Sales_Organization__c salesOrg = new ACCL__Sales_Organization__c();
        
        //commenting old name value and adding new Sales Organization name to pass the validation 
        //salesOrg.Name='global';
        salesOrg.Name= AddOnUserTestFactory.getSalesOrg()[0];
        salesOrg.ACCL__Sales_Org_Value__c = salesOrg.Name;
        
        salesOrg.ACCL__First_Day_Of_Week__c='1';
        salesOrg.ACCL__Description_Language_1__c='English';
        salesOrg.ACCL__First_Week_Of_Year__c='0';
        salesOrg.ACCL__Global_Sales_Org__c=false;
        insert salesOrg;
        return salesOrg;
    }
    public static ACCL__Consider_Default_SalesOrg__c insertDefaultSalesOrg() {
        ACCL__Consider_Default_SalesOrg__c defaultsales = new ACCL__Consider_Default_SalesOrg__c();
        defaultsales.ACCL__Consider_Global__c = True;
        insert defaultsales;
        return defaultsales;
    }
    //Test_Methods_With_No_Assert – False Positive
    //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
    public static ACCL__Sales_Organization__c insertGlobalSalesOrg(String Name,String Currency1){
            ACCL__Sales_Organization__c sOrg = new ACCL__Sales_Organization__c();
            sOrg.Name = Name;
            sOrg.ACCL__Currency__c = Currency1;
            sOrg.ACCL__Default_Price_Type__c = 'Factory';
            sOrg.ACCL__Default_Price_List_Type__c = 'Direct Customers';
            sOrg.ACCL__Description_Language_1__c = Name + '(Engish)';
            sOrg.ACCL__Global_Sales_Org__c = true;

            //set the language using enums
            sOrg.ACCL__Language_1__c = AddOnConstants.LANGUAGE.en.name();
            sOrg.ACCL__Language_2__c = AddOnConstants.LANGUAGE.de.name();
            sOrg.ACCL__Language_3__c = AddOnConstants.LANGUAGE.es.name();
            sOrg.ACCL__Language_4__c = AddOnConstants.LANGUAGE.fr.name();
            insert sOrg; 
            return sOrg;
    }
    //Test_Methods_With_No_Assert – False Positive
    //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
    public static ACCL__Sales_Organization__c insertSalesOrg(String Name, String Currency1){
            ACCL__Sales_Organization__c sOrg = new ACCL__Sales_Organization__c();
            sOrg.Name = Name;
            sOrg.ACCL__Currency__c = Currency1;
            sOrg.ACCL__Default_Price_Type__c = 'Factory';
            sOrg.ACCL__Default_Price_List_Type__c = 'Direct Customers';
            sOrg.ACCL__Description_Language_1__c = Name + '(Engish)';

            //set the language using enums
            sOrg.ACCL__Language_1__c = AddOnConstants.LANGUAGE.en.name();
            sOrg.ACCL__Language_2__c = AddOnConstants.LANGUAGE.de.name();
            sOrg.ACCL__Language_3__c = AddOnConstants.LANGUAGE.es.name();
            sOrg.ACCL__Language_4__c = AddOnConstants.LANGUAGE.fr.name();
            insert sOrg; 
            return sOrg;
    }
     /*************************************Method Which has been copied from Other SalesOrganizationTestFactory***********/ 
      //Author of this methods from origninal class is unknown. Defect Fix: Defect 326046:Duplicate SalesOrganisationTestFactory

      public static ACCL__Sales_Organization__c buildSalesOrganization( String name ){
            return buildSalesOrganization(name, false);
        }

       public static ACCL__Sales_Organization__c buildSalesOrganization( String name, Boolean isGlobal ) {
            ACCL__Sales_Organization__c salesOrg = new ACCL__Sales_Organization__c();
            salesOrg.Name = name; 
            salesOrg.ACCL__Description_Language_1__c = 'desc 1 ';
            salesOrg.ACCL__Language_1__c = 'English';
            salesOrg.ACCL__Currency__c = 'EUR';
            salesOrg.ACCL__First_Week_Of_Year__c = '1';
            salesOrg.ACCL__First_Day_Of_Week__c = '1';
            salesOrg.ACCL__Promotion_Aggregation_Level__c = 'Brand';
            salesOrg.ACCL__Global_Sales_Org__c = isGlobal;
            salesOrg.ACCL__Sales_Org_Value__c = name;
            return salesOrg;
        }

       public static ACCL__Sales_Organization__c buildDefaultSalesOrganization() {
            return buildSalesOrganization(AddOnUserTestFactory.getSalesOrg()[0], true);
        }

        //Test_Methods_With_No_Assert – False Positive
        //This class is used for unit test data creation and is used in other test classes. Hence assert is not required.
        public static ACCL__Sales_Organization__c insertSalesOrganization(String name){
            ACCL__Sales_Organization__c salesOrg = buildSalesOrganization( name );
            insert salesOrg;
            return salesOrg;
        }

        public static ACCL__Sales_Organization__c insertSalesOrganization(String name, String promotionAccessDefinitionPolicy){
            ACCL__Sales_Organization__c salesOrg = buildSalesOrganization( name );
            salesOrg.ACCL__Promotion_Access_Definition_Policy__c = promotionAccessDefinitionPolicy;
            insert salesOrg;
            return salesOrg;
        }

        public static ACCL__Sales_Organization__c insertDefaultSalesOrganization(){
            ACCL__Sales_Organization__c s = buildDefaultSalesOrganization();
            insert s;
            return s;
        }

        public static ACCL__Sales_Organization__c getDefaultSalesOrganization() {
            if( defaultSalesOrganization == null ){
                defaultSalesOrganization = insertDefaultSalesOrganization();
            }
            return defaultSalesOrganization;
        }
}