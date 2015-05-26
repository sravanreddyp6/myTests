public with sharing class RestraintReductionReport {
	public Map<Id, Restraint> restraints { get; set; }
	public Assessment_Question__c[] questions { get; set; }

	public RestraintReductionReport() {
		Date startDate = Date.parse(ApexPages.currentPage().getParameters().get('startDate'));
		Date endDate = Date.parse(ApexPages.currentPage().getParameters().get('endDate'));
		String reportType = ApexPages.currentPage().getParameters().get('type');
		Id saId = ApexPages.currentPage().getParameters().get('saId');

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

		restraints = new Map<Id, Restraint>();
		for (Assessment__c reduction: [
			SELECT Id, Name, Evaluation__c, CreatedDate
			FROM Assessment__c
			WHERE Type__c = 'Restraint Reduction'
			AND	CreatedDate >= :startDate
			AND CreatedDate <= :endDate
			AND Evaluation__r.ServiceAssignment__c = :saId
			ORDER BY CreatedDate ASC
		]) {
			if (!restraints.containsKey(reduction.Evaluation__c)) {
				restraints.put(reduction.Evaluation__c, new Restraint());
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
	}

	private class Restraint {
		public Integer MAX_REDUCTIONS = 6;
		public Reduction[] reductions { get; set; }
		private Map<Id, Reduction> reductionMap;

		public Restraint() {
			this.reductions = new Reduction[]{};
			this.reductionMap = new Map<Id, Reduction>();
		}

		public void addReduction(Reduction reduction) {
			if (this.reductions.size() >= MAX_REDUCTIONS && this.reductions.size() > 0 && reduction.compareTo(this.reductions[0]) > 0) {
				// At the limit already, so we have to remove the earliest reduction
				reductionMap.remove(reductions[0].Id);
				reductions.remove(0);
				reductions.add(reduction);
				reductionMap.put(reduction.Id, reduction);
				reductions.sort();
			} else if (this.reductions.size() < MAX_REDUCTIONS) {
				reductions.add(reduction);
				reductionMap.put(reduction.Id, reduction);
				reductions.sort();
			}
		}

		public Reduction getReductionFromId(Id Id) {
			return reductionMap.get(Id);
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