<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>V2SA_Achieved_Status_PO_Update</fullName>
        <field>Achieved_DateTime__c</field>
        <formula>NOW()</formula>
        <name>V2SA_Achieved_Status_PlanObjective</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>V2SA_Achieved_Status_PlanObjective</fullName>
        <actions>
            <name>V2SA_Achieved_Status_PO_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Objective__c.Status__c</field>
            <operation>equals</operation>
            <value>Achieved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
