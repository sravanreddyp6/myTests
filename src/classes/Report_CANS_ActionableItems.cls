public with sharing class Report_CANS_ActionableItems {
	public List<Assessment_Response__c> responses { get {
		return Database.query('SELECT Id, Name, Rating__c, Question__r.Question_Title__c, CreatedBy.Name, CreatedById, Assessment__r.Owner.Id, Assessment__r.Owner.Name, Assessment__r.Assessment_Date__c, Assessment__r.Id, Assessment__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Id FROM Assessment_Response__c WHERE ' + scoreQuery);
	} set; }
	public String scoreQuery = '';
	public String scoreChosen { get;
		set {
			if (value == '2 or 3') {
				scoreQuery = 'Rating__c = \'2\' OR Rating__c = \'3\'';
			} else {
				scoreQuery = 'Rating__c = \'3\'';
			}
			scoreChosen = value;
		}
	}
	public List<SelectOption> scoreOptions {
		get {
			List<SelectOption> options = new List<SelectOption>();
			options.add(new SelectOption('2 or 3', '2 or 3'));
			options.add(new SelectOption('Only 3', 'Only 3'));
			return options;
		}
	}
}