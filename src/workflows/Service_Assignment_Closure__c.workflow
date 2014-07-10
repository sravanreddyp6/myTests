<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Status_to_Locked</fullName>
        <field>Status__c</field>
        <literalValue>Locked</literalValue>
        <name>Set Status to Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Open</fullName>
        <description>A field update to set the status of a Service Assignment Closure back to Open after it has been rejected by an approver.</description>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>Set Status to Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Pending_Approval</fullName>
        <description>Set status to Pending Approval and prevent Edit actions with better error handling.</description>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Set Status to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
