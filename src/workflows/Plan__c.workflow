<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_for_Service_Plan_Review</fullName>
        <ccEmails>ryan.johnson@thementornetwork.com</ccEmails>
        <description>Notification for Service Plan Review</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/Service_Plan_Review_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_for_Service_Plan_Review_FL</fullName>
        <description>Notification for Service Plan Review FL</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/Service_Plan_Review_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_Service_Plan_Review_FL_Complement</fullName>
        <description>Notification of Service Plan Review FL Complement</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/Service_Plan_Review_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Expiration_Date</fullName>
        <field>Plan_Expiration_Date__c</field>
        <formula>if(  ISBLANK( Expiration_Date_Override__c ) ,Effective_Date__c +365,Expiration_Date_Override__c)</formula>
        <name>Set Expiration Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Flag_to_False_1</fullName>
        <field>Schedule_A_Time_Dependent_Notification__c</field>
        <literalValue>0</literalValue>
        <name>Set Flag to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Plan_to_Read_Only</fullName>
        <field>Read_Only__c</field>
        <literalValue>1</literalValue>
        <name>Set Plan to Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Read_Only_to_False</fullName>
        <field>Read_Only__c</field>
        <literalValue>0</literalValue>
        <name>Set Read Only to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Plan_Name</fullName>
        <field>Name</field>
        <formula>Person_Being_Served__r.FirstName  &amp; &quot; &quot; &amp; Person_Being_Served__r.LastName &amp; &quot; Plan &quot; &amp; text(Plan_Hidden__c)</formula>
        <name>Update Plan Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Plan_to_Set_flag</fullName>
        <description>Set Schedule A Time Dependent Notification to True</description>
        <field>Schedule_A_Time_Dependent_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Update Plan to Set flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Plan_to_UnSet_flag</fullName>
        <description>Set Schedule A Time Dependent Notification to False</description>
        <field>Schedule_A_Time_Dependent_Notification__c</field>
        <literalValue>0</literalValue>
        <name>Update Plan to UnSet flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notification of Service Plan Review</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.Date_Last_Reviewed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.State__c</field>
            <operation>equals</operation>
            <value>NC</value>
        </criteriaItems>
        <description>Notification of Service Plan Review North Carolina</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_for_Service_Plan_Review</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Plan__c.Date_Last_Reviewed__c</offsetFromField>
            <timeLength>180</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notification of Service Plan Review FL Complement 1</fullName>
        <actions>
            <name>Update_Plan_to_Set_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notification of Service Plan Review for Florida</description>
        <formula>OR(                 AND(                          ISCHANGED( Date_Last_Reviewed__c  ) ,                          ISPICKVAL( Status__c , &apos;Active&apos;),                          NOT(ISBLANK( Date_Last_Reviewed__c )) ,                          State__c  = &apos;FL&apos;                 ),                AND(                          ISCHANGED(  State__c  ) ,                          ISPICKVAL( Status__c , &apos;Active&apos;),                          NOT(ISBLANK( Date_Last_Reviewed__c )) ,                          State__c  = &apos;FL&apos;                ),               AND(                           ISCHANGED(  Status__c  ) ,                          ISPICKVAL( Status__c , &apos;Active&apos;),                          NOT(ISBLANK( Date_Last_Reviewed__c )) ,                          State__c  = &apos;FL&apos;               )           )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notification of Service Plan Review FL Complement 2</fullName>
        <actions>
            <name>Update_Plan_to_UnSet_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notification of Service Plan Review for Florida</description>
        <formula>OR(        AND(                  ISCHANGED( Date_Last_Reviewed__c ),                  ISBLANK(Date_Last_Reviewed__c )        ),        ISPICKVAL(Status__c, &apos;Inactive&apos;),        State__c &lt;&gt; &apos;FL&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notification of Service Plan Review FL Part 1</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.State__c</field>
            <operation>equals</operation>
            <value>FL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.Date_Last_Reviewed__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Notification of Service Plan Review for Florida</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_of_Service_Plan_Review_FL_Complement</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Plan__c.Effective_Date__c</offsetFromField>
            <timeLength>150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notification of Service Plan Review FL Part 2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.Schedule_A_Time_Dependent_Notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notification of Service Plan Review for Florida</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_for_Service_Plan_Review_FL</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Flag_to_False_1</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Plan__c.Date_Last_Reviewed__c</offsetFromField>
            <timeLength>150</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Notification to Confirm External Plan</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.External_Plan__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.Read_Only__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Please_confirm_external_plan2</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Expiration Date</fullName>
        <actions>
            <name>Set_Expiration_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>1 &gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Plan to Read Only 12 Months After Plan Is Created</fullName>
        <active>true</active>
        <formula>1 &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Plan_to_Read_Only</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Plan__c.CreatedDate</offsetFromField>
            <timeLength>365</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>System Admin Uncheck Read Only</fullName>
        <actions>
            <name>Set_Read_Only_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>Plan__c.External_Plan__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Plan Name</fullName>
        <actions>
            <name>Update_Plan_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Plan__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Please_confirm_external_Plan</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please confirm external Plan</subject>
    </tasks>
    <tasks>
        <fullName>Please_confirm_external_plan2</fullName>
        <assignedToType>owner</assignedToType>
        <description>The External Plan checkbox has been checked but the Confirm External Plan button has not been clicked on this plan. Please confirm by clicking the Confirm External Plan button on this plan or clear the External Plan checkbox.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Please confirm external plan.</subject>
    </tasks>
</Workflow>
