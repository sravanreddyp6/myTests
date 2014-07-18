@isTest
public class PBSedit_controllerTest{

public static testmethod void testPBSEditforCambridge(){

	Profile prof = [select id, name from Profile where name ='System Administrator'];
	User admin = new User(alias = 'camb',
                                email='camb@TMN.com',
                                emailencodingkey='UTF-8',
                                lastname='Last cambName', firstname='firstName', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id,
                                timezonesidkey='America/Los_Angeles',
                                username='camb@TMN.com' + System.currentTimeMillis());
                                
        insert admin;
        
   	 Tmn_User__c admintmnUser= new Tmn_User__c(operating_group__c='Cambridge', Salesforce_User_Account__c=admin.id);
        insert admintmnUser;
        
	system.runas(admin){
		
	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName222222',
			LastName='Test LName2222',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com2222',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/1980')
		);
		insert Accnt;
		
		Accnt = [select id, personcontactid from account where id = :Accnt.Id];
		Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
		
		PageReference pageRef = Page.PersonBeingServedEditNew;
        Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
		ApexPages.CurrentPage().getParameters().put('edit','true');		
		PBSEdit_Controller controller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
		system.Assert( controller.currentURL.contains('edit') == true);
		system.assert(controller.canViewFamilyInfo); //Cambridge flavor can see Family info
		system.assert(controller.showDiagnosis); // Cambrdige flavor can see Diagnosis Section
		system.assertEquals(string.ISBLANK(controller.dontShowFields), True); // No fields are hidden specifically for Cambridge flavor
		system.assertEquals(controller.TMNUser.id,admintmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		system.assert(controller.isEditor); 
		system.assert(controller.canEdit);
		system.assert(controller.canCreateAdm);
		controller.showAddRelParty();
		
		controller.relParty = PBS_Controller_Helper.saveRelatedParty('', 'test related party', 'Case Manager', 'phone1', '', 
                                              'addr', '', '', '', 'comments', pbs.Id);
                                              
		PBS_Controller_Helper.loadRelatedParty( controller.relParty.Id);
		
		controller.saveRelParty();
		controller.createRelParties();
		
		
		system.Assert( controller.relParties.size() ==1 );
		
		controller.cancelPBSController();
		system.Assert( controller.pbsEditModeOn == false );
		system.Assert( controller.Attachments.size() == 0 );
		system.Assert(controller.diagnosis.size() == 0);
		system.Assert(controller.admissions.size()== 0);
		
		pbs.MailingStateCode = 'NC'; // Updating pbs to check the validation on North Carolina for Other Id and Description
		
		try{
			update pbs;
			}
			catch(Exception e){
				system.debug('errorMessage'+e.getMessage());
				system.assert(e.getMessage().Contains('The Other ID and Other ID Description')); //Checking for Other Id and Other Id description when the State is NC
			}
		}

  	}
  	public static testmethod void testPBSEditforCaremeridian(){

	system.runas(new User(Id = Userinfo.getUserId())){ // Running as the current user as Salesforce will not allow us to create a user, assign perm sets and create a TMN user in one transaction unless we use System.runas
	profile p = [SELECT Id, Name FROM Profile WHERE Name='ESD General'];
	User cmUser = new User(alias = 'cm',
                                email='cm@TMN.com',
                                emailencodingkey='UTF-8',
                                lastname='TLastName', firstname='TfirstName', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = p.id,
                                timezonesidkey='America/Los_Angeles',
                                username='cm@TMN.com' + System.currentTimeMillis());
                                
        insert cmUser;
  
    // Permission Set Assignment 
    List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN('ESD_Notes_Common','ESD_Notes_Intaker')];
	List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();	
     	for(PermissionSet ps : theSets){
     		thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = cmUser.Id));
     		
     	}
        insert thepermAssigns;
        system.debug('permission setssss'+thePermAssigns[0].PermissionSetId);
	}
	User u2 = [SELECT ID, NAME FROM User WHERE alias = 'cm' and email='cm@TMN.com'];
	Tmn_User__c cmtmnUser= new Tmn_User__c(operating_group__c='Care Meridian', Salesforce_User_Account__c= u2.id);
        insert cmtmnUser;
        
	system.runas(u2){
		
	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName222222',
			LastName='Test LName2222',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com2222',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/1980')
		);
		insert Accnt;
		
		Accnt = [select id, personcontactid from account where id = :Accnt.Id];
		Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
		
		PageReference pageRef = Page.PersonBeingServedEditNew;
        Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
		ApexPages.CurrentPage().getParameters().put('edit','true');		
		PBSEdit_Controller controller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
		system.Assert( controller.currentURL.contains('edit') == true);
		system.assertEquals(false, controller.canViewFamilyInfo); //Care Meridian flavor cannot see Family info
		system.assertEquals(false, controller.showDiagnosis); // Care Meridian flavor cannot see Diagnosis Section
		system.assertEquals(controller.dontShowFields.Contains('Current_Medications__c'), True); // Checking the hidden fields for Care Meridian flavor 
		system.assertEquals(controller.TMNUser.id,cmtmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		system.assert(controller.isEditor); 
		system.assert(controller.canEdit);
		system.assert(controller.canCreateAdm);
		controller.showAddRelParty();
		
		controller.relParty = PBS_Controller_Helper.saveRelatedParty('', 'test related party', 'Case Manager', 'phone1', '', 
                                              'addr', '', '', '', 'comments', pbs.Id);
                                              
		PBS_Controller_Helper.loadRelatedParty( controller.relParty.Id);
		
		controller.saveRelParty();
		controller.createRelParties();
		
		
		system.Assert( controller.relParties.size() ==1 );
		
		controller.cancelPBSController();
		system.Assert( controller.pbsEditModeOn == false );
		system.Assert( controller.Attachments.size() == 0 );
		system.Assert(controller.diagnosis.size() == 0);
		system.Assert(controller.admissions.size()== 0);
		
		pbs.MailingStateCode = 'NC'; // Updating pbs to check the validation on North Carolina for Other Id and Description
		
		try{
			update pbs;
			}
			catch(Exception e){
				system.debug('errorMessage'+e.getMessage());
				system.assert(e.getMessage().Contains('The Other ID and Other ID Description')); //Checking for Other Id and Other Id description when the State is NC
			}
		}

  	}
  	
  	public static testmethod void testPBSEditforRedwood(){

	system.runas(new User(Id = Userinfo.getUserId())){ // Running as the current user as Salesforce will not allow us to create a user, assign perm sets and create a TMN user in one transaction unless we use System.runas
	profile p = [SELECT Id, Name FROM Profile WHERE Name='ESD General'];
	User redwoodUser = new User(alias = 'rd',
                                email='rd@TMN.com',
                                emailencodingkey='UTF-8',
                                lastname='TLastName', firstname='TfirstName', languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = p.id,
                                timezonesidkey='America/Los_Angeles',
                                username='rd@TMN.com' + System.currentTimeMillis());
                                
        insert redwoodUser;
  
    // Permission Set Assignment 
    List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN('ESD_Notes_Common','ESD_Notes_Intaker')];
	List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();	
     	for(PermissionSet ps : theSets){
     		thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = redwoodUser.Id));
     		
     	}
        insert thepermAssigns;
        system.debug('permission setssss'+thePermAssigns[0].PermissionSetId);
	}
	User u3 = [SELECT ID, NAME FROM User WHERE alias = 'rd' and email='rd@TMN.com'];
	Tmn_User__c rdtmnUser= new Tmn_User__c(operating_group__c='Redwood', Salesforce_User_Account__c= u3.id);
        insert rdtmnUser;
        
	system.runas(u3){
		
	String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test FName222222',
			LastName='Test LName2222',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com2222',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.parse('08/01/1980')
		);
		insert Accnt;
		
		Accnt = [select id, personcontactid from account where id = :Accnt.Id];
		Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
		
		PageReference pageRef = Page.PersonBeingServedEditNew;
        Test.setCurrentPageReference(pageRef);
		ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
		ApexPages.CurrentPage().getParameters().put('edit','true');		
		PBSEdit_Controller controller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
		system.Assert( controller.currentURL.contains('edit') == true);
		system.assertEquals(false, controller.canViewFamilyInfo); //Redwood flavor cannot see Family info
		system.assert(controller.showDiagnosis); // Redwood flavor should see Diagnosis Section
		system.assertEquals(controller.dontShowFields.Contains('Current_Medications__c'), True); // Checking the hidden fields for Care Meridian flavor 
		system.assertEquals(controller.TMNUser.id,rdtmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		system.assert(controller.isEditor); 
		system.assert(controller.canEdit);
		system.assert(controller.canCreateAdm);
		controller.showAddRelParty();
		
		controller.relParty = PBS_Controller_Helper.saveRelatedParty('', 'test related party', 'Case Manager', 'phone1', '', 
                                              'addr', '', '', '', 'comments', pbs.Id);
                                              
		PBS_Controller_Helper.loadRelatedParty( controller.relParty.Id);
		
		controller.saveRelParty();
		controller.createRelParties();
		
		
		system.Assert( controller.relParties.size() ==1 );
		
		controller.cancelPBSController();
		system.Assert( controller.pbsEditModeOn == false );
		system.Assert( controller.Attachments.size() == 0 );
		system.Assert(controller.diagnosis.size() == 0);
		system.Assert(controller.admissions.size()== 0);
		
		pbs.MailingStateCode = 'NC'; // Updating pbs to check the validation on North Carolina for Other Id and Description
		
		try{
			update pbs;
			}
			catch(Exception e){
				system.debug('errorMessage'+e.getMessage());
				system.assert(e.getMessage().Contains('The Other ID and Other ID Description')); //Checking for Other Id and Other Id description when the State is NC
			}
		}

  	}
}