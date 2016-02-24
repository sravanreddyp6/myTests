<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateImIncidentName</fullName>
        <field>Name</field>
        <formula>IF(CONTAINS(TEXT(Status__c), &apos;Event&apos;), &quot;E&quot;, &quot;I&quot;) &amp; &quot;-&quot; &amp; IF(ISBLANK(ReportedEvent__c) , Identifier__c, ReportedEvent__r.Identifier__c) 
&amp; 
IF(CONTAINS(TEXT(Status__c), &apos;Event&apos;), IF(ISBLANK(ReportedEvent__c) , &quot;R&quot; , &quot;Q&quot;), &quot;&quot;)</formula>
        <name>UpdateImIncidentName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CreateTaskToCompleteEvent</fullName>
        <actions>
            <name>Please_complete_and_submit_the_Event</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>This is to create a task to the event owner when someone creates a new event.</description>
        <formula>AND(ISPICKVAL( Status__c , &quot;Event-Draft&quot;) ,  ISNULL( ReportedEvent__c ) )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Im_Incident__c.CreatedDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CreateTaskToQualifyEvent</fullName>
        <actions>
            <name>Please_review_and_complete_the_Event</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Create Task for the Qualifier to review the task</description>
        <formula>AND(ISPICKVAL( Status__c , &quot;Event-Draft&quot;) ,   NOT(ISNULL( ReportedEvent__c ))  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
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
    <tasks>
        <fullName>Please_complete_and_submit_the_Event</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please complete and submit the Event.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Im_Incident__c.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Please complete and submit the Event.</subject>
    </tasks>
    <tasks>
        <fullName>Please_review_and_complete_the_Event</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please review and complete the Event.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Im_Incident__c.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please review and complete the Event.</subject>
    </tasks>
</Workflow>
