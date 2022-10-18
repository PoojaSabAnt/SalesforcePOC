<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>MDLZ_OrderExternalId</fullName>
        <field>MDLZ_ExternalId__c</field>
        <formula>ACCL__Order_Id__c</formula>
        <name>MDLZ_OrderExternalId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
	<fieldUpdates>
        <fullName>Set_Phase_Deleted</fullName>
        <description>Update phase as &apos;Deleted&apos;</description>
        <field>ACCL__Phase__c</field>
        <literalValue>Deleted</literalValue>
        <name>Set Phase Deleted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>MDLZ_OrderExternalID</fullName>
        <actions>
            <name>MDLZ_OrderExternalId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ACCL__Order__c.MDLZ_ExternalId__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When the External Id is empty update the externalid field to Order Id</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Order To SAP</fullName>
        <active>false</active>
        <booleanFilter>(1 AND 2) OR 3</booleanFilter>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Phase__c</field>
            <operation>equals</operation>
            <value>Send to SAP</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.MDLZ_isChanged__c</field>
            <operation>equals</operation>
            <value>TRUE</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Phase__c</field>
            <operation>equals</operation>
            <value>Deleted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
	<rules>
        <fullName>SAP Deleted Order</fullName>
        <actions>
            <name>Set_Phase_Deleted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Customer_Order_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.MDLZ_Total_Case_Quantity__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Phase__c</field>
            <operation>equals</operation>
            <value>Received By SAP</value>
        </criteriaItems>
        <description>Temporary Fix: Mark Order with Phase &apos;Received by SAP&apos; to &apos;Deleted&apos; when SAP has rejected a zero quantity order</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Timebased_Send_To_SAP</fullName>
        <active>true</active>
        <booleanFilter>(1 AND 2 ) OR 3</booleanFilter>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Phase__c</field>
            <operation>equals</operation>
            <value>Send to SAP</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.MDLZ_isChanged__c</field>
            <operation>equals</operation>
            <value>TRUE</value>
        </criteriaItems>
        <criteriaItems>
            <field>ACCL__Order__c.ACCL__Phase__c</field>
            <operation>equals</operation>
            <value>Deleted</value>
        </criteriaItems>
        <description>Workflows waits for stipulated time e.g. 1 or 2 mins before outbound message sent. # of wait minutes is controlled via custom label. Defect reference: MRELKXIW-2041.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>ACCL__Order__c.MDLZ_WF_TimeTrigger__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
