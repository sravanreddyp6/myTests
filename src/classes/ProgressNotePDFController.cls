public class ProgressNotePDFController {
    public Progress_Note__c progressNote { get; set; }
    public Progress_Note__c progressNoteValues { get; set; }
    public string noteType {get; set;}
    public string serviceAssignmentName {get; set;}
    public string html {get; set;}
    //Header and Footer Specific Variables
    public string FirstHeaderLeft {get; set;}
    public string FirstHeaderCenter {get; set;}
    public string FirstHeaderRight {get; set;}
    //Headers that will appear on all pages
    public string AllHeaderLeft {get; set;}
    public string AllHeaderCenter {get; set;}
    public string AllHeaderRight {get; set;}
    //Footers that will appear on all pages
    public string AllFooterLeft {get; set;}
    public string AllFooterCenter {get; set;}
    public string AllFooterRight {get; set;}
    //The footer that will appear on the last page. This should override the AllFooter section
    public string LastFooterLeft {get; set;}
    public string LastFooterCenter {get; set;}
    public string LastFooterRight {get; set;}
    
    //Page Number Specific Variables
    public string showPageNumbers {get; set;}
    public string showLastPageNumbers {get; set;}

    public void runOnInit(){
        initVariables();
        activateBlocks();
    }
    
    public void initVariables(){
        List<RecordType> recordTypes = new List<RecordType>();
        List<Service_Assignment__c> serviceAssignments = new List<Service_Assignment__c>();
        List<Progress_Note__c> progressNotes = new List<Progress_Note__c>();
        List<Account> personsBeingServed = new List<Account>();
        List<Service_Code__c> serviceCodeList = new List<Service_Code__c>();
        List<User> currentUser = new List<User>();
        //Query necessary because Title isn't available via UserInfo
        currentUser = [SELECT Id, Name, Title from User where id =: UserInfo.getUserId()];
        progressNotes = [SELECT Id, Service_Assignment__c, End_Time__c, Start_Time__c, Service_Location__c, Type_of_Contact__c, Collateral_Contact__c, 
                        Other_Collateral_Contact__c, Funding_Source__c, Person_Being_Served__c, Service_Code__c, Auth_Service_Code__c,  Persons_Response_to_Interventions__c,
                        Progress__c, Notes_For_Next_Visit__c, CreatedDate, Interventions__c from Progress_Note__c where id =: progressNote.Id];
        progressNoteValues = progressNotes[0];
        serviceCodeList = [SELECT Id, Name, Service_Value__c from Service_Code__c where id =: progressNoteValues.Service_Code__c];
        String serviceNum = '';
        String serviceVal = '';
        if (!serviceCodeList.isEmpty()){
            serviceNum = serviceCodeList[0].Name;
            serviceVal = serviceCodeList[0].Service_Value__c;
        }
        personsBeingServed = [SELECT Id, Name, Avatar_ID__pc, Medicaid_ID__pc, Other_ID__pc from Account where PersonContactId =: progressNoteValues.Person_Being_Served__c];
        String medicaidID = '';
        String otherId = '';
        String personName = '';
        if(!personsBeingServed.isEmpty()){
            otherId = personsBeingServed[0].Other_ID__pc;
            medicaidID = personsBeingServed[0].Medicaid_ID__pc;
            personName = personsBeingServed[0].Name;
        }
        
        serviceAssignments = [SELECT Id, Name, Program__c, Location_Region__c, Service_Line__c from Service_Assignment__c where id =: progressNoteValues.Service_Assignment__c];
        recordTypes = [SELECT Id, Name, DeveloperName from RecordType where id =: progressNote.RecordTypeId];
        noteType = recordTypes[0].DeveloperName;
        serviceAssignmentName = serviceAssignments[0].Name;
        Map<string, string> htmlVars = new Map<String, String>();
        htmlVars.put('noteType', recordTypes[0].DeveloperName);
        String BillingID = '';
        if(personsBeingServed[0].Avatar_ID__pc != null){
            BillingID = personsBeingServed[0].Avatar_ID__pc;
        }
        htmlVars.put('Avatar_ID__pc', personName+' '+ String.ValueOf(BillingID)+' '+String.ValueOf(medicaidID));
        htmlVars.put('Service_Line__c', serviceAssignments[0].Service_Line__c);
        htmlVars.put('Service_Location__c', progressNoteValues.Service_Location__c);
        htmlVars.put('Type_of_Contact__c', progressNoteValues.Type_of_Contact__c);
        htmlVars.put('Funding_Source__c',progressNoteValues.Funding_Source__c);
        htmlVars.put('otherId',otherId);
        htmlVars.put('Medicaid_ID__c',medicaidID);
        htmlVars.put('Name',personName);
        htmlVars.put('End_Time__c',progressNoteValues.End_Time__c.format('M/d/y h:mm a'));
        htmlVars.put('Start_Time__c',progressNoteValues.Start_Time__c.format('M/d/y h:mm a'));
        htmlVars.put('Interventions__c',progressNoteValues.Interventions__c);
        htmlVars.put('Persons_Response_to_Interventions__c',progressNoteValues.Persons_Response_to_Interventions__c);
        htmlVars.put('Progress__c',progressNoteValues.Progress__c);
        htmlVars.put('Notes_For_Next_Visit__c',progressNoteValues.Notes_For_Next_Visit__c);
        htmlVars.put('Auth_Service_Code__c',serviceVal);
        htmlVars.put('CreatedBy.Name',currentUser[0].Name);
        htmlVars.put('CreatedBy.Title',currentUser[0].Title);
        htmlVars.put('CreatedDate', progressNoteValues.CreatedDate.format('M/d/y h:mm a'));
        htmlVars.put('Now',Datetime.now().format('M/d/y h:mm a'));
        htmlVars.put('Program__c',serviceAssignments[0].Program__c);
        htmlVars.put('Location_Region__c',serviceAssignments[0].Location_Region__c);
        htmlVars.put('Collateral_Contact__c',progressNoteValues.Collateral_Contact__c);
        if(progressNoteValues.Other_Collateral_Contact__c != null && progressNoteValues.Other_Collateral_Contact__c != ''){
            htmlVars.put('Collateral_Contact__c','Other - ' + progressNoteValues.Other_Collateral_Contact__c);
        }
        html = FL_FSS_Progress_Note(htmlVars);
    }
    
    public void activateBlocks() { 
        //This can be removed if we no longer need conditional styling on the Visualforce page.
    }
    public Map<string, string> V2SA_ProgressNotesEmbed_PDFInclude(Map<string, string> htmlVars){
        String subHTML = '';
        List<ProgressNote_ServiceAssignment_mJO__c> mjo = 
        [Select  Name, Short_Term_Goal__c, Objective__c, Intervention__c From ProgressNote_ServiceAssignment_mJO__c Where Progress_Note__c = :progressNote.id];
        Set<ID> AllIds = new Set<ID>();
        Map<id, Objective__c> MapOBJ = new Map<id, Objective__c>();
        for (ProgressNote_ServiceAssignment_mJO__c local : mjo){
            AllIds.add(local.Short_Term_Goal__c);
            AllIds.add(local.Objective__c);
            AllIds.add(local.Intervention__c ); 
        }
        for (Objective__c local : [Select ID, (Select Intervention_Description__c From Interventions__r Where Id IN :ALLids) From Objective__c Where Id IN: ALLids]){
            MapOBJ.put(local.id, local);         
        }
        List<Short_Term_Goal__c> MyGoals = new List<Short_Term_Goal__c>();
        
        MyGoals = [Select Frequency_and_Duration__c, Status__c, Short_Term_Goal_Description__c,
          (Select Id, Objective_Description__c, Frequency_and_Duration__c, Status__c From Objectives__r Where Id IN :Allids) From Short_Term_Goal__c Where Id IN :Allids];
        Map<string,string> returnedHTML = getStaticHtml('ShortTermGoalTemplate');
        Boolean stgHeader = false;
        for(Short_Term_Goal__c stg : MyGoals){
            Boolean objLabel = false;
            if(stgHeader){
                subHTML+= '<tr><th class"stg_row">Description</th><th>Frequency and Duration</th><th>Status</th></tr>';
            }
            if(stg.Frequency_and_Duration__c == null){
                stg.Frequency_and_Duration__c = '';
            }
            if(stg.Status__c == null){
                stg.Status__c = '';
            }
            subHTML+= '<tr><td>' + stg.Short_Term_Goal_Description__c + '</td><td>' + stg.Frequency_and_Duration__c + '</td><td>' + stg.Status__c + '</td></tr>\n';
            for(Objective__c obj: stg.Objectives__r){
                if(!objLabel){
                    subHTML+= '<tr><td class="indent1"><b>Plan Objective(s)</b></td></tr>\n';
                }
                Boolean intLabel = false;
                if(obj.Frequency_and_Duration__c == null){
                    obj.Frequency_and_Duration__c = '';
                }
                if(obj.Status__c == null){
                    obj.Status__c = '';
                }
                subHTML+= '<tr><td class="indent1">' + obj.Objective_Description__c + '</td><td>' + obj.Frequency_and_Duration__c + '</td><td>' + obj.Status__c + '</td></tr>\n';
                for(Intervention__c intv: MapOBJ.get(obj.id).Interventions__r){
                    if(!intLabel){
                        subHTML+= '<tr><td class="indent2"><b>Interventions</b></td></tr>\n';
                    }
                    subHTML+= '<tr><td class="indent2">' + intv.Intervention_Description__c + '</td></tr>\n';
                }
            }
            stgHeader = true;
        }
        String html2return = returnedHTML.get('html');
        html2return = html2return.replace('<!--insert data here-->',subHTML);
        htmlVars.put('ShortTermGoals', html2return);
        return htmlVars;
    }
    public string FL_FSS_Progress_Note(Map<String, String> htmlVars){
        Map<String,String> returnedHTML = getStaticHtml('FL_FSS_Progress_Note');
        htmlVars.put('FormDate',returnedHTML.get('FormDate'));
        htmlVars = getImages(htmlVars, returnedHTML.get('html'));
        htmlVars = V2SA_ProgressNotesEmbed_PDFInclude(htmlVars);
        String htmlFlavor = addSomeFlavor(returnedHTML.get('html'), htmlVars);
        FirstHeaderRight = /*'Billing ID: '*/ + htmlVars.get('Avatar_ID__pc');//Adds the BillingID to the HeaderRight Position
        AllHeaderRight = /*'Billing ID: '*/ + htmlVars.get('Avatar_ID__pc');//Adds the BillingID to the HeaderRight Position
        return htmlFlavor;
    }
    public Map<string, string> getStaticHtml(String staticName){
        List<StaticResource> docs;
        docs = [select id, name, body, LastModifiedDate from StaticResource where name =: staticName]; 
        string htmlBody = docs[0].body.toString();
        Map<string,string> returnedHTML = new Map<string,string>();
        returnedHTML.put('html',docs[0].body.toString());
        returnedHTML.put('FormDate', docs[0].LastModifiedDate.format('M/d/y'));
        return returnedHTML;
    }
    public Map<string, string> getImages(Map<String, String> htmlVars, String tempHTML){
        Pattern p = Pattern.compile('\\{!URLFOR\\((.*)\\}');
        Matcher m = p.matcher(tempHTML);
        while(m.find()){
            String resource = m.group().substring(m.group().indexOf('Resource.') + 9, m.group().indexOf(','));
            String filename = m.group().substring(m.group().lastIndexOf(',') + 2, m.group().lastIndexOf('\''));
            String resourceURL = GetResourceURL(resource);
            if (filename.indexOf('.') != -1){
                resourceURL = resourceURL + '/' + filename;
            }
            String key = m.group().replace('{!','').replace('}','');
            htmlVars.put(key,resourceURL);
        }
        return htmlVars;
        
    }
    public string addSomeFlavor(String htmlFlavor, Map<String, String> htmlVars){
        for (String key: htmlVars.keySet()){
            System.debug('Your Key: ' + key);
            System.debug('Your Value: ' + htmlVars.get(key));
            if(htmlVars.get(key) != null){
                htmlFlavor = htmlFlavor.replace('{!' + key + '}', htmlVars.get(key));
            }else{
                htmlFlavor = htmlFlavor.replace('{!' + key + '}', '');
            }
        }
        return htmlFlavor;
    }
    public ProgressNotePDFController(ApexPages.StandardController controller) {
      this.progressNote = (Progress_Note__c) controller.getRecord();
      runOnInit();
    }
    public static String GetResourceURL(String resourceName) {
    
        List<StaticResource> resourceList = [
           SELECT Name, NamespacePrefix, SystemModStamp 
           FROM StaticResource 
           WHERE Name = :resourceName
        ];
        System.debug('resourceList ' + resourceList);
        if (resourceList.size() == 1) {
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName; 
        } else return '';
        
    }
}