public abstract class ActionSummaryBase {
    protected ApexPages.StandardController controller;
    protected Action_Summary__c ActionSummary;

    public string StartDateStr {get;set;}
    public integer Duration {get;set;}

    public ActionSummaryBase (ApexPages.StandardController controller) {
        this.controller = controller;
        ActionSummary = (Action_Summary__c )controller.getrecord();
    }
    
    public virtual Date GetServiceAssignmentStartDate() {
    	if (ActionSummary.Service_Assignment__r.Start_date__c != null){
        	return ActionSummary.Service_Assignment__r.Start_date__c;
    	}
    	return [select Start_date__c
    			  from Service_assignment__c
    			 where id = :ActionSummary.Service_Assignment__c].Start_date__c;
    	
    }
    
    public List<SelectOption> getMonthsInServiceAssignment(){
        Date first = GetServiceAssignmentStartDate();
        Date last = System.now().date().addmonths(6);
        List<SelectOption> result = new List<SelectOption>();
        for(Date month:getMonthRange(first, last)){
            System.debug(month);
            result.add(new selectOption(month.format(), Datetime.newInstance(month, Time.newInstance(0,0,0,0)).format('MMM yyyy')));
        }
        return result;
    }
    
    public List<SelectOption> getAllowedDurations(){
        return new List<SelectOption>{new SelectOption('1', '1 Month'),
           new SelectOption('3', '3 Months'),
           new SelectOption('6', '6 months'),
           new SelectOption('12', '1 Year')};
    }

    // Be nice to move this into some utility class
    public List<Date> getMonthRange(Date start, Date finish){
             System.debug(start);
            System.debug(finish);
        List<Date> result = new List<Date>();
        for(Date date1= start.toStartOfMonth(); date1 < finish ; date1 = date1.addMonths(1)){
            result.add(date1);
        }
        return result;
    }
    
    public PageReference basesave(){
        try {
            upsert ActionSummary;
        }
        catch (DMLException e) {
            if ( e.getMessage().Contains('DUPLICATE_VALUE')) {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                      'An Action Plan Summary has already been created for this time period'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'An error occurred saving this record. ' + e.getMessage()));
            }
            return null;
        }
        return new PageReference('/' + ActionSummary.id);
    }
    
        public Boolean canEditSummary { get {
    	
     List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :ActionSummary.Id ];

        if (acls.size() > 0) {
            return acls[0].HasEditAccess;
        } else { return false;}	
    	
    } set; }
    
    
    public Boolean canFinalize { get { return (!isUserLevel1or2()); } set; }
    
     // calculation of whether user is allowed to make this change
	private Boolean isUserLevel1or2() {
		
		List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
		for ( PermissionSetAssignment p : userperms ) {
			
			// user can only update if in one of these three permission sets
			if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
				System.Debug('User is level1 or level2.');
				return true;	
			}
		}
		return false;
	}
    
}