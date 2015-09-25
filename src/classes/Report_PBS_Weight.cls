public with sharing class Report_PBS_Weight {
	public Boolean reportRan { get; set; }
	// This is a dummy evaluation just so that we can bind inputFields for Start/End Date to an
	// SObject Date fields for SF's datepicker.
	public Evaluation__c dummyEvaluation { get; set; }

	public List<String> leftSelectedPrograms { get; set; }
	public List<SelectOption> leftPrograms { get; set; }
	public List<String> rightSelectedPrograms { get; set; }
	public List<SelectOption> rightPrograms { get; set; }
	public List<Id> selectedPBS { get; set; }
	public List<SelectOption> pbsList { get; set; }

	public Map<Id, Person> pbsMap { get; set; }

	public Report_PBS_Weight() {
		dummyEvaluation = new Evaluation__c();
		pbsMap = new Map<Id, Person>();

		pbsList = new List<SelectOption>();
		rightPrograms = new List<SelectOption>();
		leftPrograms = new List<SelectOption>();
		selectedPbs = new List<Id>();
		leftSelectedPrograms = new List<String>();
		rightSelectedPrograms = new List<String>();

		for (AggregateResult program: [
				SELECT service_location__r.id slID, service_location__r.Alias__c alias,
				       service_location__r.program__c prgm
				  FROM service_assignment__c
				 GROUP BY service_location__r.id, service_location__r.program__c,
				          service_location__r.Alias__c
				HAVING COUNT(service_location__r.id) > 0
				 ORDER BY service_location__r.program__c]) {
			leftPrograms.add(new SelectOption((String) program.get('alias'),
				String.valueOf(program.get('alias')) + '-' + String.valueOf(program.get('prgm')))
			);
		}

		reportRan = false;
	}

	public void addPrograms() {
		for (String p: leftSelectedPrograms){
			for(Integer i=0; i < leftPrograms.size(); i++){
				if (leftPrograms.get(i).getValue() == p) {
					rightPrograms.add(new SelectOption(leftPrograms.get(i).getValue(),
						leftPrograms.get(i).getLabel()));
					leftPrograms.remove(i);
					break;
				}
			}
		}
		updateProgramSelections();
	}

	public void removePrograms(){
		for (String p: rightSelectedPrograms){
			for(Integer i=0; i < rightPrograms.size(); i++){
				if (rightPrograms.get(i).getValue() == p) {
					leftPrograms.add(new SelectOption(rightPrograms.get(i).getValue(),
						rightPrograms.get(i).getLabel()));
					rightPrograms.remove(i);
					break;
				}
			}
		}
		updateProgramSelections();
	}

	public void updateProgramSelections(){
		List<String> selectedAliases = new List<String>();
		for (SelectOption so : rightPrograms){
			selectedAliases.add(so.getValue());
		}

		pbsList.clear();
		for (Service_Assignment__c serviceAssignment: [
				SELECT Id, Person_Being_Served__r.Account.Lastname,
				       Person_Being_Served__r.Account.Firstname
				  FROM Service_Assignment__c
				 WHERE Service_Location__r.Alias__c In :selectedAliases
				 ORDER BY Person_Being_Served__r.Account.Lastname,
				          Person_Being_Served__r.Account.Firstname
		]) {
			pbsList.add(
				new SelectOption(
					serviceAssignment.Id,
					serviceAssignment.Person_Being_Served__r.Account.Lastname + ', ' + serviceAssignment.Person_Being_Served__r.Account.Firstname
				)
			);
		}
	}

	public void runReport() {
		Boolean errorFound = false;
		// We use the Evaluation_Date__c and Dialysis_Onset__c fields from the dummy SObject
		// to model Start Date and End Date.
		Date startDate = dummyEvaluation.Evaluation_Date__c;
		Date endDate = dummyEvaluation.Dialysis_Onset__c;
		if (startDate == null) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'Start Date cannot be blank.')
			);
		}
		if (startDate > Date.Today()) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'Start Date cannot be later than today.')
			);
		}
		if (endDate == null) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'End Date cannot be blank.')
			);
		}
		if (selectedPbs.size() == 0) {
			errorFound = true;
			ApexPages.addMessage(new ApexPages.Message(
				ApexPages.Severity.ERROR,
				'You must choose at least 1 Person Being Served'
			));
		}
		if (errorFound) {
			return;
		}
		pbsMap = new Map<Id, Person>();
		Map<Id, Evaluation__c> evaluations = new Map<Id, Evaluation__c>([
			SELECT Id, RecordType.Name, ServiceAssignment__r.Id, ServiceAssignment__r.Admission__r.Person_Being_Served__r.Name
			  FROM Evaluation__c
			 WHERE ServiceAssignment__c IN :selectedPbs
			   AND (
			        (RecordType.Name = 'CNA Workbook' AND Shift_Start_Time__c <= :endDate.addDays(1) AND Shift_End_Time__c >= :startDate AND Status__c = 'Final')
			     OR (RecordType.Name = 'NursesAssessment' AND Signed_At__c >= :startDate AND Signed_At__c <= :endDate.addDays(1) AND Status__c LIKE 'Final%')
			   )
		]);
		for (Eval_Value__c value: [
				SELECT Id, Text_Under_250__c, Number_No_Decimal__c, Date_Time__c,
				       Eval_Section_Id__c, Eval__r.Field_Name__c, CreatedDate,
				       Eval__r.htmlid__c, What_Id__c, Eval__r.Eval_Type__r.Name
				  FROM Eval_Value__c
				 WHERE What_Id__c IN :evaluations.keySet()
				   AND Eval__r.Category__c = 'Diagnostics'
				   AND Eval__r.Sub_Category__c = 'Vitals Signs'
				   AND (
				           (Eval__r.Eval_Type__r.Name = 'CNA Workbook' AND (Eval__r.htmlid__c = 'weightAtAdmission' OR Eval__r.htmlid__c = 'signsDateTime'))
				        OR (Eval__r.Eval_Type__r.Name = 'Residential' AND Eval__r.htmlid__c = 'heightAtAdmission')
				   )
			]) {
			Id saId = evaluations.get(value.What_Id__c).ServiceAssignment__r.Id;
			if (!pbsMap.containsKey(saId)) {
				pbsMap.put(saId, new Person(evaluations.get(value.What_Id__c).ServiceAssignment__r.Admission__r.Person_Being_Served__r.Name));
			}
			if (value.Eval__r.htmlid__c == 'weightAtAdmission') {
				pbsMap.get(saId).addWeightKg(value.Eval_Section_Id__c, Double.valueOf(value.Text_Under_250__c));
			}
			if (value.Eval__r.htmlid__c == 'signsDateTime') {
				pbsMap.get(saId).addWeightDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
			}
			if (value.Eval__r.htmlid__c == 'heightAtAdmission') {
				pbsMap.get(saId).height = new Height(Double.valueOf(value.Text_Under_250__c));
			}
		}
		for (Person person: pbsMap.values()) {
			person.generateWeights();
		}

		reportRan = true;
	}

	public class Person {
		public List<Weight> weights { get; set; }
		public Height height { get; set; }
		public String name { get; set; }
		public Map<String, Weight> weightMap { get; set; }

		public Person(String name) {
			this.name = name;
			this.weights = new List<Weight>();
			this.weightMap = new Map<String, Weight>();
		}

		public void generateWeights() {
			this.weights = this.weightMap.values();
			// There are times when observed date/time is included, but the weight is not entered.
			// Here we filter out those entries.
			Integer index = 0;
			while (index < this.weights.size()) {
				if (this.weights[index].isNull()) {
					this.weights.remove(index);
				} else {
					index++;
				}
			}
			this.weights.sort();
		}

		public void addWeightDateTime(String sectionId, DateTime observedDateTime) {
			if (!this.weightMap.containsKey(sectionId)) {
				this.weightMap.put(sectionId, new Weight());
			}
			if (this.weightMap.get(sectionId).observedDateTime == null) {
				this.weightMap.get(sectionId).observedDateTime = observedDateTime;
			}
		}
		public void addWeightKg(String sectionId, Double kg) {
			if (!this.weightMap.containsKey(sectionId)) {
				this.weightMap.put(sectionId, new Weight());
			}
			if (this.weightMap.get(sectionId).kg == null) {
				this.weightMap.get(sectionId).kg = kg;
			}
		}
	}

	public class Weight implements Comparable {
		public Double kg {
			get;
			set {
				this.kg = value;
				Double kgToLbs = kg * 2.2046226218488;
				this.lbs = (Math.floor(kgToLbs));
				this.oz = Math.round(((kgToLbs- lbs) * 1600) / 100);
			}
		}
		public Double lbs { get; set; }
		public Double oz { get; set; }
		public DateTime observedDateTime { get; set; }

		public Integer compareTo(Object weightObj) {
			Weight weight = (Weight) weightObj;
			if (this.observedDateTime == null || weight.observedDateTime == null) {
				return 0;
			}
			if (this.observedDateTime > weight.observedDateTime) {
				return 1;
			} else {
				return -1;
			}
		}

		public Boolean isNull() {
			return kg == null;
		}
	}

	public class Height {
		public Double cm { get; set; }
		public Double inch { get; set; }
		public Double ft { get; set; }

		public Height (Double cm) {
			this.cm = cm;
			Double cmToInch = cm / 2.54;
			this.ft = Math.floor(cmToInch / 12);
			this.inch = Math.Round((cmToInch - (ft * 12)) * 100) / 100;
		}
	}
}