<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_date_part_from_service_time</fullName>
        <field>Service_Date_Part__c</field>
        <formula>DATEVALUE( Service_Time__c )</formula>
        <name>Update date part from service time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Service Time Date Part</fullName>
        <actions>
            <name>Update_date_part_from_service_time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL( Service_Time__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
