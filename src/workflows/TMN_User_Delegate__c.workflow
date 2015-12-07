<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Delegate_removed</fullName>
        <description>Delegate removed</description>
        <protected>false</protected>
        <recipients>
            <field>Delegate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Delegate_for_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TMN_User/Delegate_Removed</template>
    </alerts>
    <alerts>
        <fullName>New_Delegate_Assigned</fullName>
        <description>New Delegate Assigned</description>
        <protected>false</protected>
        <recipients>
            <field>Delegate_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Delegate_for_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TMN_User/New_Delegate_Assigned</template>
    </alerts>
    <rules>
        <fullName>Delegate removed</fullName>
        <actions>
            <name>Delegate_removed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Rule to evaluate when a delegate has been removed.</description>
        <formula>ISCHANGED( Time_Removed__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Email on Delegate Assignment</fullName>
        <actions>
            <name>New_Delegate_Assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email notification when a delegate is assigned.</description>
        <formula>NOT(ISNULL( Time_Assigned__c ))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
