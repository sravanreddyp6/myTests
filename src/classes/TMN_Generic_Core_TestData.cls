public without sharing class TMN_Generic_Core_TestData {

    public account theAccount {get; set;}
    public Admission__c theAdm {get; set;}
    public ID contactID {get; set;}
    public Service_Assignment__c theSA {get; set;}
    public Service_Code__c theServiceCode {get; set;}
    
    public TMN_Generic_Core_TestData (){
    
        loadData('AZ');
    
    }
    public void loadData(string myState){    
Blob b = Crypto.GenerateAESKey(128);
String h = EncodingUtil.ConvertTohex(b);    
    
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') LIMIT 1].Id;
        theAccount = new Account(
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
        contactID = testAcct[0].PersonContactId;
        Id aAccountId = testAcct[0].Id;  
        
        theAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = contactID,
            Effective_Date__c = date.newInstance(2013, 1, 1),
            //Discharged_Date__c = date.today(),
            //Status__c = 'Discharged',
            //Discharged_Status__c = 'Positive',
            //Reason_for_Discharge__c = 'TEST REASON FOR DISCHARGE',
            Network_Offering__c = 'ARY'
        );
        insert theAdm; 
        
        theSA = new Service_Assignment__c(
            phase_1_Start_Date__c = system.today().addDays(-7),
            Admission__c = theAdm.id,
            Person_Being_served__c = contactID,
            Program__c = 'IFCS',
            Status__c = 'Active',
            Start_Date__c = date.newInstance(2013, 1, 1),
            Projected_Treatment_End_Date__c = date.newInstance(2014, 12, 31)
        
        ); 
        
        insert theSA;              
    
        theServiceCode = new Service_Code__c(
        	Service_Code__c = '10942.1161',
        	FacilityID__c = 'TEST FAC ID',
        	Program_Code__c = 'TEST PROGRAM CODE',
        	Program_Value__c = 'TEST PROGRAM VALUE',
        	Start_Date__c = date.newInstance(2000, 1, 1)
        );
        insert theServiceCode;   
    
    }
    
    public static Service_Assignment_Closure__c createServiceAssignmentClosure(Service_Assignment__c sa) {
    	Service_Assignment_Closure__c thisServiceAssignmentClosure = new Service_Assignment_Closure__c(Service_Assignment__c = sa.Id);
    	insert thisServiceAssignmentClosure;
    	Service_Assignment_Closure__c testServiceAssignmentClosure = [ SELECT Id, Service_Assignment__c
    										FROM Service_Assignment_Closure__c 
    										WHERE Id = :thisServiceAssignmentClosure.Id];
    	return testServiceAssignmentClosure;
    }
    
    public static Assessment__c createAssessment(Admission__c adm, Service_Assignment__c sa, String type, String status, String phase, Boolean disregard) {
    	Assessment__c thisAssessment = new Assessment__c(Admission__c = adm.Id, Service_Assignment__c = sa.Id, Type__c = type, Status__c = status, Phase__c = phase, Disregard__c = disregard);
    	insert thisAssessment;
    	Assessment__c testAssessment = [ SELECT Id, Admission__c, Service_Assignment__c, Type__c, Status__c, Phase__c, Disregard__c FROM Assessment__c WHERE Id = :thisAssessment.Id ];
    	return testAssessment;
    }
    
    public static Progress_Note__c createProgressNote(Service_Assignment__c sa, Admission__c adm, Service_Code__c sc, String contactId) {
    	Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = sa.Id,
    	        													Service_Code__c = sc.Id, 
														        	Admission__c = adm.ID,
														        	Start_Time__c = datetime.newInstance(2013, 1, 2, 13, 0, 0),
														        	End_Time__c = datetime.newInstance(2013, 1, 2, 15, 0, 0),
														        	Person_Being_Served__c = contactId,
														        	No_Approval_Needed__c = true,
														        	Approval_Status__c = 'Approved',
														        	Status__c = 'Final');
    	insert thisProgressNote;
    	Progress_Note__c testProgressNote = [ SELECT Id, Service_Assignment__c FROM Progress_Note__c WHERE Id = :thisProgressNote.Id ];
    	return testProgressNote;
    }

}