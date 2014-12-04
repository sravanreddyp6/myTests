public with sharing class Notes_ProgressNote_RelatedPartyInclude {
	public Progress_Note__c thePN { get; set;}

	public List<string> strSelectedParties { get; set; }
	public List<SelectOption> soRelParties { get; set; } 
    
    public Notes_ProgressNote_RelatedPartyInclude(ApexPages.StandardController controller) {
        thePN = (Progress_Note__c)controller.getRecord();
        strSelectedParties = new List<string>();
        soRelParties = new List<SelectOption>();
        LoadData(thePN);
    } 
    
    private void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, Person_Being_Served__c, Foster_Parents__c from Progress_Note__c where id= :tmp.id limit 1];
        if ( thePN.ID == null )
        	return;
        	
        List<Related_party__c> relParties = [ select id, name, type__c from related_party__c where person_being_served__c = :thePN.Person_Being_Served__c and type__c in ('Mentor', 'Mentor Co-Applicant')];
		for ( Related_Party__c rp : relParties ) {
			// create the list of options
			soRelParties.Add( new SelectOption( rp.Name, rp.Name));
		}   
		
		if(!String.isBlank(thePN.Foster_Parents__c))
              strSelectedParties = thePN.Foster_Parents__c.split(';');
                     
    }
    
    public PageReference SaveParties() {
    	string fosters ='';
        for(String f : strSelectedParties )
        	fosters += f+';';
        
        if(fosters !=''){
                fosters = fosters.Substring (0,fosters.length() -1);
                thePN.Foster_Parents__c = fosters;
        }
        else
            thePN.Foster_Parents__c ='';
    	
    	
    	update thePN;
    	return null;
    }
    
    public PageReference SaveScheduling() {
    	update thePN;
    	return null;
    }
    
}