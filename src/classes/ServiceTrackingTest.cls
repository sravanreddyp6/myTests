@isTest
private class ServiceTrackingTest {
    @testSetup
    public static void setUpData() {
        User rwOHL3User = (new TestUtils.UserBuilder())
			                .setFirstName('RW')
			                .setLastName('OH')
			                .setUserAlias('L3')
			                .setEmail('RwOhL3-test@tmn.com')
			                .getResult();
        insert rwOHL3User;
        list<PermissionSet> L3ps = [SELECT ID From PermissionSet WHERE Name IN ('ESD_Notes_RW_Level_3', 'ESD_Notes_Common')];
        list<PermissionSetAssignment> l3psAssignment = new list<PermissionSetAssignment>(); 
        l3psAssignment.add( new PermissionSetAssignment(
                        AssigneeId = rwOHL3User.Id,
                        PermissionSetId = L3ps[0].Id) );
        l3psAssignment.add( new PermissionSetAssignment(
                        AssigneeId = rwOHL3User.Id,
                        PermissionSetId = L3ps[1].Id) );
        insert l3psAssignment;

        User rwOH_DSP = (new TestUtils.UserBuilder())
                            .setFirstName('RW')
                            .setLastName('OH')
                            .setUserAlias('RwOhDSP')
                            .setEmail('rwOH_DSP-test@tmn.com')
                            .getResult();
        insert rwOH_DSP;
        PermissionSet dspPs = [SELECT ID From PermissionSet WHERE Name = 'iServe_DSP'];
        insert (new PermissionSetAssignment( AssigneeId = rwOH_DSP.Id, PermissionSetId = dspPs.Id));
        
        System.runAs(rwOHL3User) {
        	// TMN user for the L3
        	TestUtils.createTmnUser(rwOHL3User.id, 'Redwood');
        	// RW OH Alias, IDD Service Location
            Alias__c alias = new Alias__c(  Name ='505050',
                                            Alias_Description__c='OH-REM-ICF-POTTS-IDD',
                                            Alias_unique__c='505050',
                                            Alias_Business_Unit__c='BU 505 REM Ohio, Inc',
                                            Alias_Parent__c='OH-SKINNER',
                                            Alias_Region__c='Redwood East',
                                            Alias_Service_Line__c='ICF’s',
                                            Alias_State__c='OH',
                                            Alias_Operating_Group__c='Redwood',
                                            Alias_Responsibility_Center_Code__c='27415');
            insert alias;
            Service_Location__c sl = new Service_Location__c(Name='505050',
                                                             Alias__c='505050',
                                                             City__c='Akron',
                                                             FacilityID__c=16,
                                                             ProgramID__c='505050000',
                                                             Program__c='OH-REM-ICF-POTTS-IDD',
                                                             Service_Value__c='IDD - Residential ICF/MR',
                                                             Setting__c='Inpatient/Residential',
                                                             State__c='OH',
                                                             Street__c='3561 Potts Drive',
                                                             Zip__c='44203',
                                                             UniqueID__c = '16||505050000',
                                                             NPI__c='1245396696',
                                                             Program_Rollup__c='505050000',
                                                             Source_System__c='AVATAR',
                                                             Status__c='Active',
                                                             Location_Nickname__c='Akron Facility',
                                                             Network_Offering__c='IDD',
                                                             Physical_Location__c='Facility',
                                                             Population_Served__c='Adult',
                                                             Service_Type__c='ICFIDD - ICFIDD',
                                                             TMN_Scope__c='Residential',
                                                             iServe_Program__c='OH - ICFIDD - ICFIDD - Akron Facility - IDD',
                                                             Alias_lookup__c = alias.id);
        	insert sl;

        	// PBS, Addmission, SA
	        Blob b = Crypto.GenerateAESKey(128);
	        String h = EncodingUtil.ConvertTohex(b);
	        String RecTypeId = [ select Id 
	                               from RecordType 
	                              where (DeveloperName='Person_Being_Served') 
	                                and (SobjectType='Account') limit 1].Id;
	        Account theAccount = new Account(
					                RecordTypeID=RecTypeId,
					                FirstName= 'FName' + h.substring(0,5),
					                LastName='LName'+ h.substring(0,5),
					                PersonMailingStreet='123 Test Street',
					                PersonMailingPostalCode='12345',
					                PersonMailingCity='SFO',
					                PersonMailingStateCode= 'OH',
					                PersonEmail='test@yahoo.com',
					                PersonHomePhone='12345678',
					                PersonMobilePhone='12345678',
					                Other_ID__pc = '12345-111',
					                Other_ID_description__pc = 'other Id'
	                );
	        insert theAccount;
            Id contactID = [Select Id, PersonContactId From Account a WHERE a.Id = :theAccount.Id].PersonContactId;

	        Admission__c theAdm = new Admission__c(
	                Name = 'TEST ADM',
	                Person_Being_Served__c = contactID,
	                Admission_Effective_DateTime__c = datetime.newInstance(2013, 1, 1, 0, 0, 0),
	                Network_Offering__c = 'IDD',
	                state__c = 'OH');
	        insert theAdm;

	        Service_Assignment__c theSA = new Service_Assignment__c(
	                phase_1_Start_Date__c = system.today().addDays(-7),
	                Admission__c = theAdm.id,
	                Person_Being_served__c = contactID,
	                Program__c = 'IFCS',
	                Status__c = 'Active',
	                SA_Start_DateTime__c = datetime.newInstance(2013, 1, 1, 0, 0, 0),
	                start_date__c = date.newInstance(2013,1,1),
	                Projected_Treatment_End_Date__c = date.newInstance(2014, 12, 31),
	                Service_Location__c = sl.Id
	                );
            insert theSA;
            
        	// Active Final Action Plan with a service goal and yes/no, yes/no w/time type objective
            Action_Plan__c testplan = new Action_Plan__c();
            testplan.Service_Assignment__c = theSA.Id;
            testplan.Effective_Date__c = Date.parse('1/1/2013');
            testplan.Target_Date__c = Date.parse('1/31/2013');
            insert testPlan;
            Action_Plan_Goal__c testGoal = new Action_Plan_Goal__c( description__c = 'Services', isService__c = true);
            testGoal.Action_Plan__c = testPlan.Id;
            insert testGoal;
           
            list<Action_Plan_Objective__c> testObjectives = new list<Action_Plan_Objective__c>();
            testObjectives.add(new Action_Plan_Objective__c(Action_Plan_Goal__c = testGoal.Id,
												            Description__c = 'My First yes-no Service',
												            Status__c = 'In Progress',
												            Type__c = 'Yes/No',
												            Effective_Date__c = Date.parse('1/1/2013'),
												            Target_End_Date__c = Date.parse('1/31/2013') ));
            testObjectives.add(new Action_Plan_Objective__c(Action_Plan_Goal__c = testGoal.Id,
                                                            Description__c = 'My First yes-no-w-time Service',
                                                            Status__c = 'In Progress',
                                                            Type__c = 'Yes/No w/time',
                                                            Effective_Date__c = Date.parse('1/1/2013'),
                                                            Target_End_Date__c = Date.parse('1/31/2013') ));
            insert testObjectives;
            
            testplan.Status__c = 'Active Final';
            update testplan;
                       
            Id wsRt = [select id 
                        from recordtype 
                       where sobjecttype = 'Action_Plan_Worksheet__c' 
                         and developername = 'Monthly_Service_Result' limit 1].id;
            Action_Plan_Worksheet__c testWorksheet = new Action_Plan_Worksheet__c(recordtypeid = wsRt);
            testWorksheet.Start_Date__c = Date.parse('1/1/2013');
            testWorksheet.Action_Plan__c = testplan.Id;
            insert testWorksheet;
        }
    }
    static testMethod void createServTrkng() {
        User RwOhL3 = [SELECT Id FROM User WHERE Email='RwOhL3-test@tmn.com'];
        System.runAs(RwOhL3){
	        PageReference pageRef = Page.ServiceTracking;
	        Test.setCurrentPage(pageRef);
	        // create a service tracking worksheet rec
	        Action_Plan_Worksheet__c ws = [select id from Action_Plan_Worksheet__c limit 1];
            ApexPages.CurrentPage().getParameters().put('Id', ws.Id);
            ServiceTracking controller = new ServiceTracking();
	        system.assertEquals(3, controller.getServiceProvidedOpts().size());
	        system.assertEquals(5, controller.getServiceStatusOpts().size());
	        system.assertEquals(true, controller.editMode);
	        list<Action_Plan_Objective__c> services = (list<Action_Plan_Objective__c>) JSON.deserialize(controller.getObjectives(), list<Action_Plan_Objective__c>.class);
	        system.assertEquals(2, services.size());
	        controller.objResultWrapper.action_Plan_Objective = services[0].id;
            controller.objResultWrapper.service_Provided = 'Yes';
            controller.objResultWrapper.service_Date = '1/1/2013';
            controller.objResultWrapper.initials = 'L3';
            controller.mySave();
            system.assertEquals(1, [select id from Action_objective_result__c].size());
            
            controller.myEdit();
            system.assertEquals(true, controller.editMode);
            controller.servicesList();
            controller.newServiceData();
        }
    }
    static testMethod void editServTrkng() {
        User RwOhL3 = [SELECT Id FROM User WHERE Email='RwOhL3-test@tmn.com'];
        System.runAs(RwOhL3){
        	Action_Plan_Objective__c service = [select id from Action_Plan_Objective__c where Type__c = 'Yes/No'];
        	Id SrvTrckRecId = [select Id 
                                   from RecordType 
                                  where DeveloperName='Service_Objective' 
                                    and SobjectType='Action_objective_result__c' limit 1].Id;
            Action_objective_result__c srvTrk = new Action_objective_result__c(Action_Plan_Objective__c = service.Id, Service_Date_Part__c = Date.parse('1/1/2013'), Service_Provided__c = 'Yes', Initials__c = 'l3', recordTypeId= SrvTrckRecId);
        	insert srvTrk;
	        PageReference pageRef = Page.ServiceTracking;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('Id', srvTrk.id);
            ServiceTracking controller = new ServiceTracking();
            system.assertEquals(false, controller.editMode);
        }

    }
        
    static testMethod void createServTrkngDSP() {
        User RwOhDSP = [SELECT Id FROM User WHERE Email='rwOH_DSP-test@tmn.com'];
        System.runAs(RwOhDSP){
            PageReference pageRef = Page.DSPServiceTracking;
            Test.setCurrentPage(pageRef);
            // create a service tracking worksheet rec
            Action_Plan_Worksheet__c ws = [select id from Action_Plan_Worksheet__c limit 1];            
            ApexPages.CurrentPage().getParameters().put('Id', ws.Id);
            ServiceTracking controller = new ServiceTracking();
            system.assertEquals(3, controller.getServiceProvidedOpts().size());
            system.assertEquals(5, controller.getServiceStatusOpts().size());
            system.assertEquals(true, controller.editMode);
            list<Action_Plan_Objective__c> services = (list<Action_Plan_Objective__c>) JSON.deserialize(controller.getObjectives(), list<Action_Plan_Objective__c>.class);
            system.assertEquals(2, services.size());
            controller.objResultWrapper.action_Plan_Objective = services[0].id;
            controller.objResultWrapper.service_Provided = 'Yes';
            controller.objResultWrapper.service_Date = '1/1/2013';
            controller.objResultWrapper.initials = 'L3';
            controller.mySave();
            
            system.assertEquals(1, [select id from Action_objective_result__c].size());
            controller.objResultWrapper.id = [select id from Action_objective_result__c limit 1].id;
            
            controller.myEdit();
            system.assertEquals(true, controller.editMode);
            
            controller.servicesList();
            controller.newServiceData();
        }

    }

}