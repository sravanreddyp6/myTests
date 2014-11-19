public with sharing class ProgressNoteExtension {
	
	public string MedicaidIDClear{ get; set; }
	public Progress_Note__c pn { get; set;}
	// START: EB-210 additions; NC TFC Progress Note fields / data.
		public Progress_Note__c thePn { get; set; }
		public string pnStartTime { get; set; }
		public string pnEndTime { get; set; }
		public List<String> topicsDiscussed { get; set; }
	// END: EB-210 additions; NC TFC Progress Note fields / data.
	
	//construct class with current page Id
    public ProgressNoteExtension(ApexPages.StandardController controller) {
		pn = (Progress_Note__c)controller.getRecord();
		medicaidIDClear = ApexPages.currentPage().getParameters().get('id2');
		
		// START: EB-210 additions; NC TFC Progress Note fields / data.
			Progress_Note__c thePn = [ SELECT Start_Time__c, End_Time__c, 
				Topic_Behavior_Management__c,
				Topic_Diagnostic_Psycho_education__c,
				Topic_Shared_Parenting__c,
				Topic_Family_Interactions__c,
				Topic_Life_Book_Development__c,
				Topic_Treatment_Goal_Review_PCP__c,
				Topic_TFP_Rules_of_the_Road__c,
				Topic_Separation_Loss_and_Grief_Issues__c,
				Topic_Successful_Adaptation__c,
				Topic_Other__c,
				Topic_If_Other__c
			 FROM Progress_Note__c WHERE id = :pn.Id ];
			pnStartTime = thePn.Start_Time__c.format('h:mm a');
			pnEndTime = thePn.End_Time__c.format('h:mm a');
			
			// Serialize the Progress_Note__c into JSON
			String s = JSON.serialize(thePn);
			
			// Deserialize it back into a key/value map
			Map<String,Object> obj = 
			    (Map<String,Object>) JSON.deserializeUntyped(s);
			
			// Build a set containing the fields present on our SObject
			Set<String> fieldsPresent = obj.keyset().clone();
			// Salesforce always adds an extra 'attributes' key to SObjects
			// when you do JSON stuff, so let's get rid of that.
			fieldsPresent.remove('attributes');
			fieldsPresent.remove('Start_Time__c');
			fieldsPresent.remove('End_Time__c');
			fieldsPresent.remove('RecordTypeId');
			fieldsPresent.remove('Id');
			
			topicsDiscussed = new List<String>();	
			
			Map<String,Schema.SObjectField> fields = Schema.SObjectType.Progress_Note__c.fields.getMap();
			Schema.DescribeFieldResult fieldInfo = null;
			for(Schema.SObjectField field : fields.values()) {
				fieldInfo = field.getDescribe();
				for(String aString : fieldsPresent) {
					if(fieldInfo.getName()==aString && obj.get(aString)==true) {
						if(fieldInfo.getName()=='Topic_Other__c') {
							topicsDiscussed.add(fieldInfo.getLabel() + ' (' + obj.get('Topic_If_Other__c') + ')');
						}
						else {
							topicsDiscussed.add(fieldInfo.getLabel());
						}
					}
				}
			}
		// END: EB-210 additions; NC TFC Progress Note fields / data.
		
		if ( String.IsBlank(medicaidIDClear) ) {
			Contact c = [select medicaid_id__c from contact where id= :pn.Person_Being_Served__c];
			medicaidIDClear = c.Medicaid_ID__c;
    	}
	
		
	
	}
			
    
	
}