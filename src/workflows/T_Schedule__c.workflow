<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Schedule_Name</fullName>
        <field>Name</field>
        <formula>Route__r.Name + &quot; &quot; +   TEXT(ScheduleStart__c)</formula>
        <name>Update Schedule Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>T_Schedule_Name_Update</fullName>
        <actions>
            <name>Update_Schedule_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>T_Schedule__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>DriverRouteSchedule</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
