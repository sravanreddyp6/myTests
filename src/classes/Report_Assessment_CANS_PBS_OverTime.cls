public with sharing class Report_Assessment_CANS_PBS_OverTime {
	public list<string> Columns {get; set;}
	public map<string, Assessment__c> mapColumnAssess {get; set;}

	public map<integer, Assessment_Question__c> mapQuestions {get; set;}
	public list<string> Questions {get; set;}

	public map<string, Assessment_Response__c> mapAnswers {get; set;}

	public map<string, integer> mapOverallScore {get; set;}

	public string selectedCluster{get; set;}
	public string selectedPBS{get; set;}
	public List<SelectOption> optPBS{ get; set;}
	public list<integer> QuestionsNumbersInScope {
        get{
            if(selectedCluster == 'Well-Being'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            else if(selectedCluster == 'Behavior & Risk'){return Assessment_CANS_Cluster_Defs.Behavior_AND_Risk;}
            else if(selectedCluster == 'Education'){return Assessment_CANS_Cluster_Defs.Education;}
            else {
            	list<integer> allQ = new list<integer>();
            	for(integer item = 1; item < 111; item++){
            		allQ.add(item);
            	}
            	return allQ;
            }
            return null;
        }
    }
	public Report_Assessment_CANS_PBS_OverTime() {
        optPBS = new List<SelectOption>();
        optPBS.Add( new SelectOption('','--None--'));
        // get the list of people i can see who have final, non-diregarded cans
        List<AggregateResult> arCANSList = [select count(id), accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname from assessment__c where assessment_type__r.name = 'CANS' and  disregard__c = false and status__c = 'Locked' group by accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname  order by accountperson__r.lastname];

        for ( AggregateResult ar : arCANSList ) {
            optPBS.Add( new SelectOption((String)ar.get('accountperson__c'), (String)ar.get('lastname') + ',' + (String)ar.get('firstname')));
        }

		selectedCluster = 'All';

		//runRPT();
	}

	public PageReference runRPT(){
		id PBSID = selectedPBS;
		//'001Z000000mRBtG';
		Columns = new list<string>();
		mapColumnAssess = new map<string, Assessment__c>();
		mapQuestions = new map<integer, Assessment_Question__c>();
		mapAnswers = new map<string, Assessment_Response__c>();
		mapOverallScore = new map<string, integer>();

		//set question
		for(Assessment_Question__c item :
			[select id, name, question_Number__c, Question_Title__c, Question_Domain__r.name
				from Assessment_Question__c
					where Question_Number__c in :QuestionsNumbersInScope
					and Question_Domain__r.Assessment_Type__r.Name = 'CANS']){
			mapQuestions.put(integer.valueof(item.Question_Number__c), item);
		}

		//set columns
		list<Assessment__c> BaselineAssessments = new list<Assessment__c>();
		list<Assessment_Response__c> Responses = new list<Assessment_Response__c>();

		BaselineAssessments = [select id, name, interval__c, quarter__c, status__c, assessment_date__c
									from Assessment__c
										Where AccountPerson__c = :PBSID
										AND Assessment_Type__r.Name = 'CANS'
										AND status__c = 'Locked'
										AND Disregard__c = false
										order by Admission__r.Effective_Date__c ASC, interval__c ASC, quarter__c ASC];
		//Columns.add('Intake');
		boolean hasDC = false;
		for(Assessment__c item : BaselineAssessments){
			string title = item.id + item.Interval__c;
			if(item.Interval__c =='Quarterly'){
					title += string.valueof(item.Quarter__c) ;
					Columns.add(title);
					mapColumnAssess.put(title, item);
				}
			else if(item.Interval__c =='Discharge'){hasDC = true; mapColumnAssess.put(title, item); Columns.add(title);}
			else if(item.Interval__c =='Intake' ){mapColumnAssess.put(title, item); Columns.add(title);}
		}
		//if(hasDC){Columns.add('Discharge');}

		for(string item : columns){
			mapOverallScore.put(item, 0);
		}

		//set answers
		for(Assessment_Response__c item : [select id, Question__r.Question_Number__c, rating__c, ScoreOld__c,
											name, Assessment__r.interval__c, Assessment__r.quarter__c, Assessment__r.id
												From Assessment_Response__c
												Where Assessment__r.id in : BaselineAssessments
												AND Question__r.Question_Number__c in :QuestionsNumbersInScope]){
			//todo
			string key = string.valueof(Integer.valueOf(item.Question__r.Question_Number__c)) + item.assessment__r.id + item.Assessment__r.interval__c ;
			string overallKey = item.Assessment__r.id + item.Assessment__r.interval__c;

			if(item.Assessment__r.quarter__c >0 && item.Assessment__r.Interval__c =='Quarterly'){
				key += string.valueof(item.Assessment__r.quarter__c);
				overallKey += string.valueof(item.Assessment__r.quarter__c);
			}
			mapAnswers.put(key, item);

			integer score = mapOverallScore.get(overallKey);
			score += integer.valueof(item.ScoreOld__c);
			mapOverallScore.put(overallKey, score);
		}

		return null;
	}

}