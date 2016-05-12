public without sharing class ActionPlan_FormWithoutSharing {
    
    public APWrapper apw {get; private set;}
    public string GoalAlias { get; set;}
    public string ObjAlias { get; set;}
    public string ActAlias { get; set;}
    public boolean isRedwood {get; set;}
    public boolean showISP { get; set; }
    
    private List<Action_Plan_Goal__c> goals = new List<Action_Plan_Goal__c >();
    private List<Action_Plan_Goal__c> GETgoals(){ return goals;}    
    private List<Action_Plan_Objective__c> objectives = new List<Action_Plan_Objective__c>();
    private List<Action_Plan_Objective__c> GETobjectives(){return objectives;}    
    private map<string, clsGoal> planStuff = new map<string, clsGoal> ();
    public map<string, clsGoal> GETplanStuff(){return planStuff;}    
    private List<Acknowledgment__c> planAcks = new List<Acknowledgment__c>();
    public List<AckWrapper> ackwraplist { get; set;}
    private List<Acknowledgment__c> ispAcks = new List<Acknowledgment__c>();
    public List<AckWrapper> ispackwraplist { get; set;}
    public Boolean acknowledged { get; private set;}
    public Boolean ispacknowledged { get; private set;}
    public string userOpGrp {get; private set;}
    public ID APId {get; set;}
    public ID ISPId {get; set;}
    
    public ActionPlan_FormWithoutSharing(Id actionPlanId) {
        this.APId = actionPlanId;
        
        Action_Plan__c ActionPlan = [select id, name, service_assignment__r.admission__r.name, service_assignment__r.name, Service_Assignment__r.Service_Location__r.Service_Value__c, service_assignment__r.service_location__r.programid__c, 
                                     effective_date__c, date_service_started__c, external_plan__c, target_date__c, baseline__c, status__c, service_Assignment__r.flavor__c,
                                     finalized_by__r.name, finalized_date__c,
                                     service_assignment__r.service_location__r.alias_lookup__r.alias_operating_group__c,
                                     service_assignment__r.service_location__r.state__c,
                                     service_assignment__r.service_location__r.network_offering__c 
                                     from action_plan__c where id = :this.apID LIMIT 1];
        
        if ( ActionPlan == null ) {
            apw = new APWrapper();
        } else {
            apw = new APWrapper( ActionPlan );
        }
        
        isRedwood = false;
        
        for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
            if (TU.Operating_Group__c == 'Redwood' && ActionPlan.Service_Assignment__r.Flavor__c != 'CA FSS' ){isRedwood = true;}
            userOpGrp = TU.Operating_Group__c;
        }
        
        aliasChildrenTitles();
        refreshPlan(); 
        
        // get existing acknowledgments on the plan 
        ackwrapList = new List<AckWrapper>();
        acknowledged =  false;
        planAcks = [ select user__c, user__r.name, date_acknowledged__c, initials__c from acknowledgment__c where action_plan__c = :actionPlanId LIMIT 1000];
        for ( Acknowledgment__c a : planAcks ) {
            AckWrapper aw = new AckWrapper( a.user__r.name, a.date_acknowledged__c, a.initials__c);
            ackwrapList.add( aw );
            
            if ( a.user__c == userinfo.getUserId())
                acknowledged = true;
        }
//        system.debug( 'ACTION PLAN WRAPPED' + apw);
        
        // OH-11 - get existing acknowledgments on the ISP attachment
        showISP = ( ActionPlan.service_assignment__r.service_location__r.alias_lookup__r.alias_operating_Group__c == 'Redwood' &&
					ActionPlan.service_assignment__r.service_location__r.network_offering__c == 'IDD' &&
					 ActionPlan.service_assignment__r.service_location__r.state__c == 'OH' 
					);
		
		List<Attachment> isps = [ select id from attachment where parentid = :ActionPlan.id and name like 'ISP%' order by createddate desc LIMIT 1];
        if ( isps.size() == 1) {
        	ispid = isps[0].id;
	        ispackwrapList = new List<AckWrapper>();
	        ispacknowledged =  false;
	        ispAcks = [ select user__c, user__r.name, date_acknowledged__c, initials__c from acknowledgment__c where attachment__c = :isps[0].id LIMIT 1000];
	        for ( Acknowledgment__c a : ispAcks ) {
	            AckWrapper aw = new AckWrapper( a.user__r.name, a.date_acknowledged__c, a.initials__c);
	            ispackwrapList.add( aw );
	            
	            if ( a.user__c == userinfo.getUserId())
	                ispacknowledged = true;
	 	   }
	
        } else {
        	ispid= null;
			ispacknowledged = true; // don't show if there are no ISPs
		}  
        
    }
    
    public void refreshPlan(){
        
        goals = [select id, name, description__c, CreatedDate,Sort_Order__c ,ReferenceID__c, Former_ID__c,
                 (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Action_plan_Goal__c, sort_order__c, ReferenceID__c, Former_ID__c, CreatedDate
                  from Action_Plan_Objectives__r Order By CreatedDate) 
                 from Action_Plan_Goal__c where action_plan__c = :APId Order By CreatedDate]; 
        objectives = [select id, Action_plan_goal__c, name, ReferenceID__c, Description__c, CreatedDate, sort_order__c, Action_Plan_Goal__r.Sort_Order__c,
                      (select id, description__c, ReferenceID__c, name, CreatedDate, sort_order__c, status__c, Start_Date__c, End_date__c
                       from Action_Plan_Actions__r Order By sort_order__c) 
                      from Action_Plan_Objective__c where Action_Plan_Goal__r.Action_Plan__c = :apID];        
        for(Action_Plan_Goal__c g : goals){
            clsGoal clsG = new clsGoal(g);
            planStuff.put(g.sort_order__c + g.id, clsG);
            for(Action_Plan_Objective__c o: g.Action_Plan_Objectives__r){
                clsObj clsO = new clsObj(o, false, g.id);
                planStuff.get(g.sort_order__c + g.id).GoalObjs.put(o.sort_order__c + o.id, clsO );                
            }
        }
        for(Action_Plan_Objective__c o: objectives){
            for(Action_Plan_Action__c a: o.Action_plan_actions__r){
                clsAction clsA = new clsAction(a,false,o.id);
                planStuff.get(o.Action_Plan_Goal__r.Sort_Order__c + o.Action_Plan_Goal__c).GoalObjs.get(o.sort_order__c + o.id).ObjActs.put(a.Sort_Order__c+a.id, clsA);
            }
        }        
    } //end of refresh plan
    
    public void aliasChildrenTitles(){
        GoalAlias = 'Goal';
        ObjAlias = 'Objective';
        ActAlias = 'Action';
        
        SystemSettings__c mc = SystemSettings__c.getInstance(UserInfo.getUserId());
        boolean showThis = (mc.ActnPln_CtlgEnabledFor_CM__c && userOpGrp == 'Care Meridian')
            || (mc.ActnPln_CtlgEnabledFor_Cambridge__c && userOpGrp == 'Cambridge')
            || (mc.ActnPln_CtlgEnabledFor_NR__c && userOpGrp == 'NeuroRestorative')
            || (mc.ActnPln_CtlgEnabledFor_Redwood__c && userOpGrp == 'Redwood')
            || (mc.ActnPln_CtlgEnabledFor_CAFSS__c && apw.flavor == 'CA FSS');
        if(showThis){
            if(apw.serviceval != null && apw.serviceval =='ABI' && apw.flavor != 'Ludlow'){        
                GoalAlias = 'Problem';
                ObjAlias = 'Goal';
                ActAlias = 'Intervention';
            }    
        }
        
    }
    
    public class APWrapper {
        
        public String apName { get; set;}
        public String admName  { get; set; }
        public String saName { get; set; }
        public date effDate { get; set; }
        public date endDate  { get; set; }
        public date startDate { get; set; }
        public boolean baseline { get; set; }
        public boolean extplan { get; set ;}
        public string status { get; set;}
        public string fby { get; set; }
        public date fdate { get; set; }
        public string serviceloc { get; set; }
        public string serviceval { get; set; }
        public string flavor { get; set; }
        
        public APWrapper() {}
        
        public APWrapper( Action_Plan__c a) {
            apname = a.Name;
            admName = a.service_assignment__r.admission__r.name;
            saName = a.service_assignment__r.name;
            effDate = a.effective_date__c;
            endDate = a.target_date__c;
            startDate = a.date_service_started__c;
            baseline = a.baseline__c;
            extplan = a.external_plan__c;
            status = a.status__c;
            fby = a.finalized_by__r.name;
            fdate = a.finalized_date__c;
            flavor = a.service_assignment__r.flavor__c;
            serviceloc = a.service_assignment__r.service_location__r.programid__c;
            serviceval = a.service_assignment__r.service_location__r.service_value__c;
        }
        
        
        
    }
    
    public class clsGoal{
        
        // added for oneapp
        public string description { get; set; }
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public string GoalID {get; set;}
        public string tmpIdOfGoal {get; set;}
        public Action_Plan_Goal__c theGoal {get; set;}
        public Map<string, clsObj> GoalObjs = new Map<string, clsObj>();
        public Map<string, clsObj> getGoalObjs(){ return GoalObjs;}
        Blob b = Crypto.GenerateAESKey(128);
        public string getRefID(){
            if(isNew){
                return tmpIdOfGoal;
            }
            
            return theGoal.Sort_Order__c + theGoal.ID;
        }                   
        public clsGoal(Action_Plan_Goal__c tmpGoal){
            commonlyConstructed(tmpGoal, '');
        }
        public clsGoal(Action_Plan_Goal__c tmpGoal, string key){
            commonlyConstructed(tmpGoal, '_' + key);
        }          
        public void commonlyConstructed(Action_Plan_Goal__c tmpGoal, string key){
            isNew = false;
            deleteMe = false;
            Integer len = 5;
            Blob blobKey = crypto.generateAesKey(128);
            String Randomkey = EncodingUtil.convertToHex(blobKey);
            String RandomCharKey = Randomkey.substring(0,len);
            description = tmpGoal.Description__c;
            
            theGoal = tmpGoal;  
            string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');
            tmpIdOfGoal = 'zg' + shortnow + key + RandomCharKey ;
            //EncodingUtil.ConvertTohex(b);           
            if(theGoal.id == null){
                isNew = true;
                theGoal.Sort_Order__c = shortnow;
                theGoal.Former_ID__c = tmpIdOfGoal;               
            }        
        }     
    }  
    
    public class clsObj{
        // added for oneapp
        public string description { get; set; }
        public string status { get; set; }
        public string otype { get; set; }
        public date effdate { get; set; }
        public date enddate { get; set; }
        
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public boolean isParentNew{get; set;}
        public string GoalID {get; set;}                    
        public Action_Plan_Objective__c theObj {get; set;}
        public string QuestionID {get; set;}  
        public string tmpIdOfObj {get; set;}
        public map<string, clsAction> ObjActs = new Map<string, clsAction>();
        public map<string, clsAction> getObjActs(){return ObjActs ;}
        Blob b = Crypto.GenerateAESKey(128);
        public string getRefID(){
            if(isNew){
                return tmpIdOfObj;
            }
            
            return theObj.Sort_Order__c + theObj.ID;
        }                 
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID){
            commonlyConstructed(tmpObj, isGoalNew, parentID, '');
        }  
        public clsObj(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID, string key){
            commonlyConstructed(tmpObj, isGoalNew, parentID, '_'+ key);
        }          
        public void commonlyConstructed(Action_Plan_Objective__c tmpObj, boolean isGoalNew, string parentID, string key){
            isNew = false;
            isParentNew = false;
            deleteMe = false;
            Integer len = 5;
            Blob blobKey = crypto.generateAesKey(128);
            String Randomkey = EncodingUtil.convertToHex(blobKey);
            String RandomCharKey = Randomkey.substring(0,len);
            description = tmpObj.Description__c;
            effdate = tmpObj.Effective_date__c;
            enddate = tmpObj.Target_End_Date__c;
            otype = tmpObj.type__c;
            status = tmpobj.status__c;
            
            theObj = tmpObj;
            GoalID = parentID;
            string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');  
            tmpIdOfObj  =  'zo' + shortnow + key + RandomCharKey;
            //EncodingUtil.ConvertTohex(b); 
            if(isGoalNew){
                isParentNew = true;
                Action_Plan_Goal__c apg = new Action_Plan_Goal__c();
                apg.Former_ID__c = GoalID;    
                theObj.Action_Plan_Goal__r = apg;                    
            }
            if(theObj.id == null){
                isNew = true; 
                theObj.Sort_Order__c = shortnow;
                theObj.Former_ID__c = tmpIdOfObj ;
            }
            if(theObj.id == null && !isGoalNew)
            {theObj.Action_Plan_Goal__c = GoalID.right(18) ;}        
        }             
    }     
    
    public class clsAction{
        //added for oneapp
        public string description { get; set; }
        
        public boolean isNew {get; set;}
        public boolean deleteMe {get; set;}
        public boolean isQuestionNew {get; set;}
        public string QuestionID {get; set;}
        public string ActionID {get; set;}
        public Action_Plan_Action__c theAction {get; set;}
        public string tmpIdOfAct {get; set;}
        public string objID {get; set;}  
        Blob b = Crypto.GenerateAESKey(128);   
        
        public string getRefID(){
            if(isNew){
                return tmpIdOfAct;
            }
            
            return theAction.Sort_Order__c + theAction.ID;
        }   
        
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID){        
            commonlyConstructed(tmpAction, isObjNew, parentID, '');
        }
        public clsAction(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID, string key){
            commonlyConstructed(tmpAction, isObjNew, parentID, '_'+ key);
        }         
        public void commonlyConstructed(Action_Plan_action__c tmpAction, boolean isObjNew, string parentID, string key){
            isNew = false;
            isQuestionNew = false;
            deleteMe = false;
            description = tmpaction.description__c;
            theAction = tmpAction;  
            objId = parentID; 
            string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');               
            tmpIdOfAct  =  'za' +  shortnow  + key;
            //EncodingUtil.ConvertTohex(b); 
            
            if(isObjNew){
                Action_Plan_Objective__c apo = new Action_Plan_Objective__c();
                apo.Former_Id__c = objId;
                theAction.Action_Plan_Objective__r= apo;  
            }
            if(theAction.id == null){isNew = true; theAction.Sort_Order__c =  shortnow;  }
            if(theAction.id == null && !isObjNew){theAction.Action_Plan_Objective__c = objId.right(18);}        
        }      
    }
    
    public class AckWrapper {
        public String AckBy { get; set; }
        public Date AckDate { get; set; }
        public String AckInit { get; set; }
        
        public AckWrapper( string b, date d, string i ) {
            this.AckBy = b;
            this.AckDate = d;
            this.AckInit = i;
        }
    }
    
}