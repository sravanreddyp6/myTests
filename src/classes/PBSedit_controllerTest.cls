@isTest
public class PBSedit_controllerTest{
	
//Testing Cambridge Flavor
public static testmethod void testPBSEditforCambridge(){
	//Creating a User with System Admin Profile.
    User admin = TMN_Generic_Core_TestData.createUser('System Administrator', 'cam', 'srn@tmn.com', 'first Fname', 'Last LName', 'Cambridge');
    TMN_User__c admintmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: admin.id];
   
   //Running the test as admin User     
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
		
		Test.StartTest(); // Using this method to get fresh set of Governor limits.
			
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
		system.Assert( controller.pbsEditModeOn == false ); // Assertion to check the view mode after user clicks cancel Button.
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
		Test.StopTest();
		}

  	}
 //Testing Care Meridian Flavor
 public static testmethod void testPBSEditforCaremeridian(){
 	//Creating a user with 'ESD General' Profile
	User cmUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Care Meridian');
	//Assigning Permission Sets
	List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
	system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
		TMN_Generic_Core_TestData.permsetAssign(permsets, cmUser.Id);
	}
	
	TMN_User__c cmtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: cmUser.id];
    //Running the test as Care Meridian User    
	system.runas(cmUser){
		
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
		
		Test.StartTest();
				
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
		Test.StopTest();
		}

  	}

//Testing Redwood flavor
public static testmethod void testPBSEditforRedwood(){
	//Creating a redwood User with 'ESD General' profile
    User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'rduser', 'rduser@rd.com', 'rdFname', 'rdLName', 'Redwood');
	Tmn_User__c redwoodtmnUser= [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
	
	//Assigning Permission sets necessary to create a Person Being Served
    List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
        	TMN_Generic_Core_TestData.permsetAssign(permsets, redwoodUser.Id);
        }      
   //Runing the test as redwood user     
	system.runas(redwoodUser){
		
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
		
		Test.StartTest();
			
		PBSEdit_Controller controller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
		system.Assert( controller.currentURL.contains('edit') == true);
		system.assertEquals(false, controller.canViewFamilyInfo); //Redwood flavor cannot see Family info
		system.assert(controller.showDiagnosis); // Redwood flavor should see Diagnosis Section
		system.assertEquals(controller.dontShowFields.Contains('Current_Medications__c'), True); // Checking the hidden fields for Care Meridian flavor 
		system.assertEquals(controller.TMNUser.id,redwoodtmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
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
		Test.StopTest();
		}

  	}
}