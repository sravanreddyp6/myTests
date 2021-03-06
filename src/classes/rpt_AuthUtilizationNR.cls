public with sharing class rpt_AuthUtilizationNR {
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public list<rptData> reportData{get; set;}
    public rpt_AuthUtilizationNR(){


    }
    public pageReference runRpt(){
        reportData = new list<rptData>();
       boolean inputErr = false;
       if(StartDate == null || EndDate == null   ){
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
       
       if ( inputErr ) {
            return null;
       }
              
       TimeZone zone = UserInfo.getTimeZone();
       datetime startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}


       datetime endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }    
        list<progress_note__c> notes = [select id, recordtypeid, Units__c, Therapy_Discipline__c, person_being_served__c, Service_Assignment__c,  name 
										from progress_note__c                                            
										where recordtype.developername = 'Therapy'
										AND
											(Start_Time__c >= :startDateTime AND Start_Time__c <= :endDateTime)
										AND 
											(End_Time__c >= :startDateTime AND End_Time__c <= :endDateTime)
										AND
											Disregard_Note__c = false
										AND
											Service_Assignment__r.Status__c != 'Created in Error'];
                                            
        /*
        list<string> okAuthSts = new list<string>();
        okAuthSts.add('Active Final');
        okAuthSts.add('Inactive Final');
        */
        list<authorization__c> auths = [select id, Service_Assignment__c, Total_Weekly_Auth_Therapy_Units__c, Case_Manager__r.name, 
                                                Master_Authorization__r.Open_Ended_Contract_Life_Span_Contract__c,  Master_Authorization__r.Days_Authorized_To__c, Master_Authorization__r.Funding_Source__r.Payer_Name__c,
                                                Staffing_Ratio_1_1__c, OT_Auth_Units__c, PT_Auth_Units__c, SLP_Auth_Units__c, 
                                                BIT_Auth_Units__c, Counseling_Auth_Units__c, Auth_Units_Grand_Total__c  ,
                                                Rate__c, PRN_DS__c, Number_of_Hrs_Expected__c, Days_Authorized_To__c
                                            from authorization__c 
                                            where recordtype.developername = 'Costs_TherapyNR' 
                                        	AND
	                                            ((Days_Authorized_from__c >= :startDate and Days_Authorized_from__c <= :endDate ) or
	                                            (Days_Authorized_To__c >= :startDate and Days_Authorized_To__c <= :endDate ) or
	                                            ( Days_Authorized_from__c < :startDate and Days_Authorized_To__c > :endDate)
	                                            )
                                            AND
                                            	Service_Assignment__r.Status__c != 'Created in Error'];                                            
        //build list of needed SA ids
        system.debug('auths in scope - ' + auths);
        set<id> saIDs = new set<id>();
        for(progress_note__c n: notes){
            saIDs.add(n.Service_Assignment__c);            
        }
        for(authorization__c a :auths){
            saIDs.add(a.Service_Assignment__c);  
        }
        system.debug('SA in scope - ' + saIDs);
        map<id, service_assignment__c> allSAs = new map<id, service_assignment__c>([select id, admission__c, admission__r.Effective_Date__c, person_being_served__r.name, person_being_served__r.PBS_Identifier__c from service_assignment__c where id IN :saIDs ORDER BY Person_Being_served__r.name]);
        system.debug('MAP SA in scope - ' + allSAs );
        for(service_assignment__c sa: allSAs.values()){
            rptData newRow = new rptData(endDate);
            newRow.theSA = sa;
            newRow.PBS = sa.person_being_served__r.name;
            newRow.personNumber = '';
            
            for(progress_note__c n: notes){
                if(n.service_assignment__c == sa.id){
                    newRow.allNotes.add(n);
                }                        
            } 
            for(authorization__c a: auths){
                if(sa.id == a.service_assignment__c){
                    newRow.allctAuths.add(a);
                    newRow.RATE = a.Rate__c;
                    newRow.caseManager = a.Case_Manager__r.name;
                    newRow.funder = a.Master_Authorization__r.Funding_Source__r.Payer_Name__c;
                    newRow.authorizatedUntil = a.Master_Authorization__r.Days_Authorized_To__c;
                    newRow.openEndedAuth = a.Master_Authorization__r.Open_Ended_Contract_Life_Span_Contract__c;
                }
            } 
            reportData.add(newRow);
        }      
        for(rptData data: reportData){
            data.calc();        
        }
        return null;
    }
    
    public class rptData{
        public admission__c theAdmit {get; set;}
        public service_assignment__c theSA {get; set;}
        public funding_source__c theFunder {get; set;}
        public authorization__c theAuth{get; set;}
        public date ProjDcDate {get; set;}
        public date rptEndDate{ get; set;}
        public date authorizatedUntil {get; set;}
        public boolean openEndedAuth {get; set;}
        public integer numDaysWithoutAuthFromRptEnd {get; set;}
        
        public integer actTOTAL {get; set;}
        public integer fundedTOTAL{ get; set;}
        
        public integer authTOTAL{get; set;}
        public integer expTOTAL{get; set;}
        public integer delTOTAL{get; set;}
        
        public integer actSPL {get; set;}
        public integer expSPL {get; set;}
        
        public integer actPT {get; set;}
        public integer expPT {get; set;}
        
        public integer actOT {get; set;}
        public integer expOT {get; set;}
        
        public integer actBIT {get; set;}
        public integer expBIT {get; set;}
        
        public integer actCOUN  {get; set;}
        public integer expCOUN {get; set;}   
        public string RATE {get; set;}    
        public integer expOneOneHrs {get; set;}        
        
        public decimal amountWithoutAuth {get; set;}
        public boolean flagRow{get; set;}
        public date recentEndDate {get; set;}
        public string PBS {get;set;}
        public string caseManager {get; set;}
        public string funder{get; set;}
        public string personNumber{get; set;}
        public date FundedThrough{get; set;}
        public list<Progress_Note__c> allNotes{get; set;}
        public list<Authorization__c> allctAuths{get; set;}
        public rptData(date e){
            allNotes = new list<Progress_Note__c>();
            allctAuths = new list<Authorization__c>();
            
             rptEndDate = e;
             actTOTAL = 0;
             fundedTOTAL = 0;
             authTOTAL = 0;
             expTOTAL= 0;
             delTOTAL= 0;
            
             actSPL = 0;
             expSPL = 0;
            
             actPT = 0;
             expPT = 0;
            
             actOT = 0;
             expOT = 0;
            
             actBIT = 0;
             expBIT = 0;
            
             actCOUN = 0;
             expCOUN = 0; 
             expOneOneHrs=0;  
             numDaysWithoutAuthFromRptEnd=0;  
             projDcDate = null;
             
             RATE = '';         
        }
        
        public void calc(){
            
            for(progress_note__c note : allNotes){
                if(note.Therapy_Discipline__c =='PT'){
                   actPT += integer.valueof(note.Units__c); 
                   
                }else if(note.Therapy_Discipline__c =='OT'){                
                    actOT += integer.valueof(note.Units__c);
                    
                }else if(note.Therapy_Discipline__c =='SLP'){                
                    actSPL += integer.valueof(note.Units__c);
                    
                }else if(note.Therapy_Discipline__c =='Counseling'){                
                    actCOUN += integer.valueof(note.Units__c);
                    
                }else if(note.Therapy_Discipline__c =='BIT'){                
                    actBIT += integer.valueof(note.Units__c);
                    
                }            
            }
            recentEndDate = null;
            amountWithoutAuth = 0;
            for(authorization__c auth: allctAuths){
                if(auth.Days_Authorized_To__c > recentEndDate || recentEndDate == null ){
                    recentEndDate = auth.Days_Authorized_To__c;
                }
                
                if( !string.isblank(auth.SLP_Auth_Units__c))                          expSPL  += integer.valueof(auth.SLP_Auth_Units__c);
                if( !string.isblank(auth.PT_Auth_Units__c))                           expPT   += integer.valueof(auth.PT_Auth_Units__c);
                if( !string.isblank(auth.OT_Auth_Units__c))                           expOT   += integer.valueof(auth.OT_Auth_Units__c);
                if( !string.isblank(auth.Counseling_Auth_Units__c))                   expCOUN += integer.valueof(auth.Counseling_Auth_Units__c);
                if( !string.isblank(auth.BIT_Auth_Units__c))                          expBIT  += integer.valueof(auth.BIT_Auth_Units__c);
                if( !string.isblank(auth.Total_Weekly_Auth_Therapy_Units__c))         fundedTOTAL  += integer.valueof(auth.Total_Weekly_Auth_Therapy_Units__c);
                if( !string.isblank(auth.Auth_Units_Grand_Total__c))                  authTotal  += integer.valueof(auth.Auth_Units_Grand_Total__c);
                if( !string.isblank(auth.Number_of_Hrs_Expected__c))                  expOneOneHrs  += integer.valueof(auth.Number_of_Hrs_Expected__c);
                
                
            }
            if(recentEndDate != null){
                numDaysWithoutAuthFromRptEnd = recentEndDate.daysbetween(rptEndDate);
                amountWithoutAuth = numDaysWithoutAuthFromRptEnd * (String.isNOTBlank(RATE) ? Decimal.valueof(RATE) : 0); //Sravan NRREP-31 hotfix 04/28/2016
            }
             delTOTAL = actOT + actBIT + actSPL + actPT + actCOUN;
             
             
             flagRow = ( (delTOTAL < authTOTAL) && (authTOTAL - delTOTAL > 4) );
        
        
        }
    
    }
}