public with sharing class Notes_Plan_Create_Audit_pdf {
    public string myId = ApexPages.currentPage().getParameters().get('id');
    public PageReference redirect() {       

    PageReference pageRef2 = new PageReference('/' + myId); 
    Plan__c thePlan = new Plan__c();
    
            try{               
               thePlan = [Select Name, ID, Status__c From Plan__c Where Id = :myId];             
                           
                  
                PageReference pageRef = new PageReference('/apex/V2SA_PlanView');        
                pageRef.getParameters().put('id', thePlan.id);
                Attachment attachmentPDF = new Attachment();
                attachmentPDF.parentId = thePlan.id;
                attachmentPDF.Name = thePlan.Name + ' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';
                attachmentPDF.body = pageRef.getContent();    
                           
                    if(thePlan.Status__c == 'Active')
                        {
                        insert attachmentPDF; 
                        }
            }catch(Exception e){
                thePlan.addError(e.getMessage());
            }          
        
        return pageRef2 ;
    }


    public Notes_Plan_Create_Audit_pdf(){
       // construtor  
    }


 static testMethod void testMyController()
   {      
        Notes_Plan_Create_Audit_pdf controller = new Notes_Plan_Create_Audit_pdf ();
        
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
        
        
        
        Plan__c testPlan = new Plan__c(Status__c = 'Inactive', Long_Term_Goal_1__c = '12', Admission__c = testAdm.id);
        insert testPlan;
        controller.myID = testPlan.ID;
        controller.redirect();
        
      //  controller.getdocs();
        //controller.nothing();        
   }



}