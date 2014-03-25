public with sharing class HomePageController{
    public final String OperatingGroup = [select operating_group__c from user where id=:UserInfo.getUserId() limit 1].operating_group__c;
    public static Map<String,Schema.SObjectType> gSchema;   
    public Map<String,String> sObjNamesMap{get;set;}
    public List<String> objname{get;set;}
    public List<wrapper> AppWrapper = new List<wrapper>();
    public String viewstsk{get;set;}
    public String FrstName{get;set;}
    public String LstName{get;set;}
    public boolean displayPop{get;set;}
     public String objectName{get;set;}
     
   private static Set<String> sObjNamesSet; 
      //declaration of variables
      public List<Report> refrportlst{get;set;}
      public List<Report> PBSrportlst{get;set;}
      public List<Report> contractrportlst{get;set;}
      public List<Report> docrportlst{get;set;}
      public List<Task> populateTasks{get;set;}
      public List<VF_Reports__c> VFReportlst{get;set;}
  
      public boolean RefCreate{get;set;}
      public boolean RefView{get;set;}
      public boolean PBSView{get;set;}
      public boolean PBSCreate{get;set;}
      public boolean TMNCreate{get;set;}
      public boolean TMNView{get;set;}
      public boolean ContractCreate{get;set;}
      public boolean ContractView{get;set;}
      public boolean DocCreate{get;set;}
      public boolean DocView{get;set;}
      public boolean Refresh=false;
      
      public String RefId;
      public String RedCntrctId;
      public String ESDbillingId;
      public String ESDActivityId;
      public String ESDSupyId;
      public String CareCntrctId;
      public String TypObj;
      
      
      //Constructor
     public HomePageController(){
  
        shareobj();
        reports();
        mineTasks();
       
     
    }
    //Wrapper class for Approvals
    public List<wrapper> getListApprovals(){
        if(Refresh==false){
        gSchema = Schema.getGlobalDescribe();   
        sObjNamesMap = new Map<String,String>{};
        sObjNamesSet = gSchema.keyset();
        for(String sobj:sObjNamesSet){
                 Schema.DescribeSObjectResult oSchema = gSchema.get(sobj).getDescribe();
                 String tempName = oSchema.getName();
                 String tempPrefix = oSchema.getKeyPrefix();   
                 sObjNamesMap.put(tempPrefix, tempName);   
               
        }
        
        for(ProcessInstanceWorkitem app:[select Id,ProcessInstanceId,CreatedDate,ActorId,CreatedById,CreatedBy.Name,ProcessInstance.LastModifiedBy.Name,ProcessInstance.TargetObject.Name,ProcessInstance.LastModifiedById,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() order by CreatedDate desc]){
                String sub = app.ProcessInstance.TargetObjectId;
                String IdType = sub.substring(0,3);
                String Type = sObjNamesMap.get(IdType);
                
                AppWrapper.add(new wrapper(app.Id,app.ProcessInstance.TargetObjectId,app.ProcessInstance.LastModifiedById,app.ProcessInstance.LastModifiedBy.Name,app.CreatedDate,app.ProcessInstance.TargetObject.Name,Type));
                
        }
        
        
        Refresh = true;
        }
        return AppWrapper;
    }
    //Block visibility check
    public void shareobj(){
        Schema.DescribeSObjectResult oSchema4;
      
         //Referral object
         Schema.DescribeSObjectResult oSchema1 = Referral__c.sObjectType.getDescribe();
         RefCreate = oSchema1.IsCreateable();
         RefView = oSchema1.isAccessible();
         //PBS object
         Schema.DescribeSObjectResult oSchema2 = Account.sObjectType.getDescribe();
         PBSCreate = oSchema2.IsCreateable();
         PBSView = oSchema2.isAccessible();
         //TMN object
         Schema.DescribeSObjectResult oSchema3 = TMN_Contact__c.sObjectType.getDescribe();
         TMNCreate = oSchema3.IsCreateable();
         TMNView = oSchema3.isAccessible();
         //Contract object
         List<TMN_User__c> tmnUsers = [SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c= :UserInfo.getUserId() LIMIT 1];
       
          
         for(TMN_User__c tmn:tmnUsers){
             if(tmn.Operating_Group__c=='Cambridge'){
                 oSchema4 = TMN_Contract__c.sObjectType.getDescribe();
             }else if(tmn.Operating_Group__c=='CareMeridian'){
                 oSchema4 = CareMeridian_Contract__c.sObjectType.getDescribe();
             }else if(tmn.Operating_Group__c=='NeuroRestorative' || tmn.Operating_Group__c=='Redwood'){
                oSchema4 = Redwood_Contract__c.sObjectType.getDescribe();
             }
         
         }
        
         ContractCreate = oSchema4.IsCreateable();
         ContractView = oSchema4.isAccessible(); 
        
         //Doc object
         Schema.DescribeSObjectResult oSchema5 = Document__c.sObjectType.getDescribe();
         DocCreate = oSchema5.IsCreateable();
         DocView = oSchema5.isAccessible();
       
        
        
        
    }
     //Wrapper class
     public class wrapper{
      public Id TAction{get;set;}
      public Id TRelated{get;set;}
      public String TobjName{get;set;}
      public String TType{get;set;}
      public Id MostRecent{get;set;}
      public String LMName{get;set;}
      public Datetime cDate{get;set;}
      
      public wrapper(Id Id,Id TId,Id LId,String LName,Datetime cdate,String TName,String Type){
        this.Taction = Id;
        this.TRelated = TId;
        this.TobjName = TName;
        this.MostRecent = LId;
        this.LMName = LName;
        this.cDate = cdate;
        this.TType = Type;
        
        
      }
     }

    public string referralPrefix {
        get { 
                Schema.DescribeSObjectResult d = Referral__c.sObjectType.getDescribe();
               
                return d.getKeyPrefix();
        }
        private set;
    }

  public Map<String, String> personsBeingServedViews {
    get {
        if (personsBeingServedViews != null) {
            return personsBeingServedViews;
        }
        personsBeingServedViews = new Map<String, String>();
        String query = 'SELECT ID FROM Account';
        ApexPages.StandardSetController con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        SelectOption[] options = con.getListViewOptions();
        for (SelectOption option : options) {
           
            if (option.getLabel().toLowerCase().indexOf('all persons being served')!=-1) {
                personsBeingServedViews.put('all', option.getValue());
            } else if (option.getLabel().toLowerCase().indexOf('recently viewed')!=-1) {
                personsBeingServedViews.put('recent', option.getValue());
            } else if (option.getLabel().toLowerCase().indexOf('new this week')!=-1) {
                personsBeingServedViews.put('new', option.getValue());
            } else if (option.getLabel().toLowerCase().indexOf('my persons being served')!=-1) {
                personsBeingServedViews.put('my', option.getValue());
            }
        }
       
        return personsBeingServedViews;
    }
    set;
  }
  public Map<String, String> ReferralViews {
    get {
        if (ReferralViews != null) {
            return ReferralViews;
        }
        ReferralViews = new Map<String, String>();
        String query2 = 'SELECT ID FROM Referral__c';
        ApexPages.StandardSetController con2 = new ApexPages.StandardSetController(Database.getQueryLocator(query2));
        SelectOption[] options2 = con2.getListViewOptions();
        for (SelectOption option2 : options2) {
           
            if (option2.getLabel().toLowerCase().indexOf('all')!=-1) {
                ReferralViews.put('all', option2.getValue().substring(0,15));
            } else if (option2.getLabel().toLowerCase().indexOf('my referrals')!=-1) {
                ReferralViews.put('my', option2.getValue().substring(0,15));
            }
        }
       
        return ReferralViews;
    }
    set;
  }
  public Map<String, String> DocViews {
    get {
        if (DocViews != null) {
            return DocViews;
        }
        DocViews = new Map<String, String>();
        String query1 = 'SELECT ID FROM Document__c';
        ApexPages.StandardSetController con1 = new ApexPages.StandardSetController(Database.getQueryLocator(query1));
       
        SelectOption[] options1 = con1.getListViewOptions();
       
        for (SelectOption option1 : options1) {
            
             if (option1.getLabel().toLowerCase().indexOf('all')!=-1) {
                DocViews.put('all', option1.getValue().substring(0,15));
            } else if (option1.getLabel().toLowerCase().indexOf('Cambridge BP DocView')!=-1) {
                DocViews.put('cambridge', option1.getValue().substring(0,15));
            } 
        }
        
        
        return DocViews;
    }
    set;
  }
   public Map<String, String> TMNViews {
    get {
        if (TMNViews != null) {
            return TMNViews;
        }
        TMNViews = new Map<String, String>();
        String query4 = 'SELECT ID FROM TMN_Contact__c';
        ApexPages.StandardSetController con4 = new ApexPages.StandardSetController(Database.getQueryLocator(query4));
       
        SelectOption[] options4 = con4.getListViewOptions();
       
        for (SelectOption option4 : options4) {
            
     
            
             if (option4.getLabel().toLowerCase().indexOf('my')!=-1) {
                TMNViews.put('my', option4.getValue().substring(0,15));
            } 
        }
        
      
        return TMNViews;
    }
    set;
  }
   
   public List<Report> reports() {
   	      String ESDAct,ref,Care,ESDbill,ESDsup,Red;
          VF_Reports__c vf = VF_Reports__c.getInstance();
          VFReportlst = [SELECT Name,Id,Name__c,Description__c,link__c from VF_Reports__c];
          for(Folder tmp:[SELECT AccessType,Id,IsReadonly,Name,DeveloperName,Type FROM Folder WHERE Type = 'Report']){
      
              if(tmp.DeveloperName=='Referrals'){
                RefId = tmp.Id;
                 
                }else if(tmp.DeveloperName=='CareMeridian_Contracts'){
                    CareCntrctId = tmp.Id;
                 
                }else if(tmp.DeveloperName=='ESD_Activity'){
                    ESDActivityId = tmp.Id;
                    ESDAct = 'ESDAct';
                 }
                 else if(tmp.DeveloperName=='ESD_Billing'){
                    ESDbillingId = tmp.Id;
                 }
                 else if(tmp.DeveloperName=='ESD_Supervisory'){
                    ESDSupyId = tmp.Id;
                 }
                 else if(tmp.DeveloperName=='Redwood_Contracts'){
                    RedCntrctId = tmp.Id;
                 }         
            }
            
            refrportlst = report(RefId,ref);
            contractrportlst = report(RedCntrctId,Red);
            docrportlst = report(ESDActivityId,ESDAct);
            
            for(Report rpt:report(CareCntrctId,Care)){
                contractrportlst.add(rpt);
            }
            
            PBSrportlst = report(ESDActivityId,ESDAct);
             for(Report rpt1:report(ESDbillingId,ESDbill)){
                PBSrportlst.add(rpt1);
            }
            
             for(Report rpt2:report(ESDSupyId,ESDsup)){
                PBSrportlst.add(rpt2);
            }
           
            return null;
 }
 public List<Report> report(Id ownId,String ReportText){
 	String query = 'SELECT Name, Id,OwnerId, description, DeveloperName, SystemModstamp FROM report where OwnerId=:ownId';
 	if(ReportText!=null && ReportText=='ESDAct'){
 		query+=' and description like \'%#notes%\' order by name'; 
 	}else{
 		query+= ' order by name';
 	}
 	
 	List<Report> tempreport = database.query(query);
 	return tempreport;
 }
  

  public List<SelectOption> getviewvalues() {
    List<SelectOption> Options = new List<SelectOption>();
    Options.add(new SelectOption('All Open','All Open'));
    Options.add(new SelectOption('Overdue','Overdue'));
    Options.add(new SelectOption('Today','Today'));
    Options.add(new SelectOption('Today+Overdue','Today+Overdue'));
    Options.add(new SelectOption('Tomorrow','Tomorrow'));
    Options.add(new SelectOption('Next 7 Days','Next 7 Days'));
    Options.add(new SelectOption('Next 7 Days+Overdue','Next 7 Days+Overdue'));
    Options.add(new SelectOption('This Month','This Month'));
    
    return Options;
  }
  public void mineTasks(){
    system.debug('came here');
   Id userId = UserInfo.getUserId();
    String query ='select id, subject,WhatId,What.Name,WhoId,Who.Name,status,RecordTypeId, ActivityDate, Priority from Task where OwnerId=:userId and status!=\'Completed\'';
    system.debug('*********viewstsk'+viewstsk);
            if(viewstsk==null || viewstsk=='All Open'){
                query+=' order by ActivityDate desc, Priority limit 25';
            }
            else if (viewstsk=='Overdue'){
                query+='and ActivityDate<TODAY order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='Today'){
                query+='and ActivityDate=TODAY order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='Today+Overdue'){
                query+='and ActivityDate<=TODAY order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='Tomorrow'){
                query+='and ActivityDate=TOMORROW order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='Next 7 Days'){
                query+='and ActivityDate=NEXT_WEEK order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='Next 7 Days+Overdue'){
                query+='and ActivityDate<=NEXT_WEEK order by ActivityDate desc, Priority limit 25';
            }else if (viewstsk=='This Month'){
                query+='and ActivityDate=THIS_MONTH order by ActivityDate desc, Priority limit 25';
            }else {
                query+=' order by ActivityDate desc, Priority limit 25';
            }
    //and RecordTypeId = :Utility.getRecordTypeForTask('Referral Tasks')
    
      populateTasks = database.query(query);     
                   
  }
  public PageReference getsearchNames(){
  
    try {
    	  if((FrstName!=null && FrstName!='') || (LstName!=null && LstName!='')){
           	system.debug('coming here');
           	 displayPop = false;
           	  PageReference newocp= new PageReference('/apex/HomePage_Search?FirstNM='+FrstName+'&&LastNM='+LstName);
              newocp.setRedirect(true);
              return newocp;
  	      }
      
         else{
       
          	displayPop = true;
          	return null;
          }
                
    } catch (DMLException e) {
    	
		      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error opening the Search Results.'));
		      return null;
    
    }
      
    return null;
  }
 
  
}