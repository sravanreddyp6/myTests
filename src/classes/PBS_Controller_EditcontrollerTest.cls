@isTest
public with sharing class PBS_Controller_EditcontrollerTest {
	
	// Testing Cambridge flavor
	static testMethod void insertandeditPBSTestforCambridge() {
		//Creating a user with 'ESD General' Profile and creating a corresponding TMN User record.
        User cambridgeUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Cambridge');
       //Assigning permission sets to the user.
        List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
        	TMN_Generic_Core_TestData.permsetAssign(permsets, cambridgeUser.Id);
        }
        
        TMN_User__c cambridgetmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: cambridgeUser.id];
        
        system.runas(cambridgeUser){
	        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
			Account Accnt = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test FName',
				LastName='Test LName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA', 
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.today()-60
			);
			
			Related_Party__c relParty = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
			
			PageReference ref = new PageReference('/apex/PBS_Create');
			Test.setCurrentPage(ref); 
			
			PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
			pageReference ref2;
			try{
				controller.SavePBS();
				List<ApexPages.Message> msgList = ApexPages.getMessages();
				boolean validateAge = false;
				for(ApexPages.Message msg :  ApexPages.getMessages()) {
					system.debug( msg.getSummary());
					if(msg.getsummary().contains('younger than 18')) 
					validateAge = true;
				}			
				system.assert(validateAge);	//Asserting the error message for Under age Validation
			}
			catch(exception e){	
			}
			//Assigning the related Party with type as 'Guardian' to bypass the under age Validation and now the record will be saved without errors
			controller.relParty = relParty;
			ref2 = controller.savePBS(); 
	
			Related_Party__c rp = PBS_controller_helper.loadRelatedParty(relParty.Id);
			System.assertEquals( relParty.name, rp.name);
			
			rp = PBS_controller_helper.saveRelatedParty(rp.Id, 'rp new name', rp.type__c, '', '', '', '', '', '', '', controller.personbeingserved.personcontactid);
			Related_Party__c rp2 = PBS_controller_helper.saveRelatedParty(null, 'another rp', rp.type__c, '', '', '', '', '', '', '', controller.personbeingserved.personcontactid);
			System.assertEquals( rp.type__c, rp2.type__c);
			
			//Creating another account with Same First Name, Last Name and Birthdate as above and the record insertion should fail.
			Account Accnt2 = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test FName',
				LastName='Test LName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA',
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.today()-60
			);
			
			controller = new PBS_Controller(new ApexPages.StandardController(Accnt2));
			Related_Party__c relParty2 = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
			
			try {
				controller.relParty = relParty2;
				ref2 = controller.savePBS();
				List<ApexPages.Message> msgList = ApexPages.getMessages();
				for(ApexPages.Message msg :  ApexPages.getMessages()) {
					system.debug( msg.getSummary());
	    			System.Assert(msg.getSummary().contains ('already exists') || msg.getSummary().contains('guardian'));
	    			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
				}
			} catch (Exception e) {
				// person is duplicate; should throw error
				System.Assert( e.getMessage().contains('already exists'), e.getMessage() ); // Asserting the duplicate account exception.
			}
			
			System.assertEquals( false, PBS_controller_helper.isUserLevel1or2());
			
			//Flavor Specific Assertions while inserting the account Record
			system.assert(controller.canViewFamilyInfo); //Cambridge flavor can see Family info
			system.assert(controller.showDiagnosis); // Cambridge flavor can see Diagnosis Section
			system.assertEquals(string.ISBLANK(controller.dontShowFields), True); // No fields are hidden specifically for Cambridge flavor
			system.assertEquals(controller.TMNUser.id,cambridgetmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
				
			//Testing PBSedit_controller - we can reuse the account created for testing the PBS_Controller
			Accnt = [select id, personcontactid from account where id = :Accnt.Id];
			Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
			
			PageReference pageRef = Page.PersonBeingServedEditNew;
			Test.setCurrentPage(pageRef);
			ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
			ApexPages.CurrentPage().getParameters().put('edit','true');
			
			PBSEdit_Controller editcontroller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
			system.Assert(editcontroller.currentURL.contains('edit') == true);
			system.assert(editcontroller.isEditor); 
			system.assert(editcontroller.canEdit);
			system.assert(editcontroller.canCreateAdm);
			editcontroller.showAddRelParty();
			
			editcontroller.relParty = PBS_Controller_Helper.saveRelatedParty('', 'test related party', 'Case Manager', 'phone1', '', 
                                              'addr', '', '', '', 'comments', pbs.Id);
			
			PBS_Controller_Helper.loadRelatedParty(editcontroller.relParty.Id);
			editcontroller.saveRelParty();
			editcontroller.createRelParties();
		
			system.Assert(editcontroller.relParties.size() ==3 ); // Making sure the related parties created on Create/Edit pages are retrieved.
			
			editcontroller.cancelPBSController();
			system.Assert(editcontroller.pbsEditModeOn == false ); // Assertion to check the view mode after user clicks cancel Button.
			system.Assert(editcontroller.Attachments.size() == 0 );
			system.Assert(editcontroller.diagnosis.size() == 0);
			system.Assert(editcontroller.admissions.size()== 0); 
			
			pbs.MailingStateCode = 'NC'; // Updating pbs to check the validation on North Carolina for Other Id and Description
			
			try{
				update pbs;
			}
			catch(exception e){
				system.assert(e.getMessage().Contains('The Other ID and Other ID Description')); //Checking for Other Id and Other Id description when the State is NC
			}
			
			//Flavor Specific assertions
			system.assert(editcontroller.canViewFamilyInfo); //Cambridge flavor can see Family info
			system.assert(editcontroller.showDiagnosis); // Cambrdige flavor can see Diagnosis Section
			system.assertEquals(editcontroller.dontShowFields.Contains('Advanced_Directives__c'), True); //this is available for CM only
			system.assertEquals(editcontroller.dontShowFields.Contains('Code_Status__c'), True); //this is available for CM only
			system.assertEquals(editcontroller.TMNUser.id,cambridgetmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		}
	        
		
	}
	
	static testMethod void insertandeditPBSTestforCareMeridian() {
		User careMeridianUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Care Meridian');
		List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
        	TMN_Generic_Core_TestData.permsetAssign(permsets, careMeridianUser.Id);
        }
		TMN_User__c careMeridiantmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: careMeridianUser.id];
		
		system.runas(careMeridianUser){
			
			String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
			Account Accnt = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test FName',
				LastName='Test LName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA', 
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.parse('12/17/1980')
			);
			
			PageReference ref = new PageReference('/apex/PBS_Create');
			Test.setCurrentPage(ref);
			PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
			//Flavor Specific Assertions while inserting the account Record
			system.assertEquals(false,controller.canViewFamilyInfo); // Care Meridian should not see Family Info
	        system.assertEquals(false,controller.showDiagnosis); // care Meridian should not see Diagnosis section
	        system.assertEquals(controller.dontShowFields.Contains('Current_Medications__pc'), True); //Checking for the fields to be hidden for CareMerdian flavor.
	        system.assertEquals(controller.TMNUser.id,careMeridiantmnUser.id); // Checking the TMN User created
			
			controller.savePBS();
			//Testing PBSedit_controller - we can reuse the account created for testing the PBS_Controller
			Accnt = [select id, personcontactid from account where id = :Accnt.Id];
			Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
			PageReference pageRef = Page.PersonBeingServedEditNew;
			Test.setCurrentPage(pageRef);
			ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
			ApexPages.CurrentPage().getParameters().put('edit','true');
			PBSEdit_Controller editcontroller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
			system.Assert( editcontroller.currentURL.contains('edit') == true);
	        system.assertEquals(false, editcontroller.canViewFamilyInfo); //Care Meridian flavor cannot see Family info
	        system.assertEquals(false, editcontroller.showDiagnosis); // Care Meridian flavor cannot see Diagnosis Section
	        system.assertEquals(editcontroller.dontShowFields.Contains('Current_Medications__c'), True); // Checking the hidden fields for Care Meridian flavor 
	        system.assertEquals(editcontroller.TMNUser.id,careMeridiantmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		}
	}
	static testMethod void insertandeditPBSTestforRedwood() {
		User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Redwood');
		List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
        	TMN_Generic_Core_TestData.permsetAssign(permsets, redwoodUser.Id);
        }
		TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
		
		system.runas(redwoodUser){
			
			String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
			Account Accnt = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test FName',
				LastName='Test LName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA', 
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.parse('12/17/1980')
			);
			
			PageReference ref = new PageReference('/apex/PBS_Create');
			Test.setCurrentPage(ref);
			PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
			//Flavor Specific Assertions while inserting the account Record
			system.assertEquals(false,controller.canViewFamilyInfo); // Redwood should not see Family Info
            system.assert(controller.showDiagnosis); // Redwood should See Diagnosis section
            system.assertEquals(controller.dontShowFields.Contains('Current_Medications__pc'), True); //Checking for the fields to be hidden for Redwood flavor.
            system.assertEquals(controller.TMNUser.id,redwoodtmnUser.id); // Checking the TMN User created
			controller.savePBS();
			
			//Testing PBSedit_controller - we can reuse the account created for testing the PBS_Controller
			Accnt = [select id, personcontactid from account where id = :Accnt.Id];
			Contact pbs = [ select id,MailingStateCode, LastName, FirstName from contact where id = :Accnt.personcontactId];
			PageReference pageRef = Page.PersonBeingServedEditNew;
			Test.setCurrentPage(pageRef);
			ApexPages.CurrentPage().getParameters().put('id',pbs.Id);
			ApexPages.CurrentPage().getParameters().put('edit','true');
			PBSEdit_Controller editcontroller = new PBSEdit_Controller(new ApexPages.StandardController(pbs));
			system.Assert( editcontroller.currentURL.contains('edit') == true);
	        system.assertEquals(false, editcontroller.canViewFamilyInfo); //Redwood flavor cannot see Family info
	        system.assert(editcontroller.showDiagnosis); // Redwood flavor should see Diagnosis Section
	        system.assertEquals(editcontroller.dontShowFields.Contains('Current_Medications__c'), True); // Checking the hidden fields for Redwood flavor
            system.assertEquals(editcontroller.dontShowFields.Contains('Advanced_Directives__c'), True); //this is available for CM only
            system.assertEquals(editcontroller.dontShowFields.Contains('Code_Status__c'), True); //this is available for CM only	         
	        system.assertEquals(editcontroller.TMNUser.id,redwoodtmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		}
	}
	
}