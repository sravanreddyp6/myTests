@isTest
private class ServiceAssignmentTriggeredActionsTest {

    static testMethod void myUnitTest() {
    	
	    ID pbsId = createPBS('CA');
	    ID admID = createAdmission(pbsId);
	    ID slId = createServiceLocation('CA'); 

        // create a new Service Assignment with a service location. Assert that the PBS_ServiceLocation_Count__c = 1 ; the first service assignment for this PBS in this service location
        Service_Assignment__c theSA = new Service_Assignment__c(
	            phase_1_Start_Date__c = DATE.today().addDays(-7),
	            Admission__c = admID,
	            Person_Being_served__c = pbsId,
	            Program__c = 'IFCS',
	            Status__c = 'Active',
	            Start_Date__c = DATE.TODAY().addDays(1),
	            Projected_Treatment_End_Date__c = DATE.TODAY().addYears(1),
	            Service_location__c = slId
	        ); 
  
        insert theSA;
        Service_Assignment__c insrtedSA  = [select id, PBS_ServiceLocation_Count__c from Service_Assignment__C where id =: theSA.id];
        system.assert(insrtedSA.PBS_ServiceLocation_Count__c != null, 'Incorrect service location count for a SA with a service location.');


        // create a new Service Assignment without a service location for the same PBS. Assert that the PBS_ServiceLocation_Count__c is not incremented for this record
        theSA = new Service_Assignment__c(
                phase_1_Start_Date__c = DATE.today().addDays(-7),
                Admission__c = admID,
                Person_Being_served__c = pbsId,
                Program__c = 'IFCS',
                Status__c = 'Active',
                Start_Date__c = DATE.TODAY().addDays(1),
                Projected_Treatment_End_Date__c = DATE.TODAY().addYears(1)
            ); 
  
        insert theSA;
        insrtedSA  = [select id, Service_location__c, PBS_ServiceLocation_Count__c from Service_Assignment__C where id =: theSA.id];
        system.assert(insrtedSA.PBS_ServiceLocation_Count__c == null, 'Incorrect service location count for a SA without a service location.');

        // Add same service location to the service assignment... then this becomes the second service assignment
        insrtedSA.Service_location__c = slid;
        update insrtedSA;
        insrtedSA  = [select id, Service_location__c, PBS_ServiceLocation_Count__c from Service_Assignment__C where id =: insrtedSA.id];        
        system.assert(insrtedSA.PBS_ServiceLocation_Count__c == 2, 'Incorrect service location count. Count value should be 2. but it is ' + insrtedSA.PBS_ServiceLocation_Count__c);
        
        
        // create a new Service Assignment withthe same service location. Assert that the PBS_ServiceLocation_Count__c for this record is 2
        theSA = new Service_Assignment__c(
                phase_1_Start_Date__c = DATE.today().addDays(-7),
                Admission__c = admID,
                Person_Being_served__c = pbsId,
                Program__c = 'IFCS',
                Status__c = 'Active',
                Start_Date__c = DATE.TODAY().addDays(1),
                Projected_Treatment_End_Date__c = DATE.TODAY().addYears(1),
                Service_location__c = slId
            ); 
  
        insert theSA;
        insrtedSA  = [select id, PBS_ServiceLocation_Count__c from Service_Assignment__C where id =: theSA.id];
        system.assert(insrtedSA.PBS_ServiceLocation_Count__c == 3, 'Incorrect service location count. Count value should be 3. but it is ' + insrtedSA.PBS_ServiceLocation_Count__c);

    }

    public static ID createPBS(string myState){
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);    
		    
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') LIMIT 1].Id;
        Account theAccount = new Account(
							            RecordTypeID=RecTypeId,
							            FirstName= 'FName' + h.substring(0,10),
							            LastName='LName'+ h.substring(0,10),
							            PersonMailingStreet='123 Test Street',
							            PersonMailingPostalCode='12345',
							            PersonMailingCity='SFO',
							            PersonMailingStateCode= myState,
							            PersonEmail='test@yahoo.com',
							            PersonHomePhone='12345678',
							            PersonMobilePhone='12345678'
                                        );
        insert theAccount;        
        List<Account> testAcct = [Select Id, PersonContactId From Account a WHERE a.Id = :theAccount.Id];
        ID contactID = testAcct[0].PersonContactId;
        
        return contactID;
    }
    
    public static ID createAdmission(ID contactID){    	
        Admission__c theAdm = new Admission__c(
								            Name = 'TEST ADM',
								            Person_Being_Served__c = contactID,
								            Effective_Date__c = DATE.TODAY(),
								            //Discharged_Date__c = date.today(),
								            //Status__c = 'Discharged',
								            //Discharged_Status__c = 'Positive',
								            //Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
								            Network_Offering__c = 'ARY'
					                        );
        insert theAdm;
        return theAdm.id;
    }
    
    public static ID createServiceLocation(String state){
        Service_location__c sl = new Service_location__c(
        Alias__c = '999999',
        FacilityID__c = 999,
        // Owner = UserInfo.getUserId(),
        Program__c = 'TE-ST-TESTT-ESTTESTT-EST TES-TTE',
        programID__c = '999999001',
        uniqueID__c = '999||999999001',
        State__c = state    
        );
        insert sl;
        return sl.id;
    }           
   
}