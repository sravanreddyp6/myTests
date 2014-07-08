<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>VPONoteAmendment</fullName>
        <description>VPONoteAmendment</description>
        <protected>false</protected>
        <recipients>
            <field>VPO__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Contracts/HTML_VPO_Amendment_Note</template>
    </alerts>
    <rules>
        <fullName>VPONoteContractAmendment</fullName>
        <actions>
            <name>VPONoteAmendment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>ContractAmendment__c.AreTheRatesChanging__c</field>
            <operation>equals</operation>
            <value>Lower</value>
        </criteriaItems>
        <criteriaItems>
            <field>ContractAmendment__c.HaveTheAmountOfServicesChanged__c</field>
            <operation>equals</operation>
            <value>Increased</value>
        </criteriaItems>
        <description>WFR; Note</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
