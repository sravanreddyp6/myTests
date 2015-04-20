public with sharing class GoalObjReporting {

	public ID objID { get; set { init( value); } }
	public ID saID { get; set; }
	public string effdates { get; set; }
	public ID currRespID { get; set; }
	public string objType { get; set ; }
	public Integer numRows { get; set; }
	public Action_Plan_objective__c thisObj {get ;set;}
	private Boolean hasError;
		
	public objResultWrapper currResult { get; set; }
	
	public transient List<Action_Narrative_Result__c> narrativeResults;
	public transient List<Action_Behavior_Result__c> behaviorResults;
	public transient List<Action_Skill_Result__c> skillResults; 
	
	public transient List<String> columnsToFetch { get; private set ;}
	public transient List<String> inputcolumns { get; private set ;}
	
	private Action_Narrative_Result__c newresp;
	
	public GoalObjReporting() {
		narrativeResults = new List<Action_Narrative_Result__c>();
		behaviorResults = new List<Action_Behavior_Result__c>();
		skillResults = new List<Action_Skill_Result__c>();
		
		currResult = new objResultWrapper();

	}
	
	
	public void init ( ID thisID ) {	//get the type of objective this is
		List<Action_Plan_Objective__c> apo = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where id = :thisID];
		
		if (apo.size() > 0) {
			thisObj = apo[0];
			objType = apo[0].type__c;	
			effdates = apo[0].effective_date__c.format() + ' to ' + apo[0].target_end_date__c.format();
		}					
	}
	
	public List<Action_Narrative_Result__c> getnarrativeResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c);	
		narrativeResults = [ select id, description__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from action_narrative_result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc LIMIT :numrows];
		columnsToFetch = new List<String>{'description__c','lastmodifiedbyid', 'lastmodifieddate'};
		inputcolumns = new List<String>{'description'};
		currResult.resultType = thisObj.type__c;
		currResult.objID = thisObj.Id;
		return narrativeResults;
		
	}
	
	public List<Action_Behavior_Result__c> getbehaviorCResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + objID + ',' + objType );	
		
			behaviorResults = [select id, day_time__c, occurrences__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Behavior_Result__c where action_plan_objective__c = :objID order by lastmodifieddate desc LIMIT :numrows];
			columnsToFetch = new List<string>{'day_time__c','occurences__c','createdbyid', 'createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns= new List<String>{'daytime','occurrences'};
			return behaviorResults;
	}
	
	public List<Action_Behavior_Result__c> getbehaviorDResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + objID + ',' + objType );	
		
			behaviorResults = [select id, day_time__c, occurred__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Behavior_Result__c where action_plan_objective__c = :objID order by lastmodifieddate desc LIMIT :numrows];
			columnsToFetch = new List<string>{'day_time__c','occurred__c','createdbyid', 'createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns = new List<String>{'daytime','occurred'};
			return behaviorResults;
	}
	
	public List<Action_Skill_Result__c> getskillResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + objID + ',' + objType );	
	
			skillResults = [ select id, attempts__c, day__c, initials__c, met_objective__c, status__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Skill_Result__c where action_plan_objective__c = :objID order by lastmodifieddate desc LIMIT :numrows];
			columnsToFetch = new List<String>{'attempts__c','day__c','initials__c','met_objective__c','status__c','createdbyid','createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns = new List<String>{'attempts','day','initials','metobj','status'};
			return skillResults;
	}
	
	public pageReference showEditResponse() {
		
        String query = 'SELECT ID ';
        
        for ( string col : columnsToFetch ) {
        	
        	query += ',' + col;
        }
        system.debug( 'obj type is ' + objType );
        if ( objType == 'Narrative' )  {
        		query += ' from action_narrative_result__c where Id = :currRespId';
        		newresp  = Database.query(query);
        		system.debug( newresp);
        		currResult = new objResultWrapper ( newresp.id, 'Narrative', newresp.description__c, null, null, null, null, null, null, null, null, newresp.action_plan_objective__r.effective_date__c, newresp.action_plan_objective__r.target_end_date__c );
        		system.debug('retrieving current result of ' +  currResult); 
        }
        		
        return null;
	}
	
	public void saveResult() {
        System.debug('saveresult called');
        system.debug('currresult is:' + currresult);
        String resultType = currResult.resulttype;
           
        try {
            hasError = false;
            
            if (resulttype == 'Narrative') {
            	Action_Narrative_Result__c resultNarr;
            	if ( currResult.respId != null ) {
            		resultNarr = newresp;
            		resultNarr.description__c = currResult.description ; 
            	} else 
            		resultNarr = new Action_Narrative_Result__c ( action_plan_objective__c = currResult.objID, description__c = currResult.description );
            	 
            	upsert( resultNarr );
            }
            
            
            if (resulttype.startswith('Behavior') ) {
            	Action_Behavior_Result__c resultBeh = new Action_Behavior_Result__c( action_plan_objective__c = currResult.objID, 
            																		day_time__c = currResult.daytime, 
            																		occurred__c =currResult.occurred, 
       		   																		occurrences__c = currResult.occurrences);
       		    upsert( resultBeh );
            }
            
            if (resulttype.startswith('Skill') ) {
            	Action_Skill_Result__c resultSkill = new Action_Skill_Result__c( action_plan_objective__c = currResult.objID, 
            																		day__c = currResult.day, 
            																		initials__c =currResult.initials, 
            																		met_objective__c = currResult.metobj,
            																		status__c = currResult.status);
            	upsert( resultSkill);
            }
		    currResult = new objResultWrapper();         
            
        } catch (DMLException ex) {
            hasError = true;
            system.debug(ex);
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }


	public class objResultWrapper {
		// this is a combination of all the types of results
		public string resultType { get; set; } 
		public string description {get; set;}
		public datetime daytime { get; set; }
		public boolean occurred { get; set; }
		public integer occurrences { get; set; }
		public integer attempts { get; set;}
		public date day { get; set; }
		public string initials { get; set; }
		public string metobj { get; set;}
		public string status { get; set;}
		public ID objId { get; set; }
		public ID respid { get; set; }
		
		public objResultWrapper() {
			
		}
		
		public objResultWrapper( string resultType ) {
			if ( resultType == 'Narrative') {
				description = '';
			}
			if ( resultType == 'Skill' ) {
				day = datetime.now().date();
				attempts = 0;
				initials = '';
				metobj = '';
				status = '';
			}
			if ( resultType == 'Behavior - Count') {
				daytime = datetime.now();
				occurrences = 0;
			}
			if ( resultType == 'Behavior - Duration') {
				daytime = datetime.now();
				occurred = false;
			}
		}
		
		
		public objResultWrapper( ID id, string rt, string descr, datetime dt, boolean o, integer os, integer atts, date d, string i, string m, string s, date sd, date ed ) {
			respid = id;
			resultType = rt;
			description = descr;
			daytime = dt;
			occurred = o;
			occurrences = os;
			attempts = atts;
			day = d;
			initials = i;
			metobj = m;
			status = s;
		}
		
	}


}