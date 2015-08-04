<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>proj_Chatter_Reminder_Message</fullName>
        <field>sysReminder__c</field>
        <formula>&quot;reminder&quot;</formula>
        <name>proj_Chatter_Reminder_Message</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>proj_Chatter_Reminder</fullName>
        <actions>
            <name>proj_Chatter_Reminder_Message</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF( zzDateChatterReminder__c = TODAY(),True,False)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
