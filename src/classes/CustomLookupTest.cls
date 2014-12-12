@isTest
public with sharing class CustomLookupTest {
	
    static testmethod void simpleTests() {
    	
    	
    	User u = createNewUser() ;
        System.runAs(u) {
    		setTMNUserOpGrp( u, 'Redwood' );
        	Service_Location__c svcLoc = new Service_Location__c (
        		Zip__c = '90021', 
        		UniqueID__c = '1001', 
    			Street__c = '10 Main St.', 
    			State__c = 'CA', 
    			Setting__c = 'Residential',
    			Service_Value__c = 'IDD', 
    			Program__c = 'Redwood Res', 
    			ProgramID__c = '1000', 
    			Phone__c = '213-555-5555',
				FacilityID__c = 10,
				City__c = 'Bakersfield',
				Alias__c = '10101' 
	        );
        	insert svcLoc;
        	svcLoc = new Service_Location__c (
        		Zip__c = '90021', 
        		UniqueID__c = '20100', 
    			Street__c = 'Neuro Rehab Center', 
    			State__c = 'CA', 
    			Setting__c = 'Residential',
    			Service_Value__c = 'IDD', 
    			Program__c = 'Neuro', 
    			ProgramID__c = '1000', 
    			Phone__c = '213-555-6666',
				FacilityID__c = 20,
				City__c = 'Berkeley',
				Alias__c = '20100' 
        	);
        	insert svcLoc;
            
            CustomLookup controller = new CustomLookup();
            controller.OffsetSize = 1;
            controller.objectType = 'Service_Location__c';
            
            controller.Searchfields = 'FacilityID__c, State__c';
            controller.returnfields = 'FacilityID__c, State__c';
            System.Debug(controller.query);
            System.Debug('select Id, Name,State__c,FacilityID__c From Service_Location__c');
            System.AssertEquals( controller.query.remove(' '), 'selectId,Name,State__c,FacilityID__cFromService_Location__c');
            controller.Search();
        	}
        		
        	    	
        
        System.runAs(u) {
			settmnUserOpGrp( u, 'NeuroRestorative');    
            CustomLookup controller = new CustomLookup();
            controller.OffsetSize = 1;
            controller.objectType = 'Service_Location__c';
            
            controller.Searchfields = 'FacilityID__c, State__c';
            controller.returnfields = 'FacilityID__c, State__c';
            System.Debug(controller.query);
            System.Debug('select Id, Name,State__c,FacilityID__c From Service_Location__c');
            System.AssertEquals( controller.query.remove(' '), 'selectId,Name,State__c,FacilityID__cFromService_Location__c');
            
            for ( CustomLookup.FieldWrapper fw: controller.fields ) {
            	if ( fw.name == 'State__c' ) {
            		fw.value = 'C*';
            	}
            }
            
            CustomLookup.FieldWrapper fwName = controller.NameField;
            fwName.value = '201*';
            controller.Search();
            
            List<Service_Location__c> res = (List<Service_Location__c>)controller.searchResult;
            System.AssertEquals( controller.searchSize, res.size());
           // System.AssertEquals ( controller.searchSize, 1);
            controller.First();
            if (! controller.getDisableNext())
            	controller.Next();
            controller.Last();	
            if (! controller.getDisablePrevious())
            	controller.Previous();
            	
            controller.ResetSearchItems();
            controller.OffsetSize = 0;
            System.AssertEquals( controller.getOffsetSize(), 0);
            
            fwName.value = 'Name not listed';
            controller.Search();
            res = (List<Service_Location__c>)controller.searchResult;
			System.AssertEquals ( controller.searchSize, 0);
            
        }
	}
        
        public static User createNewUser() {
        	Profile p = [SELECT Id FROM Profile WHERE Name='ESD General'];
        	User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduserabcd@testorg.com'
        	);
        	
        	insert u;
        	
        	//put user into permission sets
        	PermissionSet ps = [ select Id from PermissionSet where name='ESD_Referrals_Common'];
      		PermissionSetAssignment psa = new PermissionSetAssignment( assigneeid=u.Id, permissionsetid= ps.id);
      		insert psa;

        	ps = [ select Id from PermissionSet where name='ESD_Referrals_Intaker'];
      		psa = new PermissionSetAssignment( assigneeid=u.Id, permissionsetid= ps.id);
      		insert psa;
        	
        	return u;
        }

        
       public static void setTMNUserOpGrp( User u, String opgrp) {
        	
        	List<TMN_User__c> tmnUsers = [ select id, Operating_Group__c from TMN_User__c where salesforce_user_account__c = :u.id ];
        	
        	
        	
        	if ( tmnUsers.size() == 0 ) {
	        	TMN_User__c tmnu =  new TMN_User__c(
	        	First_Name__c = u.FirstName,
	        	Last_Name__c = u.LastName,
	            Salesforce_User_Account__c = u.Id,
	            Operating_Group__c= opgrp
		        );
		        
        		insert tmnu;
        		
        	} else {
        		for ( TMN_User__c t : tmnUsers ) {
        			t.Operating_Group__c = opgrp;
        		}
        		
        		update tmnUsers;
        	}
    }
        
}