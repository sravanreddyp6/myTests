public with sharing class NPA_Form {

    public ApexPages.StandardController stdCtrl{get; set;}
    public NPA_Audit__c theAudit {get; set;}
    
    public NPA_Audit__c getAuditFrmFields() {
    
        if(stdCtrl.getid() != NULL){
        return [Select Bill_Exceptions__c, QualityExceptions__c, HHPExceptions__c, 
            HHPExceptions_BgCheck__c, IncompleteBillingRatedQuestions__c, IncompleteQualityRatedQuestions__c, QualityExceptions_ClientFunds__c, 
            IncompleteHHPRatedQuestions__c, locked__c
                From NPA_Audit__c 
                    Where id =:stdCtrl.getid() limit 1]  ;        
        }
        
    return null;
    }
    
    public NPA_Form(ApexPages.StandardController controller) {
       stdCtrl=controller;
       theAudit = (NPA_Audit__c )stdCtrl.getRecord();
    }




    public PageReference chkFields(){
                 
            chkBillingFields();
            chkQaFields();
            chkHHpFields();    
        return null;
    }

    public void chkBillingFields(){
            Set<string> BillingFields = new Set<string>();
            boolean showBillError = false;

                for(Schema.FieldSetMember f :
                     SObjectType.Npa_Audit__c.FieldSets.ClearBillingFields.getFields()) {
                        BillingFields.Add(f.getFieldPath());
                        
                } 
                if(!theAudit.Billing_Audit__c)
                    for(String f: BillingFields){
                        if(theAudit.get(f) !=null){
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                            'The Billing Audit Section (Tab) is turned off, but the section has data. To save the Billing Tab data, go to the Core Tab and turn the audit section back on before clicking UPDATE. Otherwise, you will lose all Billing Tab data.'));
                        }
                    }//end if for billing section = false      
    
    }
    public void chkQaFields(){
            Set<string> QAFields = new Set<string>();
            boolean showQAError = false;  
                for(Schema.FieldSetMember f :
                     SObjectType.Npa_Audit__c.FieldSets.ClearQaFields.getFields()) {
                        QAFields.Add(f.getFieldPath());
                        
                }   
                
                if(!theAudit.QA_Audit__c)
                    for(String f: QAFields){
                        if(theAudit.get(f) !=null){
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                            'The Quality Audit Section (Tab) is turned off, but the section has data. To save the Quality Tab data, go to the Core Tab and turn the audit section back on before clicking UPDATE. Otherwise, you will lose all Quality Tab data.'));
                        }                                                   
                    }//end if for QA section = false                
                            
    }
    
    public void chkHHpFields(){
            Set<string> HHPFields = new Set<string>();
            boolean showHHPError = false;

                
                for(Schema.FieldSetMember f :
                     SObjectType.Npa_Audit__c.FieldSets.ClearHhpFields.getFields()) {
                        HHPFields.Add(f.getFieldPath());                        
                }   

                if(!theAudit.HHP_Audit__c )
                    for(String f: HHPFields){
                        if(theAudit.get(f) !=null){
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                            'The HHP Audit Section (Tab) is turned off, but the section has data. To save the HHP Tab data, go to the Core Tab and turn the audit section back on before clicking UPDATE. Otherwise, you will lose all HHP Tab data.'));
                        }                                                   
                    }//end if for HHP section = false 

    }

    public PageReference myupdate(){       
        
        try{
        chkBillingFields();
        chkQaFields();
        chkHHpFields(); 

        upsert theAudit;
        }
         
            catch (DMLException e) {
                ApexPages.addMessages(e);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, ' The Record was not saved ')); 
                return null;
            }   
            
                    
        NPA_Audit__c tmp = [Select Status__c From NPA_Audit__c where ID = :theAudit.id Limit 1];
      // this return is nessisary, 
     // there was a bug that if the status got set to final the locked field would be updated from a data persaepvice to true, however, 
     // the form would not refresh the value to true so when it would be seaved the locked field would be set to false then imidatly set to tru again, 
    //  this caused records to be updatible even though they were locked
        if (tmp.status__c =='Final')
            {return stdCtrl.view(); }
            
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record Saved <br/>'+  Datetime.now().format('MM/dd/yyyy @ hh:mm - z')));     
        
        return null;
    }

    public PageReference save(){
        stdCtrl.save(); 
           
        return stdCtrl.view();
    }
    
    public PageReference UnLock(){
       theAudit.Locked__c = false;
       theAudit.Status__c = 'In Progress';
       upsert theAudit; 
       return stdCtrl.view();   
    }
   
   static testMethod void testMyController()
   {
      
       //Use the PageReference Apex class to instantiate a page
       PageReference pageRef = Page.NPA_Form;
       
       //In this case, the Visualforce page named 'success' is the starting point of this test method. 
       Test.setCurrentPage(pageRef);
     
       //Instantiate and construct the controller class.   
       NPA_Audit__c NPA_Audit = new NPA_Audit__c (Status__c = 'Final', Client_First_Name__c ='12', Client_Last_Name__c = '21');
       ApexPages.StandardController stdCon = new ApexPages.standardController (NPA_Audit);
       
       NPA_Form controller = new NPA_Form(stdCon);
       controller.chkFields();
       controller.getAuditFrmFields();
       //Example of calling an Action method. Same as calling any other Apex method. 
       //Normally this is executed by a user clicking a button or a link from the Visualforce
       //page, but in the test method, just test the action method the same as any 
       //other method by calling it directly. 

       PageReference PageReturn = controller.save();
       
       // 2nd test
        NPA_Audit.Status__c = 'In Progress';
        PageReturn = controller.Myupdate();
      //  insert NPA_Audit;
        delete NPA_Audit;
       
   }


}