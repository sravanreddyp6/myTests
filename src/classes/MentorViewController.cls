public with sharing class MentorViewController {
    public TMN_Contact__c contact { get; set; }
    public TMN_Contact__c currentHouseholdMember { get; set; }
    public Id currentHouseholdMemberId { get; set; }
    public string baseUrl {
    	get {
    		String aBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    		return aBaseUrl;
    	}
    	set;
    }
    
    public TMN_Contact__c[] householdMembers {
        get {
            return [
                SELECT Id, Name, Full_Name__c, First_Name__c, Middle_Initial__c,
                       Last_Name__c, Primary_Phone__c, Secondary_Phone__c,
                       Related_Party_Type__c, Email__c, Comments__c, Age__c,
                       Date_of_Birth__c
                FROM TMN_Contact__c WHERE Mentor__c = :contact.Id
            ];
        }
    }
    public RecordType[] contactRecordTypes;

    public MentorViewController(ApexPages.standardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new String[] {'Mentor__c', 'RecordType.Name'});
        }
        contact = (TMN_Contact__c) stdController.getRecord();
        contactRecordTypes = [
            SELECT Id, Name, DeveloperName
            FROM RecordType
            WHERE SObjectType = 'TMN_Contact__c'
        ];
    }

    public void showAddHouseholdMember() {
        Id relatedPartyRecordTypeId;
        for (RecordType rt: contactRecordTypes) {
            if (rt.Name == 'Household Member') {
                relatedPartyRecordTypeId = rt.Id;
            }
        }
        this.currentHouseholdMember = new TMN_Contact__c(
            Mentor__c = contact.Id,
            RecordTypeId = relatedPartyRecordTypeId,
            OwnerId = contact.OwnerId
        );
    }

    public void showEditHouseholdMember() {
        this.currentHouseholdMember = [
            SELECT Id, Name, Full_Name__c, First_Name__c, Middle_Initial__c,
                   Last_Name__c, Primary_Phone__c, Secondary_Phone__c,
                   Related_Party_Type__c, Email__c, Comments__c, Date_of_Birth__c,
                   Age__c, Gender__c, Marital_Status__c, No_Longer_In_Home__c,
                   Population_This_Home_Is_Associated_With__c
            FROM TMN_Contact__c WHERE ID=:currentHouseholdMemberId
        ];
    }

    public void saveHouseholdMember() {
        try {
            upsert currentHouseholdMember;
        } catch (DMLException ex) {
            // SF will automatically generate a PageMessage error here.
        }
    }

    public void changeHouseholdMemberType() {
        // Blank out Gender and Marital Status fields for Pets
        if (currentHouseholdMember.Related_Party_Type__c == 'Pet') {
            currentHouseholdMember.Gender__c = '';
            currentHouseholdMember.Marital_Status__c = '';
        }
    }
}