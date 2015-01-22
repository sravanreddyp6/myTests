<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Action_Plan_Name_Update</fullName>
        <field>Name</field>
        <formula>Service_Assignment__r.Admission__r.Person_Being_Served__r.FirstName +
&quot; &quot;+  
Service_Assignment__r.Admission__r.Person_Being_Served__r.LastName  + 
&quot; - &quot; + 

IF( CONTAINS(TEXT( Status__c), &apos;Final&apos;),
  TEXT(Effective_Date__c), TEXT(Status__c))</formula>
        <name>Action Plan Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Action Plan Name</fullName>
        <actions>
            <name>Action_Plan_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
