public without sharing class Im_ResponsePlan {
	public String ackActivityId {get; set;}
	public Im_Incident__c incident {get; set;}
	private Id im_incident {get; set;}

	public Evaluation_Response__c responsePlan {get; set;}
    public list<Evaluation_Response__c> respPlanActivities {get; set;}

	public boolean editMode {get; set;}

    public Im_ResponsePlan(){
        String im_incident = ApexPages.currentPage().getParameters().get('Id');
        if (!(im_incident instanceof Id)) throw new CustomException('Missing Incident or Invalid Incident ID.');
        this.im_incident = Id.ValueOf(im_incident);
        list<Evaluation_Response__c> evalResps = [select id, Start_Date_Time__c, End_Date_Time__c, Disregard__c, TMN_User__c, TMN_User__r.Name
				                                   from Evaluation_Response__c
				                                  where IncidentResponsePlan__c = : im_incident and RecordType.Name = 'Im_IncidentResponsePlan'];
        if (evalResps.size() == 1 ){
            this.responsePlan = evalResps[0];
            this.editMode = false;
        } else {
        	this.responsePlan = new Evaluation_Response__c(Start_Date_Time__c = system.now(), End_Date_Time__c = system.now(), Disregard__c = false
                                                           , TMN_User__c = null, IncidentResponsePlan__c = this.im_incident,
                                                           RecordTypeId = Utility.getEvaluationResponseRecordType('Im_IncidentResponsePlan'));
            this.editMode = true;
        }

        String strSQL =  'SELECT Id, OwnerId, Name, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, Reported_By__c, Reported_By__r.name, ';
               strSQL += 'Date_Documented__c, Where_did_it_happen__c, When_did_it_happen__c, When_was_the_Supervisor_notified__c, Supervisor__c, Supervisor_Name__c, Service_Location__c, ';
               strSQL += 'What_Happened__c, ReportedEvent__c, Status__c, Notified_Staff__c, Identifier__c, Supervisor_for_Location__c,Supervisor_for_Location__r.Name, Agencies_notified__c  FROM Im_Incident__c WHERE Id = \'' + this.im_incident + '\'';
        incident = (Im_Incident__c) Database.query(strSQL)[0];
        refreshRpActivites();
    }


	public pageReference createFirstActivity(){
        if (this.respPlanActivities.size() == 0) return addRespPlanActivity();
        return null;
	}

    class CustomException extends Exception{ }

    @RemoteAction public static list<MyRemoteMethods.SelOption> getResponsePlanManagers(String params){
        return MyRemoteMethods.getResponsePlanManagers(params);
    }

    public pageReference addRespPlanActivity(){
    	Evaluation_Response__c respPlanActivity = new Evaluation_Response__c(Im_Rp_ActivityCategory__c = null, Im_Rp_ActivityActionNeeded__c=null, Im_Rp_ActivityAssigned_To__c=null,
                                                            Date__c = system.today(),
                                                            Im_Rp_ActivityRequiresAck__c=false,
                                                            Status__c = 'In Progress',
                                                            Narrative_Note__c=null,
                                                            IncidentResponsePlan__c = this.im_incident,
                                                            RecordTypeId = Utility.getEvaluationResponseRecordType('Im_ResponsePlanActivities'));
        insert respPlanActivity;
        this.respPlanActivities.add(respPlanActivity);
        populateAssignedTos();
        return null;
    }

    public pageReference saveRespPlan(){
    	if (! validateRespPlan()) return null;
    	editMode = false;
    	upsert this.responsePlan;
    	this.responsePlan = [select id, Start_Date_Time__c, End_Date_Time__c, Disregard__c, TMN_User__c, TMN_User__r.Name
                               from Evaluation_Response__c
                              where IncidentResponsePlan__c = : im_incident and RecordType.Name = 'Im_IncidentResponsePlan' limit 1];
        upsert this.respPlanActivities;
        refreshRpActivites();
    	return null;
    }

    private boolean validateRespPlan(){
        if ( this.responsePlan.Disregard__c && this.respPlanActivities.size() > 0) {
        	for (Evaluation_Response__c act : this.respPlanActivities){
        		if (!act.Status__c.equalsIgnoreCase('Completed') && !act.Status__c.equalsIgnoreCase('Cancelled')){
                    this.responsePlan.addError('Action cannot be completed because there are active response plan activities associated to the incident.');
	        		return false;
	        		break;
        		}
        	}
            return true;
        }

    	// Plan Start Date/Time - Date equal to today or greater
    	if ( this.responsePlan.id == null && this.responsePlan.Start_Date_Time__c.date() < system.today() ) {
    		this.responsePlan.addError('Response Plan start date cannot be in past. Please correct and try again.');
    		return false;
    	}
        if (this.responsePlan.Start_Date_Time__c >= this.responsePlan.End_Date_Time__c ) {
            this.responsePlan.addError('Response Plan Target Date/Time must be after the Plan Start Date/Time. Please correct and try again.');
            return false;
        }

        //Required fields for the activities
		//Im_Rp_ActivityCategory__c, Im_Rp_ActivityActionNeeded__c, Im_Rp_ActivityAssigned_To__c, Date__c, Status__c
        for (integer i=0 ; i < this.respPlanActivities.size(); i++) {
                Evaluation_Response__c act = this.respPlanActivities.get(i);

                if (String.IsBlank(act.Im_Rp_ActivityCategory__c)){
	                act.addError('Activity #' + (i+1).format() + ' "Response Plan Category" cannot be empty. Please select one and try again.');
	                return false;
	                break;
                }
                if (String.IsBlank(act.Im_Rp_ActivityActionNeeded__c)){
                    act.addError('Activity #' + (i+1).format() + ' "Action Needed/Response Taken" cannot be empty. Please select one and try again.');
                    return false;
                    break;
                }
                if (String.IsBlank(act.Im_Rp_ActivityAssigned_To__c)){
                    act.addError('Activity #' + (i+1).format() + ' must be "Assigned To" at least one person.');
                    return false;
                    break;
                }
                if ((act.Date__c == null) || (act.Date__c > this.responsePlan.End_Date_Time__c.date() ) ){
                    act.addError('Activity #' + (i+1).format() + ' "Target Date" cannot be greater than the Target End Date of the overall plan. Please correct and try again.');
                    return false;
                    break;
                }
                if (String.IsBlank(act.Status__c)){
                    act.addError('Activity #' + (i+1).format() + ' "Status" cannot be empty. Please select one and try again.');
                    return false;
                    break;
                }
        }

    	return true;
    }

    public map<id,map<id,String>> activityAssignedTo {get;set;}
    private void populateAssignedTos(){
        set<string> assignedTo= new set<String>();
        activityAssignedTo = new map<id,map<id,String>>();
        for(Evaluation_Response__c activity : this.respPlanActivities){
            if (String.IsNotBlank(activity.Im_Rp_ActivityAssigned_To__c))
                assignedTo.addAll(activity.Im_Rp_ActivityAssigned_To__c.split(','));
            activityAssignedTo.put(activity.id, new map<id,String>());
        }
        map<id,TMN_User__c> usr = new map<id,TMN_User__c>([select id, name from TMN_User__c where id IN : assignedTo]);
        for(Evaluation_Response__c activity : this.respPlanActivities){
        	if (String.IsBlank(activity.Im_Rp_ActivityAssigned_To__c)) continue;
            for(String k : activity.Im_Rp_ActivityAssigned_To__c.split(',')){
                if(! (k instanceof Id)) continue;
                Id key = Id.valueOf(k);
                activityAssignedTo.get(activity.id).put(key,usr.get(key).name);
            }
        }
    }
    private void refreshRpActivites(){
        this.respPlanActivities = [select Id, Im_Rp_ActivityCategory__c, Im_Rp_ActivityActionNeeded__c, Im_Rp_ActivityAssigned_To__c,
                                          Date__c, Im_Rp_ActivityRequiresAck__c, Status__c, Narrative_Note__c, IncidentResponsePlan__c
                                     from Evaluation_Response__c where IncidentResponsePlan__c = : im_incident
                                      and RecordType.Name = 'Im_ResponsePlanActivities' order by createdDate];
        populateAssignedTos();
        populateAllAcks();
    }

    public pageReference editRespPlan(){
        editMode = true;
        return null;
    }

    public pageReference cancel(){
        return new PageReference('/' + im_incident);
    }

    public pageReference ackRespPlanActivity(){
        Acknowledgment__c ack = new Acknowledgment__c (Im_RespPlanActivity__c=ackActivityId, User__c=userInfo.getUserId());
        insert ack;
        populateAllAcks();
    	return null;
    }

    public transient map<id, list<Acknowledgment__c>> allAcks {get;set;}
    public map<id, list<Acknowledgment__c>> populateAllAcks() {
        if (this.allAcks == null){
        	this.allAcks = new map<id, list<Acknowledgment__c>>();
        	for (Evaluation_Response__c act : this.respPlanActivities) {
        		allAcks.put(act.id, new list<Acknowledgment__c>());
        	}
            for (Acknowledgment__c ack : [Select id, Im_RespPlanActivity__c, User__c, CreatedDate
                                            from Acknowledgment__c
                                           where Im_RespPlanActivity__c in :allAcks.keyset() order by CreatedDate desc]) {
            	allAcks.get(ack.Im_RespPlanActivity__c).add(ack);
            }
        }
        return this.allAcks;
    }

    @InvocableMethod(label='Im_CreateActivityTasks' description='Create tasks for the tmn users that is assigned an incident response plan activity.')
    public static void createActivityTasks(list<Id> activities) {
        // delete all the tasks for these activities
        delete [select id from task where whatid IN : activities];

        map<id, Evaluation_Response__c> respPlanActivities = new map<id, Evaluation_Response__c>([select Id, Im_Rp_ActivityCategory__c, Im_Rp_ActivityActionNeeded__c, Im_Rp_ActivityAssigned_To__c,
						                                          Date__c, Im_Rp_ActivityRequiresAck__c, Status__c, Narrative_Note__c
						                                     from Evaluation_Response__c where id IN : activities and Status__c NOT IN ('Completed', 'Cancelled')]);
        set<string> assignedTo = new set<String>();
        for(Evaluation_Response__c activity : respPlanActivities.values()){
            if (String.IsNotBlank(activity.Im_Rp_ActivityAssigned_To__c)) assignedTo.addAll(activity.Im_Rp_ActivityAssigned_To__c.split(','));
        }

        map<id,TMN_User__c> usr = new map<id,TMN_User__c>([select id, name, Salesforce_User_Account__c from TMN_User__c where id IN : assignedTo and Salesforce_User_Account__c != null]);
        list<task> newtasks= new list<task>();
        for(Evaluation_Response__c activity : respPlanActivities.values()){
            if (String.IsBlank(activity.Im_Rp_ActivityAssigned_To__c)) continue;

            for(String k : activity.Im_Rp_ActivityAssigned_To__c.split(',')){
                if(! (k instanceof Id)) continue;
                Id key = Id.valueOf(k);

                task tmpTask = new task();
                tmpTask.whatid = activity.id;
                tmptask.OwnerId = usr.get(k).Salesforce_User_Account__c;
                tmpTask.Subject = 'Incident Response Plan Activity';
                tmpTask.Description = 'Please acknowledge that you have completed the activity for ' + activity.Im_Rp_ActivityCategory__c + ' and Action Needed/Response Taken: ' + activity.Im_Rp_ActivityActionNeeded__c;
                newtasks.add(tmpTask);
            }
        }
        insert newtasks;

    }

}