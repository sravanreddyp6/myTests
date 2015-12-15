@isTest
private class SeizureExtensionTest {
    static Contact person;
    static Admission__c adm;
    static Service_Assignment__c ServAssign;
    
    static testMethod void myUnitTest() {
    	createObjects();
    	
        PageReference pageRef = Page.SeizureEdit;
        Test.setCurrentPage(pageRef);
        
		string stEndTime = '11/16/2014 13:00:55';
        string stEndNextTime = '11/17/2014 13:00:55';
        
        Apexpages.currentPage().getParameters().put('service_assignment', ServAssign.id);
        Apexpages.currentPage().getParameters().put('retURL', pageRef.getUrl());
        SeizureExtension extension =  new SeizureExtension();        
        extension.seizureStart_DateTime = stEndTime;
        extension.seizureEnd_DateTime = stEndTime;
        
        extension.saveSeizure();
        System.assertequals(0,[select id from seizure__c].size());
        
        extension.seizureEnd_DateTime = stEndNextTime;
        extension.saveSeizure();
        System.assertequals(1,[select id from seizure__c].size());        
    
    	System.assertequals(false, SeizureExtension.findDuplicateSeizure(
    	                               stEndTime,
    	                               stEndTime,
    	                               ServAssign.Id,
    	                               extension.seizure.id ) );

        System.assertequals(true, SeizureExtension.findDuplicateSeizure(
                                       stEndTime,
                                       stEndNextTime,
                                       ServAssign.Id,
                                       '') );
                                       
        extension.backMethod();
    }

    private static void createObjects(){
        person = new Contact();
        person.LastName = 'Contact';
        person.FirstName = 'Test';
        insert person;

        adm = new Admission__c();
        adm.person_being_served__c = person.id;
        adm.Admission_Effective_DateTime__c = DateTime.newInstance(2013, 1,1,0,0,0);
        insert adm;  

        string tmp = String.ValueOf(system.currentTimeMillis());
        Service_Location__c svl = new Service_Location__c(Street__c = '10 Main St.', 
          State__c = 'CA', 
          Setting__c = 'Residential',
          Service_Value__c = 'IDD', 
          Program__c = 'Redwood Res',
          UniqueID__c = '10031' + tmp.Substring(tmp.length()-6, tmp.length()-1), 
          ProgramID__c = '10005', 
          Phone__c = '213-555-5555',
          FacilityID__c = 20,
          City__c = 'Bakersfield', Alias__c ='10001'+tmp.Substring(tmp.length()-6,tmp.length()-1));
          insert svl;

        ServAssign = new Service_Assignment__c(
            Name = 'TEST SERV ASSIGN',
            Admission__c = Adm.Id,
            Person_Being_Served__c = person.id,
            Start_Date__c = date.newInstance(2013, 1, 1),
            Status__c = 'Active',
            Program__c = 'IFCS',
            Service_Line__c = 'Intensive In Home - FCT',
            Service_Location__c = svl.id
        );
        insert ServAssign;
        
    }
    

}