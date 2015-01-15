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
	                                         ]) {
	            system.debug(ar);
	            
	            string st = (String)ar.get('State__c');
	            CANSStates.Add( st );
 
 	            
		}
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
       system.debug( 'start=' + startDate + ', end=' + endDate);
       
       // get the list of questions for front-end display of text
       QuestionsList = new Map<ID, Assessment_Question__c>([select id, question_number__c, question_title__c from assessment_question__c where question_number__c in :QuestionsinScope and Question_Domain__r.Assessment_Type__r.Name = 'CANS']); 
       	
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

		System.Debug('before:' + srd);
		// count of all PBS with intake by state in time period 
        list<AggregateResult> CountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where 
                                            Interval__c = 'Intake'
                                            and assessment_type__r.name = 'CANS'
                                            and disregard__c = false
                                            and status__c = 'Locked'
                                            and assessment_date__c >= :startDate 
                                            and assessment_date__c <= :endDate
                                            group by admission__r.state__c
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
        list<AggregateResult> QualifyingCountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where id in (select assessment__c 
                                                         from assessment_response__c 
                                                         where score__c > 0
                                                         and question__r.question_number__c in :QuestionsInScope
                                                         and assessment__r.Interval__c = 'Intake'
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
        		PercentDD= ((Double)qualifyingCount / (Double)PBSCount ) *100;
        	else
        		PercentDD = 0;
        		
        	return PercentDD;
        }
        	
        	
    }


}