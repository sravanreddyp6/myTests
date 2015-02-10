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
    set<id> PBSbyDD_Status {
        get{
            set<id> returnInfo = new set<id>();

            if(selectedDD_Status == 'ONLY_DD'){
                for(Assessment_Response__c item: [select id, Assessment__r.AccountPerson__r.Id 
                                                        from Assessment_Response__c 
                                                        Where Question__r.Question_Number__c = 37 
                                                        AND Assessment__r.disregard__c = false 
                                                        AND Score__c > 0 
                                                        AND Assessment__r.Interval__c = 'Quarterly' 
                                                        AND Assessment__r.Quarter__c = 1 ]){
                    returnInfo.add(item.Assessment__r.AccountPerson__r.Id);
                }
            }
            else if(selectedDD_Status == 'No_DD'){
                for(Assessment_Response__c item: [select id, Assessment__r.AccountPerson__r.Id 
                                                    from Assessment_Response__c 
                                                        Where Question__r.Question_Number__c = 37 
                                                        AND Assessment__r.disregard__c = false 
                                                        AND Score__c = 0 
                                                        AND Assessment__r.Interval__c = 'Quarterly' 
                                                        AND Assessment__r.Quarter__c = 1]){
                    returnInfo.add(item.Assessment__r.AccountPerson__r.Id);
                }
            }

            else{
                for(Assessment__c item: [select id, AccountPerson__r.Id from Assessment__c Where disregard__c = false ]){
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
        
        
        // this determines the states we will work with 
        list<AggregateResult> statesWithIntakeAssess = [select Admission__r.State__c
                                        from Assessment__c 
                                        where Interval__c = 'Intake' 
                                        and assessment_type__r.name = 'CANS'
                                        and disregard__c = false
                                        group by Admission__r.state__c];
        //for each state we will make an item in the master map 
        map<string, StateRowData> mapStateRowData = new map<string, StateRowData>();
        for(AggregateResult item : statesWithIntakeAssess){
            string state =  string.valueof(item.get('state__c'));
            mapStateRowData.put(state, new StateRowData(state));
        }
        //this is for column Number of PBS Discharged per state
        list<AggregateResult> intakeAssess = new list<AggregateResult>();
        if ( includeNullSL ) {
            intakeAssess = [select Admission__r.state__c, count(name) assesCount
                                                from Assessment__c 
                                                    where Interval__c = 'Intake' 
                                                        AND Admission__r.Status__c = 'Discharged'
                                                        AND assessment_type__r.name = 'CANS'
                                                        and disregard__c = false
                                                        AND AccountPerson__r.id IN :PBSbyDD_Status
                                                        AND ( Service_Line__c in :selectedServiceLines
                                                            OR Service_Line__c = null )
                                                        AND Admission__r.Discharged_Date__c >= :StartDate
                                                        AND Admission__r.Discharged_Date__c <= :EndDate

                                                    group by Admission__r.state__c

                                                    ];                                                              
        } else {
            intakeAssess = [select Admission__r.state__c, count(name) assesCount
                                                from Assessment__c 
                                                    where Interval__c = 'Intake' 
                                                        AND Admission__r.Status__c = 'Discharged'
                                                        AND assessment_type__r.name = 'CANS'
                                                        and disregard__c = false
                                                        AND AccountPerson__r.id IN :PBSbyDD_Status
                                                        AND Service_Line__c in :selectedServiceLines
                                                        AND Admission__r.Discharged_Date__c >= :StartDate
                                                        AND Admission__r.Discharged_Date__c <= :EndDate

                                                    group by Admission__r.state__c

                                                    ];                                                  
        }
        for(AggregateResult item : intakeAssess){
            string state =  string.valueof(item.get('state__c'));
            mapStateRowData.get(state).NumberPBSDisCharge = integer.valueof(item.get('assesCount'));
        }


        list<Assessment__c> disChargeAssess = new List<Assessment__c>();
        if ( includeNullSL ) {
        disChargeAssess = [select id, name, AccountPerson__r.Id, Admission__r.State__c
                                                from Assessment__c 
                                                where Interval__c = 'Discharge' 
                                                    AND assessment_type__r.name = 'CANS'
                                                    and disregard__c = false
                                                    AND AccountPerson__r.id IN :PBSbyDD_Status
                                                    AND ( Service_Line__c in :selectedServiceLines
                                                        OR Service_line__c = null )
                                                    AND Assessment_Date__c >= :StartDate 
                                                    AND Assessment_Date__c <= :EndDate
                                                    ];
        } else {
                    disChargeAssess = [select id, name, AccountPerson__r.Id, Admission__r.State__c
                                                from Assessment__c 
                                                where Interval__c = 'Discharge' 
                                                    AND assessment_type__r.name = 'CANS'
                                                    and disregard__c = false
                                                    AND AccountPerson__r.id IN :PBSbyDD_Status
                                                    AND Service_Line__c in :selectedServiceLines
                                                    AND Assessment_Date__c >= :StartDate 
                                                    AND Assessment_Date__c <= :EndDate
                                                    ];
        }
        map<string, PersonRowData> mapPersonRowData = new map<string, PersonRowData>();
        set<id> disChargeAssessPBSes = new set<id>();
        for(Assessment__c item : disChargeAssess){
            mapPersonRowData.put(item.AccountPerson__r.Id, new PersonRowData(item.AccountPerson__r.Id, item.Admission__r.State__c));
            mapStateRowData.get(item.Admission__r.State__c).NumberPBSDisChargeWithCANS +=1;
            disChargeAssessPBSes.add(item.AccountPerson__r.Id);
        }

        
        list<AggregateResult> intakeAssessScore = new List<AggregateResult>();
        
        if ( includeNullSL ) {
            intakeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                                    AND Assessment__r.Quarter__c = 1 
                                                                    AND ( Assessment__r.Service_Line__c in :selectedServiceLines
                                                                        OR Assessment__r.Service_Line__c = null )
                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];
        } else {
            intakeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Quarterly' 
                                                                    AND Assessment__r.Quarter__c = 1 
                                                                    AND Assessment__r.Service_Line__c in :selectedServiceLines
                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];
        }
       
        list<AggregateResult> disChargeAssessScore = new list<AggregateResult>();
        
        if ( includeNullSL ) {
            disChargeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Discharge'
                                                                    AND (Assessment__r.Service_Line__c in :selectedServiceLines
                                                                        OR Assessment__r.service_line__c = null)
                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];      
        } else {
            disChargeAssessScore = [select sum(score__c) score, Assessment__r.AccountPerson__r.Id 
                                                            from Assessment_Response__c 
                                                                Where Assessment__r.AccountPerson__r.Id IN : disChargeAssessPBSes 
                                                                    AND Assessment__r.Interval__c = 'Discharge'
                                                                    AND Assessment__r.Service_Line__c in :selectedServiceLines
                                                                    and Assessment__r.disregard__c = false
                                                                    AND Question__r.Question_Number__c IN :QuestionsInScope
                                                                    AND Assessment__r.assessment_type__r.name = 'CANS'
                                                                    Group By Assessment__r.AccountPerson__r.Id
                                                                    ];      
        }
        for(AggregateResult item : intakeAssessScore){
            string theKey = string.valueof(item.get('ID'));
            mapPersonRowData.get(theKey).IntakeScore = integer.valueof(item.get('score'));
        }
        for(AggregateResult item : disChargeAssessScore){
            string theKey = string.valueof(item.get('ID'));
            mapPersonRowData.get(theKey).disChargeScore = integer.valueof(item.get('score'));
        }

        for(PersonRowData item : mapPersonRowData.values()) {
            if(item.disChargeScore < item.IntakeScore){mapStateRowData.get(item.state).NumberPBSWithImprovement += 1;}
        }

        StateRowData TotalRow = new StateRowData('Total');
        TotalRow.sortKey = 'zz';
        
        for(StateRowData item : mapStateRowData.values()){
            if(item.NumberPBSDisChargeWithCANS != 0){
                item.PercentPBSWithImprovement = (decimal.valueof(item.NumberPBSWithImprovement) / decimal.valueof(item.NumberPBSDisChargeWithCANS)).setScale(2);
                item.PercentPBSWithImprovement = item.PercentPBSWithImprovement * 100;
                item.PrettyPercentPBSWithImp = string.valueof(item.PercentPBSWithImprovement) + '%';
            }
            

            TotalRow.NumberPBSDisCharge += item.NumberPBSDisCharge;
            TotalRow.NumberPBSDisChargeWithCANS += item.NumberPBSDisChargeWithCANS;
            TotalRow.NumberPBSWithImprovement += item.NumberPBSWithImprovement;
            

        }
        if(TotalRow.NumberPBSDisChargeWithCANS != 0){ 
            TotalRow.PercentPBSWithImprovement = (decimal.valueof(TotalRow.NumberPBSWithImprovement) / decimal.valueof(TotalRow.NumberPBSDisChargeWithCANS)).setScale(2);
            TotalRow.PercentPBSWithImprovement = TotalRow.PercentPBSWithImprovement * 100;
            TotalRow.PrettyPercentPBSWithImp = string.valueof(TotalRow.PercentPBSWithImprovement) + '%';
        }
        mapStateRowData.put('total', TotalRow);

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
        public string sortKey;
        public integer NumberPBSDisCharge;
        public integer NumberPBSDisChargeWithCANS;
        public integer NumberPBSWithImprovement;
        public decimal PercentPBSWithImprovement;
        public string PrettyPercentPBSWithImp;


        public StateRowData(string var_State){
            state = var_State;
            sortKey = var_State;
            NumberPBSDisCharge = 0;
            NumberPBSDisChargeWithCANS = 0;
            NumberPBSWithImprovement = 0;
            PercentPBSWithImprovement = 0.00;
            PrettyPercentPBSWithImp = '0.00%';
        }
    }





    

}