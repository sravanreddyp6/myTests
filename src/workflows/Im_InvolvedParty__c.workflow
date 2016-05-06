<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateImIncidentName</fullName>
        <field>Name</field>
        <formula>CASE(Type__c, &quot;Person Being Served&quot;, Person_Being_Served_Involved__r.pbsFirstName__c + &quot; &quot; + Person_Being_Served_Involved__r.pbsLastName__c, &quot;Staff&quot;,  Staff_Involved__r.Name ,&quot;&quot;)</formula>
        <name>UpdateImIncidentName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateImInvolvedPartyName</fullName>
        <actions>
            <name>UpdateImIncidentName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Im_InvolvedParty__c.Type__c</field>
            <operation>equals</operation>
            <value>Person Being Served,Staff</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
