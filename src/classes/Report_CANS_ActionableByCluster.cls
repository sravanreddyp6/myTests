public with sharing class Report_CANS_ActionableByCluster {
    
    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'WellBeing'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            if(selectedCluster == 'Behavior_and_Risk'){return Assessment_CANS_Cluster_Defs.Behavior_and_Risk;}
            return null;
        }
    }

    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<SelectOption> optClusters{ get; set;}
    public string selectedCluster{get; set;}
    public List<SelectOption> optInterval{get; set;} 
    public string selectedInterval{get; set;}
    public List<String> CANSStates {get; set;}
    public Map<String, StateRowData> srd {get;set;}
    
    public Report_CANS_ActionableByCluster() {
        
            optClusters =  new List<SelectOption>();
            optClusters.Add( new SelectOption('','--None--'));
            optClusters.Add( new SelectOption('Behavior_and_Risk','Behavior and Risk'));
            optClusters.Add( new SelectOption('WellBeing','Well Being'));

            optInterval = new List<SelectOption>();
            optInterval.Add( new SelectOption('Intake', 'Intake'));
            optInterval.Add( new SelectOption('Discharge', 'Discharge'));
        
            srd = new Map<String, StateRowData>();
            CANSStates = new List<String>();
    }

    public PageReference runReport(){
        
        boolean inputErr = false;
        ApexPages.getMessages().clear();
       
       if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } else if ( startDate > endDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       system.debug( 'start=' + startDate + ', end=' + endDate + ', cluster=' + selectedCluster);
       
       if ( String.isEmpty(selectedCluster)  ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select the cluster for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       
       if ( !inputErr ) 
            buildRpt();
            
        return null;
        
    }

    public void buildRpt(){
                
         // get all states who have ever had a CANS intake 
        for ( AggregateResult ar : [select Admission__r.State__c
                                          from Assessment__c 
                                          where Interval__c = 'Intake' 
                                          and assessment_type__r.name = 'CANS'
                                          and disregard__c = false
                                          and status__c = 'Locked'
                                          group by Admission__r.state__c
                                         ]) {
            system.debug(ar);
            
            string st = (String)ar.get('State__c');
            CANSStates.Add( st );
            StateRowData newstate = new StateRowData( st );
            srd.put( st, newstate );
            
        }
        
        // count of qualifying 'actionable' = number of PBS with intake or discharge scoring 2 or 3 for any question in the cluster
        list<AggregateResult> QualifyingCountByState = [ 
                                            select count(accountperson__c), admission__r.state__c 
                                            from assessment__c 
                                            where id in (select assessment__c 
                                                         from assessment_response__c 
                                                         where score__c in (2, 6)
                                                         and question__r.question_number__c in :QuestionsInScope
                                                         and assessment__r.Interval__c = :selectedInterval
                                                         and assessment__r.assessment_type__r.name = 'CANS'
                                                         and assessment__r.disregard__c = false
                                                         and assessment__r.status__c = 'Locked'
                                                         and assessment__r.admission__r.state__c in :CANSStates  )
                                            and admission__r.effective_date__c >= :startDate
                                            and (admission__r.discharged_date__c = null or admission__r.discharged_date__c <= :endDate)
                                            group by admission__r.state__c
                                            ];

        for ( AggregateResult ar : QualifyingCountByState ) {
            
            Integer pbscount = (Integer)ar.get('expr0');
            String pbstate = (String)ar.get('state__c');
            
            StateRowData stdata = srd.get(pbstate);
            stdata.PBSCount = pbscount;
            stdata.QualifyingCount = pbscount;
        }
                
    }
    
    

    public class StateRowData{
        public string strState;
        public Integer PBSCount {get;set;}
        public Integer QualifyingCount{get;set;}
        public Map<String, Integer> byQuestionCount;


        public StateRowData(string var_State){
            strState = var_State;
            PBSCount = 0;
            QualifyingCount = 0; 
            byQuestionCount = new Map<String, Integer>();
            
        }
    }


}