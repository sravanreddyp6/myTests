public class ProspectInsert{

    public Prospects__c myProspect {get; set;}
    public boolean success {get;set;}
    
    public ProspectInsert(){
        myProspect = new Prospects__c();
        myProspect.Entry_Point__c = 'Web';
        success = false;
        /*if(ApexPages.currentPage().getParameters().containsKey('campaignid'))
            try{
                myProspect.campaign_id__c = ApexPages.currentPage().getParameters().get('campaignid');
            }
            catch (Exception ex){
                //do nothing this is just in case the campaign id is not the correct format
            }*/
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
        
    public PageReference Submit(){
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
        success = true;
        return null;
    }
    
    private static testmethod void controllerTest(){
        //Campaign c = new Campaign();
        //c.name = 'Test Campaign';
        //insert c;
        //ApexPages.currentPage().getParameters().put('campaignid', c.id);
        ApexPages.currentPage().getParameters().put('cid__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('rs__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('org__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tp__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tag__c', '00000000000000');
        ProspectInsert pi = new ProspectInsert();
        pi.myProspect.zip__c = '55555';
        pi.myProspect.Entry_Point__c = 'Web';
        pi.myProspect.State__c = 'AL';
        pi.myProspect.Email__c = '123@321.com';
        pi.Submit();
        pi.myProspect.zip__c = '55555';
        pi.myProspect.Entry_Point__c = 'Web';
        pi.myProspect.State__c = 'AL';
        pi.myProspect.Email__c = '123@321.com';        
        pi.Submit();
      //  System.assertEquals(false, pi.success);
     //   System.assertEquals(null, pi.Submit());
        
        ApexPages.currentPage().getParameters().put('cid__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('rs__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('org__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tp__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tag__c', '00000000000000');
        ProspectInsert pi2 = new ProspectInsert();
        pi2.myProspect.zip__c = '55330';
        pi2.myProspect.Entry_Point__c = 'Web';
        pi2.myProspect.State__c = 'WI';
        System.assertEquals(false, pi2.success);
        System.assertEquals(null, pi2.Submit());
        
        ApexPages.currentPage().getParameters().put('cid__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('rs__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('org__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tp__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tag__c', '00000000000000');
        ProspectInsert pi3 = new ProspectInsert();
        pi3.myProspect.zip__c = '60420';
        pi3.myProspect.Entry_Point__c = 'Web';
        pi3.myProspect.State__c = 'IL';
        System.assertEquals(false, pi3.success);
        System.assertEquals(null, pi3.Submit());
            
        
        ApexPages.currentPage().getParameters().put('cid__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('rs__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('org__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tp__c', '00000000000000');
        ApexPages.currentPage().getParameters().put('tag__c', '00000000000000');
        ProspectInsert pi4 = new ProspectInsert();
        pi4.myProspect.zip__c = '00000';
        pi4.myProspect.Entry_Point__c = 'Web';
        pi4.myProspect.State__c = 'MA';
        System.assertEquals(false, pi4.success);
        System.assertEquals(null, pi4.Submit());
               
    }
}