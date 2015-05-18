public with sharing class ProgressNote_Esign_NC_TFC {
	// START: EB-210 additions; NC TFC Progress Note fields / data.
		public Progress_Note__c pn_ProgressNote_Esign_NC_TFC { get; set; }
		public List<String> topicsDiscussed;

    public ProgressNote_Esign_NC_TFC(ApexPages.StandardController controller) {
		pn_ProgressNote_Esign_NC_TFC = (Progress_Note__c)controller.getRecord();
    }
    
	public List<String> getTopicsDiscussed() {
		Progress_Note__c thePn = [ SELECT
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
		 FROM Progress_Note__c WHERE id = :pn_ProgressNote_Esign_NC_TFC.Id ];
		
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
		return topicsDiscussed;
	}
}