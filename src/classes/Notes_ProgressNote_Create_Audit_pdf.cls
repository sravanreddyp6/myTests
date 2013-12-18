public with sharing class Notes_ProgressNote_Create_Audit_pdf {
    public Progress_Note__c thePN = new Progress_Note__c();
    public string myId = ApexPages.currentPage().getParameters().get('id');
    public PageReference redirect() {        
        PageReference pageRef2 = new PageReference('/' + myId); 
        
        try{
        thePN = [select id, Name, No_Approval_Needed__c, Person_Being_Served__r.Name, RecordType.Name, Status__c from Progress_Note__c where id= :myId];         
            PageReference pageRef = new PageReference('/apex/V2SA_ProgressNotesPDF');
            pageRef.getParameters().put('id', thePN.id);
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = thePN.id;
            attachmentPDF.Name = thePN.Person_Being_Served__r.Name + ' - ' + thePN.RecordType.Name +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';          
            if(Test.isrunningtest()==false){ 
            	attachmentPDF.body = pageRef.getContent();
            }
            else{
            	Blob testBlob = Blob.valueOf('TEST 123');
            	attachmentPDF.body = testBlob;
            }   
       // PageReference gotoPage = new PageReference('/');          
            
                if(thePN.No_Approval_Needed__c){
                    insert attachmentPDF;
                }
                else{                    
                    insert attachmentPDF;
                    return new PageReference('/p/process/Submit?retURL=%2F'+thePN.id+'&id='+thePN.id);
                }            
            
        }catch(DMLException e){
            thePN.addError(e.getMessage());
        }
           // 
           
        
        return pageRef2 ;
    }

    public Notes_ProgressNote_Create_Audit_pdf(){
       // construtor  
    }

 static testMethod void testMyController()
   {      
        Notes_ProgressNote_Create_Audit_pdf controller = new Notes_ProgressNote_Create_Audit_pdf ();
        
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
          Program_Code__c = 'TEST PROGRAM CODE',
          Start_Date__c = date.today() 
        );
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
        
        controller.myId = testPN.id;
        controller.redirect();
         
      
   }



}