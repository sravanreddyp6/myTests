<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_for_Change_in_Service_Assignment</fullName>
        <description>Notification for Change in Service Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/Service_Assignment_Change_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_for_New_Service_Assignment</fullName>
        <description>Notification for New Service Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Progress_Notes/New_Service_Assignment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Day_of_last_note_today</fullName>
        <field>Day_of_last_Note__c</field>
        <formula>TODAY()</formula>
        <name>Day of last note today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Assessment_Only_Service_Assignmen</fullName>
        <field>Name</field>
        <formula>LEFT(Person_Being_Served__r.FirstName, 1) &amp; &quot;. &quot; &amp; Person_Being_Served__r.LastName &amp; &quot; - SA&quot; &amp; TEXT(SA_Hidden__c) &amp; IF(Program__c &lt;&gt; &apos;&apos;, &quot; - &quot; &amp;  Program__c, &quot;&quot;) &amp; IF(TEXT(Location_Region__c) &lt;&gt; &apos;&apos;, &quot; - &quot;&amp; TEXT(Location_Region__c), &quot;&quot;) &amp; IF (Service_Line__c &lt;&gt; &apos;&apos;,  &quot; - &quot; &amp;Service_Line__c,&quot;&quot;) &amp; &quot; - Asmt Only&quot;</formula>
        <name>Update Assessment Only Service Assignmen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Assignment_Name</fullName>
        <field>Name</field>
        <formula>LEFT(LEFT(Person_Being_Served__r.FirstName, 1) &amp; &quot;. &quot; &amp; Person_Being_Served__r.LastName &amp; &quot; - SA&quot; &amp; TEXT(SA_Hidden__c) &amp; IF(Service_Location__c &lt;&gt; &apos;&apos;, &quot; - &quot; &amp; Service_Location__r.Alias__c, IF (Program__c &lt;&gt; &apos;&apos;, &quot; - &quot; + Program__c, &quot;&quot;)) &amp; IF(TEXT(Location_Region__c) &lt;&gt; &apos;&apos;, &quot; - &quot; 
&amp; TEXT(Location_Region__c), &quot;&quot;) &amp; IF (Service_Line__c &lt;&gt; &apos;&apos;, &quot; - &quot; &amp;Service_Line__c,&quot;&quot;), 80)</formula>
        <name>Update Service Assignment Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notification for New Service Assignment</fullName>
        <actions>
            <name>Notification_for_New_Service_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Assignment__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification for Service Assignment Change</fullName>
        <actions>
            <name>Notification_for_Change_in_Service_Assignment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Day_of_last_note_today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name =&apos;Standard Service Assignment&apos; &amp;&amp;  ISPICKVAL(Admission__r.State__c, &apos;NC&apos;) &amp;&amp;   TODAY() !=  Day_of_last_Note__c  &amp;&amp; OR(ISCHANGED(Admission__c), ISCHANGED( Program__c), ISCHANGED( Start_Date__c ), ISCHANGED( End_Date__c ), ISCHANGED(Program_Detail__c), ISCHANGED( Location_Region__c ), ISCHANGED(Service_Line__c ), ISCHANGED( Status__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Assessment Only Service Assignment Name</fullName>
        <actions>
            <name>Update_Assessment_Only_Service_Assignmen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Assignment__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Assignment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Assessment Only</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Standard Service Assignment Name</fullName>
        <actions>
            <name>Update_Service_Assignment_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Service_Assignment__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Service_Assignment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Standard Service Assignment</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
