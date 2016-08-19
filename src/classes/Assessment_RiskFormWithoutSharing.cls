public without sharing class Assessment_RiskFormWithoutSharing extends Assessment_AbstractForm implements DSP_AssessmentResponseType{
    public list<string> displayLevel_Required_ResidentialServices = new list<string>();
    public list<string> getdisplayLevel_Required_ResidentialServices(){return displayLevel_Required_ResidentialServices ;}
    public list<string> displayLevel_Required_DayServices = new list<string>();
    public list<string> getdisplayLevel_Required_DayServices (){return displayLevel_Required_DayServices  ;}   
    
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}
    
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
    
    String[] RecDayServicesStaffingRatio= new String[]{};
        public String[] getRecDayServicesStaffingRatio() {
            return RecDayServicesStaffingRatio;
        }    
    
    String[] Staffing_Supervision_Needs= new String[]{};
        public String[] getStaffing_Supervision_Needs() {
            return Staffing_Supervision_Needs;
        }      
    
    
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
    
    public Assessment_RiskFormWithoutSharing(Id assessmentId) {
        super(assessmentId);
        
        RecDayServicesStaffingRatio.clear();
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
        
        
        String strSQLResp =  'SELECT ' + String.join(selectFieldsAssessResp, ',') + ' FROM Assessment_Response__c WHERE assessment__c = \'' + assessment.id + '\' and rating__c = \'Presents a Risk\'';
        List<Assessment_Response__c> CurrentResps = (List<Assessment_Response__c>) Database.query(strSQLResp);
        for(Assessment_Response__c local: CurrentResps){
            DomainsInScopeIDs.Add(local.Question__r.Question_Domain__c);
            QuestionsInScopeIDs.Add(local.Question__c);
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
    public override Map<id, Map<string,Object>> getMapCurrentResps(){
        if (this.mapCurrentResps == null) {
            this.mapCurrentResps = new Map<id, Map<String,Object>>();
            String strSQLResp =  'SELECT ' + String.join(selectFieldsAssessResp, ',') + ' FROM Assessment_Response__c WHERE assessment__c = \'' + assessment.id + '\' and rating__c = \'Presents a Risk\'';
            List<Assessment_Response__c> CurrentResps = (List<Assessment_Response__c>) Database.query(strSQLResp);
            for (Assessment_Response__c response : CurrentResps){
                Map<String, Object> m = new Map<String, Object>();
                for(String s : selectFieldsAssessResp){
                    m.put(s,'');
                }
                updateMapWithRelationshipKeys(m, JSON.serialize(response), '');
                mapCurrentResps.put(response.Question__c, m);
            }
        } 
        return this.mapCurrentResps;
    }
}