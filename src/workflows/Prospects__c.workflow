<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Approval_Manager_Notification</fullName>
        <description>Approval Manager Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Approving_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/Notify_Manager_Email</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_to_Prospect_Owner</fullName>
        <description>Email Notification to Prospect Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/Email_Notification_to_Prospect_Owner</template>
    </alerts>
    <alerts>
        <fullName>Final_Review_Field_Marked_Pending_Rejected_by_Manager</fullName>
        <description>Final Review Field Marked Pending/Rejected by Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/Final_Review_Field_Marked_Pending_Rejected_by_Manager</template>
    </alerts>
    <alerts>
        <fullName>Final_Review_marked_as_Approved</fullName>
        <description>Final Review marked as Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/Final_Review_Marked_Approved_by_Manager</template>
    </alerts>
    <alerts>
        <fullName>PMC_no_activity_message</fullName>
        <description>PMC no activity message</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>PMC/PMC_NO_Activity</template>
    </alerts>
    <alerts>
        <fullName>Region</fullName>
        <description>Region</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>becomeamentor@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC/Region</template>
    </alerts>
    <alerts>
        <fullName>State_No_Business</fullName>
        <description>State No Business</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>becomeamentor@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC/State_No_Business</template>
    </alerts>
    <alerts>
        <fullName>State_Served</fullName>
        <description>State Served</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>becomeamentor@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC/State_Served</template>
    </alerts>
    <alerts>
        <fullName>State_Unserved</fullName>
        <description>State Unserved</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>becomeamentor@thementornetwork.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PMC/State_Unserved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_DOI_Web_based_Inquiry</fullName>
        <field>Date_of_Inquiry__c</field>
        <formula>DATEVALUE(CreatedDate )</formula>
        <name>Set DOI Web-based Inquiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Date_Change</fullName>
        <field>Status_Change_Date__c</field>
        <formula>TODAY()</formula>
        <name>Status Date Change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Notify_Manager</fullName>
        <description>Set Notify Manager to unchecked after emails is sent to Approving Manager</description>
        <field>Notify_Manager_to_Approve__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Notify Manager</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Application_Approved_Date</fullName>
        <field>Application_Approved_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Application Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Mentor</fullName>
        <field>Status__c</field>
        <literalValue>Mentor</literalValue>
        <name>Update Status to Mentor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Review</fullName>
        <field>Status__c</field>
        <literalValue>Review</literalValue>
        <name>Update Status to Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Application Review Status Approved Update</fullName>
        <actions>
            <name>Update_Application_Approved_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Application_Review_Status__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Approving Manager Notification</fullName>
        <actions>
            <name>Approval_Manager_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Uncheck_Notify_Manager</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_to_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( Notify_Manager_to_Approve__c =TRUE, NOT(ISBLANK(Approving_Manager__c)), OR(ISCHANGED(Approving_Manager__c) ,ISCHANGED(Notify_Manager_to_Approve__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Final Review Field Marked Approved by Manager</fullName>
        <actions>
            <name>Final_Review_marked_as_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Final_Review__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Final Review Field Marked Pending%2FRejected by Manager</fullName>
        <actions>
            <name>Final_Review_Field_Marked_Pending_Rejected_by_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Final_Review__c</field>
            <operation>equals</operation>
            <value>Pending,Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Prospect TY Email Region</fullName>
        <actions>
            <name>Region</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Entry_Point__c</field>
            <operation>equals</operation>
            <value>web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Prospects__c.zzEmailTempQualifier__c</field>
            <operation>equals</operation>
            <value>Region</value>
        </criteriaItems>
        <description>Prospect TY Email - Region</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect TY Email State No Business</fullName>
        <actions>
            <name>State_No_Business</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Entry_Point__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Prospects__c.zzEmailTempQualifier__c</field>
            <operation>equals</operation>
            <value>StateNoBusiness</value>
        </criteriaItems>
        <description>Prospect TY Emai- State (no business)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect TY Email State Served</fullName>
        <actions>
            <name>State_Served</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Entry_Point__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Prospects__c.zzEmailTempQualifier__c</field>
            <operation>equals</operation>
            <value>StateServed</value>
        </criteriaItems>
        <description>Prospect TY Email State (served)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect TY Email State Unserved</fullName>
        <actions>
            <name>State_Unserved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Entry_Point__c</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Prospects__c.zzEmailTempQualifier__c</field>
            <operation>equals</operation>
            <value>StateUnserved</value>
        </criteriaItems>
        <description>Prospect TY email State Unserved</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospect no Activity - Status 30 Day</fullName>
        <active>true</active>
        <description>PMC-32</description>
        <formula>ISPICKVAL(Status__c, &apos;30 Day&apos;) &amp;&amp;  Number_of_days_since_last_activity__c  &gt;= 30</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PMC_no_activity_message</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Prospect no Activity - Status 7 Day</fullName>
        <active>true</active>
        <description>PMC-32</description>
        <formula>ISPICKVAL(Status__c, &apos;7 Day&apos;) &amp;&amp;  Number_of_days_since_last_activity__c  &gt;= 7</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PMC_no_activity_message</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Prospect no Activity - Status Active</fullName>
        <active>true</active>
        <description>PMC-32</description>
        <formula>ISPICKVAL(Status__c, &apos;Active&apos;) &amp;&amp;  Number_of_days_since_last_activity__c  &gt;= 30</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PMC_no_activity_message</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Prospect no Activity - Status Review</fullName>
        <active>true</active>
        <description>PMC-32</description>
        <formula>ISPICKVAL(Status__c, &apos;Review&apos;) &amp;&amp;  Number_of_days_since_last_activity__c  &gt;= 14</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>PMC_no_activity_message</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Owner Email Notification</fullName>
        <actions>
            <name>Email_Notification_to_Prospect_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Entry_Point__c</field>
            <operation>equals</operation>
            <value>web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Prospects__c.zzSend_Email_to_Owner__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Send Owner Email Notification</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Status 30 Day</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>30 Day</value>
        </criteriaItems>
        <description>Status 30 Day</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status 7 Day</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>7 Day</value>
        </criteriaItems>
        <description>Status 7 Day</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Active</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <description>Status Active</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Closed Agency</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>On hold - Agency</value>
        </criteriaItems>
        <description>Status Closed Agency</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Closed Prospect</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Prospect</value>
        </criteriaItems>
        <description>Status Closed Prospect</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Mentor</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>Mentor</value>
        </criteriaItems>
        <description>Status Mentor</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status On Hold Agency</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>On hold - Agency</value>
        </criteriaItems>
        <description>Status On Hold Agency</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status On Hold Prospect</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed - Prospect</value>
        </criteriaItems>
        <description>Status On Hold Prospect</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Pending Review</fullName>
        <actions>
            <name>Status_Date_Change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Status__c</field>
            <operation>equals</operation>
            <value>Review</value>
        </criteriaItems>
        <description>Status Pending Review</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Status to Mentor</fullName>
        <actions>
            <name>Update_Status_to_Mentor</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Prospects__c.Provider_Agreement_Signature_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
