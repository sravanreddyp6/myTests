<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateImIncidentName</fullName>
        <field>Name</field>
        <formula>IF(CONTAINS(TEXT(Status__c), &apos;Event&apos;), &quot;E&quot;, &quot;I&quot;) &amp; &quot;-&quot; &amp; IF(ISBLANK(ReportedEvent__c) , Identifier__c, ReportedEvent__r.Identifier__c) 
&amp; 
IF(CONTAINS(TEXT(Status__c), &apos;Event&apos;), IF(CONTAINS(TEXT(Status__c), &apos;Qualifying&apos;) , &quot;Q&quot; , &quot;R&quot;), &quot;&quot;)</formula>
        <name>UpdateImIncidentName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Im_Incident_Name_update</fullName>
        <actions>
            <name>UpdateImIncidentName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>To update the Event and/or Incident Name.</description>
        <formula>OR(ISNEW(), ISCHANGED(Status__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
