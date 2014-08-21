public class ProgressNoteExtension {
	
	public string MedicaidIDClear{ get; set; }
	public Progress_Note__c pn { get; set;}
	
	//construct class with current page Id
    public ProgressNoteExtension(ApexPages.StandardController controller) {
		pn = (Progress_Note__c)controller.getRecord();
		medicaidIDClear = ApexPages.currentPage().getParameters().get('id2');
		
		if ( String.IsBlank(medicaidIDClear) ) {
			Contact c = [select medicaid_id__c from contact where id= :pn.Person_Being_Served__c];
			medicaidIDClear = c.Medicaid_ID__c;
    	}
	}
			
    
	
}