public with sharing class Assessment_CANS_RPT_ImpAtDischarge {

    list<Admission__c> allAdmins = new list<Admission__c>();
    list<Assessment__c> allAssess = new list<Assessment__c>();

    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'Well-Being'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            if(selectedCluster == 'Behavior & Risk'){return Assessment_CANS_Cluster_Defs.Behavior_AND_Risk;}
            if(selectedCluster == 'Education'){return Assessment_CANS_Cluster_Defs.Education;}
            return null;
        }
    }
//return Assessment_CANS_Cluster_Defs.WellBeing;
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public string selectedCluster{get; set;}
    public string jsonPersonRowData{get; set;}
    public string jsonStateData{get; set;}
    public integer PBScount {get; set;}

    public Assessment_CANS_RPT_ImpAtDischarge() {
        //runRpt();
    }

    public PageReference runRpt(){
        //StartDate = system.today().addDays(-1000);
        //EndDate = system.today();
        buildRpt();
        return null;
        
    }

    public void buildRpt(){
        // this list should be order ASC by admission effective date so that when the items are put in the map the most recent one is put last (it will override any preivous entires)
        list<AggregateResult> statesWithIntakeAssess = [select Admission__r.State__c
                                        from Assessment__c 
                                        where Interval__c = 'Intake' 
                                        and assessment_type__r.name = 'CANS'
                                        and disregard__c = false
                                        group by Admission__r.state__c];
        
        map<string, StateRowData> mapStateRowData = new map<string, StateRowData>();
        for(AggregateResult item : statesWithIntakeAssess){
            string state =  string.valueof(item.get('state__c'));
            mapStateRowData.put(state, new StateRowData(state));
        }
        //this is for column Number of PBS Discharged per state
        list<AggregateResult> intakeAssess = [select Admission__r.state__c, count(name) myCount
                                                from Assessment__c 
                                                    where Interval__c = 'Intake' 
                                                        AND Admission__r.Status__c = 'Discharged'
                                                        AND assessment_type__r.name = 'CANS'
                                                        AND Admission__r.Discharged_Date__c >= :StartDate
                                                        AND Admission__r.Discharged_Date__c <= :EndDate

                                                    group by Admission__r.state__c

                                                    ];                                                  

        for(AggregateResult item : intakeAssess){
            string state =  string.valueof(item.get('state__c'));
            mapStateRowData.get(state).NumberPBSDisCharge = integer.valueof(item.get('myCount'));
        }


        list<Assessment__c> disChargeAssess = [select id, name, AccountPerson__r.Id, Admission__r.State__c
                                                from Assessment__c 
                                                where Interval__c = 'Discharge' 
                                                    AND assessment_type__r.name = 'CANS'
                                                    AND Assessment_Date__c >= :StartDate 
                                                    AND Assessment_Date__c <= :EndDate

                                                    ];

        map<string, PersonRowData> mapPersonRowData = new map<string, PersonRowData>();
        set<id> disChargeAssessPBSes = new set<id>();
        for(Assessment__c item : disChargeAssess){
            mapPersonRowData.put(item.AccountPerson__r.Id, new PersonRowData(item.AccountPerson__r.Id, item.Admission__r.State__c));
            mapStateRowData.get(item.Admission__r.State__c).NumberPBSDisChargeWithCANS +=1;
            disChargeAssessPBSes.add(item.AccountPerson__r.Id);
        }

        list<AggregateResult> intakeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Intake'
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'

                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];
        list<AggregateResult> disChargeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Discharge'
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'

                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];      

        for(AggregateResult item : intakeAssessScore){
            string theKey = string.valueof(item.get('ID'));
            mapPersonRowData.get(theKey).IntakeScore = integer.valueof(item.get('score'));
        }
        for(AggregateResult item : disChargeAssessScore){
            string theKey = string.valueof(item.get('ID'));
            mapPersonRowData.get(theKey).disChargeScore = integer.valueof(item.get('score'));
        }

        for(PersonRowData item : mapPersonRowData.values()) {
            if(item.disChargeScore > item.IntakeScore){mapStateRowData.get(item.state).NumberPBSWithImprovement += 1;}
        }

        for(StateRowData item : mapStateRowData.values()){
            if(item.NumberPBSDisChargeWithCANS != 0){
                item.PercentPBSWithImprovement = (decimal.valueof(item.NumberPBSWithImprovement) / decimal.valueof(item.NumberPBSDisChargeWithCANS)).setScale(4);
                item.PercentPBSWithImprovement = item.PercentPBSWithImprovement * 100;
                item.PrettyPercentPBSWithImp = string.valueof(item.PercentPBSWithImprovement) + '%';
            }
        }   
        jsonStateData = JSON.serializePretty(mapStateRowData.values());
        jsonPersonRowData = JSON.serializePretty(mapPersonRowData.values());

    }


    public class PersonRowData{
        public string State;
        public string PBS;
        public integer IntakeScore;
        public integer disChargeScore;



        public PersonRowData(string PBSID, string var_state){
                IntakeScore = 0;
                disChargeScore = 0;
                PBS = PBSID;
                state = var_state;
            
        }   
    }

    public class StateRowData{
        public string State;
        public integer NumberPBSDisCharge;
        public integer NumberPBSDisChargeWithCANS;
        public integer NumberPBSWithImprovement;
        public decimal PercentPBSWithImprovement;
        public string PrettyPercentPBSWithImp;


        public StateRowData(string var_State){
            state = var_State;
            NumberPBSDisCharge = 0;
            NumberPBSDisChargeWithCANS = 0;
            NumberPBSWithImprovement = 0;
            PercentPBSWithImprovement = 0;
        }
    }





    

}