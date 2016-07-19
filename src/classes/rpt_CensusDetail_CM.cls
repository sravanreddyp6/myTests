public class rpt_CensusDetail_CM {
    public date sDate {get; set;}
    public date eDate {get; set;}
    public List<SelectOption> sProgs { get; set; }
    public List<SelectOption> userConfimOptions { get; set; }

    public list<Alias__c> locs {get; set;}
    public string selectedAlias {get; set;}
    public clsReport Report {get; set;}
    public map<id, string> aliasLookup {get; set;}
    
    public boolean getShowParms (){ return ApexPages.currentPage().getParameters().get('ackID') == null;}

    public string getHost(){
    
    return URL.getSalesforceBaseUrl().getHost();
    }
        
    public rpt_CensusDetail_CM(){
        sProgs = new List<SelectOption>();
        eDate = system.today().addDays(-1);
        Report = new clsReport();
        aliasLookup = new map<id, string>();
        userConfimOptions = new list<selectoption>();
        //userConfimOptions.add(  new SelectOption( '',  ' ')  );
        userConfimOptions.add(  new SelectOption( 'Confirm',  'Confirm')  );
        userConfimOptions.add(  new SelectOption( 'Unknown',  'Unknown')  );
        
        id ackID = ApexPages.currentPage().getParameters().get('ackID');
        if(ackID != null){
        
            setReportData(ackID);
        }        
        
        locs = [select id, Alias_unique__c from Alias__c where Alias_Operating_Group__c ='Care Meridian' Order BY Alias_unique__c];
        list<service_location__c> servLocs = [select id, Alias_lookup__r.id,  Alias__c, Location_Nickname__c, iServe_Program__c from Service_Location__c where Alias_lookup__r.Alias_Operating_Group__c ='Care Meridian' AND Status__c = 'Active' Order BY Location_Nickname__c];
        for ( Alias__c L: locs ) {
            string myName = L.Alias_unique__c ;
            boolean addMe = false;
            
            for(service_location__c sl: servLocs){
                if(sl.Alias_lookup__r.id == l.id){
                    myName += ' (' + sl.Location_Nickname__c +')';
                    addME = true;
                }
            }            
            if(addMe){
                aliasLookup.put(l.id, myName);
                SelectOption option = new SelectOption( L.id,  myName );
                sProgs.Add( option );
            }
        }   
        
    
    }
    public void setReportData(id ackID){
        Attachment attach = [select id,  body from Attachment where parentId = :ackID AND name = 'Data.JSON' ];

        Blob myBlob = attach.body;
        String myString = myBlob.toString();

        report =  (clsReport)JSON.deserialize(myString , clsReport.class);

    
    }
    public boolean getHasResults(){
        return report.rptData.size() >0;
    }    

    public PageReference runRpt() {
        sDate = eDate;
        Report = new clsReport();
        Report.eDate = eDate;
        Report.sDate = sDate;
        Report.Program = aliasLookup.get(selectedAlias);
        list<Service_assignment__c> allSAs = [select id, SA_Start_DateTime__c,
                                                Person_Being_Served__r.Name, Person_Being_Served__r.id,
                                                Service_Location__r.Location_Nickname__c   
                                                    From Service_assignment__c 
                                                        Where Service_Location__r.Alias_lookup__r.id = :selectedAlias 
                                                            AND Status__c = 'Active'];
        
        
        list<authorization__c> auths = [select id, name , Funding_Source__r.Service_Assignment__r.id
                                                from authorization__c
                                                    where Type__c = 'Bed Hold' 
                                                        AND recordtype.developername = 'Funding_Source_Auth_CM'
                                                        AND Authorization_Status__c = 'Final'
                                                        AND 
                                                        
             ((Payer_Effective_Date__c >= :sDate and Payer_Effective_Date__c <= :eDate ) or
                (Payer_End_Date__c >= :sDate and Payer_End_Date__c <= :eDate ) or
                ( Payer_Effective_Date__c < :sDate and Payer_End_Date__c > :eDate)
                )                                                        
                                                        /*
                                                        (Payer_End_Date__c <= :eDate
                                                            AND
                                                        Payer_Effective_Date__c >= :sDate)
                                                        
                                                        */
                                                    
                                        ];        
        for(service_assignment__c sa: allSAs){
            rptRow row = new rptRow(sa);
                for(authorization__c a : auths){
                    if(a.Funding_Source__r.Service_Assignment__r.id == sa.id){
                        row.auths.add(a);
                    } 
                }
            Report.rptData.add(row);
        }
        
    
        return null;
    }  
    
    public pageReference signOff (){
        try{
            Acknowledgment__c ack = new Acknowledgment__c();
            ack.User__c = UserInfo.getUserId() ;
            ack.Date_Acknowledged__c = system.today();
            ack.type__c = 'CM Census Detail';
            ack.Alias__c = selectedAlias;
            insert ack;
            
            Attachment att = new Attachment();
            att.parentID = ack.id;
            att.body = Blob.valueOf( JSON.serialize(report) );
            att.name = 'Data.JSON';
            insert att;
            
            PageReference pr = new PageReference('/apex/rpt_CensusDetail_CM?ackId=' + ack.Id );
            pr.setRedirect( true);
            return pr;        
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }        
        return null;
    }
    public class clsReport{
        public date sDate {get; set;}
        public date eDate {get; set;}
        public string Program {get; set;}
        public list<rptRow> rptData {get; set;}

        public clsReport(){
            rptData = new list<rptRow>();
        }
    
    }
    public class rptRow{
        public Service_assignment__c sa     {get; set;}
        public list<authorization__c> auths {get; set;}
        public string userConf              {get; set;}
        public string getStatus(){
            if(auths.size()> 0)
                {return 'Admitted/BedHold';}
            
            return 'Admitted';
        }
        public string getIDforAuth(){
            
            if(auths.size()> 0){
                return auths[0].id;
            }
            
            return '';
        }
        public rptRow(service_assignment__c s){
             sa = s;
             auths = new list<authorization__c>();
        }
    
    }    

}