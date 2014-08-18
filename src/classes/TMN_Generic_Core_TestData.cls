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
            Network_Offering__c = 'ARY',
            state__c = mystate
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
            Program_Code__c = 'TEST PROGRAM CODE'+h.substring(0,10),
            Program_Value__c = 'TEST PROGRAM VALUE',
            Start_Date__c = date.newInstance(2000, 1, 1),
            state__c = 'IN'
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
        if(type == 'CANS' || type == 'RISK'){
            assessment_type__c tmpType = new assessment_type__c (name = type);
            insert tmpType;
            thisAssessment.assessment_type__c = tmpType.id;
        }
        thisAssessment.Assessment_Date__c = system.today();
        thisAssessment.TFC_Family_Vistas__c = 'Yes';
        thisAssessment.Interval__c = 'Intake';
        insert thisAssessment;
        Assessment__c testAssessment = [ SELECT Id, Service_Assignment__c,Admission__c, Type__c, Status__c, Phase__c, Assessment_Type__c, Assessment_Type__r.name,  Disregard__c FROM Assessment__c WHERE Id = :thisAssessment.Id ];
        return testAssessment;
    }
    
 
    public static User createUser(string profileName,string userAlias, string userName, string firstName, string lastName, string OperatingGroup){
        Map<String,Profile> profileMap = new Map<String,Profile>();
        List<Profile> proflist = [SELECT Id, Name FROM Profile];
        for(Profile p : proflist){
            profileMap.put(p.Name, P);
        }
        User testUser = new User(alias = userAlias,
                                email='sravan@TMN.com',
                                emailencodingkey='UTF-8',
                                lastname=lastName,firstname=firstName, languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = profileMap.get(profileName).id,
                                timezonesidkey='America/Los_Angeles',
                                username=username + System.currentTimeMillis());
                                
        insert testUser;
        
        Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c=OperatingGroup, Salesforce_User_Account__c=testUser.id);
        insert tmnUser;
        
        return testUser;
    } 
    
    public static void permsetAssign(string[]permSets, Id assigntoId){
        List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN :permSets];
        List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>(); 
        for(PermissionSet ps : theSets){
            thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = assigntoId));
            
        }
        insert thepermAssigns;
        
    } 
    
    public static Progress_Note__c createProgressNote(Service_Assignment__c sa, Admission__c adm, Service_Code__c sc, String contactId, Datetime startDateTime, Datetime endDateTime) {
        Progress_Note__c thisProgressNote = new Progress_Note__c(Service_Assignment__c = sa.Id,
                                                                    Service_Code__c = sc.Id, 
                                                                    Admission__c = adm.ID,
                                                                    Start_Time__c = startDateTime,
                                                                    End_Time__c = endDateTime,
                                                                    Person_Being_Served__c = contactId,
                                                                    No_Approval_Needed__c = true,
                                                                    Approval_Status__c = 'Approved',
                                                                    Status__c = 'Final');
        insert thisProgressNote;
        Progress_Note__c testProgressNote = [ SELECT Id, Service_Assignment__c FROM Progress_Note__c WHERE Id = :thisProgressNote.Id ];
        return testProgressNote;
    }

}