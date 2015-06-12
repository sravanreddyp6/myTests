<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>notify_on_new_non_employee_tmn_user_record</fullName>
        <description>notify on new non-employee tmn user record</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TMN_User/New_Non_Employee_TMN_User_Record</template>
    </alerts>
    <rules>
        <fullName>New Non-Employee TMN User Record</fullName>
        <actions>
            <name>notify_on_new_non_employee_tmn_user_record</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TMN_User__c.Current_Person_Type__c</field>
            <operation>equals</operation>
            <value>Non-Employee</value>
        </criteriaItems>
        <description>Send email on new non-employee record creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
