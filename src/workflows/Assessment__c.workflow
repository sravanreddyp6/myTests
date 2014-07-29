<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Assessment_Name_Risk</fullName>
        <field>Name</field>
        <formula>&quot;Risk - &quot; &amp;
   Admission__r.Person_Being_Served__r.FirstName &amp; &quot; &quot; &amp; Admission__r.Person_Being_Served__r.Account.LastName   &amp; &quot; - &quot;&amp;
IF(TEXT(Status__c) !=&apos;Inactive Draft&apos;,  TEXT(Approval_Date__c), TEXT(Status__c ))</formula>
        <name>Assessment Name Risk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Name - Risk</fullName>
        <actions>
            <name>Assessment_Name_Risk</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LOWER( Assessment_Type__r.Name ) =&apos;risk&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
