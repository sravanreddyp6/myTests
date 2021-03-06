<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Service_Location_Name</fullName>
        <field>Name</field>
        <formula>Alias__c</formula>
        <name>Update Service Location Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Service Location Update Name</fullName>
        <actions>
            <name>Update_Service_Location_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT ISBLANK(Alias__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
