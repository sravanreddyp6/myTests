public with sharing class Report_PBS_Intake_Output {
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

	public Report_PBS_Intake_Output() {
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
			SELECT Id, RecordType.Name, ServiceAssignment__r.Id,
			       ServiceAssignment__r.Admission__r.Person_Being_Served__r.Name
			  FROM Evaluation__c
			 WHERE ServiceAssignment__c IN :selectedPbs
			   AND (
			        (RecordType.Name = 'CNA Workbook' AND Shift_Start_Time__c <= :endDate.addDays(1) AND Shift_End_Time__c >= :startDate AND Status__c = 'Final')
			     OR (RecordType.Name = 'CMShiftAssessment' AND Shift_Start_Time__c <= :endDate.addDays(1) AND Shift_End_Time__c >= :startDate AND Status__c = 'Completed')
			   )
		]);
		System.debug(evaluations);
		for (Eval_Value__c value: [
				SELECT Id, Text_Under_250__c, Number_No_Decimal__c, Date_Time__c,
				       Eval_Section_Id__c, Eval__r.Field_Name__c, CreatedDate,
				       Eval__r.htmlid__c, What_Id__c, Eval__r.Eval_Type__r.Name, Eval__r.Length__c,
				       Eval__r.Category__c, Eval__r.Sub_Category__c, Text_Over_250__c
				  FROM Eval_Value__c
				 WHERE What_Id__c IN :evaluations.keySet()
				   AND (
				           (Eval__r.Eval_Type__r.Name = 'CNA Workbook' AND ((Eval__r.htmlid__c IN ('ObservedDateTime20', 'intakemLConsumed') AND Eval__r.Category__c = 'Intake' AND Eval__r.Sub_Category__c = 'All') OR (Eval__r.htmlid__c IN ('outputDateTime', 'outputVoidAmount', 'vomAmount', 'outputBMAmount', 'outputBMColor', 'outputConsistency') AND Eval__r.Category__c = 'Output' AND Eval__r.Sub_Category__c = 'All')))
				        OR (Eval__r.Eval_Type__r.Name = 'Head to Toe' AND ((Eval__r.htmlid__c IN ('ObservedDateTime20', 'feedingType', 'fluidType', 'fluidVolume') AND Eval__r.Category__c = 'GU/GI/Nutrition' AND Eval__r.Sub_Category__c = 'Fluid Intake') OR (Eval__r.htmlid__c IN ('ObservedDateTime20', 'bladderContinence', 'bladderContinenceDevices') AND Eval__r.Category__c = 'GU/GI/Nutrition' AND Eval__r.Sub_Category__c = 'Elimination - Bladder')))
				   )
				   AND Eval__r.Visible__c = true
			]) {
			Id saId = evaluations.get(value.What_Id__c).ServiceAssignment__r.Id;
			System.debug(value);
			if (!pbsMap.containsKey(saId)) {
				pbsMap.put(saId, new Person(evaluations.get(value.What_Id__c).ServiceAssignment__r.Admission__r.Person_Being_Served__r.Name));
			}
			if (value.Eval__r.Category__c == 'Intake' && value.Eval__r.Sub_Category__c == 'All') {
				if (value.Eval__r.htmlid__c == 'ObservedDateTime20') {
					pbsMap.get(saId).addLiquidIntakeDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
				} else if (value.Eval__r.htmlid__c == 'intakemLConsumed') {
					pbsMap.get(saId).addLiquidConsumed(value.Eval_Section_Id__c, Double.valueOf(value.Text_Under_250__c));
				}
			}
			if (value.Eval__r.Category__c == 'Output' && value.Eval__r.Sub_Category__c == 'All') {
				if (value.Eval__r.htmlid__c == 'outputDateTime') {
					pbsMap.get(saId).addOutputDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
					pbsMap.get(saId).addBMCharacteristicsDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
				} else if (value.Eval__r.htmlid__c == 'outputVoidAmount') {
					pbsMap.get(saId).addVoidAmount(value.Eval_Section_Id__c, Double.valueOf(value.Text_Under_250__c));
				} else if (value.Eval__r.htmlid__c == 'vomAmount') {
					pbsMap.get(saId).addVomitusAmount(value.Eval_Section_Id__c, Double.valueOf(value.Text_Over_250__c));
				} else if (value.Eval__r.htmlid__c == 'outputBMAmount') {
					pbsMap.get(saId).addBMAmount(value.Eval_Section_Id__c, value.Text_Under_250__c);
				} else if (value.Eval__r.htmlid__c == 'outputBMColor') {
					pbsMap.get(saId).addBMColor(value.Eval_Section_Id__c, value.Text_Under_250__c);
				} else if (value.Eval__r.htmlid__c == 'outputConsistency') {
					pbsMap.get(saId).addBMConsistency(value.Eval_Section_Id__c, value.Text_Under_250__c);
				}
			}
			if (value.Eval__r.Category__c == 'GU/GI/Nutrition' && value.Eval__r.Sub_Category__c == 'Fluid Intake') {
				if (value.Eval__r.htmlid__c == 'ObservedDateTime20') {
					pbsMap.get(saId).addFluidIntakeDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
				} else if (value.Eval__r.htmlid__c == 'feedingType') {
					pbsMap.get(saId).addFeedingType(value.Eval_Section_Id__c, value.Text_Under_250__c);
				} else if (value.Eval__r.htmlid__c == 'fluidType') {
					pbsMap.get(saId).addIntakeType(value.Eval_Section_Id__c, value.Text_Under_250__c);
				} else if (value.Eval__r.htmlid__c == 'fluidVolume') {
					pbsMap.get(saId).addIntakeVolume(value.Eval_Section_Id__c, Double.valueOf(value.Text_Under_250__c));
				}
			}
			if (value.Eval__r.Category__c == 'GU/GI/Nutrition' && value.Eval__r.Sub_Category__c == 'Elimination - Bladder') {
				if (value.Eval__r.htmlid__c == 'ObservedDateTime20') {
					pbsMap.get(saId).addBladderOutputDateTime(value.Eval_Section_Id__c, value.Date_Time__c);
				} else if (value.Eval__r.htmlid__c == 'bladderContinence') {
					pbsMap.get(saId).addBladderContinence(value.Eval_Section_Id__c, value.Text_Under_250__c);
				} else if (value.Eval__r.htmlid__c == 'bladderContinenceDevices') {
					pbsMap.get(saId).addDevices(value.Eval_Section_Id__c, value.Text_Over_250__c);
				}
			}
		}
		System.debug(pbsMap);
		for (Person person: pbsMap.values()) {
			person.generateLineItems();
		}
		reportRan = true;
	}

	public class Person implements Comparable {
		public String name { get; set; }
		public List<ObservedDate> observedDates { get; set; }
		public Map<Date, ObservedDate> observedDateMap { get; set; }

		public Map<String, FluidIntakeLineItem> fluidIntakeLineItemMap { get; set; }
		public Map<String, LiquidIntakeLineItem> liquidIntakeLineItemMap { get; set; }
		public Map<String, OutputLineItem> outputLineItemMap { get; set; }
		public Map<String, BladderOutputLineItem> bladderOutputLineItemMap { get; set; }
		public Map<String, BMCharacteristicsLineItem> bmCharacteristicsLineItemMap { get; set; }

		public Integer numberOfLineItems { get; set; }

		public Person(String name) {
			this.name = name;
			this.numberOfLineItems = 0;
			this.observedDates = new List<ObservedDate>();
			this.observedDateMap = new Map<Date, ObservedDate>();

			this.fluidIntakeLineItemMap = new Map<String, FluidIntakeLineItem>();
			this.liquidIntakeLineItemMap = new Map<String, LiquidIntakeLineItem>();
			this.outputLineItemMap = new Map<String, OutputLineItem>();
			this.bladderOutputLineItemMap = new Map<String, BladderOutputLineItem>();
			this.bmCharacteristicsLineItemMap = new Map<String, BMCharacteristicsLineItem>();
		}

		public void addFluidIntakeDateTime(String sectionId, DateTime observedDateTime) {
			if (!fluidIntakeLineItemMap.containsKey(sectionId)) {
				fluidIntakeLineItemMap.put(sectionId, new FluidIntakeLineItem());
			}
			fluidIntakeLineItemMap.get(sectionId).observedDateTime = observedDateTime;
		}

		public void addFeedingType(String sectionId, String feedingType) {
			if (!fluidIntakeLineItemMap.containsKey(sectionId)) {
				fluidIntakeLineItemMap.put(sectionId, new FluidIntakeLineItem());
			}
			fluidIntakeLineItemMap.get(sectionId).feedingType = feedingType;
		}

		public void addIntakeType(String sectionId, String intakeType) {
			if (!fluidIntakeLineItemMap.containsKey(sectionId)) {
				fluidIntakeLineItemMap.put(sectionId, new FluidIntakeLineItem());
			}
			fluidIntakeLineItemMap.get(sectionId).intakeType = intakeType;
		}

		public void addIntakeVolume(String sectionId, Double intakeVolume) {
			if (!fluidIntakeLineItemMap.containsKey(sectionId)) {
				fluidIntakeLineItemMap.put(sectionId, new FluidIntakeLineItem());
			}
			fluidIntakeLineItemMap.get(sectionId).intakeVolume = intakeVolume;
		}

		public void addLiquidIntakeDateTime(String sectionId, DateTime observedDateTime) {
			if (!liquidIntakeLineItemMap.containsKey(sectionId)) {
				liquidIntakeLineItemMap.put(sectionId, new LiquidIntakeLineItem());
			}
			liquidIntakeLineItemMap.get(sectionId).observedDateTime = observedDateTime;
		}

		public void addLiquidConsumed(String sectionId, Double liquidConsumed) {
			if (!liquidIntakeLineItemMap.containsKey(sectionId)) {
				liquidIntakeLineItemMap.put(sectionId, new LiquidIntakeLineItem());
			}
			liquidIntakeLineItemMap.get(sectionId).liquidConsumed = liquidConsumed;
		}

		public void addOutputDateTime(String sectionId, DateTime observedDateTime) {
			if (!outputLineItemMap.containsKey(sectionId)) {
				outputLineItemMap.put(sectionId, new OutputLineItem());
			}
			outputLineItemMap.get(sectionId).observedDateTime = observedDateTime;
		}

		public void addVoidAmount(String sectionId, Double voidAmount) {
			if (!outputLineItemMap.containsKey(sectionId)) {
				outputLineItemMap.put(sectionId, new OutputLineItem());
			}
			outputLineItemMap.get(sectionId).voidAmount = voidAmount;
		}

		public void addVomitusAmount(String sectionId, Double vomitusAmount) {
			if (!outputLineItemMap.containsKey(sectionId)) {
				outputLineItemMap.put(sectionId, new OutputLineItem());
			}
			outputLineItemMap.get(sectionId).vomitusAmount = vomitusAmount;
		}

		public void addBladderOutputDateTime(String sectionId, DateTime observedDateTime) {
			if (!bladderOutputLineItemMap.containsKey(sectionId)) {
				bladderOutputLineItemMap.put(sectionId, new BladderOutputLineItem());
			}
			bladderOutputLineItemMap.get(sectionId).observedDateTime = observedDateTime;
		}

		public void addBladderContinence(String sectionId, String bladderContinence) {
			if (!bladderOutputLineItemMap.containsKey(sectionId)) {
				bladderOutputLineItemMap.put(sectionId, new BladderOutputLineItem());
			}
			bladderOutputLineItemMap.get(sectionId).bladderContinence = bladderContinence;
		}

		public void addDevices(String sectionId, String devices) {
			if (!bladderOutputLineItemMap.containsKey(sectionId)) {
				bladderOutputLineItemMap.put(sectionId, new BladderOutputLineItem());
			}
			bladderOutputLineItemMap.get(sectionId).devices = devices;
		}

		public void addBMCharacteristicsDateTime(String sectionId, DateTime observedDateTime) {
			if (!bmCharacteristicsLineItemMap.containsKey(sectionId)) {
				bmCharacteristicsLineItemMap.put(sectionId, new BMCharacteristicsLineItem());
			}
			bmCharacteristicsLineItemMap.get(sectionId).observedDateTime = observedDateTime;
		}

		public void addBMAmount(String sectionId, String bmAmount) {
			if (!bmCharacteristicsLineItemMap.containsKey(sectionId)) {
				bmCharacteristicsLineItemMap.put(sectionId, new BMCharacteristicsLineItem());
			}
			bmCharacteristicsLineItemMap.get(sectionId).bmAmount = bmAmount;
		}

		public void addBMColor(String sectionId, String bmColor) {
			if (!bmCharacteristicsLineItemMap.containsKey(sectionId)) {
				bmCharacteristicsLineItemMap.put(sectionId, new BMCharacteristicsLineItem());
			}
			bmCharacteristicsLineItemMap.get(sectionId).bmColor = bmColor;
		}

		public void addBMConsistency(String sectionId, String bmConsistency) {
			if (!bmCharacteristicsLineItemMap.containsKey(sectionId)) {
				bmCharacteristicsLineItemMap.put(sectionId, new BMCharacteristicsLineItem());
			}
			bmCharacteristicsLineItemMap.get(sectionId).bmConsistency = bmConsistency;
		}

		public void generateLineItems() {
			for (FluidIntakeLineItem item: this.fluidIntakeLineItemMap.values()) {
				System.debug(item);
				if (!this.observedDateMap.containsKey(item.observedDateTime.date())) {
					this.observedDateMap.put(item.observedDateTime.date(), new ObservedDate(item.observedDateTime.date()));
				}
				this.observedDateMap.get(item.observedDateTime.date()).fluidIntakeLineItems.add(item);
			}
			for (LiquidIntakeLineItem item: this.liquidIntakeLineItemMap.values()) {
				if (!this.observedDateMap.containsKey(item.observedDateTime.date())) {
					this.observedDateMap.put(item.observedDateTime.date(), new ObservedDate(item.observedDateTime.date()));
				}
				this.observedDateMap.get(item.observedDateTime.date()).liquidIntakeLineItems.add(item);
			}
			for (outputLineItem item: this.outputLineItemMap.values()) {
				if (!this.observedDateMap.containsKey(item.observedDateTime.date())) {
					this.observedDateMap.put(item.observedDateTime.date(), new ObservedDate(item.observedDateTime.date()));
				}
				this.observedDateMap.get(item.observedDateTime.date()).outputLineItems.add(item);
			}
			for (bladderOutputLineItem item: this.bladderOutputLineItemMap.values()) {
				if (!this.observedDateMap.containsKey(item.observedDateTime.date())) {
					this.observedDateMap.put(item.observedDateTime.date(), new ObservedDate(item.observedDateTime.date()));
				}
				this.observedDateMap.get(item.observedDateTime.date()).bladderOutputLineItems.add(item);
			}
			for (bmCharacteristicsLineItem item: this.bmCharacteristicsLineItemMap.values()) {
				if (!this.observedDateMap.containsKey(item.observedDateTime.date())) {
					this.observedDateMap.put(item.observedDateTime.date(), new ObservedDate(item.observedDateTime.date()));
				}
				this.observedDateMap.get(item.observedDateTime.date()).bmCharacteristicsLineItems.add(item);
			}

			this.observedDates = this.observedDateMap.values();
			this.observedDates.sort();
			for (ObservedDate observedDate: this.observedDates) {
				observedDate.generateLineItems();
				this.numberOfLineItems += observedDate.lineItems.size();
			}
			System.debug(observedDates);
			System.debug(numberOfLineItems);
		}

		public Integer compareTo(Object compareToObj) {
			Person compareTo = (Person) compareToObj;
			return this.name.compareTo(compareTo.name);
		}
	}

	public class ObservedDate implements Comparable {
		public Date day { get; set; }
		public Double totalVolume { get; set; }
		public Double totalLiquidConsumed { get; set; }
		public Double totalVoidAmount { get; set; }
		public Double totalVomitusAmount { get; set; }

		public LineItem[] lineItems { get; set; }

		public FluidIntakeLineItem[] fluidIntakeLineItems { get; set; }
		public LiquidIntakeLineItem[] liquidIntakeLineItems { get; set; }
		public OutputLineItem[] outputLineItems { get; set; }
		public BladderOutputLineItem[] bladderOutputLineItems { get; set; }
		public BMCharacteristicsLineItem[] bmCharacteristicsLineItems { get; set; }


		public ObservedDate(Date day) {
			this.day = day;

			fluidIntakeLineItems = new FluidIntakeLineItem[]{};
			liquidIntakeLineItems = new LiquidIntakeLineItem[]{};
			outputLineItems = new OutputLineItem[]{};
			bladderOutputLineItems = new BladderOutputLineItem[]{};
			bmCharacteristicsLineItems = new BMCharacteristicsLineItem[]{};
		}

		public void generateLineItems() {
			fluidIntakeLineItems.sort();
			liquidIntakeLineItems.sort();
			outputLineItems.sort();
			bladderOutputLineItems.sort();
			bmCharacteristicsLineItems.sort();

			lineItems = new LineItem[]{};
			Integer lineItemSize = Math.max(fluidIntakeLineItems.size(), Math.max(liquidIntakeLineItems.size(), Math.max(outputLineItems.size(), bladderOutputLineItems.size())));
			System.debug(lineItemSize);
			for (Integer i=0; i<lineItemSize; i++) {
				LineItem lineItem = new LineItem();
				if (fluidIntakeLineItems.size() > i) {
					lineItem.fluidIntakeLineItem = fluidIntakeLineItems[i];
					if (fluidIntakeLineItems[i].intakeVolume != null) {
						if (totalVolume == null) {
							totalVolume = fluidIntakeLineItems[i].intakeVolume;
						} else {
							totalVolume += fluidIntakeLineItems[i].intakeVolume;
						}
					}
				}
				if (liquidIntakeLineItems.size() > i) {
					lineItem.liquidIntakeLineItem = liquidIntakeLineItems[i];
					if (liquidIntakeLineItems[i].liquidConsumed != null) {
						if (totalLiquidConsumed == null) {
							totalLiquidConsumed = liquidIntakeLineItems[i].liquidConsumed;
						} else {
							totalLiquidConsumed += liquidIntakeLineItems[i].liquidConsumed;
						}
					}
				}
				if (outputLineItems.size() > i) {
					lineItem.outputLineItem = outputLineItems[i];
					if (outputLineItems[i].voidAmount != null) {
						if (totalVoidAmount == null) {
							totalVoidAmount = outputLineItems[i].voidAmount;
						} else {
							totalVoidAmount += outputLineItems[i].voidAmount;
						}
					}
					if (outputLineItems[i].vomitusAmount != null) {
						if (totalVomitusAmount == null) {
							totalVomitusAmount = outputLineItems[i].vomitusAmount;
						} else {
							totalVomitusAmount += outputLineItems[i].vomitusAmount;
						}
					}
				}
				if (bladderOutputLineItems.size() > i) {
					lineItem.bladderOutputLineItem = bladderOutputLineItems[i];
				}
				if (bmCharacteristicsLineItems.size() > i) {
					lineItem.bmCharacteristicsLineItem = bmCharacteristicsLineItems[i];
				}
				lineItems.add(lineItem);
			}
		}

		public Integer compareTo(Object compareToObj) {
			ObservedDate compareTo = (ObservedDate) compareToObj;
			if (this.day > compareTo.day) {
				return -1;
			} else if (this.day == compareTo.day) {
				return 0;
			} else {
				return 1;
			}
		}
	}

	public virtual class ComparableByObservedDateTime implements Comparable {
		public DateTime observedDateTime { get; set; }

		public Integer compareTo(Object compareToObj) {
			ComparableByObservedDateTime compareTo = (ComparableByObservedDateTime) compareToObj;
			if (this.observedDateTime == null || compareTo.observedDateTime == null) {
				return 0;
			}
			if (this.observedDateTime > compareTo.observedDateTime) {
				return -1;
			} else {
				return 1;
			}
		}
	}

	public class FluidIntakeLineItem extends ComparableByObservedDateTime {
		public String feedingType { get; set; }
		public String intakeType { get; set; }
		public Double intakeVolume { get; set; }
	}

	public class LiquidIntakeLineItem extends ComparableByObservedDateTime {
		public Double liquidConsumed { get; set; }
	}

	public class OutputLineItem extends ComparableByObservedDateTime {
		public Double voidAmount { get; set; }
		public Double vomitusAmount { get; set; }
	}

	public class BladderOutputLineItem extends ComparableByObservedDateTime {
		public String bladderContinence { get; set; }
		public String devices { get; set; }
	}

	public class BMCharacteristicsLineItem extends ComparableByObservedDateTime {
		public String bmAmount { get; set; }
		public String bmColor { get; set; }
		public String bmConsistency { get; set; }
	}

	public class LineItem {
		public FluidIntakeLineItem fluidIntakeLineItem { get; set; }
		public LiquidIntakeLineItem liquidIntakeLineItem { get; set; }
		public BladderOutputLineItem bladderOutputLineItem { get; set; }
		public OutputLineItem outputLineItem { get; set; }
		public BMCharacteristicsLineItem bmCharacteristicsLineItem { get; set; }

		public LineItem() {
			fluidIntakeLineItem = new FluidIntakeLineItem();
			liquidIntakeLineItem = new LiquidIntakeLineItem();
			outputLineItem = new OutputLineItem();
			bladderOutputLineItem = new BladderOutputLineItem();
			bmCharacteristicsLineItem = new BMCharacteristicsLineItem();
		}
	}
}