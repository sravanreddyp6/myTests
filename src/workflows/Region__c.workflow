<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Name_for_State_Regions</fullName>
        <field>Name</field>
        <formula>TEXT(State__c)</formula>
        <name>Set Name for State Regions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update State Region Name</fullName>
        <actions>
            <name>Set_Name_for_State_Regions</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Region__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Region__c.Type__c</field>
            <operation>equals</operation>
            <value>State</value>
        </criteriaItems>
        <description>Update State Region Name</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
