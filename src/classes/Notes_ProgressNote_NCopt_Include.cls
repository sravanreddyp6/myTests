public with sharing class Notes_ProgressNote_NCopt_Include {

    public List<SelectOption> soRelParties { get; set; } 
    public List<string> strSelectedParties { get; set; }
    public Progress_Note__c thePN { get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Notes_ProgressNote_NCopt_Include(ApexPages.StandardController stdController) {
        this.thePN = (Progress_Note__c)stdController.getRecord();
        constructClass();
    }
    public void constructClass(){
        strSelectedParties = new list<string>(); 
        soRelParties = new List<SelectOption>();  
        soRelParties.Add( new SelectOption( '', '--None--'));   
        for ( Related_Party__c rp :  
                [ select id, name, type__c from related_party__c where person_being_served__c = :thePN.Person_Being_Served__c and type__c in ('Physician - Primary') ORDER BY Name] ) {
          // create the list of options
          soRelParties.Add( new SelectOption( rp.Name, rp.Name));
        }  
        /*  
        if(!String.isBlank(thePN.Primary_Care_Provider_Name__c))
              strSelectedParties = thePN.Primary_Care_Provider_Name__c.split(';');                     
        */
        }
        

    public PageReference SaveParties() {
    	/*
    }
      string primaryCareNames ='';
        for(String f : strSelectedParties )
          primaryCareNames += f+';';
        
        if(primaryCareNames !=''){
                //chop the last ;
                primaryCareNames = primaryCareNames.Substring (0,primaryCareNames.length() -1);
                thePN.Primary_Care_Provider_Name__c = primaryCareNames;
        }
        else{
            thePN.Primary_Care_Provider_Name__c ='';
        }
        */
      update thePN;
      return null;
      
    }    


}