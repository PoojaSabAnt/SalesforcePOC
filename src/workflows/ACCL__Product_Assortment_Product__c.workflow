<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MDLZ_UpdateExternalId</fullName>
        <field>MDLZ_ExternalId__c</field>
        <formula>LEFT(ACCL__Product_Assortment__r.Name,16)+TEXT(MDLZ_SchematicsSection__c)+&apos;_&apos;+ACCL__Product__r.ACCL__ExternalId__c+&apos;_Schematic_Product&apos;</formula>
        <name>MDLZ_UpdateExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Prod_Assortment_Product</fullName>
        <field>MDLZ_ExternalId__c</field>
        <formula>ACCL__Product_Assortment__r.ACCL__Description__c</formula>
        <name>Update Prod Assortment Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>MDLZ_PAP_UpdateExternalId</fullName>
        <actions>
            <name>MDLZ_UpdateExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>ACCL__Product_Assortment_Product__c.ACCL__Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Product_Assortment_Product__c.MDLZ_ExternalId__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Product_Assortment__c.Name</field>
            <operation>contains</operation>
            <value>Schematic</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
