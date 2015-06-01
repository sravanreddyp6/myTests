public with sharing class rptAssess_Restraint_PBS_Sum {
    public string PBSID {set; get;}
    public Account PBS {set; get{

        return [SELECT id, name, FirstNAme, LastName, PBS_Identifier__pc from account where id = :PBSID];
        }}
    public date sDate {get; set;}
    public date eDate {get; set;}
    public list<string> colIndex {set; get;}
    public list<Assessment_Question__c> allQuestions {get; set;}
    public map<string, Assessment__c> mapAllAssess { get; set; }
    public map<string, Assessment_Response__c> mapAllData {get; set;}
    public List<SelectOption> optPBS{ get; set;}
    public rptAssess_Restraint_PBS_Sum() {
        mapAllData = new map<string, Assessment_Response__c>();
        PBSID = ApexPages.currentPage().getParameters().get('PBS');
        allQuestions = [select id, name, question_title__c 
                                FROM Assessment_Question__c 
                                WHERE Question_Domain__r.Assessment_Type2__c ='Restraint Reduction'  
                                ORDER BY Question_Number__c ASC];
        optPBS = new List<SelectOption>();
        optPBS.Add( new SelectOption('','--None--'));
        // get the list of people i can see who have final, non-diregarded cans
        List<AggregateResult> arCANSList = [select count(id), accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname 
                                                    from assessment__c 
                                                    where Type__c ='Restraint Reduction' 
                                                        and  disregard__c = false 
                                                        and status__c = 'Final' 
                                                    group by accountperson__c, accountperson__r.name, accountperson__r.lastname, accountperson__r.firstname  order by accountperson__r.lastname];
                
        for ( AggregateResult ar : arCANSList ) {
            optPBS.Add( new SelectOption((String)ar.get('accountperson__c'), (String)ar.get('lastname') + ', ' + (String)ar.get('firstname')));
        }                                
    }

    public PageReference runRpt(){
        list<Assessment__c> allAsses = [ SELECT id, name, Guidelines__c, Assessment_Date__c, 
                (select id, name, rating__c, question__c, score__c from Assessment_Response__r) resRecord,
                                                CreatedDate, 
                                                Score__c, Service_Assignment__c 
                                                    from Assessment__c 
                                                    where AccountPerson__c = :PBSID 
                                                        AND Status__c = 'Final' 
                                                        AND Disregard__c = false
                                                        AND Assessment_Date__c >= :sDate
                                                        AND Assessment_Date__c <= :eDate
                                                    ORDER BY Assessment_Date__c DESC
                                                    Limit 6];


        list<string> tmpcolIndex = new list<string>();
        mapAllAssess = new map<string, Assessment__c>();

        for(Assessment__c assess: allAsses){
            tmpcolIndex.add(assess.id);
            mapAllAssess.put(assess.id, assess);
            for(Assessment_Response__c res : assess.Assessment_Response__r){
                mapAllData.put( string.valueof(assess.id) + string.valueof(res.Question__c) , res);
            }
        }
        //invert the sorting
        colIndex = new list<string>();
        for(Integer i = tmpcolIndex.size()-1; i>=0;i--)
        {
            colIndex.add(tmpcolIndex.get(i));
        }        
        return null;
    }


}