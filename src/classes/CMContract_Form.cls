public with sharing class CMContract_Form {
    public boolean editMode {get; set;}
    public boolean isRenewal {get; set;}
    public string oldID =  apexpages.currentpage().getparameters().get('oldid');
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
    public List<SelectOption> changeTypes;  
    public List<String> selectedTypes { get; set;}
    public Boolean isNeuro{get ; set;}
    public Boolean isCM{get ; set;}   
    public CareMeridian_Contract__c rectype {get; set;}
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
            s++;
        
        }
        if(myContract.id == null){
            editMode = true;
            mycontract.ownerid = UserInfo.getUserId();
              
         
            if(ApexPages.currentPage().getParameters().get('RecordType') == null){
            	
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
            rectype = [SELECT ID, RecordTypeID, RecordType.DeveloperName FROM CareMeridian_Contract__c WHERE id=:ApexPages.CurrentPage().getparameters().get('id')];
            
            system.debug(rectype.RecordType.DeveloperName);
            
            if (rectype.RecordType.DeveloperName =='NeuroRestorative_Contracts'){
                isNeuro=True;
                locations=[SELECT ID, Name, service_location__c,Service_Location_Service_Value__c, Service_Location__r.Setting__c, Service_Location_Program__c,Service_Location_Street__c,Service_Location_City__c,
                						Service_Location_State__c, Service_Location_Zip__c,	LastModifiedDate FROM Contract_ServiceLocation_JO__c WHERE Contract__c=:ApexPages.CurrentPage().getparameters().get('id')];
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
                    for(Schema.FieldSetMember f : SObjectType.CareMeridian_Contract__c.FieldSets.Renewal_Fields.getFields()) {        
                        query += f.getFieldPath() + ', ';
            
                    }    
                    query += 'Id FROM CareMeridian_Contract__c Where ID =\'';    
                    query += oldID;
                    query += '\'';
                    OldContract = Database.query(query);
                    System.Debug( oldcontract);
                    isRev = true;   // catches case of new contract that is a revision
                    for(Schema.FieldSetMember f : SObjectType.CareMeridian_Contract__c.FieldSets.Renewal_Fields.getFields()) {        
                        myContract.put(f.getFieldPath(), OldContract.get(f.getFieldPath()));
                    }
                    integer i = 0;
                    List<CareMeridian_Contract_Rate_and_Level__c>  tmpQ = [select Sort_Key__c, Bed_Holds__c, Level_1__c, Level_2__c, Level_3__c, Level_4__c, Level_5__c, Level_6__c, Level_7__c, CareMeridian_Contract__c, Details__c from CareMeridian_Contract_Rate_and_Level__c Where CareMeridian_Contract__c = :OldContract.id Order By Sort_Key__c];
                    for(CareMeridian_Contract_Rate_and_Level__c item: tmpQ){
                        CareMeridian_Contract_Rate_and_Level__c tmp = new CareMeridian_Contract_Rate_and_Level__c ();
                        tmp = item.clone();
                        clsRateLevel tmpRL = new clsRateLevel(tmp, true);
                        MapRateLevel.put(tmpRL.theRL.Sort_Key__c + string.valueof(i), tmpRL);
                        //cmRL.add( tmp) ;   
                        i++;
                    
                    }        
        
        }
        
      		
                      
    }

    public PageReference myEdit() {
        editMode = true;
        return null;
    }
    public PageReference myAddRL() {
        CareMeridian_Contract_Rate_and_Level__c newRL = new CareMeridian_Contract_Rate_and_Level__c();
        clsRateLevel tmpRL = new clsRateLevel(newRL , true);
        MapRateLevel.put('Z'+string.valueof(system.now()).remove(' ').remove(':').remove('-'), tmpRL);
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
        }
        catch(Exception e) {
                ApexPages.addMessages(e);
                System.debug('The following exception has occurred: ' + e.getMessage());  
            } 
        return null; 
    }
    
    public PageReference save() {
        try{
            
            
            if(oldID!= null) 
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
            
            if(oldID!= null){
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
            
            
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.mycontract);
        
            return ctr.view();             
        
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            System.debug('The following exception has occurred: ' + e.getMessage());
    
    }    
       return null;
    
 }
 
 public PageReference addtinnpi(){
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
 
 public void showAddLocation() {
    location = new Contract_ServiceLocation_JO__c();
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