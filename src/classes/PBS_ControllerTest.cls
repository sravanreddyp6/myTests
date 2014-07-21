@isTest
private class PBS_ControllerTest {
//   COMMENTED OUT 5/15/14 BY J. GILLIAM TO GET US THROUGH MAY DEPLOYMENT

// Testing Cambridge flavor
	static testMethod void insertPBSTestforCambridge() {
       	User admin = TMN_Generic_Core_TestData.createUser('System Administrator', 'cam', 'srn@tmn.com', 'firt Fname', 'Last LName', 'Cambridge');
	   	TMN_User__c admintmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: admin.id];
		system.runas(admin){
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
		system.assert(controller.canViewFamilyInfo); //Cambridge flavor can see Family info
		system.assert(controller.showDiagnosis); // Cambrdige flavor can see Diagnosis Section
		system.assertEquals(string.ISBLANK(controller.dontShowFields), True); // No fields are hidden specifically for Cambridge flavor
		system.assertEquals(controller.TMNUser.id,admintmnUser.id); // Making sure the returned TMN User in controller is same as the one created in test class
		PageReference ref2;
		try {
			ref2 = controller.savePBS();
			List<ApexPages.Message> msgList = ApexPages.getMessages();
			boolean validateAge = false;
			for(ApexPages.Message msg :  ApexPages.getMessages()) {
				system.debug( msg.getSummary());
				if(msg.getsummary().contains('younger than 18')) 
				validateAge = true;
			System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
			}			
			system.assert(validateAge);	//Checking for page Message when the peron being served age is less than 18.
		
		} catch (Exception e) {
			// person is less than 18 and no guardian provided; should throw error
			system.debug(e.getMessage());
			System.Assert( e.getMessage().contains('less than 18'), e.getMessage() ); //Asserting the exception for Under age Validation
			
			}
			
		controller.relParty = relParty;
		ref2 = controller.savePBS();

		
		Related_Party__c rp = PBS_controller_helper.loadRelatedParty(relParty.Id);
		System.assertEquals( relParty.name, rp.name);
		
		rp = PBS_controller_helper.saveRelatedParty(rp.Id, 'rp new name', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
		Related_Party__c rp2 = PBS_controller_helper.saveRelatedParty(null, 'another rp', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
		System.assertEquals( rp.type__c, rp2.type__c);
		
		
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
		
		}
    }
    
    //  Testing Care Meridian Flavor
    static testMethod void insertPBSTestforCareMeridian() {
	/*system.runas(new User(Id = Userinfo.getUserId())){ // Running as the current user as Salesforce will not allow us to create a user, assign perm sets and create a TMN user in one transaction unless we use System.runas
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
        List<String> sets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        
        TMN_Generic_Core_TestData.permsetAssign(sets, cmUser.Id);
        
	} 
	
	User u2 = [SELECT ID, NAME FROM User WHERE alias = 'cm' and email='cm@TMN.com'];
	Tmn_User__c cmtmnUser= new Tmn_User__c(operating_group__c='Care Meridian', Salesforce_User_Account__c= u2.id);
        insert cmtmnUser; */
        
        
        User cmUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Care Meridian');
        List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
        
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
        	TMN_Generic_Core_TestData.permsetAssign(permsets, cmUser.Id);
        }
        
        TMN_User__c cmtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: cmUser.id];
		system.runas(cmUser){
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
		Account Accnt = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test CMFName',
			LastName='Test CMLName',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.today()-10
		);
		
		Related_Party__c relParty = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
		
		PageReference ref = new PageReference('/apex/PBS_Create');
		Test.setCurrentPage(ref); 
		
		PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
		system.assertEquals(false,controller.canViewFamilyInfo); // Care Meridian should not see Family Info
		system.assertEquals(false,controller.showDiagnosis); // care Meridian should not see Diagnosis section
		system.assertEquals(controller.dontShowFields.Contains('Current_Medications__pc'), True); //Checking for the fields to be hidden for CareMerdian flavor.
		system.assertEquals(controller.TMNUser.id,cmtmnUser.id); // Checking the TMN User created
		PageReference ref2;
		try {
			ref2 = controller.savePBS();
			List<ApexPages.Message> msgList = ApexPages.getMessages();
			boolean validateAge = false;
			for(ApexPages.Message msg :  ApexPages.getMessages()) {
				system.debug( msg.getSummary());
				if(msg.getsummary().contains('younger than 18')) 
				validateAge = true;
			}			
			system.assert(validateAge);	
		
		} catch (Exception e) {
			// person is less than 18 and no guardian provided; should throw error
			system.debug(e.getMessage());
			System.Assert( e.getMessage().contains('less than 18'), e.getMessage() );
			
			}
			
		controller.relParty = relParty;
		ref2 = controller.savePBS();

		
		Related_Party__c rp = PBS_controller_helper.loadRelatedParty(relParty.Id);
		System.assertEquals( relParty.name, rp.name);
		
		rp = PBS_controller_helper.saveRelatedParty(rp.Id, 'rp new name', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
		Related_Party__c rp2 = PBS_controller_helper.saveRelatedParty(null, 'another rp', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
		System.assertEquals( rp.type__c, rp2.type__c);
		
		
		Account Accnt2 = new Account(
			RecordTypeID=RecTypeId,
			FirstName= 'Test CMFName',
			LastName='Test CMLName',
			PersonMailingStreet='10 Main St.',
			PersonMailingPostalCode='12345',
			PersonMailingCity='SF',
			PersonMailingStateCode='CA',
			PersonEmail='test@yahoo.com',
			PersonHomePhone='1234567',
			PersonMobilePhone='12345678',
			PersonBirthdate= date.today()-10
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
			System.Assert( e.getMessage().contains('already exists'), e.getMessage() );
		}
		
		System.assertEquals( false, PBS_controller_helper.isUserLevel1or2());
		
		}
    }
    
    // Testing Redwood flavor
	static testMethod void insertPBSTestforRedwood() {

		User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'rduser', 'rduser@rd.com', 'rdFname', 'rdLName', 'Redwood');
		Tmn_User__c redwoodtmnUser= [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
		
	    List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker'};
	        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
	        	TMN_Generic_Core_TestData.permsetAssign(permsets, redwoodUser.Id);
	        } 
	        
			system.runas(redwoodUser){
	        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
			Account Accnt = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test rdFName',
				LastName='Test rdLName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA',
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.today()-30
			);
			
			Related_Party__c relParty = new Related_Party__c ( Name='rp name', type__c = 'Guardian');
			
			PageReference ref = new PageReference('/apex/PBS_Create');
			Test.setCurrentPage(ref); 
			
			PBS_Controller controller = new PBS_Controller(new ApexPages.StandardController(Accnt));
			system.assertEquals(false,controller.canViewFamilyInfo); // Redwood should not see Family Info
			system.assert(controller.showDiagnosis); // Redwood should See Diagnosis section
			system.assertEquals(controller.dontShowFields.Contains('Current_Medications__pc'), True); //Checking for the fields to be hidden for Redwood flavor.
			system.assertEquals(controller.TMNUser.id,redwoodtmnUser.id); // Checking the TMN User created
			PageReference ref2;
			try {
				ref2 = controller.savePBS();
				List<ApexPages.Message> msgList = ApexPages.getMessages();
				boolean validateAge = false;
				for(ApexPages.Message msg :  ApexPages.getMessages()) {
					system.debug( msg.getSummary());
					if(msg.getsummary().contains('younger than 18')) 
					validateAge = true;
				}			
				system.assert(validateAge);	
			
			} catch (Exception e) {
				// person is less than 18 and no guardian provided; should throw error
				system.debug(e.getMessage());
				System.Assert( e.getMessage().contains('less than 18'), e.getMessage() );
				
				}
				
			controller.relParty = relParty;
			ref2 = controller.savePBS();
	
			
			Related_Party__c rp = PBS_controller_helper.loadRelatedParty(relParty.Id);
			System.assertEquals( relParty.name, rp.name);
			
			rp = PBS_controller_helper.saveRelatedParty(rp.Id, 'rp new name', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
			Related_Party__c rp2 = PBS_controller_helper.saveRelatedParty(null, 'another rp', rp.type__c, '', '', '', '', '', '', '', controller.pBSId);
			System.assertEquals( rp.type__c, rp2.type__c);
			
			
			Account Accnt2 = new Account(
				RecordTypeID=RecTypeId,
				FirstName= 'Test rdFName',
				LastName='Test rdLName',
				PersonMailingStreet='10 Main St.',
				PersonMailingPostalCode='12345',
				PersonMailingCity='SF',
				PersonMailingStateCode='CA',
				PersonEmail='test@yahoo.com',
				PersonHomePhone='1234567',
				PersonMobilePhone='12345678',
				PersonBirthdate= date.today()-30
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
				System.Assert( e.getMessage().contains('already exists'), e.getMessage() );
			}
			
			System.assertEquals( false, PBS_controller_helper.isUserLevel1or2());
			
			}
	    }
	    
}