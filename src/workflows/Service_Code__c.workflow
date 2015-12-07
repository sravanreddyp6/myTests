<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Notes_Service_Code_Unique_Check</fullName>
        <field>Unique_Check__c</field>
        <formula>FacilityID__c +Program_Code__c  +   Service_Code__c + if(Assessment_Only__c,&quot;T&quot;,&quot;F&quot;)</formula>
        <name>Notes Service Code Unique Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notes Service Code Unique Check</fullName>
        <actions>
            <name>Notes_Service_Code_Unique_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
