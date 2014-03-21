public class CMContract_Form {

     class cSearchedServiceLocationResults {
         public Service_Location__c sl {get; set;}
         public Boolean selected {get; set;}
  
         
         public cSearchedServiceLocationResults(Service_Location__c psl) {
             sl = psl;
             selected = false;
         }
     }

    public string nameFilter{get;set;}
    public string cityFilter{get;set;}
    public string stateFilter{get;set;} 
    public Integer CountTotalRecords{get;set;}       
    public List<Service_Location__c> tmpResults{get;set;}
    public string searchedServiceLocationName{get;set;}
    public string searchedServiceLocationId{get;set;}
    public Integer OffsetSize = 0;
    private Integer QueryLimit = 25;
    public List<cSearchedServiceLocationResults> searchedServiceLocationResultsList {get; set;}
    
    public id paramSvcLocId { get; set; }
    // The method to remove an item from the list
    public PageReference RemoveItem(){
        //locations.remove(paramSvcLocId);  
        system.debug('paramSvcLocId--->'+paramSvcLocId);
        id ContractId=ApexPages.CurrentPage().getparameters().get('id');    
          system.debug('ContractId--->'+ContractId);
          system.debug('myContract.id--->'+myContract.id);
        list<Contract_ServiceLocation_JO__c> csJO=[SELECT id from Contract_ServiceLocation_JO__c 
                                            WHERE Contract__c=:myContract.id 
                                            AND Service_Location__c=:paramSvcLocId];
        if(csJO!=null)
            delete csJO;                                    
        pagereference ref = new pagereference('/apex/CMContract_Form?id='+myContract.id+'&sfdc.override=1');
        ref.setredirect(True);
        return ref;
        //return null;
    }
    
    public id paramSvcLocId2 { get; set; }
    // The method to remove an item from the list
    public PageReference RemoveItem2(){
        //locations.remove(paramSvcLocId);  
        system.debug('paramSvcLocId2--->'+paramSvcLocId2);
        List<cSearchedServiceLocationResults> tmpselectedsLocs=new List<cSearchedServiceLocationResults>();
        for(cSearchedServiceLocationResults cCon : selectedsLocs) {
          if(cCon.sl.id != paramSvcLocId2) {
              tmpselectedsLocs.add(cCon);
          }
        }
        selectedsLocs=tmpselectedsLocs;
        system.debug('selectedsLocs--->'+selectedsLocs);
        return null;
    }    
    
    public List<cSearchedServiceLocationResults> searchedServiceLocationResults{get;set;}
    public List<cSearchedServiceLocationResults> selectedsLocs{get;set;}
    List<Contract_ServiceLocation_JO__c> Contractlocs { get; set; }
      public void processSelected() {
          list<Contract_ServiceLocation_JO__c> locs=new list<Contract_ServiceLocation_JO__c>();
          Contract_ServiceLocation_JO__c location;
          id ContractId=ApexPages.CurrentPage().getparameters().get('id');    
          system.debug('ContractId--->'+ContractId);
          system.debug('myContract.id--->'+myContract.id);      
          if(selectedsLocs==null)
              selectedsLocs = new List<cSearchedServiceLocationResults>();
          set<id> ServiceLocIds=new set<id>();
          system.debug('Locations--->'+Locations);
          if(Locations!=null){
              for(Contract_ServiceLocation_JO__c conServiceLoc : Locations) {
                  ServiceLocIds.add(conServiceLoc.service_location__c);
              }
              system.debug('loc-searchedServiceLocationResults--->'+searchedServiceLocationResults);
              for(cSearchedServiceLocationResults cCon : searchedServiceLocationResults) {
                  if(cCon.selected == true && !ServiceLocIds.contains(cCon.sl.id)) {
                      selectedsLocs.add(cCon);
                      location=new Contract_ServiceLocation_JO__c();
                      location.Contract__c=ContractId;
                      location.Service_Location__c=cCon.sl.id;
                      locs.add(location);
                  }
                  system.debug('selectedsLocs--->'+selectedsLocs);
              }
              system.debug('locs--->'+locs);
              insert locs;
              locations=locs;
          }
          else{
              system.debug('searchedServiceLocationResults--->'+searchedServiceLocationResults);
              /*for(cSearchedServiceLocationResults cCon : searchedServiceLocationResults) {
                  if(cCon.selected == true) {
                      selectedsLocs.add(cCon);
                      location=new Contract_ServiceLocation_JO__c();
                      location.Contract__c=ContractId;
                      location.Service_Location__c=cCon.sl.id;
                      locs.add(location);
                  }
                  system.debug('selectedsLocs--->'+selectedsLocs);
              }
              system.debug('locs--->'+locs);
              insert locs;
              locations=locs;              */
              selectedsLocs = new List<cSearchedServiceLocationResults>();
              for(cSearchedServiceLocationResults cCon : searchedServiceLocationResults) {
                  if(cCon.selected == true) {
                      selectedsLocs.add(cCon);
                  }
              }
              system.debug('selectedsLocs--->'+selectedsLocs);
          }          
      }

    public Integer getOffsetSize(){
        return OffsetSize;
    }
    public Integer searchedServiceLocationResultSize{
        get{
            return (searchedServiceLocationResults!=null) ? searchedServiceLocationResults.size():0;
        }
        set;
    }
    public void resetSearchItems(){
        tmpResults=null;
        searchedServiceLocationResults=null;
        nameFilter=null;
        stateFilter=null;
        cityFilter=null;
        searchedServiceLocationName=null;
        searchedServiceLocationId=null;
        OffsetSize = 0;
        QueryLimit = 25;
        CountTotalRecords = 0;
    }
    public Boolean getDisablePrevious(){
        if(OffsetSize>0){
            return false;
        }
        else return true;
    }

    public Boolean getDisableNext() {
        system.debug('OffsetSize--->'+OffsetSize);
        system.debug('QueryLimit--->'+QueryLimit); 
        system.debug('countTotalRecords--->'+countTotalRecords);                
        if (OffsetSize + QueryLimit < countTotalRecords){
            return false;
        }
        else return true;
    }
    public void First() {
        OffsetSize =0;
        //return null;
    }
    public void Last() {
        Integer tmp=(counttotalrecords/QueryLimit);
        if(Math.mod(counttotalrecords,QueryLimit)==0){
            OffsetSize = (tmp-1)*QueryLimit;
        }else{
            OffsetSize = (tmp)*QueryLimit;
        }
        //return null;
    }
    public void Next() {
        system.debug('Before-OffsetSize--->'+OffsetSize);
        OffsetSize += QueryLimit;
        system.debug('After-OffsetSize--->'+OffsetSize);
        //return null;
    }

    public void Previous() {
        OffsetSize -= QueryLimit;
        //return null;
    }

  public String OperatingGroup{
      get{
          if(operatinggroup!=null && operatinggroup!='' && operatingGroup.equalsIgnoreCase('Care Meridian')){
              operatinggroup = 'CareMeridian';
          }
          return operatinggroup;
      }
      set;
  }

    public void searchRes(){
        isSearchClicked=true;
        tmpResults=null;
        searchedServiceLocationResults=null;
        String qs1='select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where ';
        string qs = '';
    
        //if(!((nameFilter=='' || nameFilter==null)&&(cityFilter=='' || cityFilter==null)&&(stateFilter=='' || stateFilter==null))){
            
            if(!(nameFilter=='' || nameFilter==null)){
                if(nameFilter.contains('*')){
                    qs+=' name like \''+String.escapeSingleQuotes(nameFilter.replace('*','%'))+'\' ';
                }else{
                    qs+=' name = :nameFilter ';
                }
            }
            if(!(cityFilter=='' || cityFilter==null)){
                if(!(nameFilter=='' || nameFilter==null)){
                    if(cityFilter.contains('*')){
                        qs+=' and city__c like \''+String.escapeSingleQuotes(cityFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and city__c = :cityFilter ';
                    }
                }else{
                    if(cityFilter.contains('*')){
                        qs+=' city__c like \''+String.escapeSingleQuotes(cityFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' city__c = :cityFilter ';
                    }
                }
            }
            if(!(stateFilter=='' || stateFilter==null)){
                if(!((nameFilter=='' || nameFilter==null) && (cityFilter=='' || cityFilter==null))){
                    if(stateFilter.contains('*')){
                        qs+=' and state__c like \''+String.escapeSingleQuotes(stateFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' and state__c = :stateFilter ';
                    }
                }else{
                    if(stateFilter.contains('*')){
                        qs+=' state__c like \''+String.escapeSingleQuotes(stateFilter.replace('*','%'))+'\' ';
                    }else{
                        qs+=' state__c = :stateFilter ';
                    }
                }

            }
            if ( qs != '') qs += ' and ';
            //if (this.operatinggroup == 'NeuroRestorative') {
                qs += 'FacilityId__c = 20';
            //} else {
            //    qs += 'FacilityId__c != 20';
            //}
            tmpResults=Database.query(qs1 + qs);
            countTotalRecords=tmpResults.size();
            showAddListLocs();
            
            //return (tmpResults!=null) ? [select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c from service_location__c where id in :tmpResults order by name limit :QueryLimit offset :OffsetSize] : null;
            //system.debug('searchedServiceLocationResultsList--->'+searchedServiceLocationResultsList);
            searchedServiceLocationResultsList=new List<cSearchedServiceLocationResults>();            
            if(tmpResults!=null){
                for(service_location__c sloc : [select name, city__c, state__c, street__c, setting__c, service_value__c, program__c, zip__c, phone__c 
                                                from service_location__c where id in :tmpResults order by name limit :QueryLimit offset :OffsetSize]) {
                    searchedServiceLocationResultsList.add(new cSearchedServiceLocationResults(sloc));
                    
                }
            }
            searchedServiceLocationResults=searchedServiceLocationResultsList;
            
        /*}else{
            tmpResults=null;
            countTotalRecords=0;
        }*/
    }
    
    public boolean editMode {get; set;}
    public boolean isRenewal {get; set;}
    public string oldID =  apexpages.currentpage().getparameters().get('oldid');
    public boolean isClone =  apexpages.currentpage().getparameters().get('isClone') == '1';
    public boolean isRev{ get; set; }
    public string removeid {get; set;}
    public CareMeridian_Contract__c OldContract = new CareMeridian_Contract__c ();
    public CareMeridian_Contract__c getOldContract()
        { return OldContract;}
    public CareMeridian_Contract__c myContract = new CareMeridian_Contract__c ();
    public CareMeridian_Contract__c getmyContract() 
        {return myContract; }
    public map<string, clsRateLevel> MapRateLevel = new Map<string, clsRateLevel>();
    public map<string, clsRateLevel> getMapRateLevel()
        { return MapRateLevel;}
    public list<string> mapRateLevelKeys = new list<string>();
    public list<string> getMapRateLevelKeys() {
        return mapRateLevelKeys;
    }
    public List<SelectOption> changeTypes;  
    public List<String> selectedTypes { get; set;}
    public Boolean isNeuro{get ; set;}
    public Boolean isCM{get ; set;}   
    public CareMeridian_Contract__c rectype {get; set;}
    public CareMeridian_Contract__c oldrectype {get; set;}
    public string tin {get; set;}
    public string npi{get; set;}
    public string tinnpi{get; set;}
    public List<Contract_ServiceLocation_JO__c> locations { get; set; }
    public Contract_ServiceLocation_JO__c location { get; set; }
    
        /*
    public list< CareMeridian_Contract_Rate_and_Level__c>  cmRL = new list< CareMeridian_Contract_Rate_and_Level__c>();
    public list< CareMeridian_Contract_Rate_and_Level__c>  getcmRL() 
        {return cmRL;}
    */
    public CMContract_Form(ApexPages.StandardController controller) {

        myContract = (CareMeridian_Contract__c)controller.getRecord();
        changeTypes = new List<SelectOption>();
        selectedTypes = new List<String>();      
        isRev = false;
        editMode = false;
        isNeuro = false;
        tin='';
        npi='';
        tinnpi='';
        integer s = 0;
        for(CareMeridian_Contract_Rate_and_Level__c item : 
                    [select Sort_Key__c, Bed_Holds__c, Level_1__c, Level_2__c, Level_3__c, Level_4__c, Level_5__c, Level_6__c, Level_7__c, CareMeridian_Contract__c, Details__c 
                        from CareMeridian_Contract_Rate_and_Level__c
                            Where CareMeridian_Contract__c = :myContract.id
                                Order By Sort_Key__c]){
//            cmRL.add( item);
            clsRateLevel tmpRL = new clsRateLevel(item, false);
            MapRateLevel.put(string.valueof(s) + item.id, tmpRL);
            MapRateLevelKeys.add(string.valueof(s) + item.id);
            s++;
        
        }
        if(myContract.id == null || isClone){
            editMode = true;
            mycontract.ownerid = UserInfo.getUserId();
              
         
            if(ApexPages.currentPage().getParameters().get('RecordType') == null && (oldId== null || oldId== '')){
                
                Schema.DescribeSObjectResult describecontract = Schema.SObjectType.CareMeridian_Contract__c;
                List<Schema.RecordTypeInfo> rtInfos = describecontract.getRecordTypeInfos();
                for(Schema.RecordTypeinfo rtInfo: rtInfos){
                    if(rtInfo.getName()!='Master' && rtInfo.isAvailable()){
                        System.debug('The RecordType :' +rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() +' is available');
                        if(rtInfo.getName()=='NeuroRestorative Contracts'){
                            isNeuro=True;
                        }else{
                            isNeuro=False;
                        }
                    
                        
                    }
                }
            }
            RecordType neuroRestorativeContractsRT =[Select r.Id From RecordType r WHERE r.SobjectType='CareMeridian_Contract__c' 
                AND r.DeveloperName='NeuroRestorative_Contracts' AND r.IsActive=True];
            if(neuroRestorativeContractsRT==null) return; 
            if(ApexPages.currentPage().getParameters().get('RecordType')== neuroRestorativeContractsRT.id)
                   
                   isNeuro=True;              
            
        } else {
            rectype = [SELECT ID, RecordTypeID, RecordType.DeveloperName FROM CareMeridian_Contract__c WHERE id=:myContract.id];
            
            system.debug(rectype.RecordType.DeveloperName);
            
            if (rectype.RecordType.DeveloperName =='NeuroRestorative_Contracts'){
                isNeuro=True;
                if(ApexPages.CurrentPage().getparameters().get('id')!=null){
                    locations=[SELECT ID, Service_Location__r.Name, Name, service_location__c,Service_Location_Service_Value__c, Service_Location__r.Setting__c, Service_Location_Program__c,Service_Location_Street__c,Service_Location_City__c,
                                            Service_Location_State__c, Service_Location_Zip__c, LastModifiedDate FROM Contract_ServiceLocation_JO__c WHERE Contract__c=:ApexPages.CurrentPage().getparameters().get('id')];
                    system.debug('locations--->'+locations);
                }
                else
                    locations=new List<Contract_ServiceLocation_JO__c>();
           }

           if (rectype.RecordType.DeveloperName =='CareMeridian_Contracts'){
               isNeuro=False;
           }
            isRev = true;   // want to enter type of change on every update other than brand new contract
           if ( !String.isBlank( myContract.Type_of_Change__c ))
                selectedTypes = myContract.Type_of_Change__c.Split(';');
                
        }
            
         
        
            
        if(oldID != null){
                   
                    String query = 'SELECT ';
                    FieldSet copyfields = isClone 
                                        ? SObjectType.CareMeridian_Contract__c.FieldSets.Full_Clone_Fields
                                        : SObjectType.CareMeridian_Contract__c.FieldSets.Renewal_Fields;
                    for(Schema.FieldSetMember f : copyFields.getFields()) {        
                        query += f.getFieldPath() + ', ';
            
                    }    
                    query += 'Id FROM CareMeridian_Contract__c Where ID =:oldID';    
//                    query += oldID;
//                    query += '\'';
                    OldContract = Database.query(query);
                    System.Debug( oldcontract);
                    isRev = !isClone;   // catches case of new contract that is a revision
                    for(Schema.FieldSetMember f : copyfields.getFields()) {        
                        myContract.put(f.getFieldPath(), OldContract.get(f.getFieldPath()));
                    }
                    integer i = 0;
                    List<CareMeridian_Contract_Rate_and_Level__c>  tmpQ = [select Sort_Key__c, Bed_Holds__c, Level_1__c, Level_2__c, Level_3__c, Level_4__c, Level_5__c, Level_6__c, Level_7__c, CareMeridian_Contract__c, Details__c from CareMeridian_Contract_Rate_and_Level__c Where CareMeridian_Contract__c = :OldContract.id Order By Sort_Key__c];
                    for(CareMeridian_Contract_Rate_and_Level__c item: tmpQ){
                        CareMeridian_Contract_Rate_and_Level__c tmp = new CareMeridian_Contract_Rate_and_Level__c ();
                        tmp = item.clone();
                        clsRateLevel tmpRL = new clsRateLevel(tmp, true);
                        MapRateLevel.put(tmpRL.theRL.Sort_Key__c + string.valueof(i), tmpRL);
                        MapRateLevelKeys.Add(tmpRL.theRL.Sort_Key__c + string.valueof(i));
                        //cmRL.add( tmp) ;   
                        i++;
                    
                    }
                    
                    if(ApexPages.currentPage().getParameters().get('RecordType') == null){
					oldrectype = rectype = [SELECT ID, RecordTypeID, RecordType.DeveloperName FROM CareMeridian_Contract__c WHERE id=:oldId];
						if (rectype.RecordType.DeveloperName =='NeuroRestorative_Contracts')
						isNeuro=True;
						if (rectype.RecordType.DeveloperName =='CareMeridian_Contracts')
						isNeuro=False;
				}        
        
        }
        
            
        //isShowAddLocation=false;                      
    }

    public PageReference myEdit() {
        editMode = true;
        return null;
    }
    public PageReference myAddRL() {
        CareMeridian_Contract_Rate_and_Level__c newRL = new CareMeridian_Contract_Rate_and_Level__c();
        clsRateLevel tmpRL = new clsRateLevel(newRL , true);
        string key = 'Z'+string.valueof(system.now()).remove(' ').remove(':').remove('-');
        MapRateLevel.put(key, tmpRL);
        MapRateLevelKeys.add(key);
      // 'z'+string.valueof(system.now()).remove(' ').remove(':').remove('-'),
        return null ;
    }  
    
    public PageReference removeCRL() {
        system.debug('delete me ' + removeid);
        try{
            if(!MapRateLevel.get(removeid).isNew ){
                delete MapRateLevel.get(removeid).theRL; 
            }
            
            MapRateLevel.remove(removeid);  
            MapRateLevelKeys = ListRemove(MapRateLevelKeys,removeid); 
        }
        catch(Exception e) {
                ApexPages.addMessages(e);
                System.debug('The following exception has occurred: ' + e.getMessage());  
            } 
        return null; 
    }
    
    private list<string> ListRemove(list<string> listobj, string removeValue) {
        list<string> newlist = new list<string>();
        for(string item: listobj){
            if (item != removeValue){
                newlist.add(item);
            }
        }
        return newlist;
    }
    
    public PageReference save() {
        try{
            
            
            if(oldID!= null && !isClone) 
                myContract.Previous_Contract__c = OldContract.id;

            System.Debug( 'selectedTypes1 = ' + selectedTypes + ', isrev=' + isrev);    
            if ( isRev ) {              
                System.Debug( 'selectedTypes2 = ' + selectedTypes); 
                // ECDC-40 01/06/14: record type of change field 
                String strtypes= '';
                for ( String s : selectedTypes ) 
                    strtypes += s + ';';    
                
                if ( strtypes != '' )  {
                    strtypes = strtypes.Substring(0, strtypes.length() - 1); // cut last semicolon off
                    myContract.Type_of_Change__c = strtypes;
                } else {
                    // type of change required for revisions/amendments
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one Type of Change must be selected to Save this record.'));
                     return null;
                } 
                    
                
                
                
            }
            
            upsert myContract;
            
            if(oldID!= null && !isClone){
                oldContract.Renewed__c = true;
                oldContract.Status__c = 'Closed';           
                OldContract.Next_Contract__c = myContract.id;
                update oldcontract;  
            }
            
//            CareMeridian_Contract_Rate_and_Level__c 
            list<CareMeridian_Contract_Rate_and_Level__c>  cmRL = new list<CareMeridian_Contract_Rate_and_Level__c>();
            for(clsRateLevel item: MapRateLevel.values()){
                item.theRL.CareMeridian_Contract__c = myContract.id;
                cmRL.add(item.theRL);
            }
            upsert cmRL;
            
            if(editMode && isNeuro){
              Contract_ServiceLocation_JO__c location;
              list<Contract_ServiceLocation_JO__c> locs=new list<Contract_ServiceLocation_JO__c>();
              for(cSearchedServiceLocationResults cCon : selectedsLocs) {
                  location=new Contract_ServiceLocation_JO__c();
                  location.Contract__c=myContract.id;
                  location.Service_Location__c=cCon.sl.id;
                  locs.add(location);
              }
              system.debug('locs--->'+locs);
              insert locs;
              locations=locs;
            }
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.mycontract);
        
            return ctr.view();             
        
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('The following exception has occurred: ' + e.getMessage());
    
    }    
       return null;
    
 }
 
 public PageReference addtinnpi() {
    if(editMode && myContract.TIN_NPI__c==null){
        tinnpi=tin+' - '+npi+';'+'\n';
    }
    else
        tinnpi=myContract.TIN_NPI__c+'\n'+tin+' - '+npi+';'+'\n';
    tin='';
    npi='';
    myContract.TIN_NPI__c=tinnpi;
    return null;
    
 }
 
  public boolean isSearchClicked{get;set;}
 public void showAddLocation() {
    location = new Contract_ServiceLocation_JO__c();
    isSearchClicked=true;
  }

  public pagereference SearchClicked(){
    isSearchClicked=true;
      return null;
  }

  public boolean isShowAddLocation{get;set;}
  public boolean isReloadPage{get;set;}
  public pagereference showAddLocations(){
      isShowAddLocation=true;
      resetSearchItems();
      return null;      
  }
  public boolean isHideSearchDialog{get;set;}
  public pagereference hideAddLocations(){
      processSelected();        
      isShowAddLocation=false;
      if(!editMode)
          isReloadPage=true;//isModeNew
      else
          isReloadPage=false;
      hideAddListLocs();
      isSearchClicked=false;
      isHideSearchDialog=true;
      return null;
  }
  
  public pagereference selectAllLocations(){
      system.debug('searchedServiceLocationResults--->'+searchedServiceLocationResults);
      for(cSearchedServiceLocationResults cCon : searchedServiceLocationResults) {
          cCon.selected = true;
      }        
      return null;
  }
  
  public pagereference unSelectAllLocations(){
      system.debug('searchedServiceLocationResults--->'+searchedServiceLocationResults);
      for(cSearchedServiceLocationResults cCon : searchedServiceLocationResults) {
          cCon.selected = false;
      }        
      return null;
  }
  
  public boolean isShowListLocs{get;set;}
  public pagereference showAddListLocs(){
      isShowListLocs=true;
      return null;      
  }

  public pagereference hideAddListLocs(){
      isShowListLocs=false;
      return null;
  }  
   
  public List<Attachment> Attachments{
        get{
            
            if(Attachments==null){
                Attachments= [select Id, ParentId, Name, Description from Attachment where parentId=:ApexPages.CurrentPage().getparameters().get('id')];
            }
            return Attachments;
        }
        set;
    }
 
 
    public class clsRateLevel{
        public CareMeridian_Contract_Rate_and_Level__c theRL {get; set;}
        public boolean isNew {get; set;}
    
        public clsRateLevel(CareMeridian_Contract_Rate_and_Level__c tmp, boolean tmpisnew){        
            theRL = tmp;  
            isNew = tmpisnew;
            string shortnow = string.valueof(system.now()).remove(' ').remove(':').remove('-');
            
            if(theRL.Sort_Key__c == null){theRL.Sort_Key__c = shortnow;}
        }
    
    
    } 
    
    public List<SelectOption> getchangeTypes() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult changeType = CareMeridian_Contract__c.Type_of_Change__c.getDescribe();
        //System.Debug( 'ChangeType field describe: ' + changeType );
        for (Schema.PicklistEntry a : changeType.getPickListValues())
            options.add(new SelectOption(a.getLabel(), a.getValue())); 

        //system.debug('Change types: ' +  options);
        return options;
    }    
    
    

}