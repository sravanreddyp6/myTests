public with sharing class HomePageSearchController{
	
	//declaring variables
   public String FirstNM{get;set;}
   public String LastNM{get;set;}
   public List<wrapper> AppWrapper = new List<wrapper>();

 // constructor
 public HomePageSearchController(){
 	FirstNM = ApexPages.currentPage().getParameters().get('FirstNM');
 	LastNM = ApexPages.currentPage().getParameters().get('LastNM');
 }
   //wrapper return method
    public List<wrapper> getTotalList(){
         String fullname; 
         String age;  
         String state;
         String types;
         Id recordId;
         String Names;
         String FirstNMe = FirstNM + '%';
         String LastNMe = LastNM + '%';
      // person being served     
    
      List<Contact> tempList1 = [select Id,Name,FirstName,First_Name_SoundEx_Key__c,LastName,Last_Name_SoundEx_Key__c,Age__c,Account.BillingState,(select Person_Being_Served__r.Name,Person_Being_Served__c,State__c from Episodes__r) from Contact where FirstName like:FirstNMe and LastName like:LastNMe];
      system.debug('**************************tempList1'+tempList1);
      for(Contact cnt:[select Id,Name,FirstName,First_Name_SoundEx_Key__c,LastName,Last_Name_SoundEx_Key__c,Age__c,Account.BillingState,(select Person_Being_Served__r.Name,Person_Being_Served__c,State__c from Episodes__r) from Contact where FirstName like:FirstNMe and LastName like:LastNMe]){
         
             fullname = cnt.LastName + ', ' + cnt.FirstName;
             age = String.valueof(cnt.Age__c);
             for(Admission__c adm:cnt.Episodes__r){
                if(adm.Person_Being_Served__c==cnt.AccountId && adm.State__c!=null){
                    state = adm.State__c;
                }
                else{
                    state = cnt.Account.BillingState;
                }
             }
             
              types = 'Person Being Served';
              recordId = cnt.Id;
              Names = cnt.Name;
                AppWrapper.add(new wrapper(fullname,age,state,types,recordId,Names));
       }
       
       //Person Being Referred
       List<Person_Being_Referred__c> tempList2 = [select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c,(select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where First_Name__c like:FirstNMe and Last_Name__c like :LastNMe];
      system.debug('**************************tempList2'+tempList2);
      for(Person_Being_Referred__c pbr:[select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c,(select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where First_Name__c like:FirstNMe and Last_Name__c like :LastNMe]){
            fullname = pbr.Last_Name__c + ', ' + pbr.First_Name__c;
            age = String.valueOf(pbr.Age__c);
            for(Referral__c ref:pbr.Referrals__r){
                if(ref.State_for_Preferred_Service__c!=null && ref.Person_Being_Referred__c==pbr.Id){
                    state = ref.State_for_Preferred_Service__c;
                }else{
                    state = pbr.State__c;
                }
                Names = ref.Name;
            }
            types = 'Person Being Referred';
            recordId = pbr.Id;
             
            AppWrapper.add(new wrapper(fullname,age,state,types,recordId,Names));
       }
       
      // Mentor
      List<TMN_Contact__c> tempList3 = [select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c from TMN_Contact__c where First_Name__c like:FirstNMe and Last_Name__c like:LastNMe];
      system.debug('**************************tempList3'+tempList3);
        for(TMN_Contact__c tmn:[select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c from TMN_Contact__c where First_Name__c like:FirstNMe and Last_Name__c like:LastNMe])  {
            fullname = tmn.Last_Name__c + ', ' + tmn.First_Name__c;
            age = String.valueOf(tmn.Age__c);
            state = tmn.State__c;
            types = 'Mentor';
            recordId = tmn.Id;
             Names = tmn.Name;
            AppWrapper.add(new wrapper(fullname,age,state,types,recordId,Names));
        }
        
        return AppWrapper;
    }
    public class wrapper{
         public String FullName{get;set;}
         public String Age{get;set;}
         public String State{get;set;}
         public String Type{get;set;}
         public Id recordId{get;set;}
         public String Names{get;set;}
         public wrapper(String fullname,String age,String state,String types,Id recordId,String Names){
             this.FullName = fullname;
             this.Age = age;
             this.State = state;
             this.Type = types;
             this.recordId = recordId;
             this.Names = Names;
          }
     }
}