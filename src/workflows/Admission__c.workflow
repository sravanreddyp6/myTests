<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Admission_Discharge_Notification</fullName>
        <description>New Admission Discharge Notification</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/New_Amission_Discharge_Notification</template>
    </alerts>
    <alerts>
        <fullName>New_Admission_Notification</fullName>
        <description>New Admission Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/New_Amission_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Admission_external_ID</fullName>
        <field>Active_admission_ID__c</field>
        <name>Clear Active Admissoin ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Admission_Active_External_ID</fullName>
        <field>Active_admission_ID__c</field>
        <formula>Person_Being_Served__r.AccountId + &quot;-&quot; +  text(State__c)</formula>
        <name>Set Admission Active External ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Admission_Name</fullName>
        <field>Name</field>
        <formula>&quot;Admission &quot;  &amp; TEXT(Admission_Hidden__c) &amp; &quot; - &quot; &amp;  Person_Being_Served__r.FirstName &amp; &quot; &quot; &amp;  Person_Being_Served__r.LastName</formula>
        <name>Update Admission Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notification for Admission Discharge</fullName>
        <actions>
            <name>New_Admission_Discharge_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Admission__c.Status__c</field>
            <operation>equals</operation>
            <value>Discharged</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification for New Admission</fullName>
        <actions>
            <name>New_Admission_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Admission__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Admission Name</fullName>
        <actions>
            <name>Update_Admission_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Admission__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
