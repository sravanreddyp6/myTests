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
         String firstNames;
          String LastNames; 
         String age;  
         String state;
         String types;
         Id recordId;
        
         String FirstNMe = SoundEx.ToSoundEx(FirstNM);
         String LastNMe = SoundEx.ToSoundEx(LastNM);
         
      // person being served     
    
     
      for(Contact cnt:[select Id,Name,FirstName,LastName,Age__c,Account.First_Name_SoundEx_Key__c,Account.Last_Name_SoundEx_Key__c,Account.BillingState,(select Person_Being_Served__r.Name,Person_Being_Served__c,State__c from Episodes__r) from Contact where (Account.First_Name_SoundEx_Key__c=:FirstNMe or Account.Last_Name_SoundEx_Key__c=:LastNMe) and (FirstName!=null or LastName!=null)]){
        
             firstNames = cnt.FirstName;
             LastNames = cnt.LastName;
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
              recordId = cnt.AccountId;
              
                AppWrapper.add(new wrapper(firstNames,LastNames,age,state,types,recordId));
         
       }
       
       //Person Being Referre
       
      for(Person_Being_Referred__c pbr:[select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c,(select Name,State_for_Preferred_Service__c,Name_PBR__c,Person_Being_Referred__r.Name,Person_Being_Referred__c from Referrals__r) from Person_Being_Referred__c where (First_Name_SoundEx_Key__c =:FirstNMe or Last_Name_SoundEx_Key__c =:LastNMe) and (First_Name__c!=null or Last_Name__c!=null)]){
       //  if(pbr.First_Name__c!=null || pbr.Last_Name__c!=null){
             firstNames = pbr.First_Name__c;
             LastNames = pbr.Last_Name__c;
            age = String.valueOf(pbr.Age__c);
            for(Referral__c ref:pbr.Referrals__r){
                if(ref.State_for_Preferred_Service__c!=null && ref.Person_Being_Referred__c==pbr.Id){
                    state = ref.State_for_Preferred_Service__c;
                }else{
                    state = pbr.State__c;
                }
               
            }
            types = 'Person Being Referred';
            recordId = pbr.Id;
             
            AppWrapper.add(new wrapper(firstNames,LastNames,age,state,types,recordId));
       // }
       }
       
      // Mentor
        
        for(TMN_Contact__c tmn:[select Id,Name,First_Name__c,First_Name_SoundEx_Key__c,Last_Name__c,Last_Name_SoundEx_Key__c,Full_Name__c,Age__c,State__c from TMN_Contact__c where (First_Name_SoundEx_Key__c =:FirstNMe or Last_Name_SoundEx_Key__c =:LastNMe) and (First_Name__c!=null or Last_Name__c!=null)])  {
             
          // if(tmn.First_Name__c!=null || tmn.Last_Name__c!=null){  
             firstNames = tmn.First_Name__c;
             LastNames = tmn.Last_Name__c;
            
            age = String.valueOf(tmn.Age__c);
            state = tmn.State__c;
            types = 'Mentor';
            recordId = tmn.Id;
           
            AppWrapper.add(new wrapper(firstNames,LastNames,age,state,types,recordId));
         // }
        }
        
        return AppWrapper;
    }
    public class wrapper{
         public String firstname{get;set;}
         public String lastname{get;set;}
         public String Age{get;set;}
         public String State{get;set;}
         public String Type{get;set;}
         public Id recordId{get;set;}
         public String Names{get;set;}
         public wrapper(String firstNames,String LastNames,String age,String state,String types,Id recordId){
             this.firstname = firstNames;
             this.lastname = LastNames;
             this.Age = age;
             this.State = state;
             this.Type = types;
             this.recordId = recordId;
             
          }
     }
}