public with sharing class Notes_ProgressNote_Clone_test {
    static testMethod void myUnitTest() {
        
        Contact testContact = new Contact(
        LastName = 'TestLastName'
      );
      insert testContact;
      
      Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today()
      );
      insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
          Admission__c = testAdm.Id,
          Person_Being_Served__c = testContact.Id
        );
        insert testServAssignment;
        
        Service_Code__c testServCode = new Service_Code__c(
          Service_Code__c = 'TEST SVC CODE',
          FacilityID__c = 'TEST FAC ID',
          Program_Code__c = 'TEST PROGRAM CODE' 
          
        );
        testServCode.Start_Date__c = date.newInstance(2012, 1, 1);
        insert testServCode;
        
        Progress_Note__c testPN = new Progress_Note__c(
          Service_Assignment__c = testServAssignment.Id, 
          Service_Code__c = testServCode.Id, 
          Admission__c = testAdm.ID,
          Start_Time__c = datetime.newInstance(2012, 1, 1, 13, 0, 0),
          End_Time__c = datetime.newInstance(2012, 1, 1, 15, 0, 0),
          Person_Being_Served__c = testContact.Id,
          No_Approval_Needed__c = true,
          Approval_Status__c = 'Approved'
        );
        insert testPN;

        
       // Progress_Note__c pn = new Progress_Note__c();
        PageReference pageRef = Page.Notes_ProgressNote_Clone;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testPN);
        Notes_ProgressNote_Clone mee = new Notes_ProgressNote_Clone(sc);
        
        mee.getCreatableFieldsSOQL(testPN.id);
        mee.thePN = testPN;
        mee.newPN = testPN;
        mee.holdPN = testPN;
        
        mee.MyClone();
        
        
    }
}