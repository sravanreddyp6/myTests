<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>UserAcct_Service_Center</fullName>
        <ccEmails>pmcrequests@thementornetwork.com; servicecenter@thementornetwork.com</ccEmails>
        <description>UserAcct Service Center</description>
        <protected>false</protected>
        <recipients>
            <recipient>ryan.johnson@thementornetwork.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/UserAcct_Service_Center</template>
    </alerts>
    <alerts>
        <fullName>UserAcct_State_Admin</fullName>
        <ccEmails>pmcrequests@thementornetwork.com;</ccEmails>
        <description>UserAcct State Admin</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Transfer_Prospects_To__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>User_State_Administrator__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>PMC/UserAcct_State_Admin</template>
    </alerts>
    <fieldUpdates>
        <fullName>EmailSentStateAdmin</fullName>
        <field>EmailSentStateAdmin__c</field>
        <formula>&quot;Yes&quot;</formula>
        <name>EmailSentStateAdmin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EmailSentStateAdminReset</fullName>
        <field>EmailSentStateAdmin__c</field>
        <name>EmailSentStateAdminReset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Action</fullName>
        <field>Action__c</field>
        <name>UserAcct Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Activate</fullName>
        <field>Activate__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct Activate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_AddRemove</fullName>
        <field>Region_Add_Remove__c</field>
        <name>UserAcct AddRemove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Assign_State</fullName>
        <field>Assign_State_Administrator__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct Assign State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Deactivate</fullName>
        <field>Deactivate__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct Deactivate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_EmailSent</fullName>
        <field>EmailSent__c</field>
        <formula>&quot;Yes&quot;</formula>
        <name>UserAcct EmailSent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_EmailSentReset</fullName>
        <field>EmailSent__c</field>
        <name>UserAcct EmailSentReset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_PassReset</fullName>
        <field>Password_Reset__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct PassReset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_PassUnlock</fullName>
        <field>Password_Unlock__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct PassUnlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Profile</fullName>
        <field>Profile__c</field>
        <name>UserAcct Profile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Programs</fullName>
        <field>Programs__c</field>
        <name>UserAcct Programs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_RegionAddRemove</fullName>
        <field>Region_Add_Remove__c</field>
        <name>UserAcct RegionAddRemove</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Role</fullName>
        <field>Role__c</field>
        <name>UserAcct Role</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Route_To</fullName>
        <field>Route_To_Change_Info__c</field>
        <name>UserAcct Route To</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_State_Admin</fullName>
        <field>User_State_Administrator__c</field>
        <name>UserAcct State Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Transfer</fullName>
        <field>Transfer_Prospects_To__c</field>
        <name>UserAcct Transfer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UserAcct_Unassign_State</fullName>
        <field>Unassign_State_Administrator__c</field>
        <literalValue>0</literalValue>
        <name>UserAcct Unassign State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UserAcct Service Center</fullName>
        <actions>
            <name>UserAcct_Service_Center</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UserAcct_EmailSent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>1. Send an email to the Service Center if Action is not blank</description>
        <formula>OR( ActionText__c=&quot;Activation&quot;,  ActionText__c= &quot;Deactivation&quot;,  AND(ActionText__c= &quot;Update&quot;, OR(Unassign_State_Administrator__c=TRUE, Assign_State_Administrator__c=TRUE, NOT(ISPICKVAL(Profile__c, &quot;&quot;)), NOT(ISPICKVAL(Role__c, &quot;&quot;)))), ActionText__c=&quot;Password Unlock&quot;,  ActionText__c=&quot;Password Reset&quot;, Unassign_State_Administrator__c=TRUE, Assign_State_Administrator__c=TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UserAcct Service Center 2</fullName>
        <actions>
            <name>UserAcct_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Assign_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_EmailSentReset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Profile</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Role</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Unassign_State</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Administration__c.EmailSent__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>2. Reset Action, Profile, Role, Assign/Unassign State Administrator fields after Email is sent</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UserAcct State Admin</fullName>
        <actions>
            <name>UserAcct_State_Admin</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>EmailSentStateAdmin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>1. Send an email to the state administrator for any changes requested.</description>
        <formula>User_State_Administrator__c &lt;&gt; &quot;&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UserAcct State Admin 2</fullName>
        <actions>
            <name>EmailSentStateAdminReset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Programs</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_RegionAddRemove</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Route_To</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_State_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UserAcct_Transfer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Administration__c.EmailSentStateAdmin__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Reset Program, Transfer, Route To, State Admin after email is sent</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
