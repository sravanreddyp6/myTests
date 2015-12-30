public with sharing class PBS_AddTask_Page {

	public Task tsk {get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public PBS_AddTask_Page(ApexPages.StandardController stdController) {
        tsk = (Task)stdController.getRecord();
        if (tsk.WhatId == null){
            tsk.WhatId = ApexPages.currentPage().getParameters().get('accID');
            tsk.WhoID = ApexPages.currentPage().getParameters().get('pbs');
        }
        if(tsk.OwnerID == null){
            tsk.OwnerID = UserInfo.getUserId();
        }
    }
    public PageReference save(){
        upsert tsk;
        pageReference ref = new pageReference('/' + ApexPages.currentPage().getParameters().get('pbs'));
        ref.setRedirect(true);
        return ref;
    }
    public PageReference cancel(){
        pageReference ref = new pageReference('/' + ApexPages.currentPage().getParameters().get('pbs'));
        ref.setRedirect(true);
        return ref;
    }
}