public with sharing class Notes_ProgressNote_Approval {
    public Progress_Note__c thePN = new Progress_Note__c();
    public Progress_Note__c getthePN(){return thePN;}
    public List<Progress_Note__c> pnOverlap {get; set;}
    public boolean hasOverlap {get { return pnOverlap.size() > 0;} }
    
    public Notes_ProgressNote_Approval(ApexPages.StandardController controller) {
        this.thePN = (Progress_Note__c)controller.getRecord();
        LoadData(thePN);
    } 
    public void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, No_Approval_Needed__c, Person_Being_Served__r.Name, RecordType.Name, Number_of_Required_Signatures__c, Status__c, start_time__c, end_time__c, admission__c, service_assignment__c, plan__c from Progress_Note__c where id= :tmp.id limit 1];
        
        pnOverLap = [select id, Name, Person_being_served__r.Name, start_time__c, end_time__c, status__c, owner.name from Progress_Note__c 
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
    }
    public PageReference myFinal(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_Create_Flavor_PDF');
        PageReference pageRefFlavor = ApexPages.currentPage();
        pageRef .getParameters().put('id', thePN.id);
        if(thePN.Number_of_Required_Signatures__c == 0 && thePN.RecordType.Name == 'FL-FSS Progress Note' ){
        	PageRefFlavor = new PageReference('/apex/Notes_ProgressNote_FL_FFS');
        	pageRefFlavor .getParameters().put('id', thePN.id);
        }
        
        try{
            update thePN;
            return pageRef;
            return pageRefFlavor;
        }
            catch(DMLException e){
                thePN.addError(e.getMessage());
            }      
        
        return null;
    }
}