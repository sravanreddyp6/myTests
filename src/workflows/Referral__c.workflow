<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Referral_Eval_By_Update</fullName>
        <description>Updates Evaluated By from the name of the lookup field evaluated_by_internal__c (TMN User).  This is for Care Meridian only - it was an existing field that we want populated.</description>
        <field>Evaluated_By__c</field>
        <formula>Evaluated_By_Internal__r.Name</formula>
        <name>Referral Eval By Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Evaluated By name</fullName>
        <actions>
            <name>Referral_Eval_By_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
