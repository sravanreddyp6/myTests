public with sharing class GoalObjReporting {

	public ID objID { get; set { init( value); } }
	public ID saID { get; set; }
	public string effdates { get; set; }
	public ID currRespID { get; set; }
	public string objType { get; set ; }
	public Integer numRows { get; set; }
	public Action_Plan_objective__c thisObj {get ;set;}
	public datetime shiftStart { get; set; }
	
	private Boolean hasError;
		
	public objResultWrapper currResult { get; set; }
	
	public transient List<Action_Narrative_Result__c> narrativeResults;
	public transient List<Action_Behavior_Result__c> behaviorResults;
	public transient List<Action_Skill_Result__c> skillResults; 
	
	public transient List<String> columnsToFetch { get; private set ;}
	public transient List<String> inputcolumns { get; private set ;}
	
	private SObject newresp;
	
	
	public GoalObjReporting() {
		narrativeResults = new List<Action_Narrative_Result__c>();
		behaviorResults = new List<Action_Behavior_Result__c>();
		skillResults = new List<Action_Skill_Result__c>();
		
		currResult = new objResultWrapper();

	}
	
	
	public void init ( ID thisID ) {	//get the type of objective this is
		List<Action_Plan_Objective__c> apo = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where id = :thisID];
		system.debug( 'APO is' + apo);
		if (apo.size() > 0) {
			thisObj = apo[0];
			objType = apo[0].type__c;	
			effdates = apo[0].effective_date__c.format() + ' to ' + apo[0].target_end_date__c.format();
			
			if (objType == 'Behavior - Count' || objType == 'Behavior - Duration' ) 
				currResult.currResultB = new Action_Behavior_Result__c( action_plan_objective__c = thisObj.Id );
			else if ( objType == 'Skill')
				currResult.currResultS = new Action_Skill_Result__c ( action_plan_objective__c = thisObj.Id);
			else if ( objType == 'Narrative')
				currResult.currResultN = new Action_Narrative_Result__c ( action_plan_objective__c = thisObj.id);
		} 
	}
	
	public List<Action_Narrative_Result__c> getnarrativeResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c);	
		narrativeResults = [ select id, description__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from action_narrative_result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
		columnsToFetch = new List<String>{'description__c','lastmodifiedbyid', 'lastmodifieddate'};
		inputcolumns = new List<String>{'description'};
		currResult.resultType = thisObj.type__c;
		currResult.objID = thisObj.Id;
		return narrativeResults;
		
	}
	
	public List<Action_Behavior_Result__c> getbehaviorCResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c );	
		
			behaviorResults = [select id, day_time__c, occurrences__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Behavior_Result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
			columnsToFetch = new List<string>{'day_time__c','occurences__c','createdbyid', 'createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns= new List<String>{'daytime','occurrences'};
			currResult.resultType = thisObj.type__c;
			currResult.objID = thisObj.Id;
			return behaviorResults;
	}
	
	public List<Action_Behavior_Result__c> getbehaviorDResults() {	
		if (numrows == null)
			numrows = 1000;
			system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c);	
		
			behaviorResults = [select id, day_time__c, occurred__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Behavior_Result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
			columnsToFetch = new List<string>{'day_time__c','occurred__c','createdbyid', 'createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns = new List<String>{'daytime','occurred'};
			currResult.resultType = thisObj.type__c;
			currResult.objID = thisObj.Id;
			return behaviorResults;
	}
	
	public List<Action_Skill_Result__c> getskillResults() {	
		if (numrows == null)
			numrows = 1000;
		system.debug( 'GETTING: ' + thisObj.ID + ',' + thisObj.type__c );	
	
			skillResults = [ select id, attempts__c, day__c, initials__c, met_objective__c, status__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from Action_Skill_Result__c where action_plan_objective__c = :thisObj.ID order by lastmodifieddate desc ];
			columnsToFetch = new List<String>{'attempts__c','day__c','initials__c','met_objective__c','status__c','createdbyid','createddate','lastmodifiedbyid', 'lastmodifieddate'};
			inputcolumns = new List<String>{'attempts','day','initials','metobj','status'};
			currResult.resultType = thisObj.type__c;
			currResult.objID = thisObj.Id;
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
        		currResult = new objResultWrapper ( newresp.id, 'Narrative', newresp);
        		system.debug('retrieving current result of ' +  currResult); 
        }

        if ( objType == 'Skill' )  {
        		query += ' from action_skill_result__c where Id = :currRespId';
        		newresp  = Database.query(query);
        		system.debug( newresp);
        		currResult = new objResultWrapper ( newresp.id, 'Skill', newresp);
        		system.debug('retrieving current result of ' +  currResult); 
        }
        if ( objType.contains('Behavior' ))  {
        		query += ' from action_behavior_result__c where Id = :currRespId';
        		newresp  = Database.query(query);
        		system.debug( newresp);
        		currResult = new objResultWrapper ( newresp.id, objType, newresp);
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
            	upsert( currResult.currResultN );
            }
            
            if (resulttype.startswith('Behavior') ) {
       		    upsert( currResult.currResultB);
            }
            
            if (resulttype.startswith('Skill') ) {
            	upsert( currResult.currResultS);
            }
		    currResult = new objResultWrapper(resulttype, thisObj.id);         
            
        } catch (DMLException ex) {
            hasError = true;
            system.debug(ex);
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }


	public class objResultWrapper {
		public string resultType { get; set; } 
		public ID objId { get; set; }
		public ID respid { get; set; }
		public String lastModMilitary { get; set; }
		public Action_Behavior_Result__c currResultB { get; set; }
		public Action_Skill_Result__c currResultS { get; set; }
		public Action_Narrative_Result__c currResultN { get; set; }
	
		public objResultWrapper() {
			
		}
		
		public objResultWrapper( string resultType, ID objID ) {
			if ( resultType == 'Narrative') {
				currResultN = new Action_Narrative_Result__c ( action_plan_objective__c = objID );
			}
			if ( resultType == 'Skill' ) {
				currResultS = new Action_Skill_Result__c (action_plan_objective__c = objID, 
														day__c = datetime.now().date());
														
			}
			if ( resultType.Contains('Behavior')) {
				currResultB = new Action_Behavior_Result__c ( action_plan_objective__c = objID);
			}
		}
		
		
		public objResultWrapper( ID id, string rt, SObject obj) {
			respid = id;
			resultType = rt;
			lastModMilitary = Utility.getMilitaryTime( (datetime)obj.get('lastmodifieddate'));

			if ( rt == 'Narrative' ) 
				currResultN = (Action_Narrative_Result__c)obj;
			if ( rt == 'Skill')
				currResultS = (Action_Skill_Result__c)obj;
			if ( rt.Contains('Behavior'))
				currResultB = (Action_Behavior_Result__c)obj;
		}
	}

}