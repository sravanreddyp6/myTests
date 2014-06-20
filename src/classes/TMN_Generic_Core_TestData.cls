public without sharing class TMN_Generic_Core_TestData {

    public account theAccount {get; set;}
    public Admission__c theAdm {get; set;}
    public ID contactID {get; set;}
    public Service_Assignment__c theSA {get; set;}
    
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
    
    
    
    }

}