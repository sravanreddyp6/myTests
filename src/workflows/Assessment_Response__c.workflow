<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Response_Has_Value</fullName>
        <description>A field update to indicate that the Response__c field in the Assessment Response has a value.  Added to get around the validation rule on AssessmentResponseCount__c on the Assessment__c object for the ISSA assessment, that uses both Response and Rating.</description>
        <field>Response_Has_Value__c</field>
        <literalValue>1</literalValue>
        <name>Update Response Has Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Response_Has_Value_NOT</fullName>
        <field>Response_Has_Value__c</field>
        <literalValue>0</literalValue>
        <name>Update Response Has Value (NOT)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Check</fullName>
        <description>A field update workflow rule to prevent redundant assesssment response values.</description>
        <field>Unique_Check__c</field>
        <formula>( Assessment__r.Id  +   Question__r.Id )</formula>
        <name>Update Unique Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Insert Unique AssessmentID QuestionID Concat</fullName>
        <actions>
            <name>Update_Unique_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Assessment_Response__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>A workflow rule that inserts a unique concatenation of the Assessment ID and Question ID values into a &quot;Field Update&quot; workflow...field?  bucket?...so we don&apos;t get redundant assessment responses.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Response Has Value</fullName>
        <actions>
            <name>Update_Response_Has_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Assessment_Response__c.Response__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Assessment_Response__c.Rating__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Assessment_Response__c.Score__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Response Has Value %28NOT%29</fullName>
        <actions>
            <name>Update_Response_Has_Value_NOT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Assessment_Response__c.Response__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Assessment_Response__c.Rating__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Assessment_Response__c.Score__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
