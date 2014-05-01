<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
        <fullName>No_Approval_Needed_False</fullName>
        <field>No_Approval_Needed__c</field>
        <literalValue>0</literalValue>
        <name>No Approval Needed False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Progress_Note_In_Progress</fullName>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Progress Note In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Progress_Note_Name_Update</fullName>
        <field>Name</field>
        <formula>Person_Being_Served__r.FirstName &amp; &quot; &quot; &amp; Person_Being_Served__r.LastName &amp; &quot; - &quot; &amp; text(month(datevalue(Start_Time__c))) &amp; &quot;/&quot; &amp; text(day(datevalue(Start_Time__c))) &amp; &quot;/&quot; &amp; text(year(datevalue(Start_Time__c))) &amp; &quot; - &quot; &amp; $RecordType.Name &amp; IF(NOT(ISPICKVAL(Type_of_Activity__c, &quot;&quot;)), &quot; - &quot; &amp; TEXT(Type_of_Activity__c), &quot;&quot;)</formula>
        <name>Progress Note Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_FCT_Phase</fullName>
        <description>At note creation, set this number field to the value of the current phase of FCT treatment, so there is a record of what the phase of treatment was at note creation.</description>
        <field>FCT_Phase_at_Note_Creation__c</field>
        <formula>Service_Assignment__r.Phase__c</formula>
        <name>Set FCT Phase</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_In_Progress_Overall_Status</fullName>
        <field>Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Set In Progress Overall Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Set_Needs_Refinement_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Needs Refinement</literalValue>
        <name>Set Needs Refinement Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pending_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Set Pending Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Staff_Credentials_Field_Update</fullName>
        <field>Staff_Credentials__c</field>
        <formula>Staff_Credentials_Current__c</formula>
        <name>Staff Credentials Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
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
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Final_for_Overall_Status</fullName>
        <field>Status__c</field>
        <literalValue>Final</literalValue>
        <name>Update Final for Overall Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Recalled_by_User_Date</fullName>
        <field>Approval_Status_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Recalled by User Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Recalled_by_User_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recalled by User</literalValue>
        <name>Update Recalled by User Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_to_Bypass_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Bypass</literalValue>
        <name>Update to Bypass Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Progress Note IMAPP Create Task</fullName>
        <actions>
            <name>Note_NC_IMAPP_Perform_Curriculum_Lesson</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Progress_Note__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>NC - IMAPP Progress Note</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Progress Note Name Update</fullName>
        <actions>
            <name>Progress_Note_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Progress_Note__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Progress Note Unlocked</fullName>
        <actions>
            <name>No_Approval_Needed_False</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Progress_Note_In_Progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Progress_Note__c.Locked__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rory Update</fullName>
        <active>true</active>
        <formula>AND(  Interventions__c &lt;&gt; LastModifiedById)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Phase for FCT Note</fullName>
        <actions>
            <name>Set_FCT_Phase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1=1</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Staff Credentials</fullName>
        <actions>
            <name>Staff_Credentials_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Staff_Name__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Submit For Approval Reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Progress_Note__c.Approval_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Please_submit_your_Progress_Note_for_approval</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Approval Fields if No Approval Needed</fullName>
        <actions>
            <name>Lock_Progress_Note</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Approval_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Final_for_Overall_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_to_Bypass_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( No_Approval_Needed__c = True, ISCHANGED(No_Approval_Needed__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Note_NC_IMAPP_Perform_Curriculum_Lesson</fullName>
        <assignedTo>rory@tmn.prod</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Perform Curriculum Lesson</subject>
    </tasks>
    <tasks>
        <fullName>Please_submit_your_Progress_Note_for_approval</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please submit your Progress Note for approval</subject>
    </tasks>
</Workflow>
