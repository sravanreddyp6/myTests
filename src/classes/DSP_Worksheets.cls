public without sharing class DSP_Worksheets {

	public ID ActionPlanId { get; set; }
	public map<String, List<WorksheetWrapper>> mapSheets { get; set; }
	
	public DSP_Worksheets ( ID APId) {
		this.ActionPlanID = APId;
		mapSheets = new Map<String, List<WorksheetWrapper>>();
		populateWorksheets();
	}
	
	public DSP_Worksheets(TxnQueueResponseController controller) {
	}

	public class worksheetWrapper {
		
		public ID wID { get; set; }
		public String wName { get; set; }
		public Date startdate { get; set; }
		public String wType { get; set; }
		public String CreatedBy { get; set; }
		public String LastModifiedBy { get; set; }
		public DateTime Created { get; set; }
		public DateTime LastModified { get; set; }
		
		public worksheetWrapper( Action_Plan_Worksheet__c ap ) {
			wID = ap.id;
			wName = ap.name;
			startdate = ap.start_date__c;
			wType = ap.recordtype.name;
			CreatedBy = ap.createdby.name;
			Created = ap.createddate;
			LastmodifiedBy = ap.lastmodifiedby.name;
			LastModified = ap.lastmodifieddate;
		}
		
		
	}
	
	public void populateWorksheets() {
    	List<Action_Plan_Worksheet__c> wks = [ select id, name, start_date__c, recordtype.name, createdby.name, createddate, lastmodifiedby.name, lastmodifieddate
    											from Action_Plan_Worksheet__c
    											where action_plan__c = :ActionPlanId 
    											order by recordtype.name, start_date__c desc];

		List<WorksheetWrapper> beh;
		List<WorksheetWrapper> skill;
		for ( Action_Plan_Worksheet__c a : wks ) {                     
    		
    		WorksheetWrapper w = new WorksheetWrapper( a );
    		 
    		if ( a.recordtype.name.contains('Behavior')) {
    			
    			if ( (beh = mapSheets.get('Behavior')) == null ) {
    				
    				beh = new List<WorksheetWrapper>();
    			}
    			beh.add( w );
    			mapSheets.put( 'Behavior', beh); 
    			
    		} else if ( a.recordtype.name.contains('Skill')) {
    			if ( (skill = mapSheets.get('Skill')) == null ) {
    				
    				skill = new List<WorksheetWrapper>();
    			}
    			skill.add( w ); 
    			mapSheets.put('Skill', skill);
    		}
    		
		}
	}
}

