<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Manager_about_Non_employee_confirmation</fullName>
        <description>Notify Manager about Non-employee confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TMN_User/Non_employee_manager_confirmation_notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Non_employee_Account_expiration</fullName>
        <description>Notify Non-employee about Account expiration</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>tmnaccess@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TMN_User/Non_employee_last_day_notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Non_employee_about_Account_expiration</fullName>
        <description>Notify Non-employee about Account expiration</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>tmnaccess@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TMN_User/Non_employee_last_day_notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_nonemployee_account_end_date</fullName>
        <description>Notify nonemployee account end date</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TMN_User/Non_employee_last_day_notification</template>
    </alerts>
    <alerts>
        <fullName>TMNAccess_Pre_Hire_Notification</fullName>
        <description>TMNAccess Pre-Hire Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Recruiter_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>tmnaccess@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TMN_User/New_Non_Employee_TMN_User_Record</template>
    </alerts>
    <alerts>
        <fullName>TMN_Access_Pre_Hire_Notification</fullName>
        <description>TMN Access Pre-Hire Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Recruiter_Email_Address__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>tmnaccess@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TMN_User/New_Non_Employee_TMN_User_Record</template>
    </alerts>
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
    <rules>
        <fullName>Notification to nonemployee account expiration</fullName>
        <actions>
            <name>Notify_Non_employee_Account_expiration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>TEXT(Current_Person_Type__c) = &apos;Non-Employee&apos; &amp;&amp; TEXT( Job_Status__c) = &apos;Active&apos; &amp;&amp;  (Last_Day__c - TODAY() = 1 || Last_Day__c - TODAY() = 14 || Last_Day__c - TODAY() = 7) &amp;&amp; ISBLANK(Email__c) = false &amp;&amp;  LastModifiedBy.LastName = &apos;integration&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Manager about the action on non-employee confirmation</fullName>
        <actions>
            <name>Notify_Manager_about_Non_employee_confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp;  LastModifiedBy.FirstName == &apos;Non Employee Attestation&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Pre_Hire_Notification</fullName>
        <active>false</active>
        <criteriaItems>
            <field>TMN_User__c.Current_Person_Type__c</field>
            <operation>equals</operation>
            <value>Pre-hire</value>
        </criteriaItems>
        <description>Send 1 hour delayed email notification on a pre-hire tmnuser record creation.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TMN_Access_Pre_Hire_Notification</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
