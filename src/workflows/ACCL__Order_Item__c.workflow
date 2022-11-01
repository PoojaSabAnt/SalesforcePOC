<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MDLZ_OrderItemExternalId</fullName>
        <field>MDLZ_ExternalId__c</field>
        <formula>MDLZ_ExternalFormula__c</formula>
        <name>MDLZ_OrderItemExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MDLZ_OrderItemExternalId</fullName>
        <actions>
            <name>MDLZ_OrderItemExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ACCL__Order_Item__c.MDLZ_ExternalId__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Order item external Id is empty then update the external id to MDLZ_ExternalFormula field</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
