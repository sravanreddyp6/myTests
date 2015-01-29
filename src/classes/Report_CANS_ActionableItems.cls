public with sharing class Report_CANS_ActionableItems {
	public List<Assessment_Response__c> responses { get; set; }
	public String baseUrl {
		get {
			return System.URL.getSalesforceBaseUrl().toExternalForm();
		}
	}

	public Date startDate { get; set; }
	public Date endDate { get; set; }

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
	public void runReport() {
		Boolean errorFound = false;
		if (startDate == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date is required.'));
			errorFound = true;
		}
		if (endDate == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date is required.'));
			errorFound = true;
		}
		if (endDate <= startDate) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date cannot be earlier than Start Date.'));
			errorFound = true;
		}
		if (errorFound) {
			scoreChosen = '';
			return;
		}
		responses = Database.query('SELECT Id, Name, Rating__c, Question__r.Question_Title__c, CreatedBy.Name, CreatedById, Assessment__r.Owner.Id, Assessment__r.Owner.Name, Assessment__r.Assessment_Date__c, Assessment__r.Id, Assessment__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Name, Assessment__r.Admission__r.Person_Being_Served__r.Id FROM Assessment_Response__c WHERE (' + scoreQuery + ') AND Assessment__r.Assessment_Date__c > :startDate AND Assessment__r.Assessment_Date__c < :endDate');
	}

	public Report_CANS_ActionableItems() {
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (params.containsKey('scoreChosen')) {
			if (params.get('scoreChosen') == '2 or 3') {
				scoreChosen = '2 or 3';
			} else {
				scoreChosen = 'Only 3';
			}
		}
		if (params.containsKey('startDate')) {
			startDate = parseDate(params.get('startDate'));
		}
		if (params.containsKey('endDate')) {
			endDate = parseDate(params.get('endDate'));
		}
		System.debug('startDate: ' + startDate);
		System.debug('endDate: ' + endDate);
		System.debug('scoreChosen: ' + scoreChosen);
		if (startDate != null && endDate != null && scoreChosen != null) {
			runReport();
		}
	}

	private Date parseDate(String dateStr) {
		String[] dateStrings = dateStr.split('-');
		Date d = Date.newInstance(Integer.valueOf(dateStrings[0]), Integer.valueOf(dateStrings[1]), Integer.valueOf(dateStrings[2]));
		return d;
	}
}