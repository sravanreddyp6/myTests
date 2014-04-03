@isTest
public with sharing class MentorTests {
    static testmethod void testEdit() {
        TMN_Contact__c contact = new TMN_Contact__c();
        MentorEditController controller = new MentorEditController(
            new ApexPages.standardController(contact)
        );
        System.assert(controller.contact.Id == null);
        insert contact;
        controller = new MentorEditController(
            new ApexPages.standardController(contact)
        );
        System.assertEquals(contact.Id, controller.contact.Id);
    }

    static testmethod void testView() {
        TMN_Contact__c contact = new TMN_Contact__c(
            RecordTypeId = getRecordTypeId('TMN_Contact__c', 'Mentor')
        );
        insert contact;
        Id rpRecordTypeId = getRecordTypeId('TMN_Contact__c', 'Household Member');
        TMN_Contact__c[] householdMembers = new TMN_Contact__c[] {
            new TMN_Contact__c(
                RecordTypeId = rpRecordTypeId,
                Mentor__c = contact.Id,
                Related_Party_Type__c = 'Co-Applicant',
                Email__c = 'test@test.com'
            ),
            new TMN_Contact__c(
                RecordTypeId = rpRecordTypeId,
                Mentor__c = contact.Id,
                Related_Party_Type__c = 'Foster Parent\'s Child'
            )
        };
        insert householdMembers;
        MentorViewController controller = new MentorViewController(
            new ApexPages.standardController(contact)
        );
        System.assertEquals(contact.Id, controller.contact.Id);
        System.assertEquals(2, controller.householdMembers.size());
        controller.showAddHouseholdMember();
        controller.currentHouseholdMember.Related_Party_Type__c = 'Foster Parent\'s Relative';
        controller.currentHouseholdMember.RecordTypeId = rpRecordTypeId;
        controller.currentHouseholdMember.Mentor__c = contact.Id;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='ESD General' LIMIT 1 ];
        
		User testUser1 = new User(
          	Alias = 'standt', 
          	Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='alpha@testorg.com'
		);
		insert testUser1;        
        
        controller.currentHouseholdMember.OwnerId = testUser1.Id;
        System.debug('SAVE ATTEMPT HERE');
        System.debug('controller.currentHouseholdMember AT SAVE ATTEMPT: ' + controller.currentHouseholdMember);
        controller.saveHouseholdMember();
        System.assertEquals(3, controller.householdMembers.size());
        controller.currentHouseholdMemberId = householdMembers[1].Id;
        controller.showEditHouseholdMember();
        System.assertEquals(householdMembers[1].Id,
            controller.currentHouseholdMember.Id
        );
        
        String theBaseUrl = controller.baseUrl;
        
        controller.changeHouseholdMemberType();
        
    }

    static testmethod void testEditAll() {
        TMN_Contact__c contact = new TMN_Contact__c();
        MentorEditAllController controller = new MentorEditAllController(
            new ApexPages.standardController(contact)
        );
        System.assert(controller.routeRequest().getUrl().indexOf('MentorEdit') != -1);
        System.assert(controller.routeRequest().getUrl().indexOf('editId') == -1);
        contact.RecordTypeId = getRecordTypeId('TMN_Contact__c', 'Household Member');
        contact.Related_Party_Type__c = 'Co-Applicant';
        contact.Email__c = 'test@test.com';
        insert contact;
        System.debug('What is contact: ' + contact);
        controller = new MentorEditAllController(
            new ApexPages.standardController(contact)
        );
        //System.assert(!controller.routeRequest().getParameters().containsKey('editId'));
        TMN_Contact__c rp = new TMN_Contact__c(
            Mentor__c = contact.Id,
            RecordTypeId = getRecordTypeId('TMN_Contact__c', 'Household Member'),
            Related_Party_Type__c = 'Foster Parent\'s Relative'
        );
        insert rp;
        controller = new MentorEditAllController(
            new ApexPages.standardController(rp)
        );
        Map<String, String> paramMap = controller.routeRequest().getParameters();
        System.debug('paramMap: ' + paramMap);
        System.debug('url: ' + controller.routeRequest().getUrl());
        System.assert(paramMap.containsKey('editId'));
        System.assertEquals(contact.Id, paramMap.get('id'));
        System.assertEquals(rp.Id, paramMap.get('editId'));
    }

    static testmethod void testViewAll() {
        TMN_Contact__c contact = new TMN_Contact__c(
            RecordTypeId = getRecordTypeId('TMN_Contact__c', 'Mentor')
        );
        insert contact;
        MentorViewAllController controller = new MentorViewAllController(
            new ApexPages.standardController(contact)
        );
        System.assertEquals(contact.Id, controller.routeRequest().getParameters().get('id'));
        System.assertEquals(null, controller.routeRequest().getAnchor());
        TMN_Contact__c rp = new TMN_Contact__c(
            Mentor__c = contact.Id,
            RecordTypeId = getRecordTypeId('TMN_Contact__c', 'Household Member'),
            Related_Party_Type__c = 'Co-Applicant',
            Email__c = 'test@test.com'
        );
        insert rp;
        controller = new MentorViewAllController(
            new ApexPages.standardController(rp)
        );
        PageReference resultRef = controller.routeRequest();
        System.assertEquals(contact.Id, controller.routeRequest().getParameters().get('id'));
        System.assertEquals('householdMembers', controller.routeRequest().getAnchor());
    }

    public static id getRecordTypeId(string objectAPIName, string recordTypeName){
        if(String.isEmpty(objectAPIName) || String.isEmpty(recordTypeName)){
            return null;
        }
        Map<String, Schema.SObjectType> sobjectSchemaMap = Schema.getGlobalDescribe();

        Schema.SObjectType sObjType = sobjectSchemaMap.get(objectAPIName) ;
        Schema.DescribeSObjectResult cfrSchema = sObjType.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id recordTypeId = RecordTypeInfo.get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }
}