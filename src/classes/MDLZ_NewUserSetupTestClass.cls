/***************************************************************
Name: MDLZ_NewUserSetupTestClass
======================================================
Purpose:
a.Create a batch of 100 users per batch for all users last modified today
	to assign sales org and user settings.
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Bharath V                    Initial Development    Test class for New user setup Apex class and Batch

***************************************************************/
@isTest
public class MDLZ_NewUserSetupTestClass {   
    static testMethod void userSetup(){
       
        Profile p1 = [select Id from Profile  where Name ='System Administrator']; 
        
                          
        ACCL__Sales_Organization__c salesorg = new ACCL__Sales_Organization__c();
        salesorg.Name ='US01';
        salesorg.ACCL__Currency__c ='US Dollar';
        salesorg.ACCL__Sales_Org_Value__c ='US01';
        salesorg.ACCL__Distance_Unit__c ='Miles';
        salesorg.ACCL__Description_Language_1__c ='US01';
        salesorg.ACCL__Language_1__c ='English';
        salesorg.ACCL__First_Week_Of_Year__c ='';
        salesorg.ACCL__First_Day_Of_Week__c ='';
        salesorg.ACCL__Account_Product_List_Type__c ='Global';
        salesorg.ACCL__Used_Reference_Date__c ='Start Date';
        salesorg.ACCL__Promotion_Aggregation_Level__c ='Brand';
        salesorg.ACCL__Promotion_Access_Definition_Policy__c='Independent Anchors';
        salesorg.ACCL__Weight_Unit__c ='pound';
        salesorg.ACCL__Volume_Unit__c ='gallon';
        insert salesorg;
        
        User opUser = new user(alias = 'test123', email='test123@noemail.com',
                            emailencodingkey='UTF-8', firstName='Test', lastname='Testing', languagelocalekey='en_US',IsActive=true,
                            localesidkey='en_US', profileid = p1.Id, country='United States',
                            timezonesidkey='America/Los_Angeles', username='test04@noemail.com', ACCL__Sales_Org__c=salesorg.Name); 
        insert opUser;
        
        
        ACCL__Sales_Organization_User__c sOrgUser = new ACCL__Sales_Organization_User__c();
        sOrgUser.ACCL__Sales_Organization__c =salesorg.id;
        sOrgUser.ACCL__User__c = opUser.id;
        insert sOrgUser;
        
        ACCL__User_Setting__c us = new ACCL__User_Setting__c();
        us.ACCL__User__c=opUser.id;
        us.ACCL__Default_Management_Type__c ='Sales';
        us.ACCL__Landing_Page__c ='UserCockpit';
        us.ACCL__Display_Weekend__c =true;
        insert us;
       

        
       
        // Run your code with inserted user.
        
             
        Test.startTest();
        
        MDLZ_NewUserSetup nuserSetup=new MDLZ_NewUserSetup();
        nuserSetup.getNewUsers(new List<user> {opUser});
         
        MDLZ_NewUserSetupBatch batch1= new MDLZ_NewUserSetupBatch(20);
        DataBase.executeBatch(batch1,20);
        SchedulableContext sc = null;
        
        MDLZ_NewUserSetupBatch bdsec=new MDLZ_NewUserSetupBatch(20);
        bdsec.execute(sc);
            
         Test.stopTest();
    }
        

}