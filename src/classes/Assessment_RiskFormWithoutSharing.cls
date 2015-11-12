public without sharing class Assessment_RiskFormWithoutSharing {
   public list<string> selectFields = new list<string>();

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
	    	for(String s : selectFields){
	    		m.put(s,'');
	    	}
	    	updateMapWithRelationshipKeys(m, JSON.serialize(this.assessment), '');
            return m;
    	} else return this.assessmentWrapper;
    }

	private void updateMapWithRelationshipKeys(Map<String, Object> m, String jsonString, String relationshipKey){
	    	Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
	    	Map<String, Object> newMap = new Map<String, Object>(); 
	    	for(String k : temp.keySet()){
	    		if(k.endsWithIgnoreCase('__r') || k == 'LastModifiedBy' || k == 'CreatedBy') updateMapWithRelationshipKeys(m, JSON.serialize(temp.get(k)), k);
	    		else {
	    			if (String.IsBlank(relationshipKey) ) newMap.put(k, temp.get(k));
	    			else newMap.put(relationshipKey + '.' + k, 	temp.get(k));
	    		}
	    	}
	    	m.putAll(newMap);
	    	m.remove(String.IsBlank(relationshipKey) ? 'attributes' : relationshipKey + '.attributes'); // this is to remove this key, SF adds this when serializing the sObject.
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
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Assessment__c').getDescribe().Fields.getMap();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
        selectFields.addAll(new List<String>{ 'Admission__r.Name', 'Admission__r.State__c', 'LastModifiedBy.Name', 'CreatedBy.Name', 'Approved_By__r.Name', 'Admission__r.Person_Being_Served__r.Name'});
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Assessment__c WHERE Id = \'' + assessmentId + '\'';
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
    private Boolean isNumber(String input) {
        // Check whether a String is a Number or not
        try {
            Decimal.valueOf(input);
            return True;
        } catch (System.TypeException ex) {
            return False;
        }
    }
}