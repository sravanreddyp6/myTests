<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Off_Locked</fullName>
        <field>Locked__c</field>
        <literalValue>0</literalValue>
        <name>Off Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>On_Locked</fullName>
        <description>NPA</description>
        <field>Locked__c</field>
        <literalValue>1</literalValue>
        <name>On Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Status Final</fullName>
        <actions>
            <name>On_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>NPA_Audit__c.Status__c</field>
            <operation>equals</operation>
            <value>Final</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Not Final</fullName>
        <actions>
            <name>Off_Locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>NPA_Audit__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Final</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
