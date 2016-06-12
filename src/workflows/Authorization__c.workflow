<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cost_Therapy_rejection</fullName>
        <description>Cost &amp; Therapy rejection</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Public/C_T_Rejection_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Lock_Progress_Note</fullName>
        <field>Locked__c</field>
        <literalValue>1</literalValue>
        <name>Lock Progress Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Locked_Field_Update</fullName>
        <field>Locked__c</field>
        <literalValue>1</literalValue>
        <name>Locked Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Name_Update</fullName>
        <field>Name</field>
        <formula>Person_Being_Served__r.FirstName + Person_Being_Served__r.LastName + 
&apos; - &apos; +
 TEXT(Effective_Date_of_Cost_Therapy__c)+
&apos; - Costs &amp; Therapy Authorization&apos;</formula>
        <name>Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Needs_Refinement_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Needs Refinement Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pending_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Set Pending Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pending_Status_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Pending Status Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Progress_Note</fullName>
        <field>Locked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Progress Note</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_rc</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Needs Refinement</literalValue>
        <name>Update Approval Status-rc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Authorization_ID</fullName>
        <field>Name</field>
        <formula>Payer_Authorization_ID__c</formula>
        <name>Update Authorization ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Authorization ID Update</fullName>
        <actions>
            <name>Update_Authorization_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Authorization__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Authorization__c.Payer_Authorization_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cost %26 Therapy Auth Name</fullName>
        <actions>
            <name>Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Authorization__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Costs_TherapyNR</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
