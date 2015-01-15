public with sharing class Report_CANS_ActionableByCluster {
    
    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'WellBeing'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            if(selectedCluster == 'Behavior_and_Risk'){return Assessment_CANS_Cluster_Defs.Behavior_and_Risk;}
            if(selectedCluster == 'Education') {return Assessment_CANS_Cluster_Defs.Education;}
            return null;
        }
    }

	public transient Map<ID, Assessment_Question__c> QuestionsList{ get; set;}	// holds list of questions in scope - ID, name, number
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<SelectOption> optClusters{ get; set;}
    public string selectedCluster{get; set;}
    public List<SelectOption> optInterval{get; set;} 
    public string selectedInterval{get; set;}
    public List<String> CANSStates {get; set;}
    public transient Map<String, StateRowData> srd {get;set;}
    public boolean showData { get; set;}
    
    public Report_CANS_ActionableByCluster() {
        
            optClusters =  new List<SelectOption>();
            optClusters.Add( new SelectOption('','--None--'));
            optClusters.Add( new SelectOption('Behavior_and_Risk','Behavior and Risk'));
            optClusters.Add( new SelectOption('Education','Education'));
            optClusters.Add( new SelectOption('WellBeing','Well Being'));

            optInterval = new List<SelectOption>();
            optInterval.Add( new SelectOption('Intake', 'Intake'));
            optInterval.Add( new SelectOption('Discharge', 'Discharge'));
        
            QuestionsList = new Map<ID, Assessment_Question__c>();

            CANSStates = new List<String>();

	         // get all states who have ever had a CANS intake 
	        for ( AggregateResult ar : [select Admission__r.State__c
	                                          from Assessment__c 
	                                          where Interval__c = 'Intake' 
	                                          and assessment_type__r.name = 'CANS'
	                                          and disregard__c = false
	                                          and status__c = 'Locked'
	                                          group by Admission__r.state__c
	                                         ]) {
	            system.debug(ar);
	            
	            string st = (String)ar.get('State__c');
	            CANSStates.Add( st );
 
 	            
		}
		showData = false;
            
    }

    public PageReference runReport(){
        showData = false;
        boolean inputErr = false;
        ApexPages.getMessages().clear();
       
       if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } else if ( startDate > endDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       system.debug( 'start=' + startDate + ', end=' + endDate + ', cluster=' + selectedCluster);
       
       if ( String.isEmpty(selectedCluster)  ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select the cluster for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } else {
       	    // get the list of questions for front-end display of text
         	QuestionsList = new Map<ID, Assessment_Question__c>([select id, question_number__c, question_title__c from assessment_question__c where question_number__c in :QuestionsinScope and Question_Domain__r.Assessment_Type__r.Name = 'CANS']); 
       	
       	// build out the question matrix
       		StateRowData newstate;
       		srd = new Map<String, StateRowData>();
       		for ( String st : CANSStates ) {
 
 		        newstate = new StateRowData( st );
            	
	            newstate.byQuestionCount = new Map<Integer, Integer>();
	            for ( Integer i: QuestionsInScope) {
	            	newstate.byQuestionCount.put( i, 0);
	            }
	            srd.put( st, newstate );
 
	          
       		}  	
       }

       
       if ( !inputErr ) 
            buildRpt();
            
        return null;
        
    }

    public void buildRpt(){
         
        Integer pbscount = 0;
        String pbstate = '';
        
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 2 or 3 for any question in the cluster
        list<AggregateResult> QualifyingCountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where id in (select assessment__c 
                                                         from assessment_response__c 
                                                         where score__c in (2, 6)
                                                         and question__r.question_number__c in :QuestionsInScope
                                                         and assessment__r.Interval__c = :selectedInterval
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and assessment__r.admission__r.state__c in :CANSStates  )
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
                                            ];

        for ( AggregateResult ar : QualifyingCountByState ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.PBSCount = pbscount;
            stdata.QualifyingCount = pbscount;
        }
        
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 2 or 3 for any question in the cluster
        list<AggregateResult> QualifyingCountByQuestion = [ select count(score__c), 
        														   question__c, 
        														   assessment__r.admission__r.state__c 
        													from assessment_response__c 
        													where 
        													score__c in (2, 6) 
	                                                         and question__r.question_number__c in :QuestionsInScope
    	                                                     and assessment__r.Interval__c = :selectedInterval
        	                                                 and assessment__r.assessment_type__r.name = 'CANS'
            	                                             and assessment__r.disregard__c = false
                	                                         and assessment__r.status__c = 'Locked'
                                                         	 and assessment__r.admission__r.state__c in :CANSStates 
                                            and assessment__r.assessment_date__c >= :startDate 
                                            and assessment__r.assessment_date__c <= :endDate
                                            group by question__c, assessment__r.admission__r.state__c
                                            ];
                                        
       Assessment_Question__c currQ;                                    
       for ( AggregateResult ar : QualifyingCountByQuestion ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
 			currQ = QuestionsList.get((ID)ar.get('question__c'));
 			system.debug('Current Question: ' + currQ + ', state=' + pbstate + ', pbscount=' + pbscount);
 			if ( currQ != null )
            	stdata.byQuestionCount.put((Integer)currQ.Question_number__c, pbscount);
            
        }   
        showData = true;
        System.Debug( 'Final Result: ' + srd );      
    }
    
    

    public class StateRowData{
        public string strState;
        public Integer PBSCount {get;set;}
        public Integer QualifyingCount{get;set;}
        public Map<Integer, Integer> byQuestionCount {get;set;}

        public StateRowData(string var_State){
            strState = var_State;
            PBSCount = 0;
            QualifyingCount = 0; 
			          
        }
    }


}