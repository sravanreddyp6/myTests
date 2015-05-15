public with sharing class GenerateGoalObjPDF {

	public List<ObjectiveWrapper> objectives { get; private set;}	
	
	public GenerateGoalObjPDF() {
		objectives = new List<ObjectiveWrapper>();
	}
	
	
	public void init ( ID evalID, String evalType) {	
			
		if (evalType == 'Residential')
			return;
		
		Evaluation__c eval = [ select id, name, shift_start_time__c, shift_end_time__c, serviceassignment__c from evaluation__c where id = :evalID limit 1];
		if ( eval == null)
			return;
		
		Date shiftStart = eval.shift_start_time__c.date();
		Date shiftEnd = eval.shift_end_time__c.date();
		ID saID = eval.serviceassignment__c;
			 
		if ( objectives.size() > 0 ) {
			// don't reload
			return;
		}
		
		// find all reportable objectives during the time period
		List<Action_Plan_Objective__c> lstAPO = [ select id, description__c, type__c, effective_date__c, target_end_date__c from action_plan_objective__c where Action_Plan_Goal__r.Action_Plan__r.service_assignment__c = :saID
									and (
										 (effective_date__c > :shiftStart  and effective_date__c <= :shiftEnd)
										  or
										 (effective_date__c <= :shiftStart and target_end_date__c >= :shiftStart) 
									)
									and Status__c in ('In Progress', 'Revised', 'New')
									and action_plan_goal__r.action_plan__r.status__c = 'Active Final' ];
		for (Action_Plan_Objective__c apo : lstAPO) {
			ObjectiveWrapper obj = new ObjectiveWrapper( apo.id, apo.type__c, shiftStart, shiftEnd );
			objectives.add( obj);
		} 
		
	}
	


	public class ObjectiveWrapper {
		 
		public ID objId { get; set; }
		public string objType { get; set; }
		public Date shiftStart { get; set; }
		public Date shiftEnd { get; set; }
		
		public ObjectiveWrapper( ) {
			objID = null;			
			objType = null;
			shiftStart = null;
			shiftEnd = null;
		}
		
		public ObjectiveWrapper( ID oID, String oType, Date shStart, Date shEnd ) {
	
			objID = oID;
			objType  = oType;
			shiftStart = shStart;
			shiftEnd = shEnd;
		}
		
	}
	
	

}