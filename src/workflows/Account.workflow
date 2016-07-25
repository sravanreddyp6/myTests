<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Dedupe_Person_Being_Served</fullName>
        <field>Dedupe_Hidden__c</field>
        <formula>FirstName + &quot;-&quot; +  LastName + &quot;-&quot; +  TEXT(PersonBirthdate)</formula>
        <name>Dedupe Person Being Served</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Dedupe Person Being Served</fullName>
        <actions>
            <name>Dedupe_Person_Being_Served</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 = 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
