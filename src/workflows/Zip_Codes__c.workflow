<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetUniqueCheckFieldtoName</fullName>
        <field>Zip_Code__c</field>
        <formula>Name</formula>
        <name>SetUniqueCheckFieldtoName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateZipCodeUniqueCheck</fullName>
        <actions>
            <name>SetUniqueCheckFieldtoName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Zip_Codes__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Checks zip code uniqueness by adding the name to an externID field that is required to be unique.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
