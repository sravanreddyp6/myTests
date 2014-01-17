public class TMN_DecryptMedicaidID {
    public Progress_Note__c note = new Progress_Note__c();
    public Progress_Note__c getNote(){
        return note;
    }
    //construct class with current page Id
    public TMN_DecryptMedicaidID(ApexPages.StandardController controller) {
        loadData(ApexPages.currentPage().getParameters().get('id'));
    }
    //construct class passing myId
     public TMN_DecryptMedicaidID(String myId2) {
        loadData(myId2);
    }
    //load data into note variable when loadData is called
    public void loadData(String myId){
    //tf=true;
       note = [select id, name, Person_Being_Served__r.Medicaid_ID__c from Progress_Note__c where id = :myId limit 1];
           
       
    }
    
    public boolean tf {get; set;}
    
       public PageReference CreateEsign(){//getContentAsPDF
         PageReference pageRef = ApexPages.currentPage();
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = note.id;
            attachmentPDF.Name = note.name + '.pdf';
            attachmentPDF.body = pageRef.getContentAsPDF();          
            
                insert attachmentPDF;
        
        tf=true;
 try {
      insert attachmentPDF;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
      return null;
    } finally {
      attachmentPDF = new Attachment(); 
    }
 
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return null;
    }
    
    
    
    
    
    
    
   
    
            
            
}