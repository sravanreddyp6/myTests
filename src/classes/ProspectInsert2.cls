public class ProspectInsert2{

    public Prospects__c myProspect {get; set;}
    public boolean success {get;set;}
    
    public ProspectInsert2(){
        myProspect = new Prospects__c();
        myProspect.Entry_Point__c = 'Web';
        success = false;
        if(ApexPages.currentPage().getParameters().containsKey('cid__c'))
            myProspect.cid__c = ApexPages.currentPage().getParameters().get('cid__c');
        if(ApexPages.currentPage().getParameters().containsKey('org__c'))
            myProspect.org__c = ApexPages.currentPage().getParameters().get('org__c');
        if(ApexPages.currentPage().getParameters().containsKey('rs__c'))
            myProspect.rs__c = ApexPages.currentPage().getParameters().get('rs__c');
        if(ApexPages.currentPage().getParameters().containsKey('tp__c'))
            myProspect.tp__c = ApexPages.currentPage().getParameters().get('tp__c');
        if(ApexPages.currentPage().getParameters().containsKey('tag__c'))
            myProspect.tag__c = ApexPages.currentPage().getParameters().get('tag__c');
    }
        

    
            public PageReference SubmitMADAH(){
      try{
              list <Prospects__c> myList = [select Id,Email__c,Multiple_Inquiry_Comments__c from Prospects__c where Email__c = :myProspect.Email__c];
        
                if(myList.size()> 0){
                    prospects__c temp = myList[0];
                    date currentDate = date.Today();
                    string strCurrentDate = currentDate.month()+'/'+currentDate.day()+'/'+currentDate.year();
                    string currentInquiryComment = temp.Multiple_Inquiry_Comments__c;
            
            
                    if(currentInquiryComment==null){currentInquiryComment='';}
                    temp.Multiple_Inquiry_Comments__c = currentInquiryComment+'<b>Date Inquiry Added: </b>'+strCurrentDate+'<br/><b>Name: </b>'+myProspect.First_Name__c+' '+myProspect.Name+'<br/><b>Phone #: </b>'+myProspect.Primary_Phone__c+'<br/><b>Comments: </b>'+myProspect.Prospect_Comments__c+'<br/><br/>';
            

                    update temp;  
                }
            else{insert myProspect;}
        }
        catch (DMLException ex){
            ApexPages.addMessages(ex);
            return null;
        }
    
       
          PageReference tyPage = Page.ProspectWebRegistrationFormThankyouMADAH;
        //  tyPage.setRedirect(true);
          return tyPage;

    }
    
    private static testmethod void controllerTest(){
        //Campaign c = new Campaign();
        //c.name = 'Test Campaign';
        //insert c;
        //ApexPages.currentPage().getParameters().put('campaignid', c.id);
            ProspectInsert2 controller = new ProspectInsert2();    
    String nextPage = controller.SubmitMADAH().getUrl();
        
        ApexPages.currentPage().getParameters().put('cid__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('rs__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('org__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tp__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tag__c', '00000000000000');
        ProspectInsert2 pi11 = new ProspectInsert2();
        pi11.myProspect.zip__c = '55555';
        pi11.myProspect.Entry_Point__c = 'Web';
        pi11.myProspect.State__c = 'AL';
        controller.SubmitMADAH();
        System.assertEquals(false, pi11.success);
        System.assertEquals('/apex/prospectwebregistrationformthankyoumadah', nextPage );
        
        
     
               
    }
}