<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ServiceAssignmentClosureName</fullName>
        <field>Name</field>
        <formula>LEFT(Service_Assignment__r.Admission__r.Person_Being_Served__r.FirstName, 1) + &apos;.&apos; +
 Service_Assignment__r.Admission__r.Person_Being_Served__r.LastName + &apos;-SAC&apos;</formula>
        <name>ServiceAssignmentClosureName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ServiceAssignmentClosureName</fullName>
        <actions>
            <name>ServiceAssignmentClosureName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
