public with sharing class RestraintReductionReport {
	public Map<Id, Restraint> restraints { get; set; }
	public Assessment_Question__c[] questions { get; set; }
	public Integer[] rows { get; set; }
	public Service_Assignment__c serviceAssignment { get; set; }
	public Date startDate { get; set; }
	public Date endDate { get; set; }

	public RestraintReductionReport() {
		startDate = Date.parse(ApexPages.currentPage().getParameters().get('startDate'));
		endDate = Date.parse(ApexPages.currentPage().getParameters().get('endDate'));
		String reportType = ApexPages.currentPage().getParameters().get('type');
		Id saId = ApexPages.currentPage().getParameters().get('saId');
		serviceAssignment = [
			SELECT Id, Admission__c, Person_Being_Served__c
			FROM Service_Assignment__c
			WHERE Id=:saId
		];

		questions = [
			SELECT ID, Question_Number__c, Question_Title__c, Name, Question_Description__c,
			       Assessment_Type__c, Is_MultiSelect__c,Question_Domain__c, Question_Domain__r.Name,
			       (SELECT Name, Score__c, Rating__c, Color__c, Rating_Description__c
			        FROM Assessment_Question_Option__r
			        ORDER BY sort_order__c ASC)
			FROM Assessment_Question__c
			WHERE Question_Domain__r.Name = 'Restraint Questions'
			AND Question_Domain__r.Assessment_Type2__c = 'Restraint Reduction'
			ORDER BY Question_Number__c ASC
		];
		Integer numRows = questions.size() + 2;  // We need space for Total and Guideline as well

		restraints = new Map<Id, Restraint>();
		for (Assessment__c reduction: [
			SELECT Id, Name, Evaluation__c, CreatedDate
			FROM Assessment__c
			WHERE Type__c = 'Restraint Reduction'
			AND	CreatedDate >= :startDate
			AND CreatedDate <= :endDate.addDays(1)  // We need to include reports on the end day as well, so we'll add 1 day to the End Date
			AND Evaluation__r.ServiceAssignment__c = :saId
			ORDER BY CreatedDate ASC
		]) {
			if (!restraints.containsKey(reduction.Evaluation__c)) {
				Integer maxReductions = (reportType == 'Detailed' ? 4 : 6);
				restraints.put(reduction.Evaluation__c, new Restraint(maxReductions));
			}
			Restraint restraint = restraints.get(reduction.Evaluation__c);
			restraint.addReduction(new Reduction(reduction));
		}
		Id[] reductions = new Id[]{};
		for (Restraint restraint: restraints.values()) {
			for (Reduction reduction: restraint.reductions) {
				reductions.add(reduction.Id);
			}
		}

		for (Assessment_Response__c response: [
			SELECT ID, Name, Question__c, Score__c, Rating__c, Color__c,
			       Question__r.Question_Domain__r.Name, Question__r.Question_Title__c,
			       Assessment__r.Evaluation__c, Assessment__c
			FROM Assessment_Response__c
			WHERE Assessment__c IN :reductions
			AND Assessment_Domain_Result__r.Assessment_Domain__r.Name = 'Restraint Questions'
			ORDER BY Question__r.Question_Number__c ASC
		]) {
			Reduction reduction = restraints.get(response.Assessment__r.Evaluation__c).getReductionFromId(response.Assessment__c);
			reduction.addResponse(response);
		}

		for (Assessment_Domain_Result__c result: [
			SELECT Name, ID, Sort_Order__c, Assessment_Domain__c, Title__c, Total_Questions__c,
			       Answered_Questions__c, Score__c, Assessment__r.Evaluation__c, Assessment__c
			FROM Assessment_Domain_Result__c
			WHERE Assessment__c IN :reductions
			AND Assessment_Domain__r.Name = 'Restraint Questions'
		]) {
			Reduction reduction = restraints.get(result.Assessment__r.Evaluation__c).getReductionFromId(result.Assessment__c);
			reduction.setDomainResult(result);
		}

		for (Eval_Value__c preRestraintResponse: [
			SELECT eval_section_id__c, id, boolean__c, currency__c, date_time__c,
			       number_no_decimal__c, text_over_250__c, text_under_250__c, eval__c,
			       eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,
			       owner.name, createddate, eval__r.length__c, what_id__c,
			       eval__r.field_name__c, eval__r.field_type__c, eval__r.field_sub_type__c
			FROM eval_value__c
			WHERE what_id__c IN :restraints.keySet()
			AND what_id_object__c = 'Evaluation__c'
			AND eval__r.Field_name__c != 'Dummy Value'
			ORDER BY eval__r.cat_seq_text__c, eval__r.subcat_seq_text__c,
			         eval__r.subsubcat_seq_text__c, eval__r.field_sequence__c,
			         eval_section_id__c, createddate
		]) {
			restraints.get(preRestraintResponse.What_Id__c).addPreRestraintResponse(preRestraintResponse);
			if (numRows < restraints.get(preRestraintResponse.What_Id__c).preRestraintKeyOrder.size()) {
				numRows = restraints.get(preRestraintResponse.What_Id__c).preRestraintKeyOrder.size();
			}
		}

		rows = new Integer[] {};
		for (Integer i = 0; i < numRows; i ++) {
			rows.add(i);
		}
	}

	private class Restraint {
		public Reduction[] reductions { get; set; }
		public Map<String, String> preRestraintResponses { get; set; }
		public String[] preRestraintKeyOrder { get; set; }
		public DateTime preRestraintDate { get; set; }
		public Integer maxReductions;

		private Map<Id, Reduction> reductionMap;

		public Restraint(Integer maxReductions) {
			this.reductions = new Reduction[]{};
			this.reductionMap = new Map<Id, Reduction>();
			this.preRestraintResponses = new Map<String, String>();
			this.preRestraintKeyOrder = new String[] {};
			this.maxReductions = maxReductions;
		}

		public void addReduction(Reduction reduction) {
			if (this.reductions.size() >= maxReductions && this.reductions.size() > 0 && reduction.compareTo(this.reductions[0]) > 0) {
				// At the limit already, so we have to remove the earliest reduction
				reductionMap.remove(reductions[0].Id);
				reductions.remove(0);
				reductions.add(reduction);
				reductionMap.put(reduction.Id, reduction);
				reductions.sort();
			} else if (this.reductions.size() < maxReductions) {
				reductions.add(reduction);
				reductionMap.put(reduction.Id, reduction);
				reductions.sort();
			}
		}

		public Reduction getReductionFromId(Id Id) {
			return reductionMap.get(Id);
		}

		public void addPreRestraintResponse(Eval_Value__c response) {
			String value;
			if (response.Eval__r.Field_Type__c == 'Boolean')  { // Boolean can be Checkbox, Radio, or Dropdown
				if (response.Eval__r.Field_Sub_Type__c == 'Checkbox') {
					value = response.Boolean__c ? 'Yes': 'No';
				} else if (response.Eval__r.Field_Sub_Type__c == 'Dropdown') {
					if (response.Text_Under_250__c == '1') {
						value = 'Yes';
					} else if (response.Text_Under_250__c == '0') {
						value = 'No';
					}
				}
			} else if (response.Eval__r.Field_Type__c=='String') {
				if (response.Eval__r.Length__c > 250) {
					value = response.text_over_250__c;
				} else {
					value = response.text_under_250__c;
				}
			} else if (response.Eval__r.Field_Type__c == 'Int') {
				value = String.valueOf(response.Number_No_Decimal__c);
			} else if (response.Eval__r.Field_Type__c == 'Double') {
				value = response.Text_Under_250__c;
			} else if (response.Eval__r.Field_Type__c == 'DropDown') {
				value = response.Text_Under_250__c;
			} else if (response.Eval__r.Field_Type__c == 'Date') {
				value = response.Date_Time__c.Date().format();
			} else if (response.Eval__r.Field_Type__c == 'Datetime') {
				value = Utility.getMilitarytime(response.date_time__c);
			} else if (response.Eval__r.Field_Type__c == 'Multiselect') {
				if (response.Eval__r.Length__c > 250) {
					value = response.Text_Over_250__c;
				} else {
					value = response.Text_Under_250__c;
				}
				if (preRestraintResponses.containsKey(response.Eval__r.Field_Name__c)) {
					value = preRestraintResponses.get(response.Eval__r.Field_Name__c) + '; ' + value;
				}
			}
			if (value != null) {
				if (!preRestraintResponses.containsKey(response.Eval__r.Field_Name__c)) {
					preRestraintKeyOrder.add(response.Eval__r.Field_Name__c);
				}
				preRestraintResponses.put(response.Eval__r.Field_Name__c, value);
			}
			if (preRestraintDate == null) {
				preRestraintDate = response.CreatedDate;
			}
		}
	}

	private class Reduction implements Comparable {
		public Map<Id, Assessment_Response__c> responseMap { get; set; }
		public Assessment__c assessment { get; set; }
		public Id Id { get; set; }
		public DateTime CreatedDate { get; set; }
		public Assessment_Domain_Result__c domainResult { get; set; }

		public Reduction(Assessment__c assessment) {
			responseMap = new Map<Id, Assessment_Response__c>();
			this.assessment = assessment;
			this.Id = assessment.Id;
			this.CreatedDate = assessment.CreatedDate;
		}

		public Integer compareTo(Object anotherReductionObj) {
			Reduction anotherReduction = (Reduction) anotherReductionObj;
			if (this.assessment.CreatedDate < anotherReduction.assessment.CreatedDate) {
				return -1;
			} else if (this.assessment.CreatedDate == anotherReduction.assessment.CreatedDate) {
				return 0;
			} else {
				return 1;
			}
		}

		public void addResponse(Assessment_Response__c response) {
			responseMap.put(response.Question__c, response);
		}

		public void setDomainResult(Assessment_Domain_Result__c result) {
			domainResult = result;
		}
	}
}