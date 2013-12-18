public with sharing class Notes_ProgressNote_Create {


//varibles
    public list<RecordType> myRTs = new list<RecordType>();
    public list<RecordType> getmyRTs(){return myRTs;}

    public string RTid;
    public string myState = ApexPages.currentPage().getParameters().get('state');
    public Id AZ_OPT_ID;
    public String pbsName { get; set; }

    public list<SelectOption> rtOptions = new list<SelectOption>();
    public list<SelectOption> getrtOptions(){return rtOptions ;}



//contructs
    public Notes_ProgressNote_Create(ApexPages.StandardController controller) {
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c'];
        for (RecordType rt: myRTs) {
            if (rt.Name == 'AZ - OPT') {
                AZ_OPT_ID = rt.Id;
            }
        }
        String pbsId = ApexPages.currentPage().getParameters().get('person');
        if (!String.isBlank(pbsId)) {
            pbsName = [SELECT Name FROM Contact WHERE Id=:pbsId].Name;
        }
        if (!Test.isRunningTest()) {
            controller.addFields(new String[] {'RecordType.Name'});
        }
        Progress_Note__c pn = (Progress_Note__c) controller.getRecord();
        // If Progress Note is AZ-OPT, we have to default some fields here
        if (myState == 'AZ') {
            pn.Number_of_Required_Signatures__c = 1;
            pn.RecordTypeId = AZ_OPT_ID;
        }
        loadData();
    }
    public Notes_ProgressNote_Create() {
        myRTs = [select Name, Id, sObjectType, Description from RecordType where sObjectType = 'Progress_Note__c'];
        loadData();
    }
//load
    public void loadData(){
        //important - normalize the strings to lower case
        myState=myState.toLowerCase();
        //create record type selection option there is an escape option so is the filter is incorrect as a short term messure -go to the url and remove state in the VF page | (state=) < null or blank |
        for (RecordType thisRT : myRTs){
            string myName = thisRT.Name.toLowerCase();
            if(String.isBlank(myState)){
                SelectOption SO = new SelectOption(thisRt.Id, thisRt.Name);
                rtOptions.Add(SO);
            }
            else{
                if(myName.StartsWith(myState)){
                    SelectOption SO = new SelectOption(thisRt.Id, thisRt.Name);
                    rtOptions.Add(SO);
                }
            }
        }

    }



}