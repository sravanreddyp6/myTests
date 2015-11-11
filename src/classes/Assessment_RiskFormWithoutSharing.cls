public without sharing class Assessment_RiskFormWithoutSharing {
   public string glbListSeperator {get{return ';';} set;}
   public string glbItemSeperator {get{return '__';} set;}
   public boolean hasErrorOnFinalize {get; set;}
   public list<string> displayLevel_Required_ResidentialServices = new list<string>();
   public list<string> getdisplayLevel_Required_ResidentialServices(){return displayLevel_Required_ResidentialServices ;}
   public list<string> displayLevel_Required_DayServices = new list<string>();
   public list<string> getdisplayLevel_Required_DayServices (){return displayLevel_Required_DayServices  ;}   

    public List<id> DomainsInScopeIDs = new List<id>();
    public List<id> QuestionsInScopeIDs = new List<id>();
    public List<id> OptionsInScope = new List<id>();
    public List<Assessment_Response__c> CurrentResps = new List<Assessment_Response__c>();
    public List<Assessment_Response__c> getCurrentResps(){ return CurrentResps;}
    
    public Map<id, Assessment_Response__c> mapCurrentResps {get;set;}         
     
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}
    
    public map<id, boolean> mapDomainHasRisk = new map<id, boolean>();
    public map<id, boolean> getmapDomainHasRisk  (){ return mapDomainHasRisk ;}    
    
    public List<Assessment_Domain__c> DomainsInScope = new List<Assessment_Domain__c>();
    public List<Assessment_Domain__c> getDomainsInScope() {
    	return [Select ID,  Name, Description__c, Assessment_Type__c, Header__c,  External_Id__c,
                        (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c , External_Id__c
                                From Question__r 
                                Where ID in :QuestionsInScopeIDs
                                Order By Question_Number__c) 
                From Assessment_Domain__c Where id in :DomainsInScopeIDs Order By Sort_Order__c]; }


    public Assessment__c assessment { get; set; }

    public transient Map<String, Object> assessmentWrapper;
    public Map<String, Object> getAssessmentWrapper() {
    	if (this.assessmentWrapper == null){
	    	Map<String, Object> m = new Map<String, Object>();
	    	updateMapWithRelationshipKeys(m, JSON.serialize(this.assessment), '');
            return m;
    	} else return this.assessmentWrapper;
    }

	private void updateMapWithRelationshipKeys(Map<String, Object> m, String jsonString, String relationshipKey){
	    	m.remove('attributes'); // this is to remove this key, SF adds this when serializing the sObject.
	    	Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
	    	Map<String, Object> newMap = new Map<String, Object>(); 
	    	for(String k : temp.keySet()){
	    		if(k.endsWithIgnoreCase('__r') || k == 'LastModifiedBy') updateMapWithRelationshipKeys(m, JSON.serialize(temp.get(k)), k);
	    		else {
	    			if (String.IsBlank(relationshipKey) ) newMap.put(k, temp.get(k));
	    			else newMap.put(relationshipKey + '.' + k, 	temp.get(k));
	    		}
	    	}
	    	m.putAll(newMap);
	}	
    
    public String recommendedDayServicesStaffingRatio { get; set; }
    public String recommendedDayServicesStaffingRatioOther { get; set; }
    public String recommendedDayServicesStaffingRatioFull { get; set; }
    
    public String levelRequiredDayServices { get; set; }
    public String levelRequiredDayServicesFull { get; set; }
    public String levelRequiredDayServicesSupport { get; set; }
    public String levelRequiredDayServicesSupportOtherInterval { get; set; }
    public String levelRequiredDayServicesWithoutCaregiverDuration { get; set; }
    public String levelRequiredDayServicesWithoutCaregiverInterval { get; set; }
    public String levelRequiredDayServicesSpecificPlan { get; set; }
    
    public String levelRequiredResidential { get; set; }
    public String levelRequiredResidentialFull { get; set; }
    public String levelRequiredResidentialUnsupervisedHome { get; set; }
    public String levelRequiredResidentialUnsupervisedHomeInterval { get; set; }
    public String levelRequiredResidentialUnsupervisedCommunity { get; set; }
    public String levelRequiredResidentialUnsupervisedCommunityInterval { get; set; }
    public String levelRequiredResidentialSpecificPlan { get; set; }
       
    String[] Level_Required_ResidentialServices = new String[]{};
         public String[] getLevel_Required_ResidentialServices  () {
         //string item: Level_Required_ResidentialServices 
            for (Integer item = 0; item < Level_Required_ResidentialServices.size() ; item++){
                    string tmp = Level_Required_ResidentialServices[item].substringAfter(glbItemSeperator);
                    if(Level_Required_ResidentialServices[item].contains('Can be unsupervised in the community for')){
                        
                        if(tmp.contains(' Hours'))
                            {levelRequiredResidentialUnsupervisedCommunityInterval=' Hours'; levelRequiredResidentialUnsupervisedCommunity = tmp.substringBefore(' Hours');}
                        else if(tmp.contains(' Minutes'))
                            {levelRequiredResidentialUnsupervisedCommunityInterval=' Minutes'; levelRequiredResidentialUnsupervisedCommunity = tmp.substringBefore(' Minutes');}
                        Level_Required_ResidentialServices[item] = 'Can be unsupervised in the community for';
                    }
                    else if(Level_Required_ResidentialServices[item].contains('Can be unsupervised at home for')){
                        //string tmp = Level_Required_ResidentialServices[item].substringAfter(glbItemSeperator);
                        if(tmp.contains(' Hours'))
                            {levelRequiredResidentialUnsupervisedHomeInterval=' Hours'; levelRequiredResidentialUnsupervisedHome = tmp.substringBefore(' Hours');}
                        else if(tmp.contains(' Minutes'))
                            {levelRequiredResidentialUnsupervisedHomeInterval=' Minutes'; levelRequiredResidentialUnsupervisedHome = tmp.substringBefore(' Minutes');}                    
                    
                        Level_Required_ResidentialServices[item] = 'Can be unsupervised at home for';
                    }
                    else if(Level_Required_ResidentialServices[item].contains('Specific Plan')){
                        levelRequiredResidentialSpecificPlan =tmp;
                        Level_Required_ResidentialServices[item] = 'Specific Plan';
                    
                    } 
                    else{//str4Level_Required_ResidentialServices  += item + glbListSeperator;
                    }                      
            
            
            }         
         
             return Level_Required_ResidentialServices ;
         }

         public void setLevel_Required_ResidentialServices  (String[] Level_Required_ResidentialServices ) {
            this.Level_Required_ResidentialServices = Level_Required_ResidentialServices ;
        }
        
    String[] Level_Required_DayServices = new String[]{};
        public String[] getLevel_Required_DayServices () {
                for(Integer item = 0; item < Level_Required_DayServices.size(); item++ ){
                    
                        if(Level_Required_DayServices[item].contains('Current level of services required for health and safety supports')){                
                        
                            string tmp = Level_Required_DayServices[item].substringAfter(glbItemSeperator);
                        
                            if(tmp =='Full Day'){levelRequiredDayServicesSupport = 'Full Day';}
                            else if(tmp=='Partial Day'){levelRequiredDayServicesSupport = 'Partial Day';}
                            else{levelRequiredDayServicesSupport = 'Other'; levelRequiredDayServicesSupportOtherInterval = tmp;}
                            Level_Required_DayServices[item] ='Current level of services required for health and safety supports';
                    }
//levelRequiredDayServicesWithoutCaregiverInterval
                    if(Level_Required_DayServices[item].contains('Can be without caregiver for')){
                        string tmp = Level_Required_DayServices[item].substringAfter(glbItemSeperator);
                        if(tmp.contains(' Hours'))
                            {levelRequiredDayServicesWithoutCaregiverInterval=' Hours'; levelRequiredDayServicesWithoutCaregiverDuration = tmp.substringBefore(' Hours');}
                        else if(tmp.contains(' Minutes'))
                            {levelRequiredDayServicesWithoutCaregiverInterval=' Minutes'; levelRequiredDayServicesWithoutCaregiverDuration = tmp.substringBefore(' Minutes');}                    
                        Level_Required_DayServices[item] = 'Can be without caregiver for';
                    
                    }
                    if(Level_Required_DayServices[item].contains('Specific Plan')){
                        string tmp = Level_Required_DayServices[item].substringAfter(glbItemSeperator);
                        
                        levelRequiredDayServicesSpecificPlan = tmp;
                         Level_Required_DayServices[item] = 'Specific Plan';
                    }
                                            
                }        
        
            return Level_Required_DayServices ;
        }
    
        public void setLevel_Required_DayServices (String[] Level_Required_DayServices ) {
            this.Level_Required_DayServices = Level_Required_DayServices ;
        }     
   
    String[] RecDayServicesStaffingRatio= new String[]{};
        public String[] getRecDayServicesStaffingRatio() {
            return RecDayServicesStaffingRatio;
        }
    
        public void setRecDayServicesStaffingRatio(String[] RecDayServicesStaffingRatio) {
            this.RecDayServicesStaffingRatio= RecDayServicesStaffingRatio;
        }    
    
    String[] Staffing_Supervision_Needs= new String[]{};
        public String[] getStaffing_Supervision_Needs() {
            return Staffing_Supervision_Needs;
        }
    
        public void setStaffing_Supervision_Needs(String[] Staffing_Supervision_Needs) {
            this.Staffing_Supervision_Needs= Staffing_Supervision_Needs;
        }      
        
    public boolean editMode{get; set;}
    public string mode{get; set;}
    public List<Assessment__c> AllAsses = new List<Assessment__c>();
    public List<Assessment__c> getAllAsses(){return AllAsses ;}

    public Boolean canEditRisk { get {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :assessment.Id ];
        if (acls.size() > 0) {
            return acls[0].HasEditAccess;
        } else { return false;} 
    } set; }
    
    public Boolean canFinalize { get {
        // do not allow level 1 or 2 to finalize
        return (!isUserLevel1or2()); } set; }
    
    public Boolean staffingRatioInFlavor {
        get {
                return assessment.Admission__r.State__c=='MN';
        }
    }
    public Boolean dayServicesInFlavor {
        get {
                return assessment.Admission__r.State__c=='MN' || assessment.Admission__r.State__c=='IN';
        }
    }
    public Boolean showConfirmationButton {
        get {
            for (Acknowledgment__c c: assessment.Acknowledgments__r) {
                if (c.User__c == UserInfo.getUserId() && assessment.ID == c.Assessment__c) {
                    return false;
                }
            }
            if(assessment.status__c != 'Active Final'){ return false;}
            return true;
        }
    }
    
    public Assessment_RiskFormWithoutSharing(Id assessmentId) {
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Assessment__c').getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
        if (!selectFields.isEmpty()) {
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')) {
                selects = selects.substring(0,selects.lastIndexOf(','));
            }
        }
        String strSQL =  'SELECT ' + selects + ' FROM Assessment__c WHERE Id = \'' + assessmentId + '\'';
        strSQL = strSQL.Replace('SELECT ', 'SELECT Admission__r.Name,Admission__r.State__c, LastModifiedBy.Name, Admission__r.Person_Being_Served__r.Name, ');
        this.assessment = (Assessment__c) Database.query(strSQL)[0];
        
        mode = 'view';
        RecDayServicesStaffingRatio.clear();
        hasErrorOnFinalize = false;
        
        if(assessment.Recommended_Day_Services_Staffing_Ratio__c !=null){
            RecDayServicesStaffingRatio =  assessment.Recommended_Day_Services_Staffing_Ratio__c.split(glbListSeperator);
            // 01/01/14 - adding this line to support the display of staffing ratio in summary mode
            recommendedDayServicesStaffingRatioFull = String.valueOf(RecDayServicesStaffingRatio.size() > 0);
            }
        if(assessment.Staffing_Supervision_Needs__c != null){
            Staffing_Supervision_Needs = assessment.Staffing_Supervision_Needs__c.split(glbListSeperator);
            }
        if(assessment.Services_Required_Level_Day_Services__c != null){ 
            Level_Required_DayServices = assessment.Services_Required_Level_Day_Services__c.split(glbListSeperator);
            displayLevel_Required_DayServices = assessment.Services_Required_Level_Day_Services__c.split(glbListSeperator);
            // 01/01/14 - adding this line to support the display of day services in summary mode
            levelRequiredDayServicesFull = String.valueOf(displayLevel_Required_DayServices.size() > 0);
        }
        if(assessment.Support_Required_Level_Residential__c != null){
            Level_Required_ResidentialServices = assessment.Support_Required_Level_Residential__c.split(glbListSeperator);
            displayLevel_Required_ResidentialServices  = assessment.Support_Required_Level_Residential__c.split(glbListSeperator);
            // 01/01/14 - adding this line to support the display of residential services in summary mode
            levelRequiredResidentialFull = String.valueOf(displayLevel_Required_ResidentialServices.size() > 0);
        }
        
        mapCurrentResps  = new Map<id, Assessment_Response__c>();
        CurrentResps = [Select id, Rating__c, Description_of_Risk__c, Plan_to_reduce_Risk__c, Comment__c, 
                               Assessment_Domain_Result__c, Question__c, Question__r.External_Id__c,  
                               Question__r.Question_Domain__c, Question__r.Question_Title__c 
                          From Assessment_Response__c Where assessment__c = :assessment.id and rating__c = 'Presents a Risk'];
       
        ID idDomId = null;
        for(Assessment_Response__c local: CurrentResps){
            idDomId = local.Question__r.Question_Domain__c;
            DomainsInScopeIDs.Add(idDomId);
            QuestionsInScopeIDs.Add(local.Question__c);
            mapCurrentResps.put(local.Question__c, local);
            
            // calculate whether this domain as a whole has risk
            if (mapDomainHasRisk.containsKey(idDomId) && mapDomainHasRisk.get(idDomId)) {
                continue;
            } else {
                if(local.rating__c != null  &&  local.rating__c.equalsIgnoreCase('presents a risk') ) {
                    mapDomainHasRisk.put(idDomId,true);
                    //system.debug('Putting ' + idDomId + ' into hasrisk list with true');
                } else {
                    mapDomainHasRisk.put(idDomId,false);
                } 
            }
        }
        List<Assessment_Question__c > tmpQ = [Select ID, External_Id__c, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c,  
								                     (Select Name, Score__c, Rating__c, Color__c, Rating_Description__c, Show_These_Fields__c, id
								                        From Assessment_Question_Option__r order By Sort_Order__c)
								               From Assessment_Question__c 
								              Where ID in  :QuestionsInScopeIDs];
        for(Assessment_Question__c local : tmpQ){
                // always show the extra questions - we'll do the show/hide toggle on the front end
                List<String> showFields= new List<String>{'Description_of_Risk__c','Plan_to_reduce_Risk__c'};
                    for(Assessment_Question_Option__c QO : local.Assessment_Question_Option__r ){
                        //QO.Rating__c
                        mapQuestions.put(local.id+QO.Rating__c, showFields) ;      
                    }
                // add the question options for when the radio button is not selected
                mapQuestions.put(local.id, showFields);
        }
    }

    class InputException extends Exception {}
    private void validateHardcodedQuestions() {
        this.validateHardcodedQuestions(false);
    }
    private void validateHardcodedQuestions(Boolean checkRequired) {
        // Validating and processing Recommended Day Services Staffing Ratio section
        /*
        if (recommendedDayServicesStaffingRatio=='Other') {
            if (recommendedDayServicesStaffingRatioOther == '') {
                throw new InputException('Recommended Day Services Staffing Ratio is not provided');
            }
            this.assessment.Recommended_Day_Services_Staffing_Ratio__c = recommendedDayServicesStaffingRatioOther;
        } else {
            this.assessment.Recommended_Day_Services_Staffing_Ratio__c = recommendedDayServicesStaffingRatio;
        }
        */
        
        // Validating and processing Level of Services Required for Day Services section
        if (levelRequiredDayServices=='Specific Plan') {
            if (levelRequiredDayServicesSpecificPlan=='') {
              //  throw new InputException('Specific Plan for Level of Services Required for Day Services is not provided');
            }
            this.assessment.Services_Required_Level_Day_Services__c = levelRequiredDayServicesSpecificPlan;
        } else if (levelRequiredDayServices=='Current level of services required for health and safety supports') {
            String supportDuration = '';
            if (levelRequiredDayServicesSupport=='other') {
                if (levelRequiredDayServicesSupportOtherInterval=='') {
                    throw new InputException('Duration that the current level of services required for healthy and safety support is not provided');
                }
                supportDuration = levelRequiredDayServicesSupportOtherInterval;
            } else {
                if (levelRequiredDayServicesSupport==null) {
                    throw new InputException('Duration that the current level of services required for healthy and safety support is not provided');
                }
                supportDuration = levelRequiredDayServicesSupport;
            }
            this.assessment.Services_Required_Level_Day_Services__c = levelRequiredDayServices + ' ' + supportDuration;
        } else if (levelRequiredDayServices=='Can be without caregiver for') {
            if (levelRequiredDayServicesWithoutCaregiverInterval==null) {
                throw new InputException('Interval for Can be without caregiver is not provided');
            }
            if (levelRequiredDayServicesWithoutCaregiverDuration=='') {
                throw new InputException('Duration for Can be without caregiver is not provided');
            } else if (!isNumber(levelRequiredDayServicesWithoutCaregiverDuration)) {
                throw new InputException('Duration for Can be without caregiver is not a number');
            }
            this.assessment.Services_Required_Level_Day_Services__c = levelRequiredDayServices + ' ' +
                levelRequiredDayServicesWithoutCaregiverDuration + ' ' +
                levelRequiredDayServicesWithoutCaregiverInterval;
        } else {
            this.assessment.Services_Required_Level_Day_Services__c = levelRequiredDayServices;
        }
        // Validating and processing Level of Support Required for Residential Services section
        if (levelRequiredResidential=='Specific Plan') {
            if (levelRequiredResidentialSpecificPlan=='') {
                throw new InputException('Specific Plan for Level of Support Required for Residential Services is not provided');
            }
            this.assessment.Support_Required_Level_Residential__c = levelRequiredResidentialSpecificPlan;
        } else if (levelRequiredResidential=='Can be unsupervised at home for') {
            if (levelRequiredResidentialUnsupervisedHomeInterval==null) {
                throw new InputException('Interval for Can be unsupervised at home is not provided');
            }
            if (levelRequiredResidentialUnsupervisedHome==null) {
                throw new InputException('Duration for Can be unsupervised at home is not provided');
            } else if (!isNumber(levelRequiredResidentialUnsupervisedHome)) {
                throw new InputException('Duration for Can be unsupervised at home is not a number');
            }
            this.assessment.Support_Required_Level_Residential__c = levelRequiredResidential + ' ' +
                levelRequiredResidentialUnsupervisedHome + ' ' +
                levelRequiredResidentialUnsupervisedHomeInterval;
        } else if (levelRequiredResidential=='Can be unsupervised in the community for') {
            if (levelRequiredResidentialUnsupervisedCommunityInterval==null || levelRequiredResidentialUnsupervisedCommunityInterval=='') {
                throw new InputException('Interval for Can be unsupervised in community is not provided');
            }
            if (levelRequiredResidentialUnsupervisedCommunity=='') {
                throw new InputException('Duration for Can be unsupervised in community is not provided');
            } else if (!isNumber(levelRequiredResidentialUnsupervisedCommunity)) {
                throw new InputException('Duration for Can be unsupervised in community is not a number');
            }
            this.assessment.Support_Required_Level_Residential__c = levelRequiredResidential + ' ' +
                levelRequiredResidentialUnsupervisedCommunity + ' ' +
                levelRequiredResidentialUnsupervisedCommunityInterval;
        } else {
            this.assessment.Support_Required_Level_Residential__c = levelRequiredResidential;
        }
        System.debug('checkReq: ' + checkRequired);
        System.debug('this.staffingRatioInFlavor: ' + this.staffingRatioInFlavor);
        System.debug('Recommended_Day_Services_Staffing_Ratio__c: ' + assessment.Recommended_Day_Services_Staffing_Ratio__c);
        System.debug('Support_Required_Level_Residential__c: ' + assessment.Support_Required_Level_Residential__c);
       /*
        if (checkRequired && ((this.staffingRatioInFlavor && this.assessment.Recommended_Day_Services_Staffing_Ratio__c == null) ||
            this.assessment.Support_Required_Level_Residential__c == null ||
            (this.dayServicesInFlavor && this.assessment.Services_Required_Level_Day_Services__c == null) ||
            this.assessment.Staffing_Supervision_Needs__c == null)) {
                throw new InputException('You have not filled out all the questions in this form!');
        }
        */
    }
        
    private Boolean isNumber(String input) {
        // Check whether a String is a Number or not
        try {
            Decimal.valueOf(input);
            return True;
        } catch (System.TypeException ex) {
            return False;
        }
    }

    /**
     * Notify people who have confirmed reading older version of this assessment
     * when the new version is finalized.
     */
    public void notifyNewAssessmentVersion() {
        System.debug('Start notifying people');
        if (this.assessment.Previous__c==null || this.assessment.Status__c!='Active Final') {
                System.debug('Conditions not met! Return now.');
                System.debug('Previous: ' + this.assessment.Previous__c);
                System.debug('Status: ' + this.assessment.Status__c);
            return;
        }
        System.debug('Conditions met to notify people');
        // EB-551 - 2015-10-14 - only get active users or an error will be thrown
        User[] usersToNotify = [
           SELECT ID, ContactID FROM User
           WHERE ID IN (SELECT User__c FROM Acknowledgment__c WHERE Assessment__c=:this.assessment.Previous__c and user__r.isactive = true)
        ];
        System.debug('Users to notify: ' + usersToNotify);
        List<Task> tasks = new List<Task>();
        for (User userToNotify: usersToNotify) {
            tasks.add(new Task(
                WhatId = this.assessment.ID,
                OwnerId = userToNotify.ID,
                ActivityDate = this.assessment.Approval_Date__c,
                Subject = 'Assessment Confirmation',
                Description = 'Please confirm that you have read the new version of the assessment',
                WhoId = this.assessment.Admission__r.Person_Being_Served__c
            ));
        }
        System.debug('Tasks to create: ' + tasks);
        insert tasks;
    }
    
    public boolean getCanReviseAssess(){
        boolean canit = false;
        List<Assessment__c> newestAssessment = [
            SELECT ID, Status__c FROM Assessment__c
            WHERE Admission__c = :assessment.Admission__c 
              AND Assessment_Type__c = :assessment.Assessment_Type__c
            ORDER BY CreatedDate DESC 
        ];
        
        for(Assessment__c a : newestAssessment ){
            if (assessment.Id==a.Id && a.Status__c=='Active Final') {
                    canit = true;
            }
            if(a.Status__c =='Inactive Draft'){ return false;}
        }
        return canit;
    
    }
    
    // calculation of whether user is allowed to make this change
    private Boolean isUserLevel1or2() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];
         
        for ( PermissionSetAssignment p : userperms ) {

            //System.Debug( p.permissionset.name );
                        
            // user can only update if in one of these three permission sets
            if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
                System.Debug('User is level1 or level2.');
                return true;    
            }
        }
        return false;
    }
}