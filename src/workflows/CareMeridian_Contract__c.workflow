<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CM_Contract_Edit_Note</fullName>
        <description>CM_Contract_Edit_Note</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contracts/CM_Contract_Edit_Note</template>
    </alerts>
    <alerts>
        <fullName>NeuroRestorative_Termination_Notice_Alert</fullName>
        <description>NeuroRestorative Termination Notice Alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contracts/Neuro_Termination_Notice_Alert</template>
    </alerts>
    <alerts>
        <fullName>Neuro_Termination_Notice_alert</fullName>
        <description>Neuro Termination Notice alert</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contracts/NeuroRestorative_Termination_Notice</template>
    </alerts>
    <alerts>
        <fullName>Neuro_need_to_get_notified_alert</fullName>
        <description>Neuro need to get notified alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contracts/NeuroRestorative_Termination_Notice</template>
    </alerts>
    <fieldUpdates>
        <fullName>cm_set_initial_on</fullName>
        <field>Initial__c</field>
        <literalValue>1</literalValue>
        <name>cm set initial on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_is_email_temp_new</fullName>
        <field>email_temp_is_record_new__c</field>
        <literalValue>0</literalValue>
        <name>set is email temp new</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CM Contract Edit Note</fullName>
        <actions>
            <name>CM_Contract_Edit_Note</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>set_is_email_temp_new</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the contract is brand new send a note.
if a change is made send a note.
If the contract has renew&apos;d send a note on the renewal but not on the old contract.</description>
        <formula>!ISCHANGED( Next_Contract__c )|| ISNEW()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CM set initial</fullName>
        <actions>
            <name>cm_set_initial_on</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK( Previous_Contract__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NeuroRestorative Need to get notified notice</fullName>
        <active>true</active>
        <criteriaItems>
            <field>CareMeridian_Contract__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>NeuroRestorative Contracts</value>
        </criteriaItems>
        <criteriaItems>
            <field>CareMeridian_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>CareMeridian_Contract__c.Termination_Notice__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CareMeridian_Contract__c.Need_to_get_Notified__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Neuro_need_to_get_notified_alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CareMeridian_Contract__c.Neuro_Term_Notice_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NeuroRestorative Termination notice alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>CareMeridian_Contract__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>NeuroRestorative Contracts</value>
        </criteriaItems>
        <criteriaItems>
            <field>CareMeridian_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>CareMeridian_Contract__c.Termination_Notice__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NeuroRestorative_Termination_Notice_Alert</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>CareMeridian_Contract__c.Neuro_Termination_Not_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
