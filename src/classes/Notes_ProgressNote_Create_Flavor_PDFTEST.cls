/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 * Shaun Added a comment here for a Demo with Sravan.
 */
@isTest
private class Notes_ProgressNote_Create_Flavor_PDFTEST {

    static testMethod void myUnitTest() {     
    	Notes_ProgressNote_Create_Flavor_PDF controller = new Notes_ProgressNote_Create_Flavor_PDF ();
        
	 	  Contact testContact = new Contact(
	        LastName = 'TestLastName', 
	        Medicaid_ID__c = '12345'
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
	          Program_Code__c = 'TEST PROGRAM CODE',
	          Start_Date__c = date.newInstance(2012,1,1) 
	        );
	        insert testServCode;
	        
	        
	        List<RecordType> pnRecordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Progress_Note__c' AND IsActive = true];
	        
	        System.Debug('What is in pnRecordTypes: ' + pnRecordTypes);
	        
	        List<Progress_Note__c> pnsToInsert = new List<Progress_Note__c>();
		    Integer pnsToInsertCounter = 0;             
	       	
	       	for(RecordType rt : pnRecordTypes){
	       		
	       		pnsToInsertCounter++;
	       		
	       		  if(pnsToInsertCounter==pnRecordTypes.size()){
		       		  pnsToInsert.add( 
			       		  new Progress_Note__c(
				          Service_Assignment__c = testServAssignment.Id, 
				          Service_Code__c = testServCode.Id, 
				          Admission__c = testAdm.ID,
				          Start_Time__c = datetime.now().addHours(-2),
				          End_Time__c = datetime.now(),
				          Person_Being_Served__c = testContact.Id,
				          No_Approval_Needed__c = true,
				          Approval_Status__c = 'Approved',
				          RecordTypeId = rt.Id)
			        );
	       		}
		        else {
		       		  pnsToInsert.add( 
			       		  new Progress_Note__c(
				          Service_Assignment__c = testServAssignment.Id, 
				          Service_Code__c = testServCode.Id, 
				          Admission__c = testAdm.ID,
				          Start_Time__c = datetime.now().addHours(-2),
				          End_Time__c = datetime.now(),
				          Person_Being_Served__c = testContact.Id,
				          No_Approval_Needed__c = false,
				          Approval_Status__c = 'Approved',
				          RecordTypeId = rt.Id)
			        );
		        } 
		        
		             	
	       	}
	       	
	       	insert pnsToInsert;
	       	
	       	for(Integer i=0; i<pnsToInsertCounter; i++){
	       		controller.myId = pnsToInsert[i].id;
		    	controller.redirect();
    		}
    		
    		List<Id> pnIdsForWhichToGetAttchmts = new List<Id>();
    		for(Progress_Note__c p : pnsToInsert){
    			pnIdsForWhichToGetAttchmts.add(p.Id);
    		}	
		    
		    List<Attachment> listAtchmnts = [SELECT Id, ParentId, Body FROM Attachment WHERE ParentId = :pnIdsForWhichToGetAttchmts];
		    Map<Id,Attachment> mapAtchmnts = new Map<Id,Attachment>();
		    
		    for(Attachment atchms : listAtchmnts){
		    	mapAtchmnts.put(atchms.Id, atchms);
		    	System.Debug('atchms.body = ' + atchms.body.toString());
		    	System.Assert(atchms.body.toString()=='FLAVOR PDF BODY CONTENTS','This does not seem to be a flavor PDF');
		    }
		    
		    System.Debug('listAtchmnts.size() = ' + listAtchmnts.size());
		    System.Debug('pnsToInsertCounter = ' + pnsToInsertCounter);
		    
		    System.Assert(listAtchmnts.size()>0,'There are no attachments!');
		    System.Assert(listAtchmnts.size() == (pnsToInsertCounter - 4), 'The number of attachments inserted does not equal the number of record types!');
		    
		    
		    ApexPages.StandardController sc = new ApexPages.StandardController( pnsToInsert[0]);
	       	ProgressNoteExtension pe = new ProgressNoteExtension(sc);
        	System.assertEquals( pe.MedicaidIDClear, testContact.Medicaid_Id__c);
        	
	   }
}