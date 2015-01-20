public with sharing class Report_CANS_PBSOverTimeGraph {
    
    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'WellBeing'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            if(selectedCluster == 'Behavior_and_Risk'){return Assessment_CANS_Cluster_Defs.Behavior_and_Risk;}
            if(selectedCluster == 'Education') {return Assessment_CANS_Cluster_Defs.Education;}
            return null;
        }
    }

	public transient Map<ID, Assessment_Question__c> QuestionsList{ get; set;}	// holds list of questions in scope - ID, name, number
    public List<SelectOption> optClusters{ get; set;}
    public string selectedCluster{get; set;}
    public List<SelectOption> optPBS{ get; set;}
    public String selectedPBS { get; set;}
    public boolean showData { get; set;}
    public transient List<CANSData> pbsCANS {get; set;}
    
    public Report_CANS_PBSOverTimeGraph() {
        
	   	optClusters =  new List<SelectOption>();
	    optClusters.Add( new SelectOption('','--None--'));
	    optClusters.Add( new SelectOption('Behavior_and_Risk','Behavior and Risk'));
	    optClusters.Add( new SelectOption('Education','Education'));
	    optClusters.Add( new SelectOption('WellBeing','Well Being'));
	
	        
	    QuestionsList = new Map<ID, Assessment_Question__c>();
	
	 	optPBS = new List<SelectOption>();
	 	optPBS.Add( new SelectOption('','--None--'));
	 	// get the list of people i can see who have final, non-diregarded cans
	 	List<AggregateResult> arCANSList = [select count(id), accountperson__c, accountperson__r.name, accountperson__r.lastname from assessment__c where assessment_type__r.name = 'CANS' and  disregard__c = false and status__c = 'Locked' group by accountperson__c, accountperson__r.name, accountperson__r.lastname  order by accountperson__r.lastname];
	 			
	 	for ( AggregateResult ar : arCANSList ) 
	 		optPBS.Add( new SelectOption((String)ar.get('account_person__c'), (String)ar.get('name')));
			
		showData = false;
	            
    }

    public PageReference runReport(){
        showData = false;
        boolean inputErr = false;
        ApexPages.getMessages().clear();
       
       if ( String.isEmpty(selectedPBS)  ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select the Person Being Served for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       
       if ( !inputErr ) 
            buildRpt();
       
       
       return null;
        
    }

    public void buildRpt(){

		// get the CANS scores for this person being served
		pbsCANS = new List<CANSdata>();
            
       
		// if no cluster selected, get overall scores
		if (String.isEmpty( selectedCluster)) {
			
			for (Assessment__c asmt : [select id, name, assessment_date__c, interval__c, quarter__c, overall_score__c 
										from assessment__c 
										where accountperson__c = :selectedPBS 
										and disregard__c = false
										and status__c = 'Locked'
										order by assessment_date__c
										]) {
											
				CANSData newasmt = new CANSData( asmt.assessment_date__c, asmt.name, asmt.id, asmt.overall_score__c, asmt.quarter__c, asmt.interval__c);								
				pbsCANS.add( newasmt );							
											
			}
		}

         /*
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
                                            and service_line__c in :selectedSL
                                            group by admission__r.state__c
                                            ];

		integer totalPBS = 0, totalQual = 0;
        for ( AggregateResult ar : QualifyingCountByState ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.PBSCount = pbscount;
            stdata.QualifyingCount = pbscount;
            totalPBS += pbscount;
            totalQual += pbscount;
            
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
                                            and assessment__r.service_line__c in :selectedSL
                                            group by question__c, assessment__r.admission__r.state__c
                                            ];
                                        
       Assessment_Question__c currQ;
       integer currcount;
       for ( AggregateResult ar : QualifyingCountByQuestion ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
 			currQ = QuestionsList.get((ID)ar.get('question__c'));
 			system.debug('Current Question: ' + currQ + ', state=' + pbstate + ', pbscount=' + pbscount);
 			if ( currQ != null ) { 
            	stdata.byQuestionCount.put((Integer)currQ.Question_number__c, pbscount);
				currcount = totdata.byQuestionCount.get((integer)currQ.Question_number__c);
            	totdata.byQuestionCount.put((integer)currQ.Question_number__c, currcount + pbscount );
 			}
        }   
        */
        
		showData = true;
              
    }
    
    

    public class CANSData{
        public Date Assessment_Date {get; set;}
        public Decimal Score{get;set;}
        public string Assessment_Name { get; set;}
        public ID AssessmentID { get; set;}
        public Decimal Quarter { get; set;}
        public String Interval { get; set;}

        public CANSData (Date dt, String nm, ID id, Decimal sc, Decimal q, String intv ){
            Assessment_Date = dt;
            Assessment_Name = nm;
            AssessmentID = id; 
            Score = sc;
            Quarter = q;
            Interval = intv;
        }
        
    }


}