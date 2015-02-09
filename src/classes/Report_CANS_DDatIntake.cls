public with sharing class Report_CANS_DDatIntake {

	// create list for developmental/intellectual
	list<integer> questionsinscope = new List<integer>{ 37 };
	public transient Map<ID, Assessment_Question__c> QuestionsList{ get; set;}	// holds list of questions in scope - ID, name, number
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<String> CANSStates {get; set;}
    public transient Map<String, StateRowData> srd {get;set;}
    public boolean showData { get; set;}
    public boolean totalExists { get; set;}
    public transient Map<String, String> asmtsByState {get;set;} 
    public transient string asmtStates{ get; set;}
    public List<string> selectedSL { get; set; }
    public List<SelectOption> optSL { get; set; }
                                           
    public Report_CANS_DDatIntake() {
        
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
	                                          order by Admission__r.state__c
	                                         ]) {
	            system.debug(ar);
	            
	            string st = (String)ar.get('State__c');
	            CANSStates.Add( st );
 
 	            
		}
		totalExists = false;
		showData = false;
		
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
       system.debug( 'start=' + startDate + ', end=' + endDate);
       if ( selectedSL.size() == 0 ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select at least one service line for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       // get the list of questions for front-end display of text
       QuestionsList = new Map<ID, Assessment_Question__c>([select id, question_number__c, question_title__c from assessment_question__c where question_number__c in :QuestionsinScope and Question_Domain__r.Assessment_Type__r.Name = 'CANS']); 
       	asmtsByState = new Map<String, String>();
       	// build out the question matrix
       		StateRowData newstate;
       		srd = new Map<String, StateRowData>();
       		for ( String st : CANSStates ) {
 
 		        newstate = new StateRowData( st );
 		        newstate.PBSCount = 0;
 		        newstate.QualifyingCount = 0;
	            srd.put( st, newstate );
 
	          
       		}  	
       

       
       if ( !inputErr ) 
            buildRpt();
            
        return null;
        
    }

    public void buildRpt(){
         
        Integer pbscount = 0;
        String pbstate = '';
        integer totalPBS = 0, totalQual = 0;

		Boolean includeNullSL = false;
        
        for ( string s : selectedSL ) {
        	if ( s == 'NS')
        		includeNullSL = true;
        }
        
		System.Debug('before:' + srd);
		// count of all PBS with 1st quarterly by state in time period 
        list<AggregateResult> CountByState = new List<AggregateResult>();
        
        if ( includeNullSL )
        	CountByState = [ 	
        								select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where 
                                            Interval__c = 'Quarterly'
                                            and quarter__c = 1
                                            and assessment_type__r.name = 'CANS'
                                            and disregard__c = false
                                            and status__c = 'Locked'
                                            and ( service_line__c in :selectedSL
                                            	or service_line__c = null )
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
                                            order by admission__r.state__c
                                            ];
		else
			CountByState = [ 	
        								select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where 
                                            Interval__c = 'Quarterly'
                                            and quarter__c = 1
                                            and assessment_type__r.name = 'CANS'
                                            and disregard__c = false
                                            and status__c = 'Locked'
                                            and service_line__c in :selectedSL
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
                                            order by admission__r.state__c
                                            ];
		
        for ( AggregateResult ar : CountByState ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.PBSCount = pbscount;
            totalPBS += pbscount;
        }

        system.debug('in between:' + srd);
        
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 1, 2 or 3 for any question in the cluster
        list<AggregateResult> QualifyingCountByState = new list<AggregateResult>();
        
        if ( includeNullSL )
        	QualifyingCountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where id in (select assessment__c 
                                                         from assessment_response__c 
                                                         where score__c > 0
                                                         and question__r.question_number__c in :QuestionsInScope
                                                         and assessment__r.Interval__c = 'Quarterly'
                                                         and assessment__r.Quarter__c = 1
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and ( assessment__r.service_line__c in :selectedSL
                                                         	or assessment__r.service_line__c = null )
                                                         and assessment__r.admission__r.state__c in :CANSStates  )
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
                                            order by admission__r.state__c
                                            ];
			else 
				QualifyingCountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where id in (select assessment__c 
                                                         from assessment_response__c 
                                                         where score__c > 0
                                                         and question__r.question_number__c in :QuestionsInScope
                                                         and assessment__r.Interval__c = 'Quarterly'
                                                         and assessment__r.Quarter__c = 1
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and assessment__r.service_line__c in :selectedSL
                                                         and assessment__r.admission__r.state__c in :CANSStates  )
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
                                            order by admission__r.state__c
                                            ];

        for ( AggregateResult ar : QualifyingCountByState ) {
            
            pbscount = (Integer)ar.get('expr0');
            pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.QualifyingCount = pbscount;
            totalQual += pbscount;
        }
        
        showData = true;
        
        // add total row
        StateRowData stdata; 
        if ( !totalExists ) {
        	CANSStates.Add('TOTAL');
        	stdata = new StateRowData('TOTAL');
        	totalExists = true;
        } else {
        	stdata = srd.get('TOTAL');
        }
        
        stData.pbsCount = totalPBS;
        stData.QualifyingCount = totalQual;
        srd.put('TOTAL', stdata);   
        System.Debug( 'Final Result: ' + srd );   
        
        // get the drilldown data
        List<Assessment_Response__c> asmtresp = new List<Assessment_Response__c>();
        
        if (includeNullSL )
        	asmtresp = [select assessment__r.name, assessment__c, score__c, assessment__r.assessment_date__c, assessment__r.admission__r.state__c 
                                                         from assessment_response__c 
                                                         where 
                                                         question__r.question_number__c in :QuestionsInScope
                                                         and score__c > 0
                                                         and assessment__r.Interval__c = 'Quarterly'
                                                         and assessment__r.quarter__c = 1
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and assessment__r.admission__r.state__c in :CANSStates
                                                         and ( assessment__r.service_line__c in :selectedSL
                                                         	or assessment__r.service_line__c = null )
                                            			 and assessment__r.assessment_date__c >= :startDate 
                                            			 and assessment__r.assessment_date__c <= :endDate
                                            			 order by assessment__r.admission__r.state__c];
                                            			 
        else 
        	asmtresp = [select assessment__r.name, assessment__c, score__c, assessment__r.assessment_date__c, assessment__r.admission__r.state__c 
                                                         from assessment_response__c 
                                                         where 
                                                         question__r.question_number__c in :QuestionsInScope
                                                         and score__c > 0
                                                         and assessment__r.Interval__c = 'Quarterly'
                                                         and assessment__r.quarter__c = 1
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and assessment__r.admission__r.state__c in :CANSStates
                                                         and assessment__r.service_line__c in :selectedSL
                                            			 and assessment__r.assessment_date__c >= :startDate 
                                            			 and assessment__r.assessment_date__c <= :endDate
                                            			 order by assessment__r.admission__r.state__c];

        // group the assessment responses by state, and put into a list for the front end                                   
        List<Assessment_Response__c> listbyState = new List<Assessment_Response__c>();
        String currst = '', st = '';                                    			 
        for (Assessment_Response__c a : asmtresp ) {
        	
        	// get this response's state
        	st = a.assessment__r.admission__r.state__c;
        	if ( st != currst ) {
        		system.debug( 'asmt state is: ' + st + ', currst is: ' + currst + ', listbystate: ' + listByState);
        		// if we're moving on to next state, serialize the list, put it into the map for front end, and re-init
        		if ( !String.IsEmpty(currst))
        			asmtsByState.put( currst, JSON.serialize(listbyState) );
        			
        		currst = st;
        		listbyState = new List<Assessment_Response__c>();
        		
        	} 
        	listbyState.Add(a); // add this response to the list for the state
        }
        // do the last state
        if ( !String.IsEmpty(currst)) {
        	system.debug( 'asmt state is: ' + st + ', currst is: ' + currst + ', listbystate: ' + listByState);
        	asmtsByState.put( currst, JSON.serialize(listbyState) );
        		
        }
        
        for (String k: asmtsByState.keyset())
        	asmtStates +=(asmtStates==''?'':',')+k;
        	 
        System.debug( asmtsByState);
    }
    
    public class StateRowData{
        public string strState;
        public Integer PBSCount {get; set { pbscount = value; calcPct();}}
        public Integer QualifyingCount{get;set { qualifyingcount = value; calcPct();}}
        public Double PercentDD { get; set;}

        public StateRowData(string var_State){
            strState = var_State;
            PBSCount = 0;
            QualifyingCount = 0; 
			PercentDD = 0.0;          
        }
        
        public double calcPct( ) {
        	
        	if ( PBSCount > 0 ) 
        		PercentDD= ((Double)qualifyingCount / (Double)PBSCount ); // will be formatted at % by page
        	else
        		PercentDD = 0;
        		
        	return PercentDD;
        }
        	
        	
    }


}