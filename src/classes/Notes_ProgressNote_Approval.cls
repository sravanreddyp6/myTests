public with sharing class Notes_ProgressNote_Approval {
    public Progress_Note__c thePN = new Progress_Note__c();
    public Progress_Note__c getthePN(){return thePN;}
    public List<Progress_Note__c> pnOverlap {get; set;} 
    public boolean hasOverlap {get { return pnOverlap.size() > 0;} }
    
    public Notes_ProgressNote_Approval(ApexPages.StandardController controller) {
        this.thePN = (Progress_Note__c)controller.getRecord();
        pnOverlap = new List<Progress_Note__c>();
        LoadData(thePN);
    } 
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c, Person_Being_Served__r.Name, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c, owner.name from Progress_Note__c where id= :tmp.id limit 1];
        
    	List<Progress_Note__c> samepbsNotes = [select id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c, Owner.Name from Progress_Note__c 
        			where id != :thePN.id 
        			and Person_Being_Served__c = :thePN.Person_Being_Served__c
        			and Admission__c = :thePN.Admission__c
        			and	Service_Assignment__c = :thePN.Service_Assignment__c
        			and Plan__c = :thePN.Plan__c
        			and (
        					(start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
        				or 	(end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
        				or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
        				)
        				];   
       //Added by Sravan to display the Progress Notes with overlapping time with a different PBS. EB-188 08/12/2014 12:26 PM			
   		List<Progress_Note__c> diffpbsNotes = [SELECT Id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c, Owner.Name from Progress_Note__c 
        			where id != :thePN.id 
        			and Person_Being_Served__c != :thePN.Person_Being_Served__c
        			and Owner.Name = :thePN.Owner.Name
        			and (
        					(start_time__c >= :thePN.start_Time__c and start_time__c <= :thePN.end_time__c)
        				or 	(end_time__c >= :thePN.start_time__c and end_time__c <= :thePN.end_time__c)
        				or  ( start_time__c <= :thePN.start_time__c and end_time__c >= :thePN.end_time__c )
        				) 
        				]; 
        				
        pnOverlap.addall(samepbsNotes);
        pnOverlap.addall(diffpbsNotes);    
    }
    public PageReference myFinal(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_Create_Flavor_PDF');
        pageRef.getParameters().put('id', thePN.id);
        
        try{
            update thePN;
            return pageRef;
        }
            catch(DMLException e){
                thePN.addError(e.getMessage());
            }      
        
        return null;
    }
}