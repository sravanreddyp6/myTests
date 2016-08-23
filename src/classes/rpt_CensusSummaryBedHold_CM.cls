public with sharing class rpt_CensusSummaryBedHold_CM {
    public date rptDate {get; set;}
    public List<SelectOption> sProgs { get; set; }
    public List<SelectOption> nProgs { get; set; }
    public list<string> selProgs{get;set;}
    public list<string> notProgs{get;set;}
    public list<Integer> allDays {get; set;}
    public map<string, rptRow> rptData {get; set;}
    public list<Service_Location__c> locs {get; set;}
    public integer getDayCount(){
    
        return allDays.size();
    
    }
    public rpt_CensusSummaryBedHold_CM(){
        allDays = new list<Integer>();
        rptDate = system.today();
        selProgs = new list<string>();
        notProgs = new list<string>();
        rptData = new map<string, rptRow>(); 
        locs = [select id, Alias__c, Location_Nickname__c, iServe_Program__c from Service_Location__c where Alias_lookup__r.Alias_Operating_Group__c ='Care Meridian' AND iServe_Program__c != null Order BY iServe_Program__c];
        
        orderProgSelections(selProgs, false);
    
    }
    public PageReference calcProgs(){
        
        for(string item: notProgs){
            selProgs.add(item);
        }
        for(selectoption op: sProgs){
            selProgs.add( op.getValue() );        
        }        
        orderProgSelections(selProgs, false);
        return null;
    }
    public PageReference removeProgs(){
    
        list<string> allSelections = new list<string>();
      
        for(selectoption op: sProgs){
            boolean addMe = true;
            for(Integer i=0; i < selProgs.size(); i++){            
                if(selProgs.get(i) == op.getValue() ){ addMe = false;}            
            }            
            if( addMe ){
                allSelections.add( op.getValue() );        
            }
        } 
         
               
        orderProgSelections(allSelections, false);
        return null;
    }    
    
    
    public void orderProgSelections(list<string> selections, boolean isRemove ){

        nProgs = new List<SelectOption>();
        sProgs = new List<SelectOption>();
    
         for ( Service_Location__c L: locs ) {
            SelectOption option = new SelectOption( L.id, (l.iServe_Program__c + ' - ' + L.alias__c) );
            boolean addedToSelected = false;
            if(!isRemove){
                for(Integer i=0; i < selections.size(); i++){
                    if( selections.get(i) == string.valueof(L.id) ){                
                       sProgs.Add( option );
                       addedToSelected = true; 
                    }
                }
            }
            
            
            if(!addedToSelected){
                nProgs.Add( option );
            }

            
            
          }  
          
          if( sProgs.size() == 0){
                sProgs.Add( new SelectOption( '', '--None--', true ) );
          }
          if( nProgs.size() == 0){
                nProgs.Add( new SelectOption( '', '--None--', true ) );
          }          
        selProgs = new list<string>();
        notProgs = new list<string>();
    
    
    
    }
    public boolean getHasResults(){
        return !rptData.isEmpty();
    }
    
    
    public PageReference runRpt() {
    system.debug('selected progs ' + selProgs);
    list<string> actualSelectedProgs = new list<string>();
    for(selectoption op: sProgs){
        actualSelectedProgs.add( op.getValue() );
    
    }
       rptData = new map<string, rptRow>(); 
       datetime startDateTime   = Date.newInstance(rptDate.year(), rptDate.Month(), 1); 
       date     startDate   = Date.newInstance(rptDate.year(), rptDate.Month(), 1);
       datetime endDateTime = rptDate;
       TimeZone zone = UserInfo.getTimeZone();
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       } 
       system.debug('end datetime ' + endDateTime);
       allDays = new list<Integer>();
       //
       for(Integer i = 1; i <  rptDate.day() ; i++){
           allDays.add(i);
       
       }
       allDays.add( rptDate.day() );
       
       
       list<service_assignment__c> allSAs = [ select id,
                                               Service_Location__r.iServe_Program__c, SA_Start_DateTime__c, End_Date__c, Status__c,
                                               Service_Location__r.Location_Nickname__c, 
                                               Service_Location__r.Alias__c, Service_Location__r.capacity__c, Service_Location__r.id
                                               from Service_Assignment__c
                                               
                                               where
                                                   Service_Location__r.Alias_lookup__r.Alias_Operating_Group__c ='Care Meridian'
                                                       AND
                                                   SA_Start_DateTime__c < :endDateTime 
                                                       AND   
                                                   (Status__c = 'Active' 
                                                       OR
                                                       
                                                       ( 
                                                           Status__c = 'Inactive'
                                                               AND
                                                           SA_Start_DateTime__c > :startDateTime 
                                                       )
                                                   )
                                                   
                                                   //    AND
                                                   //Service_Location__c IN :actualSelectedProgs
       
                                           ];
       
       
       for(service_assignment__c sa: allSAs){
           string pName = sa.Service_Location__r.Alias__c;
           string uid = sa.Service_Location__r.Alias__c;
           decimal cap = sa.Service_Location__r.capacity__c;   
              if( !rptData.containsKey(uid) ){  
                      system.debug('adding new row');
                    rptRow row = new rptRow(rptDate, allDays);                    
                    row.progName = pName;
                    row.nickNames.add(sa.Service_Location__r.Location_NickName__c);
                    row.SAs.add(sa);
                        
                        if(cap != null && cap > 0 ){row.totalCapList.put(sa.Service_Location__r.id,cap);}
                    
                    rptData.put(uid,row);
                    
                    
                }
                else{
                    rptRow row = rptData.get(uid);
                    row.SAs.add(sa);
                    
                    row.nickNames.add(sa.Service_Location__r.Location_NickName__c);
                    if(cap != null && cap > 0 ){row.totalCapList.put(sa.Service_Location__r.id,cap);}
                    

                    rptData.put(uid,row);
                
                }       
       
       }
       list<authorization__c> allAuths = [select id, 
                                            Funding_Source__r.Service_Assignment__r.Service_Location__r.iServe_Program__c,
                                            Funding_Source__r.Service_Assignment__r.Service_Location__r.Location_Nickname__c,
                                            Funding_Source__r.Service_Assignment__r.Service_Location__r.id,
                                            Funding_Source__r.Service_Assignment__r.Service_Location__r.capacity__c,
                                            Funding_Source__r.Service_Assignment__r.SA_Start_DateTime__c,
                                            Funding_Source__r.Service_Assignment__r.status__c,
                                            Funding_Source__r.Service_Assignment__r.Service_Location__r.Alias__c,
                                            Payer_Effective_Date__c, Payer_End_Date__c
                                                    from authorization__c 
                                                    
                                                    where  Type__c = 'Bed Hold' 
                                                        AND recordtype.developername = 'Funding_Source_Auth_CM'
                                                        AND Funding_Source__r.Service_Assignment__r.SA_Start_DateTime__c < :endDateTime                                                        
                                                        AND Authorization_Status__c = 'Final'
                                                        AND 
                                                            (
                                                                Funding_Source__r.Service_Assignment__r.Status__c = 'Active' 
                                                                    OR
                                                                (Funding_Source__r.Service_Assignment__r.Status__c = 'Inactive'
                                                                    AND Funding_Source__r.Service_Assignment__r.End_Date__c > :startDate  
                                                                )
                                                            )
                                                        
                                                        
                                                       // AND Funding_Source__r.Service_Assignment__r.Service_Location__c IN :actualSelectedProgs                                                    

                                            ];
                                            
        system.debug('auths' + allAuths);
                                            
        for(authorization__c auth: allAuths){
              string pName = auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.Alias__c;
              string uid = auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.Alias__c;
              system.debug('asddata - ' + rptData.keyset());
              decimal cap = auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.capacity__c;
              if( !rptData.containsKey(uid) ){  
                      system.debug('adding new row');
                    rptRow row = new rptRow(rptDate, allDays);                    
                    row.progName = pName;
                    row.auths.add(auth);
                        
                        if(cap != null && cap > 0 ){row.totalCapList.put(auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.id,cap);}
                    row.nickNames.add(auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.Location_NickName__c);

                    rptData.put(uid,row);
                    
                    
                }
                else{
                    system.debug('updaing row' + pName);
                    
                    rptRow row = rptData.get(uid);
                    if(cap != null && cap > 0 ){row.totalCapList.put(auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.id,cap);}
                    row.auths.add(auth);                    
                    row.nickNames.add(auth.Funding_Source__r.Service_Assignment__r.Service_Location__r.Location_NickName__c);
                    
                    rptData.put(uid,row);

                
                
                }
        }
        
        for(rptRow row: rptData.values() ){
            
            row.calc();
            
        }
        return null;
    }    
    
    
    public class rptRow{
        public string                   progName   {get; set;}
        public string                   alias      {get; set;}
        public date                     rDate      {get; set;}
        public decimal                  totalCap   {get; set;}
        public map<id, decimal>         totalCapList {get; set;}
        public list<id>                 admitIDs   {get; set;}
        public list<authorization__c>   auths      {get; set;}
        public list<service_assignment__c> SAs     {get; set;}
        public list<integer>            theDays    {get; set;}
        public map<integer, integer>    mapCensus  {get; set;}
        public map<integer, decimal>    mapOcc     {get; set;}
        public map<integer, decimal>    mapMtdCen  {get; set;}
        public map<integer, decimal>    mapmtdOcc  {get; set;}
        public set<string>              nickNames   = new set<string>();
        
        public string getNameString(){
            string item = '';
            for(string s: nickNames){
            
                item += ' (' + s + ') ';
            }
            return item;
        
        }
    
        public rptRow(date d, list<integer> aDays){
            admitIDs =    new list<id>();
            auths =       new list<authorization__c>();
            SAs =         new list<service_assignment__c>();
            totalCap =    0;
            rDate =       d;
            theDays =     aDays;
            mapCensus =   new map<integer, integer> ();
            mapOcc =      new map<integer, decimal> ();
            mapMtdCen =   new map<integer, decimal>();
            mapmtdOcc =   new map<integer, decimal> ();
            totalCapList = new map<id, decimal> ();
            
            
            
        
        }
        
        public void calc(){
            mapCensus = new map<integer, integer> ();
            decimal runningCensusTotal  = 0;
            system.debug('cur auth count ' + auths.size() );
            for(decimal item : totalCapList.values() ){
                totalCap +=item;
                
            }
            
            for(integer day: theDays){
                date    curLoopDate     = Date.newInstance(rDate.year(), rDate.Month(), day); 
                integer curCensus       = 0;       
                integer curBeds         = 0;
                       
                        mapCensus.put(day, 0);
                        mapOcc.put(day, 0);
                        mapMtdCen.put(day, 0);
                        mapmtdOcc.put(day, 0);
                
                
              
                for(authorization__c auth: auths){
                    date    curAuthStart = auth.Payer_Effective_Date__c; 
                    
                    
                    if(curAuthStart <= curLoopDate &&   auth.Payer_End_Date__c >= curLoopDate ){
                        curBeds = curBeds + 1;
                        mapCensus.put(day, curBeds);
                    }
                    
                    
                
                }
                runningCensusTotal += mapCensus.get(day);
                
                decimal mtdCen = (runningCensusTotal /  day).setScale(1);
                
                //mapMtdCen.put(day, mapMtdCen.get(day).setScal(1) );
                mapMtdOcc.put(day, mtdCen);
                
                
                for(service_assignment__c sa: SAs){
                    date    curAdmitDay = sa.SA_Start_DateTime__c.date(); 
                    
                    if(sa.Status__c == 'Active'){
                        if(curAdmitDay <= curLoopDate){
                            curCensus = curCensus + 1;
                            mapMtdCen.put(day, curCensus );
                        }    
                    }else if(sa.Status__c == 'Inactive'){
                        date curAdmitEnd = sa.End_Date__c; 
                        if(curAdmitDay <= curLoopDate && curAdmitEnd >= curLoopDate){
                            curCensus = curCensus + 1;
                            mapMtdCen.put(day, curCensus );
                        } 
                    }            
                } 
                if(totalCap != null && totalCap > 0){
                    mapOcc.put(day, (mapMtdCen.get(day) / totalCap) * 100 );                
                }               
                
                
            }
            
            

        
        }
    
    
            public set<id> getCountSA(){
                set<id> sa = new set<id>();
                
                for(service_assignment__c item : SAs){
                    sa.add(item.id);
                }
                return sa;
                
            
            }    
    }
    
    

}