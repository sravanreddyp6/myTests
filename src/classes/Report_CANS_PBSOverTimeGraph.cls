public with sharing class Report_CANS_PBSOverTimeGraph {
    
    list<integer> QuestionsInScope {
        get{ 
            if(selectedCluster == 'WellBeing'){return Assessment_CANS_Cluster_Defs.WellBeing;}
            if(selectedCluster == 'Behavior_and_Risk'){return Assessment_CANS_Cluster_Defs.Behavior_and_Risk;}
            if(selectedCluster == 'Education') {return Assessment_CANS_Cluster_Defs.Education;}
            return null;
        }
    }

    public transient Map<ID, Assessment_Question__c> QuestionsList{ get; set;}  // holds list of questions in scope - ID, name, number
    public List<SelectOption> optClusters{ get; set;}
    public string selectedCluster{get; set;}
    public List<SelectOption> optPBS{ get; set;}
    public String selectedPBS { get; set;}
    public String selectedPerson { get ; set;}
    public boolean showData { get; set;}
    public transient List<CANSData> pbsCANS {get; set;}
    
    public Report_CANS_PBSOverTimeGraph() {
        
        optClusters =  new List<SelectOption>();
        optClusters.Add( new SelectOption('','All'));
        optClusters.Add( new SelectOption('Behavior_and_Risk','Behavior & Risk Cluster'));
        optClusters.Add( new SelectOption('Education','Education Cluster'));
        optClusters.Add( new SelectOption('WellBeing','Well-Being Cluster'));
    
            
        QuestionsList = new Map<ID, Assessment_Question__c>();
    
        optPBS = new List<SelectOption>();
        optPBS.Add( new SelectOption('','--None--'));
        // get the list of people i can see who have final, non-diregarded cans
        List<AggregateResult> arCANSList = [select count(id), accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname from assessment__c where assessment_type__r.name = 'CANS' and  disregard__c = false and status__c = 'Locked' group by accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname  order by accountperson__r.lastname];
                
        for ( AggregateResult ar : arCANSList ) {
            optPBS.Add( new SelectOption((String)ar.get('accountperson__c'), (String)ar.get('lastname') + ',' + (String)ar.get('firstname')));
        }
        showData = false;
                
    }

    public PageReference runReport(){
        showData = false;
        boolean inputErr = false;
        ApexPages.getMessages().clear();
       
       if ( String.isEmpty(selectedPBS)  ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please select the Person Being Served for this report');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } 
       if ( !inputErr ) 
            buildRpt();
       
       
       return null;
        
    }

    public void buildRpt(){


        // get the selected person's name
        selectedPerson = [select name from account where id = :selectedPBS].name;

        // get the CANS scores for this person being served
        pbsCANS = new List<CANSdata>();
            
       
        // if no cluster selected, get overall scores
        if (String.isEmpty( selectedCluster)) {
            
            for (Assessment__c asmt : [select id, name, assessment_date__c, interval__c, quarter__c, score__c, admission__r.name
                                        from assessment__c 
                                        where accountperson__c = :selectedPBS 
                                        and disregard__c = false
                                        and status__c = 'Locked'
                                        and assessment_type__r.name = 'CANS'
                                        order by assessment_date__c
                                        ]) {
                                            
                CANSData newasmt = new CANSData( asmt.assessment_date__c, asmt.name, asmt.admission__r.name, asmt.id, asmt.score__c, asmt.quarter__c, asmt.interval__c);                                
                pbsCANS.add( newasmt );     
                                            
            }
        } else {
            
            // only get total score for those questions in the cluster
            for (AggregateResult ar : [ select assessment__c, assessment__r.name, assessment__r.assessment_date__c, assessment__r.interval__c, assessment__r.admission__r.name admname, avg(assessment__r.quarter__c) quarter, sum(score__c) score
                                        from assessment_response__c 
                                        where question__r.question_number__c in :QuestionsInScope 
                                        and assessment__r.accountperson__c = :selectedPBS
                                        and assessment__r.disregard__c = false 
                                        and assessment__r.status__c = 'Locked'
                                        and assessment__r.assessment_type__r.name = 'CANS'
                                        group by assessment__c, assessment__r.name, assessment__r.assessment_date__c, assessment__r.interval__c, assessment__r.admission__r.name 
                                        order by assessment__r.assessment_date__c
                                        ]) {
                CANSData newasmt = new CANSData( (Date)ar.get('assessment_date__c'), (String)ar.get('name') , (String)ar.get('admname'), (ID)ar.get('assessment__c'), (Decimal)ar.get('score'), (Decimal)ar.get('quarter'), (String)ar.get('interval__c') );
                pbsCANS.add( newasmt );
                                        }
        }
        
        
        showData = true;
              
    }
    
    public class CANSData{
        public Date Assessment_Date {get; set;}
        public Decimal Score{get;set;}
        public string Assessment_Name { get; set;}
        public string Admission_Name { get; set;}
        public ID AssessmentID { get; set;}
        public Decimal Quarter { get; set;}
        public String Interval { get; set;}
        public String Interval_Qtr { get; set;}
        public String GraphName { get; set;}

        public CANSData (Date dt, String nm, String adnm, ID id, Decimal sc, Decimal q, String intv ){
            Assessment_Date = dt;
            Assessment_Name = nm;
            Admission_Name = adnm;
            AssessmentID = id; 
            Score = sc;
            Quarter = q;
            Interval = intv;
            Interval_Qtr = intv;
            if (intv == 'Quarterly') 
                Interval_Qtr = 'Q' + q;
            else 
                Interval_Qtr = intv;
            
            GraphName = Interval_Qtr + '\n' + Assessment_Date.format();
            
        }
        
    }


}