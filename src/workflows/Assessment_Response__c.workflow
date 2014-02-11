<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unique_Check</fullName>
        <description>A field update workflow rule to prevent redundant assesssment response values.</description>
        <field>Unique_Check__c</field>
        <formula>( Assessment__r.Id  +   Question__r.Id )</formula>
        <name>Update Unique Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Insert Unique AssessmentID QuestionID Concat</fullName>
        <actions>
            <name>Update_Unique_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Assessment_Response__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>A workflow rule that inserts a unique concatenation of the Assessment ID and Question ID values into a &quot;Field Update&quot; workflow...field?  bucket?...so we don&apos;t get redundant assessment responses.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
