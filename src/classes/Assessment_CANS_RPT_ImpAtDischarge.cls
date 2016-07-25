public with sharing class Assessment_CANS_RPT_ImpAtDischarge {

    list<Admission__c> allAdmins = new list<Admission__c>();
    list<Assessment__c> allAssess = new list<Assessment__c>();


    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'Well-Being'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            else if(selectedCluster == 'Behavior & Risk'){return Assessment_CANS_Cluster_Defs.Behavior_AND_Risk;}
            else if(selectedCluster == 'Education'){return Assessment_CANS_Cluster_Defs.Education;}
            else {
                list<integer> allQ = new list<integer>();
                for(integer item = 1; item < 111; item++){
                    allQ.add(item);
                }
                return allQ;                
            }
            return null;
        }
    }
    set<id> PBSbyDD_Status {
        get{
            set<id> returnInfo = new set<id>();
            map<id, date> mapOnlyDD = new map <id, date>();
            map<id, date> mapNoDD = new map <id, date>();

            for(Assessment_Response__c item: [select id, Assessment__r.AccountPerson__r.Id, Assessment__r.Assessment_Date__c 
                                                    from Assessment_Response__c 
                                                    Where Question__r.Question_Number__c = 37 
                                                    AND Assessment__r.disregard__c = false 
                                                    AND Assessment__r.Status__c = 'Locked'
                                                    AND Score__c > 0 
                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                    AND Assessment__r.Quarter__c = 1 ]){
                if( !mapOnlyDD.containsKey(item.Assessment__r.AccountPerson__r.Id) ){
                    mapOnlyDD.put(item.Assessment__r.AccountPerson__r.Id, item.Assessment__r.Assessment_Date__c);                    
                }
                else if(mapOnlyDD.get(item.Assessment__r.AccountPerson__r.Id) <  item.Assessment__r.Assessment_Date__c){
                    mapOnlyDD.put(item.Assessment__r.AccountPerson__r.Id, item.Assessment__r.Assessment_Date__c);                    
                }
                
            }
            for(Assessment_Response__c item: [select id, Assessment__r.AccountPerson__r.Id, Assessment__r.Assessment_Date__c 
                                                from Assessment_Response__c 
                                                    Where Question__r.Question_Number__c = 37 
                                                    AND Assessment__r.disregard__c = false 
                                                    AND Assessment__r.Status__c = 'Locked'
                                                    AND Score__c = 0 
                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                    AND Assessment__r.Quarter__c = 1]){
                if( !mapNoDD.containsKey(item.Assessment__r.AccountPerson__r.Id) ){
                    mapNoDD.put(item.Assessment__r.AccountPerson__r.Id, item.Assessment__r.Assessment_Date__c);                    
                }
                else if(mapNoDD.get(item.Assessment__r.AccountPerson__r.Id) <  item.Assessment__r.Assessment_Date__c){
                    mapNoDD.put(item.Assessment__r.AccountPerson__r.Id, item.Assessment__r.Assessment_Date__c);                    
                }
            }            


            if(selectedDD_Status == 'ONLY_DD'){
                for(ID item: mapOnlyDD.keySet() ){
                    IF( mapNoDD.get(item) > mapOnlyDD.get(item) ){ mapOnlyDD.remove(item);}
                }
                returnInfo = mapOnlyDD.keySet();
            }else if(selectedDD_Status == 'No_DD'){
                for(ID item: mapNoDD.keySet() ){
                    IF( mapOnlyDD.get(item) > mapNoDD.get(item) ){ mapNoDD.remove(item);}
                } 
                returnInfo = mapNoDD.keySet();
            }else{
                for(Assessment__c item: [select id, AccountPerson__r.Id from Assessment__c Where disregard__c = false AND Status__c = 'Locked' ]){
                    returnInfo.add(item.AccountPerson__r.Id);
                }
            }

            return returnInfo;
        }
    }
    public list<string> selectedServiceLines {get;set;}
    public list<SelectOption> serviceLines {get; set;}
//return Assessment_CANS_Cluster_Defs.WellBeing;
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public string selectedCluster{get; set;}
    public string selectedDD_Status{get; set;}
    public string jsonPersonRowData{get; set;}
    public string jsonStateData{get; set;}
    public integer PBScount {get; set;}

    public Assessment_CANS_RPT_ImpAtDischarge() {
        //runRpt();
        selectedServiceLines = new list<string>();
        serviceLines = new list<SelectOption>();
        selectedCluster = 'All';
        Schema.DescribeFieldResult fieldResult = Assessment__c.Service_Line__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry f : ple){
              serviceLines.add(new SelectOption(f.getValue(), f.getLabel()));
              selectedServiceLines.add(f.getValue());
       }               

        serviceLines.add(new SelectOption( 'NS', 'Not specified'));
        selectedServiceLines.add( 'NS');
    }

    public PageReference runRpt(){
        //StartDate = system.today().addDays(-1000);
        //EndDate = system.today();
        buildRpt();
        return null;
        
    }



    public void buildRpt(){
        
        Boolean includeNullSL = false;
        
        for ( string s : selectedServiceLines ) {
            if ( s == 'NS')
                includeNullSL = true;
        }
        
        
        // this determines the states we will work with and display in column 1
        list<AggregateResult> statesWithIntakeAssess = [select Admission__r.State__c
                                        from Assessment__c 
                                        where Interval__c = 'Intake' 
                                        and assessment_type__r.name = 'CANS'
                                        AND Status__c = 'Locked'
                                        and disregard__c = false
                                        group by Admission__r.state__c];
        //for each state we will make an item in the master map 
        // we are gonna pull back the state from assessments and use it as our key
        // we'll also add each person to a list as we go over them
        map<string, StateRowData> mapStateRowData = new map<string, StateRowData>();
        for(AggregateResult item : statesWithIntakeAssess){
            string state =  string.valueof(item.get('state__c'));
            mapStateRowData.put(state, new StateRowData(state));
        }

        // next we'll add the discharge assessment - because they have the filters from the user on them
        // later we will compair them to the Q1 assessment
        list<Assessment__c> baseAssess = new List<Assessment__c>();
        list<Assessment__c> endAssess = new List<Assessment__c>();
        if ( includeNullSL ) {
            endAssess = [select id, name, AccountPerson__r.Id, AccountPerson__r.name, 
                                Admission__r.State__c, admission__r.id, admission__r.name,
                                Assessment_Date__c, Score__c
                         from Assessment__c 
                                    where Interval__c = 'Discharge' 
                                        AND assessment_type__r.name = 'CANS'
                                        AND Status__c = 'Locked'
                                        AND disregard__c = false
                                        AND AccountPerson__r.id IN :PBSbyDD_Status
                                        AND ( Service_Line__c in :selectedServiceLines
                                            OR Service_line__c = null )
                                        AND Assessment_Date__c >= :StartDate 
                                        AND Assessment_Date__c <= :EndDate
                            ];

        } else {
            endAssess = [select id, name, AccountPerson__r.Id, AccountPerson__r.name, 
                                Admission__r.State__c, admission__r.id, admission__r.name,
                                Assessment_Date__c, Score__c
                         from Assessment__c 
                                    where Interval__c = 'Discharge' 
                                        AND assessment_type__r.name = 'CANS'
                                        AND Status__c = 'Locked'
                                        AND disregard__c = false
                                        AND AccountPerson__r.id IN :PBSbyDD_Status
                                        AND Service_Line__c in :selectedServiceLines
                                        AND Assessment_Date__c >= :StartDate 
                                        AND Assessment_Date__c <= :EndDate
                            ];
        }
        //now we need do get all the admission id fron the assessments so we can get the correct Q1 assessments
        //later we'll look to make sure a PBS has both Q1 and Discharge if they dont we'll kick them outta the master list!!!
        //we'll set up some sets for later SOQL usage on the responses
        set<id> admitInEndAssess = new set<id>();
        set<id> admitInBaseAssess = new set<id>();
        for(Assessment__c item : endAssess){
            boolean addPBSToDischargeCount = true;
            string cur_state = item.Admission__r.State__c ;
            string cur_pbs = item.AccountPerson__r.Id;
            string cur_admit = item.Admission__r.id;
                PersonRowData prd = new PersonRowData(cur_pbs, item.AccountPerson__r.name, cur_admit, item.Admission__r.name, cur_state);
                prd.endAssess = item;
                mapStateRowData.get(cur_state).mPbsData.put(cur_admit, prd);          
                admitInEndAssess.add(cur_admit);
       }

        baseAssess = [select id, name, AccountPerson__r.Id, AccountPerson__r.name, 
                            Admission__r.State__c, admission__r.id, admission__r.name,
                            Assessment_Date__c, Score__c
                                from Assessment__c 
                                    where Interval__c = 'Quarterly' 
                                    AND Quarter__c = 1
                                    AND Admission__c in :admitInEndAssess
                                    AND Disregard__c = false
                                    AND Status__c = 'Locked'
                    ];
        //lets get the base assessment in the correct spot
        for(Assessment__c item : baseAssess){
            string cur_state = item.Admission__r.State__c ;
            string cur_pbs = item.AccountPerson__r.Id;    
            string cur_admit = item.Admission__r.id;
            PersonRowData prd = mapStateRowData.get(cur_state).mPbsData.get(cur_admit); 
            prd.baseAssess = item;
            prd.admitHasBaseAndEndAssess = true;
            admitInBaseAssess.add(cur_admit);
        }

        //lets scrub the list removing admits that dont have both a Q1 and Discharge assessment
        for(StateRowData s : mapStateRowData.values() ){
            for(PersonRowData p : s.mPbsData.values() ){
                if( !p.admitHasBaseAndEndAssess ) {
                    s.mPbsData.remove(p.admitID);
                    admitInEndAssess.remove(p.admitID);
                }
            }
        }


        //now we'll get a lists of the scores
        list<AggregateResult> baseAssessScore = new list<AggregateResult>();
        list<AggregateResult> endAssessScore = new list<AggregateResult>();
        if ( includeNullSL ) {
            baseAssessScore = [select sum(score__c) score, Assessment__r.Admission__r.Id admitID, Assessment__r.Admission__r.State__c State 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.admission__c IN : admitInBaseAssess 
                                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                                    AND Assessment__r.Quarter__c = 1 
                                                                    AND ( Assessment__r.Service_Line__c in :selectedServiceLines
                                                                        OR Assessment__r.Service_Line__c = null )

                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    AND Assessment__r.Status__c = 'Locked'

                                                                    Group By Assessment__r.Admission__r.Id, Assessment__r.Admission__r.State__c
                                                                    ];

            endAssessScore = [select sum(score__c) score, Assessment__r.Admission__r.Id admitID, Assessment__r.Admission__r.State__c State 
                                                        from Assessment_Response__c 
                                                            Where Assessment__r.admission__c IN : admitInEndAssess 
                                                                AND Assessment__r.Interval__c = 'Discharge'
                                                                AND (Assessment__r.Service_Line__c in :selectedServiceLines
                                                                    OR Assessment__r.service_line__c = null)

                                                                and Assessment__r.disregard__c = false
                                                                AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                AND Assessment__r.Status__c = 'Locked'

                                                                Group By Assessment__r.Admission__r.Id, Assessment__r.Admission__r.State__c
                                                                ];                                                                 
        } else {
            baseAssessScore = [select sum(score__c) score, Assessment__r.Admission__r.Id admitID, Assessment__r.Admission__r.State__c State
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.admission__c IN : admitInBaseAssess 
                                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                                    AND Assessment__r.Quarter__c = 1 
                                                                    AND Assessment__r.Service_Line__c in :selectedServiceLines

                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    AND Assessment__r.Status__c = 'Locked'

                                                                    Group By Assessment__r.Admission__r.Id, Assessment__r.Admission__r.State__c 
                                                                    ];

            endAssessScore = [select sum(score__c) score, Assessment__r.Admission__r.Id admitID, Assessment__r.Admission__r.State__c State  
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.admission__c IN : admitInEndAssess 
                                                                    AND Assessment__r.Interval__c = 'Discharge'
                                                                    AND Assessment__r.Service_Line__c in :selectedServiceLines

                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    AND Assessment__r.Status__c = 'Locked'

                                                                    Group By Assessment__r.Admission__r.Id, Assessment__r.Admission__r.State__c
                                                                    ];      
        }
        for(AggregateResult item : baseAssessScore){
            string theKey = string.valueof(item.get('admitID'));
            string theState = string.valueof(item.get('State'));
            integer thescore = integer.valueof(item.get('score'));
            mapStateRowData.get(theState).mPbsData.get(theKey).baseScore = thescore;
        }
        for(AggregateResult item : endAssessScore){
            string theKey = string.valueof(item.get('admitID'));
            string theState = string.valueof(item.get('State'));
            integer thescore = integer.valueof(item.get('score'));
            mapStateRowData.get(theState).mPbsData.get(theKey).endScore = thescore;            
        }



/*
//some test data
        StateRowData aqrow = new StateRowData('AQ');
            PersonRowData prd = new PersonRowData('1', 'poly', '2', 'poly-admit', 'AQ');
            prd.endScore = 2;
            prd.baseScore = 3;
            aqrow.mPbsData.put('1', prd); 
            PersonRowData prd2 = new PersonRowData('1', 'zoly', '2', 'zoly-admit', 'AQ');
            prd2.endScore = 7;
            prd2.baseScore = 7;
            aqrow.mPbsData.put('2', prd2);
            PersonRowData prd3 = new PersonRowData('1', 'aoly', '2', 'aoly-admit', 'AQ');
            prd3.endScore = 1;
            prd3.baseScore = 15;
            aqrow.mPbsData.put('3', prd3);                                   
            mapStateRowData.put('AQ', aqrow);

        */   

        //does the admit have imoprovement from q1 to DC?
        for(StateRowData s : mapStateRowData.values() ){
            for(PersonRowData p : s.mPbsData.values() ){
                if(p.endScore < p.baseScore){
                    s.numAdmitImproved += 1;
                    p.hasImprovement = true;
                }
            }
        }


        jsonStateData = JSON.serializePretty(mapStateRowData.values());


    }


    public class PersonRowData{
        public string State;

        public integer baseScore = 0;
        public integer endScore = 0;

        public string pbsName;
        public string pbsID;
        public string admitID;
        public string admitName;

        public Assessment__c baseAssess {get; set;}
        public Assessment__c endAssess {get; set;}

        public boolean admitHasBaseAndEndAssess = false;
        public boolean hasImprovement = false;



        public PersonRowData(string var_pbsID, string var_pbsName, string var_admitID, string var_admitName, string var_state){
                pbsID = var_pbsID;                
                pbsName = var_pbsName;
                admitID = var_admitID;
                admitName = var_admitName;
                state = var_state;
                baseAssess = new Assessment__c();
                endAssess = new Assessment__c();
            
        }   
    }

    public class StateRowData{
        public string State;
        public integer numAdmitBaseAndEnd {set; get {return mPbsData.size(); } }
        public integer numAdmitImproved = 0;
        public decimal percentImproved {set; get {
            if(numAdmitImproved == 0){ return 0.00;}
            else{
                decimal startVal = decimal.valueof(numAdmitImproved);
                decimal endVal = decimal.valueof(numAdmitBaseAndEnd);

                return ((startVal / endVal) * 100).setScale(2); }
            return null;
            } }
        public string prettyPercentImproved { set; get{ return string.valueof(percentImproved) + '%';} }

        public map<string, PersonRowData> mPbsData {get; set;}
        public list<PersonRowData> pbsData { set; get{return mPbsData.values();}}

        public StateRowData(string var_State){
            state = var_State;
            mPbsData = new map<string, PersonRowData>();
        }
    }





    

}