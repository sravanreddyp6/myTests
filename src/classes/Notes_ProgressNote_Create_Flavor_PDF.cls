public with sharing class Notes_ProgressNote_Create_Flavor_PDF {
    public Progress_Note__c thePN = new Progress_Note__c();
    public string myId = ApexPages.currentPage().getParameters().get('id');
    public PageReference redirect() {        
        PageReference pageRef2 = new PageReference('/' + myId); 
//AZ - OPT        
        try{
        thePN = [select id, Name, No_Approval_Needed__c, Person_Being_Served__r.Name, person_being_served__r.medicaid_Id__c, RecordType.DeveloperName, Recordtype.Name, Status__c from Progress_Note__c where id= :myId];
        
        	// use developername on record type to allow us to easily change the label for the record type in the future
        	// CTEAE-25 02/03/2014         
            PageReference pageRef = new PageReference('/');
            if(thePN.RecordType.DeveloperName=='FL_FSS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_FL_FSS');
            }
            else if(thePN.RecordType.DeveloperName=='MA_IFCS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_MA_IFCS');
            }
            else if(thePN.RecordType.DeveloperName=='Shift_Note'){
                pageRef = new PageReference('/apex/Notes_ShiftNote_Pdf');
            }            
            else if(thePN.RecordType.DeveloperName=='AZ_OPT'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_AZ_OPT');
            }            
            else if(thePN.RecordType.DeveloperName=='MD_IFCS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_MD_IFCS');
            }
            else if(thePN.RecordType.DeveloperName=='VA_IFCS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_VA_IFCS');
            }
            else if(thePN.RecordType.DeveloperName=='MA_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_MA');
            }                        
            else if(thePN.RecordType.DeveloperName=='NC_Child_and_Family_Team'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NC_ChildAndTeam');
            }   
            else if(thePN.RecordType.DeveloperName=='NC_IFCS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NC_IFCS');
            }
            else if(thePN.RecordType.DeveloperName=='NC_IIH_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NC_IIH'); 
            }
            else if(thePN.RecordType.DeveloperName=='NC_IMAPP_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NC_IMAPP');
            }
            else if(thePN.RecordType.DeveloperName=='NC_OPT_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NC_OPT');
            }
            else if(thePN.RecordType.DeveloperName=='NJ_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_NJ');
            }
            else if(thePN.RecordType.DeveloperName=='PA_BHRS_BSC'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_PA_BHRS_BCS');
            }
            else if(thePN.RecordType.DeveloperName=='PA_BHRS_MT'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_PA_BHRS_MT');
            }
            else if(thePN.RecordType.DeveloperName=='PA_CaseMgmnt_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_PA_CaseMgmnt');
            }
            else if(thePN.RecordType.DeveloperName=='PA_FBS_Progress_Note'){
                pageRef = new PageReference('/apex/Notes_ProgressNote_PDF_PA_FBS');
            }
            else{ // fix this - it causes an endless redirect loop that errors out
                pageRef = new PageReference('/'+thePN.id);
            }
            
            pageRef.getParameters().put('id', thePN.id);
            pageRef.getParameters().put('id2', thePN.Person_Being_Served__r.Medicaid_ID__c);	// this is required so we can unmask the field on PDF
            
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = thePN.id;
            attachmentPDF.Name = 'State Template (no signature) - ' + thePN.Person_Being_Served__r.Name + ' - ' + thePN.RecordType.Name +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';
            if(Test.isrunningtest()==false){ 
                attachmentPDF.body = pageRef.getContent();
            }
            else{
                Blob testBlob = Blob.valueOf('FLAVOR PDF BODY CONTENTS');
                attachmentPDF.body = testBlob;
            }  
       // PageReference gotoPage = new PageReference('/');          

           System.Debug('What is in thePN.No_Approval_Needed__c WHEN I NEED IT?: ' + thePN.No_Approval_Needed__c);
           
                if(thePN.No_Approval_Needed__c){
                    insert attachmentPDF;
                    return new PageReference('/apex/Notes_ProgressNote_Create_Audit_pdf?id='+thePN.id);
                }
                else{                    
                    insert attachmentPDF;
                    return new PageReference('/apex/Notes_ProgressNote_Create_Audit_pdf?id='+thePN.id);
                }            
            
        }catch(DMLException e){
            thePN.addError(e.getMessage());
        }
           // 
           
        
        return pageRef2 ;
    }

    public Notes_ProgressNote_Create_Flavor_PDF(){
       // construtor  
    }
}