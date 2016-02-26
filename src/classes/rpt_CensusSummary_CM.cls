public class rpt_CensusSummary_CM {
    public date rptDate {get; set;}
    public List<SelectOption> Progs { get; set; }
    public list<id> selProgs{get;set;}
    public list<rptRow> rptData {get; set;}
    public rpt_CensusSummary_CM(){
    
        rptDate = system.today();
        selProgs = new list<id>();
        list<Service_Location__c> locs = [select id, Alias__c, Location_Nickname__c, iServe_Program__c from Service_Location__c where Alias_lookup__r.Alias_Operating_Group__c ='Care Meridian' AND iServe_Program__c != null];
        Progs = new List<SelectOption>();
        for ( Service_Location__c L: locs ) {
            
            SelectOption option = new SelectOption( L.id, l.iServe_Program__c );
            Progs.Add( option );
        }
    
    }
    
    
    public PageReference runRpt() {
       rptData = new list<rptRow>(); 
       datetime endDateTime = rptDate;
       TimeZone zone = UserInfo.getTimeZone();
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       } 
        list<authorization__c> allAuths = [select id, admission__c 
                                                    from authorization__c 
                                                    
                                                    where Type__c = 'Bed Hold' 
                                                        AND admission__r.Status__c = 'Active' 
                                                        AND admission__r.Admission_Effective_DateTime__c > :endDateTime
                                                        AND recordtype.developername = 'Funding_Source_Auth_CM'
                                            ];
        for(authorization__c auth: allAuths){
                rptRow row = new rptRow();
                rptData.add(row);
        }
        return null;
    }    
    
    
    public class rptRow{
        public String progName{ get; set;}
        public string alias { get; set;}
        public list<id> admitIDs{get; set;}
        public list<id> authIDs{get; set;}
        
    
        public rptRow(){
            admitIDs = new list<id>();
            authIDs = new list<id>();
        
        
        }
    
    
    }
    
    

}