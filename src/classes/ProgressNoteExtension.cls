public with sharing class ProgressNoteExtension {
	
	public string MedicaidIDClear{ get; set; }
	public string OtherId {get;set;}
	public Progress_Note__c pn { get; set;}
	// START: EB-210 additions; NC TFC Progress Note fields / data.
		public Progress_Note__c thePn { get; set; }
		public string pnStartTime { get; set; }
		public string pnEndTime { get; set; }
		public List<String> topicsDiscussed { get; set; }
		Public Boolean showGoalsObjActionsInclude{get;set;}//added by Amruth for a different page to be included for goals
	// END: EB-210 additions; NC TFC Progress Note fields / data.
	SystemSettings__c pnnew = SystemSettings__c.getOrgDefaults();
	Public list<TMN_User__c> TU = [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1];
	
	
	//construct class with current page Id
    public ProgressNoteExtension(ApexPages.StandardController controller) {
		pn = (Progress_Note__c)controller.getRecord();
		medicaidIDClear = ApexPages.currentPage().getParameters().get('id2');
		showGoalsObjActionsInclude = false;//added by Amruth for a different page to be included for goals
		// START: EB-210 additions; NC TFC Progress Note fields / data.
			Progress_Note__c thePn = [ SELECT Start_Time__c, End_Time__c,recordtype.DeveloperName, 
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
		
		
		if ( String.IsBlank(medicaidIDClear) ||  String.IsBlank(otherId)) {
			Contact c = [select medicaid_id__c, Other_id__c from contact where id= :pn.Person_Being_Served__c];
			medicaidIDClear = c.Medicaid_ID__c;
			otherId = c.Other_id__c;
    	}
    	
    	if(TU.size()>0 && pnnew.AZ_OPT_Enabler__c && thePn.recordtype.DeveloperName == 'AZ_OPT' && TU[0].Operating_Group__c == 'Redwood'){
        	showGoalsObjActionsInclude = true;		 	 
      	}
    	
	
		
	
	}
			
    
	
}