public with sharing class Assessment_RiskForm {
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
     
    public Map<id, List<SelectOption>> mapOptions = new Map<id, List<SelectOption>>();
    public Map<id, List<SelectOption>> getMapOptions(){return mapOptions ;}
    string assessID = ApexPages.currentPage().getParameters().get('id');
    public string thetest{get;set;}
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}
    
    public map<id, boolean> mapDomainHasRisk = new map<id, boolean>();
    public map<id, boolean> getmapDomainHasRisk  (){ return mapDomainHasRisk ;}    
    
    Public List<Assessment_Domain__c> DomainsInScope = new List<Assessment_Domain__c>();
    Public List<Assessment_Domain__c> getDomainsInScope() {return DomainsInScope;}


    public Assessment__c assessment { get; set; }
    //dang page
    public ApexPages.standardController stdController;
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
public PageReference testForCans() {
    if(assessment.Assessment_Type__r.name == 'CANS'){
        PageReference ref =  new PageReference('/apex/AssessmentView?id='+this.assessment.id);
            
            return ref;
       }
       if (assessment.type__c == 'FAD'){
           PageReference ref =  new PageReference('/apex/Assessment_FAD_Form?id='+this.assessment.id);
           return ref;
       
       }     
            return null;

}    
    public List<SelectOption> getSOLevel_Required_ResidentialServices  () {
        List<SelectOption> options = new List<SelectOption>();
        //string item: Level_Required_DayServices options.add(new SelectOption(Level_Required_DayServices[item],'Current level of services required for health and safety supports'));
        options.add(new SelectOption('Current level of services required for health and safety supports','Current level of services required for health and safety supports'));  
        options.add(new SelectOption('Can be without caregiver for','Can be without caregiver for'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Specific Plan','Specific Plan (Identify in detail any special arrangements which would need to be implemented in order for person to remain alone or unsupervised or identify where specific plan is located)'));                      
            return options;
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
    public List<SelectOption> getSOLevel_Required_DayServices () {
        List<SelectOption> options = new List<SelectOption>();
        //string item: Level_Required_DayServices options.add(new SelectOption(Level_Required_DayServices[item],'Current level of services required for health and safety supports'));
        options.add(new SelectOption('Current level of services required for health and safety supports','Current level of services required for health and safety supports'));  
        options.add(new SelectOption('Can be without caregiver for','Can be without caregiver for'));
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Specific Plan','Specific Plan (Identify in detail any special arrangements which would need to be implemented in order for person to remain alone or unsupervised or identify where specific plan is located)'));                      
            return options;
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
        
        
    public List<SelectOption> getSOrecommendedDayServicesStaffingRatio() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1 to 4','1 to 4'));
        options.add(new SelectOption('1 to 6','1 to 6'));
        options.add(new SelectOption('1 to 8','1 to 8'));
        
        boolean hadOther = false;
        for(string item: RecDayServicesStaffingRatio){
            
            if(item.contains('Other')){
                //string tmp;
                hadOther = true;
                recommendedDayServicesStaffingRatioOther = item.remove('Other').remove(glbItemSeperator);
                options.add(new SelectOption(item,'Other'));
            } 
  
        
        }
            
            if(!hadOther ){
                options.add(new SelectOption('Other','Other'));
            }            
            
            
            return options;
        }
    public boolean editMode{get; set;}
    public string mode{get; set;}
    public List<Assessment__c> AllAsses = new List<Assessment__c>();
    public List<Assessment__c> getAllAsses(){return AllAsses ;}

  //  public List<String> lstRecDayServicesStaffingRatio {get; set;}
  //  public List<String> getlstRecDayServicesStaffingRatio(){return lstRecDayServicesStaffingRatio ;}
    
    
    

    
    public Boolean canEditRisk { get {
        
     List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :assessment.Id ];

        if (acls.size() > 0) {
            return acls[0].HasEditAccess;
        } else { return false;} 
        
    } set; }
    
    public Boolean canFinalize { get {
        // do not allow level 1 or 2 to finalize
        return (!isUserLevel1or2());
        }
        set;
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
    
    public PageReference myEdit() {
    
        mode = 'edit';
        return null;
    
    }    
    
    public Assessment_RiskForm(ApexPages.StandardController controller) {

        this.assessment = (Assessment__c) controller.getRecord();
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
            System.Debug('display level required res: ' + displayLevel_Required_ResidentialServices + ', size: ' + String.valueOf(displayLevel_Required_ResidentialServices.size()));
        }
        
        
        
        
        if(ApexPages.currentPage().getParameters().get('summary') == '1')
            { mode = 'summary';  }
            
        if(ApexPages.currentPage().getParameters().get('new') == '1')
            { mode = 'edit';  }            
        
        if (assessment.id == null)
            {mode='edit';}
        mapCurrentResps  = new Map<id, Assessment_Response__c>();
        
        CurrentResps = [Select id, Rating__c, Description_of_Risk__c, Plan_to_reduce_Risk__c, Assessment_Domain_Result__c, Question__c,  Question__r.Question_Domain__c, Question__r.Question_Title__c From Assessment_Response__c Where assessment__c = :assessment.id];
       // system.debug(currentresps);
       
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
        
        List<Assessment_Question__c > tmpQ = [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c,  
                        (Select 
                                Name, Score__c, Rating__c, Color__c, Rating_Description__c, Show_These_Fields__c, id
                                From Assessment_Question_Option__r 
                                Order By Sort_Order__c)  
                From Assessment_Question__c 
                Where ID in  :QuestionsInScopeIDs];
        
            for(Assessment_Question__c local : tmpQ){
                List<SelectOption> tmpSO = new List<SelectOption>();
                
                // always show the extra questions - we'll do the show/hide toggle on the front end
                List<String> showFields= new List<String>{'Description_of_Risk__c','Plan_to_reduce_Risk__c'};
                    for(Assessment_Question_Option__c QO : local.Assessment_Question_Option__r ){
                    
                        //QO.Rating__c
                        tmpSO.ADD(new SelectOption(QO.Rating__c, ''));       
                        
                        //system.debug('here'+QO.id);
                        //if(QO.Show_These_Fields__c == null){QO.Show_These_Fields__c ='false';}
                        //showFields = QO.Show_These_Fields__c.split(',');
                        //showFields={'Description_of_Risk__c','Plan_to_reduce_Risk__c'};
                        
                        
                        mapQuestions.put(local.id+QO.Rating__c, showFields) ;      
                          
                    }
                    // add the question options for when the radio button is not selected
                    mapQuestions.put(local.id, showFields);
                mapOptions.Put(local.id, tmpSO);
                       
            
            }
            system.debug(mapquestions);
            
            DomainsInScope= [Select ID,  Name, Description__c, Assessment_Type__c, Header__c,  
                        (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c 
                                From Question__r 
                                Where ID in :QuestionsInScopeIDs
                                Order By Question_Number__c) 
                From Assessment_Domain__c Where id in :DomainsInScopeIDs Order By Sort_Order__c];
            
        // Processing the ratio
        /*
        String ratio = this.assessment.Recommended_Day_Services_Staffing_Ratio__c;
        if (ratio!= null && ratio!='1 to 4' && ratio!='1 to 6' && ratio!='1 to 8') {
            recommendedDayServicesStaffingRatio = 'Other';
            recommendedDayServicesStaffingRatioOther = ratio;
            recommendedDayServicesStaffingRatioFull = recommendedDayServicesStaffingRatio + ' ' + ratio; 
        } else {
            recommendedDayServicesStaffingRatio = ratio;
            recommendedDayServicesStaffingRatioFull = ratio;
        }
        */
        // Processing Level of Services Required for Day Services
        /*
        Boolean showSpecificPlan = false;
        String dayService = this.assessment.Services_Required_Level_Day_Services__c;
        if (dayService==null) dayService = '';
        if (dayService.indexOf('Current level of services required for health and safety supports')!=-1) {
            levelRequiredDayServices = 'Current level of services required for health and safety supports';
            String supportInterval = dayService.remove('Current level of services required for health and safety supports ');
            if (supportInterval=='full day' || supportInterval=='partial day') {
                levelRequiredDayServicesSupport = supportInterval;
            } else {
                levelRequiredDayServicesSupport = 'other';
                levelRequiredDayServicesSupportOtherInterval = supportInterval;
            }
        } else if (dayService.indexOf('Can be without caregiver for')!=-1) {
            String caregiverString = dayService.remove('Can be without caregiver for ');
            String caregiverDuration = caregiverString.split(' ')[0];
            String caregiverInterval = caregiverString.split(' ')[1];
            if ((caregiverInterval!=' Minutes' && caregiverInterval!=' Hours') ||
                !isNumber(caregiverDuration)) {
                showSpecificPlan = true;
            } else {
                levelRequiredDayServices = 'Can be without caregiver for';
                levelRequiredDayServicesWithoutCaregiverDuration = caregiverDuration;
                levelRequiredDayServicesWithoutCaregiverInterval = caregiverInterval;
            }
        } else if (dayService == 'Other') {
            levelRequiredDayServices = 'Other';
        } else if (dayService != null && dayService != '') {
            showSpecificPlan = true;
        }
        if (showSpecificPlan) {
            levelRequiredDayServices = 'Specific Plan';
            levelRequiredDayServicesSpecificPlan = dayService;
            levelRequiredDayServicesFull = levelRequiredDayServices + ': ' + levelRequiredDayServicesSpecificPlan;
        } else {
            levelRequiredDayServicesFull = dayService;
        }
        */
        // Processing Level of Support Required for Residential Services
        
        /*
        showSpecificPlan = false;
        String residentialService = this.assessment.Support_Required_Level_Residential__c;
        if (residentialService==null) residentialService = '';
        if (residentialService=='Support person on premises at all times when individual is home') {
            levelRequiredResidential = residentialService;
        } else if (residentialService.indexOf('Can be unsupervised at home for')!=-1) {
            String homeUnsupervisedString = residentialService.remove('Can be unsupervised at home for ');
            String homeUnsupervisedDuration = homeUnsupervisedString.split(' ')[0];
            String homeUnsupervisedInterval = homeUnsupervisedString.split(' ')[1];
            if ((homeUnsupervisedInterval!=' Minutes' && homeUnsupervisedInterval!=' Hours') ||
                !isNumber(homeUnsupervisedDuration)) {
                showSpecificPlan = true;
            } else {
                levelRequiredResidential = 'Can be unsupervised at home for';
                levelRequiredResidentialUnsupervisedHome = homeUnsupervisedDuration;
                levelRequiredResidentialUnsupervisedHomeInterval = homeUnsupervisedInterval;
            }
        } else if (residentialService.indexOf('Can be unsupervised in the community for')!=-1) {
            String communityUnsupervisedString = residentialService.remove('Can be unsupervised in the community for ');
            String communityUnsupervisedDuration = communityUnsupervisedString.split(' ')[0];
            String communityUnsupervisedInterval = communityUnsupervisedString.split(' ')[1];
            if ((communityUnsupervisedInterval!=' Minutes' && communityUnsupervisedInterval!=' Hours') ||
                !isNumber(communityUnsupervisedDuration)) {
                showSpecificPlan = true;
            } else {
                levelRequiredResidential = 'Can be unsupervised in the community for';
                levelRequiredResidentialUnsupervisedCommunity = communityUnsupervisedDuration;
                levelRequiredResidentialUnsupervisedCommunityInterval = communityUnsupervisedInterval;
            }
        } else if (residentialService != null && residentialService != '') {
            showSpecificPlan = true;
        }
        if (showSpecificPlan) {
            levelRequiredResidential = 'Specific Plan';
            levelRequiredResidentialSpecificPlan = residentialService;
            levelRequiredResidentialFull = levelRequiredResidential + ': ' + levelRequiredResidentialSpecificPlan;
        } else {
            levelRequiredResidentialFull = residentialService;
        }
        
        */
    }

   
    public PageReference myConfirm(){ 
        try{
            Acknowledgment__c confirmRec = new Acknowledgment__c(Assessment__c = assessment.id, User__c = UserInfo.getUserId());
            insert confirmRec;
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
        //ctr.save();
        return ctr.view();   
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
        
             
    }
    
    public PageReference myCancel(){ 
        //used only on new form
        try{
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
            assessment.Delete_Assessment__c =true;            
            ctr.save();
            PageReference ref =  new PageReference('/'+this.assessment.admission__c);
            
            return ref; 
              
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
        
             
    }    
    
    public PageReference mySave(){ 
        List<Assessment_Response__c> tmpRes = new List<Assessment_Response__c>();
        tmpRes = mapCurrentResps.values();
        boolean hasAnError = false;
        //clear out any values that have been hidden
        for(Assessment_Response__c local : tmpRes){
            if(local.Rating__c != null && !local.Rating__c.equalsIgnoreCase('presents a risk')){
                local.Description_of_Risk__c = '';
                local.Plan_to_reduce_Risk__c = '';
            
            }        
        }
 
        try {
      
        
        
        
            this.validateHardcodedQuestions();
        } catch (InputException ex) {
                ApexPages.addMessages(ex);
                return null;
        }
        // Without initializing a new stdcontroller, sometimes the controller
        // refuses to save        
        try{
            //1
            string str4RecDayServ = '';
            for(string item: RecDayServicesStaffingRatio){                
                if(item.contains('Other')){
                    
                    if(recommendedDayServicesStaffingRatioOther ==null || recommendedDayServicesStaffingRatioOther =='' ){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                            'Recommended Day Services Staffing Ratio is Other not provided');
                            ApexPages.addMessage(myMsg);  
                            hasAnError = true; 
                    }
                    str4RecDayServ += 'Other' + glbItemSeperator + recommendedDayServicesStaffingRatioOther ;
                    
                }
                else{str4RecDayServ +=  item;}
                str4RecDayServ += glbListSeperator;            
            }
            //2
            string str4Staffing_Supervision_Needs = '';            
            for(string item : Staffing_Supervision_Needs ){str4Staffing_Supervision_Needs +=  item + glbListSeperator;}


            //3
            string str4Level_Required_DayServices = ''; 
            
            for(string item : Level_Required_DayServices){
                
                    if(item.contains('Current level of services required for health and safety supports')){
                       // string tmp = item.substringAfter(glbItemSeperator); 
                        if(levelRequiredDayServicesSupport =='' || levelRequiredDayServicesSupport ==null  ){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Duration that the current level of services required for healthy and safety support is not provided');
                                ApexPages.addMessage(myMsg);  
                                hasAnError = true;   
                        }
                        if(levelRequiredDayServicesSupport =='Full Day'){str4Level_Required_DayServices  += item + glbItemSeperator + 'Full Day'+ glbListSeperator;}
                        else if(levelRequiredDayServicesSupport =='Partial Day'){str4Level_Required_DayServices  += item  + glbItemSeperator + 'Partial Day'+ glbListSeperator;}
                        else{
                            if(levelRequiredDayServicesSupportOtherInterval =='' || levelRequiredDayServicesSupportOtherInterval==null){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                    'Duration that the current level of services required for healthy and safety support is not provided');
                                    ApexPages.addMessage(myMsg); 
                                    hasAnError = true;          
                            
                            }
                            str4Level_Required_DayServices  += item + glbItemSeperator + levelRequiredDayServicesSupportOtherInterval+ glbListSeperator;
                        }
                        
                    }
                    else if(item.contains('Can be without caregiver for')){
                        if(levelRequiredDayServicesWithoutCaregiverDuration =='' || levelRequiredDayServicesWithoutCaregiverInterval==''){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                    'Duration for Can be without caregiver is not provided');
                                    ApexPages.addMessage(myMsg);  
                                    hasAnError = true;   
                        
                        }
                    
                        str4Level_Required_DayServices  += item;
                        str4Level_Required_DayServices  += glbItemSeperator +levelRequiredDayServicesWithoutCaregiverDuration+ levelRequiredDayServicesWithoutCaregiverInterval;
                        str4Level_Required_DayServices  += glbListSeperator;
                    }
                    else if(item.contains('Specific Plan')){
                        //
                        if(levelRequiredDayServicesSpecificPlan ==''){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Specific Plan for Level of Services Required for Day Services is not provided');
                                ApexPages.addMessage(myMsg); 
                                hasAnError = true;                                              
                        }
                        str4Level_Required_DayServices  += item + glbItemSeperator + levelRequiredDayServicesSpecificPlan + glbListSeperator;
                    } 
                    else{str4Level_Required_DayServices  += item + glbListSeperator;}                
                
            }
            
            
            
            
            //4
            string str4Level_Required_ResidentialServices  = '';
            for (string item: Level_Required_ResidentialServices ){
                    if(item.contains('Can be unsupervised in the community for')){
                        if(levelRequiredResidentialUnsupervisedCommunity =='' || levelRequiredResidentialUnsupervisedCommunityInterval=='' || levelRequiredResidentialUnsupervisedCommunityInterval==null){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Interval for Can be unsupervised in community is not provided');
                                ApexPages.addMessage(myMsg); 
                                hasAnError = true;                        
                        }                    
                        str4Level_Required_ResidentialServices  += item;
                        str4Level_Required_ResidentialServices  += glbItemSeperator +levelRequiredResidentialUnsupervisedCommunity + levelRequiredResidentialUnsupervisedCommunityInterval;
                        str4Level_Required_ResidentialServices  += glbListSeperator;
                    }
                    else if(item.contains('Can be unsupervised at home for')){
                        if(levelRequiredResidentialUnsupervisedHome =='' || levelRequiredResidentialUnsupervisedHomeInterval=='' || levelRequiredResidentialUnsupervisedHomeInterval ==null){
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Interval for Can be unsupervised at home is not provided');
                                ApexPages.addMessage(myMsg); 
                                hasAnError = true;                        
                        }
                        str4Level_Required_ResidentialServices  += item;
                        str4Level_Required_ResidentialServices  += glbItemSeperator +levelRequiredResidentialUnsupervisedHome + levelRequiredResidentialUnsupervisedHomeInterval;
                        str4Level_Required_ResidentialServices  += glbListSeperator;
                    }
                    else if(item.contains('Specific Plan')){
                        if(levelRequiredResidentialSpecificPlan ==''){
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                                'Specific Plan for Level of Support Required for Residential Services is not provided');
                                ApexPages.addMessage(myMsg); 
                                hasAnError = true;                                              
                        }                    
                    
                        str4Level_Required_ResidentialServices  += item + glbItemSeperator + levelRequiredResidentialSpecificPlan + glbListSeperator;
                    
                    } 
                    else{str4Level_Required_ResidentialServices  += item + glbListSeperator;}                      
            
            
            }
            
            
            
            
            
            assessment.Support_Required_Level_Residential__c = str4Level_Required_ResidentialServices  ;
            assessment.Staffing_Supervision_Needs__c = str4Staffing_Supervision_Needs ;
            assessment.Recommended_Day_Services_Staffing_Ratio__c = str4RecDayServ ;
            assessment.Services_Required_Level_Day_Services__c =  str4Level_Required_DayServices ;
            
             if(hasAnError){
            //    
                if(assessment.Recommended_Day_Services_Staffing_Ratio__c !=null){RecDayServicesStaffingRatio =  assessment.Recommended_Day_Services_Staffing_Ratio__c.split(glbListSeperator);}
                if(assessment.Staffing_Supervision_Needs__c != null){Staffing_Supervision_Needs = assessment.Staffing_Supervision_Needs__c.split(glbListSeperator);}
                if(assessment.Services_Required_Level_Day_Services__c != null){ 
                    Level_Required_DayServices = assessment.Services_Required_Level_Day_Services__c.split(glbListSeperator);
                    displayLevel_Required_DayServices = assessment.Services_Required_Level_Day_Services__c.split(glbListSeperator);
                }
                if(assessment.Support_Required_Level_Residential__c != null){
                    Level_Required_ResidentialServices = assessment.Support_Required_Level_Residential__c.split(glbListSeperator);
                    displayLevel_Required_ResidentialServices  = assessment.Support_Required_Level_Residential__c.split(glbListSeperator);
                } 
                 return null;          
            }           
            
                   
            update tmpRes;
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
           // upsert assessment;
            ctr.save();
            return ctr.view();
        }
        
        catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
      
        return null;
    
    }


    public PageReference myRevise(){ 
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommended Day Services Staffing Ratio is not provided'));
        try{
            Assessment__c curAssess = new Assessment__c();
            Assessment__c newAssess = new Assessment__c();
            curAssess = [Select id, Assessment_Type__c, Admission__c, AccountPerson__c from Assessment__c Where ID = :assessment.id];
            newAssess = curAssess.clone();
            newAssess.Previous__c = curAssess.id;
            newAssess.Status__c = 'Inactive Draft';
            insert newAssess;
            
            assessment.status__c = 'Active Final';  
            update assessment ;          
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(newAssess);
            return ctr.view();
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    
    }
    
    public PageReference myApprove(){ 
     
        
        try{
            hasErrorOnFinalize = false;
            boolean hasDesError = false;
            
            for(Assessment_Response__c local :  mapCurrentResps.values()){
                if(local.Rating__c != null && local.Rating__c.equalsIgnoreCase('presents a risk')){
                    system.debug('entered loop for ' + local.id);
                    IF(local.Description_of_Risk__c == null || local.Description_of_Risk__c == ''  )
                        {
                            hasDesError =true;
                            system.debug('true ' + local.id);
                            local.Description_of_Risk__c.addError('Description of Risk must be entered');
                        }
                    IF(local.Plan_to_reduce_Risk__c ==null || local.Plan_to_reduce_Risk__c == '')
                        {
                            hasDesError = true;
                            local.Plan_to_reduce_Risk__c.addError('Plan to reduce Risk must be entered');
                        }
                
                }                   
            } 
           // this.validateHardcodedQuestions(true);
            if(hasDesError ){
                mode='edit';
                return null;

                
            }
            

            
            update mapCurrentResps.values() ;
            
            try {
                Assessment__c currFinal = [select id, status__c from assessment__c where Admission__c = :assessment.Admission__c AND Assessment_Type__c = :assessment.Assessment_Type__c and status__C = 'Active Final' LIMIT 1];
                currFinal.Status__c = 'Inactive Final';
                update currFinal;
            }
            catch (Exception e) {
                mode= 'edit';
                // ok to let this go through.. 
            }
            
            Assessment.Status__c = 'Active Final';            
            Assessment.Finalized_Date__c = system.today();
            Assessment.Approved_By__c = UserInfo.getUserId() ;
            
            update Assessment;            
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
            notifyNewAssessmentVersion();
            return ctr.view();
        }
        catch(Exception e){
            Assessment.Status__c = 'Inactive Draft'; 
            Assessment.Finalized_Date__c = null;
            Assessment.Approved_By__c = null ; 
            mode='edit'; 
            hasErrorOnFinalize = true;
            ApexPages.addMessages(e); 
            
            
                     
        }
        
        
        return null;        
        
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
        User[] usersToNotify = [
           SELECT ID, ContactID FROM User
           WHERE ID IN (SELECT User__c FROM Acknowledgment__c WHERE Assessment__c=:this.assessment.Previous__c)
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
    public PageReference clearStaffNeeds(){ 
        assessment.Staffing_Supervision_Needs__c = null;
        return null;
    
    }
    public PageReference clearStaffRatio(){ 
        recommendedDayServicesStaffingRatio = ' ';
        return null;
    
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