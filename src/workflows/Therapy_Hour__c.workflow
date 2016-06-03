<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>update_StartTime_DatePart</fullName>
        <field>StartTime_DatePart__c</field>
        <formula>DATEVALUE(Start_Time__c)</formula>
        <name>update StartTime_DatePart</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_therapy_hour_name</fullName>
        <field>Name</field>
        <formula>pbsFirstName__c+&apos; &apos;+pbsLastName__c+ &apos; &apos;+ TEXT(MONTH(DATEVALUE(Start_Time__c)))+ &apos;/&apos;+TEXT(DAY(DATEVALUE(Start_Time__c)))+&apos;/&apos;+RIGHT(TEXT(YEAR(DATEVALUE(Start_Time__c))),2)</formula>
        <name>update therapy hour name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update date Part of the Start TIme</fullName>
        <actions>
            <name>update_StartTime_DatePart</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Therapy_Hour__c.Start_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>update therapy hour name</fullName>
        <actions>
            <name>update_therapy_hour_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Therapy_Hour__c.Start_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
