/***************************************************************
Name: MDLZ_SystemSettingsFieldSetFilterTest
======================================================
Purpose:
Test class for SystemSettingsFieldSetFilterCriteria and SystemSettingsFieldSet class 
======================================================
History
-------
VERSION     AUTHOR         REVIEWER      DATE             DETAIL              Description
1.0      Gaurav Gupta                               Initial Development 

***************************************************************/
@isTest
public class MDLZ_SystemSettingsFieldSetFilterTest {

    static testMethod void createProductFilterSettings(){
        Test.startTest();
        SystemSettingsFieldSetFilterCriteria.createProductFilterSettings();
        Test.stopTest();
    }
}