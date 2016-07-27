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
    public List<string> selectedSL { get; set; }
    public List<SelectOption> optSL { get; set; }
	public String selectedDD { get; set; }
    public List<SelectOption> optDD { get; set; }
    public boolean totalExists { get; set;}
    
    public Report_CANS_ActionableByCluster() {
        
            optClusters =  new List<SelectOption>();
            optClusters.Add( new SelectOption('','--None--'));
            optClusters.Add( new SelectOption('Behavior_and_Risk','Behavior & Risk'));
            optClusters.Add( new SelectOption('Education','Education'));
            optClusters.Add( new SelectOption('WellBeing','Well-Being'));

            optInterval = new List<SelectOption>();
            optInterval.Add( new SelectOption('Intake', 'Intake'));
            optInterval.Add( new SelectOption('Q1', '1st Quarter'));
            optInterval.Add( new SelectOption('Discharge', 'Discharge'));
        
            optDD = new List<SelectOption>();
            optDD.Add( new SelectOption('All', 'All PBS'));
            optDD.Add( new SelectOption('With', 'Only PBS with DD'));
            optDD.Add( new SelectOption('Without', 'Only PBS without DD'));
        	
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
		optSL = new List<SelectOption>();
		selectedSL = new List<String>();
		
		  // Get the object type of the SObject.
		  Schema.sObjectType objType = Assessment__c.getSObjectType(); 
		  // Describe the SObject using its object type.
		  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
		  // Get a map of fields for the SObject
		  map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
		  // Get the list of picklist values for this field.
		  list<Schema.PicklistEntry> values = fieldMap.get('Service_Line__c').getDescribe().getPickListValues();
		  // Add these values to the selectoption list.
		  for (Schema.PicklistEntry a : values)
		  { 
		     optSL.add(new SelectOption(a.getValue(), a.getLabel())); 
		     selectedSL.add(a.getValue());
		  }
		  
		  optSL.add(new SelectOption( 'NS', 'Not specified'));
		  selectedSL.add( 'NS');
		  
		 totalExists = false; 
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
       
       if ( selectedSL.size() == 0 ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select at least one service line for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
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
         
        Integer pbscount = 0, uniquePBS = 0;
        
        String pbstate = '';
        Boolean includeNullSL = false;
        
        for ( string s : selectedSL ) {
        	if ( s == 'NS')
        		includeNullSL = true;
        }
        
        List<ID> DDPBS = new LIst<ID>();
		for (List<Assessment_Response__c> DDPeople :  [select assessment__r.accountperson__c from assessment_response__c  
									where score__c > 0 
									and question__r.question_number__c = 37 
									and assessment__r.interval__c = 'Intake'  
									and assessment__r.disregard__c = false 
                                    and assessment__r.status__c = 'Locked'  
                                    and assessment__r.admission__r.state__c in :CANSStates]) {
			for (Assessment_Response__c ar: DDPeople ) 
				DDPBS.Add( (ID) ar.assessment__r.accountperson__c);
        }	                                                  
                                                  
        String strQuery = 'select count_distinct(accountperson__c), count(accountperson__c), admission__r.state__c from assessment__c where id in (select assessment__c ' + 
                                                         ' from assessment_response__c' + 
                                                         ' where score__c in (2, 6)' +
                                                         ' and question__r.question_number__c in :questionsInScope' ;
		if (selectedInterval == 'Q1')
			strQuery += ' and assessment__r.Interval__c = \'Quarterly\' and assessment__r.Quarter__c = 1';
		else
			strQuery += ' and assessment__r.Interval__c = :selectedInterval' ;
		
		strQuery += ' and assessment__r.assessment_type__r.name = \'CANS\'' + 
                                                         ' and assessment__r.disregard__c = false' + 
                                                         ' and assessment__r.status__c = \'Locked\'' + 
                                                         ' and assessment__r.admission__r.state__c in :CANSStates)' + 
                                                         ' and assessment_date__c >= :startDate' + 
                                            			 ' and assessment_date__c <= :endDate'+
                                            			 ' and ';
         if ( includeNullSL)  {
 				strQuery += '( service_line__c = null OR service_line__c in :selectedSL)';        	
         } else {
         		strQuery += 'service_line__c in :selectedSL';
         }
         
		if ( selectedDD == 'With')
			strQuery += ' and accountperson__c in :DDPBS';
			
		if ( selectedDD == 'Without')
			strQuery += ' and accountperson__c not in :DDPBS';
			
		strQuery += ' group by admission__r.state__c';
		                                            			 
        system.debug('QUERY:' + strQuery );
                                      
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 2 or 3 for any question in the cluster
        list<AggregateResult> QualifyingCountByState = database.query(strQuery);

		integer totalPBS = 0, totalQual = 0; 
        for ( AggregateResult ar : QualifyingCountByState ) {
            
            uniquePBS = (Integer)ar.get('expr0');
            pbscount = (Integer)ar.get('expr1');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.PBSCount = uniquePBS;
            stdata.QualifyingCount = pbscount;
            totalPBS += uniquePBS;
            totalQual += pbscount;
            
        }


        // add total row
        StateRowData totdata; 
        
        if ( !totalExists ) {
        	CANSStates.Add('TOTAL');
        	totdata = new StateRowData('TOTAL');
        	totdata.byQuestionCount = new Map<Integer, Integer>();
	            for ( Integer i: QuestionsInScope) {
	            	totdata.byQuestionCount.put( i, 0);
	            }
        	srd.put('TOTAL', totdata);
        	totalExists = true;
        } else {
        	totdata = srd.get('TOTAL');
        }

		totdata.pbsCount = totalPBS;
		totdata.QualifyingCount = totalQual;
		
		        
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 2 or 3 for any question in the cluster
       strQuery = 'select count(score__c), question__c, assessment__r.admission__r.state__c from assessment_response__c' + 
        		' where score__c in (2, 6) and question__r.question_number__c in :QuestionsInScope' ;
        		
		if (selectedInterval == 'Q1')
			strQuery += ' and assessment__r.Interval__c = \'Quarterly\' and assessment__r.Quarter__c = 1';
		else
			strQuery += ' and assessment__r.Interval__c = :selectedInterval' ;
		
		strQuery += ' and assessment__r.assessment_type__r.name = \'CANS\'' + 
                                                         ' and assessment__r.disregard__c = false' + 
                                                         ' and assessment__r.status__c = \'Locked\'' + 
                                                         ' and assessment__r.admission__r.state__c in :CANSStates' + 
                                                         ' and assessment__r.assessment_date__c >= :startDate' + 
                                            			 ' and assessment__r.assessment_date__c <= :endDate' +
                                            			 ' and ';
                                            			 
         if ( includeNullSL)  {
 				strQuery += '( assessment__r.service_line__c = null OR assessment__r.service_line__c in :selectedSL)';        	
         } else {
         		strQuery += 'assessment__r.service_line__c in :selectedSL';
         }                                    			 
                                            			 
		if ( selectedDD == 'With')
			strQuery += ' and assessment__r.accountperson__c in :DDPBS';
			
		if ( selectedDD == 'Without')
			strQuery += ' and assessment__r.accountperson__c not in :DDPBS';
			
		strQuery += ' group by question__c, assessment__r.admission__r.state__c';
		                                            			 
        system.debug('QUERY:' + strQuery );                                     
       list<AggregateResult> QualifyingCountByQuestion = database.query( strQuery);
                                        
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
        
		showData = true;
//        System.Debug( 'Final Result: ' + srd );      
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