<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Compliance_Survey_Follow_Up_Notification</fullName>
        <ccEmails>Compliance.officer@thementornetwork.com</ccEmails>
        <description>Compliance Survey Follow Up Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Public/Compliance_Survey_Follow_Up_Notification</template>
    </alerts>
    <rules>
        <fullName>Compliance Survey Follow Up Notification</fullName>
        <actions>
            <name>Compliance_Survey_Follow_Up_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Response__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed with Follow Up</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
