public with sharing class Notes_ProgressNote_DurationInclude {
	
	public Progress_Note__c thePN { get; set;}
	public Boolean diffStartEndDates { get; set; }
	
    public Notes_ProgressNote_DurationInclude(ApexPages.StandardController controller) {
        this.thePN = (Progress_Note__c)controller.getRecord();
        this.diffStartEndDates = false;
        LoadData(thePN);
    } 
    
    private void LoadData(Progress_Note__c tmp){
        thePN = [select id, Name, Start_Time__c, End_Time__c, Duration__c from Progress_Note__c where id= :tmp.id limit 1];
        
        if ( thePN.id != null ) {
	     	Date dtStart = thePN.Start_Time__c.Date();
	    	Date dtEnd = thePN.End_Time__c.Date();
	    	
	    	diffStartEndDates = ( dtStart != dtEnd );
	    	
        }     
    }
    
}