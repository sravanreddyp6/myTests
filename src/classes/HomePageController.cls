public with sharing class HomePageController{
    SystemSettings__c OS = SystemSettings__c.getOrgDefaults();

    public final String OperatingGroup = [select operating_group__c from user where id=:UserInfo.getUserId() limit 1].operating_group__c;
    public static Map<String,Schema.SObjectType> gSchema;
    public Map<String,String> sObjNamesMap{get;set;}
    public List<String> objname{get;set;}
    public List<wrapper> AppWrapper = new List<wrapper>();
    public String viewstsk{get;set;}
    public String FrstName{get;set;}
    public String LstName{get;set;}
    public String Prgm { get;set;}
    public List<SelectOption>activeSelList { get; set; }
    public String activeChoice { get; set; }
    public String objectName{get;set;}

    // Used for daily actions
    public string evalType { get; set; }
    public string subCat { get; set; }
    public string cat { get; set; }
    public string evalSecId { get; set; }
    public string evalSecType { get; set; }
    public Id evaluationId { get; set; }

    // List of permission sets that the user is assigned to
    public String permissionSetString { get; set; }

    private static Set<String> sObjNamesSet;
    //declaration of variables

    public List<Task> populateTasks{get;set;}
    public Map<Id, String> taskToNameMap { get; set; }

    public boolean Refresh=false;

    // NEVAL-56
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }

    public String TypObj;

    // We use this variable to keep track of which service assignment we want
    // to run an action on
    public Id serviceAssignmentIdForAction { get; set; }

    // Given the id of a service assignment, here's a map of the actions
    // (excluding Create New Shift Doc) for the latest shift doc of that service
    // asignment (providing that the shift doc is active)
    public Map<Id, List<SelectOption>> serviceAssignmentToSelectOptionMap { get; set; }
    
    // list of options in the navigation drop down on each row of the PBS table
    // this had to come server side because VF was having trouble with rendering properly based on properties 
    // of the pageblock table
    public Map<Id, List<SelectOption>> saNavOptionMap { get; set; }

    // List of repeatable section/subsection/subsubsection for CM Shift Doc && CNA Workbook
    public List<String> cmShiftDocRepeatable;
    public List<String> cnaWorkbookRepeatable;
    public Map<Id, Id> evaluationtoServiceAssignmentMap { get; set; }

    // search funcitonality
    public transient List<OneAppSearchController.SearchResult> searchResultList { get; set; }
    public String searchResultPBS { get; set; }
    public String searchResultSA { get; set; }
    public Boolean searchResultIsFav { get; set; }
    private List<String> currentSALIst;
    private List<String> currentPBSList;
    
    private Set<PBSWrapper> peopleToServe { get; set; } // list of PBS on this page (includes favorites and single-transaction PBS)
    private Set<ID> admissions = new Set<ID>(); // list of admissions in focus
    private Set<ID> setAcks = new Set<ID>();    // list of things this user has acknowledged for the focus admissions
    private Set<ID> plans = new Set<ID>();      // list of plans in focus
    private Map<String, ID> admAssess = new Map<String, ID>();  // map of admissionid+assessmenttype to assessment id
    private Map<String, ID> apWksht = new Map<String, ID>();    // map of planid+worksheettype to worksheet id
    
    public List<PBSWrapper> mypbsList { get { return new List<PBSWrapper>(peopleToServe);} set; }   
    
    
    public Boolean canSeeCNAWorkbook { get; set; }
    public Boolean canSeeShiftDoc { get; set; }
    public Boolean canCreateProgressNotes { get; set; }

    // EC-196 - Shift notes
    public Boolean canCreateNote { get; private set; }
    //PBS object
    public Boolean canSeePBS { get; private set; }
    public Boolean canAccessSA { get; private set; }
    public Map<Id, Evaluation__c> shiftDocMap { get; set; }
    public Map<Id, Evaluation__c> cnaWorkbookMap { get; set; }
    public Map<Id, Boolean> hasShiftDocMap { get; set; }
    public Map<Id, Boolean> hasCnaWorkbookMap { get; set; }


    // IADAY-10 - support creation of Time Log entry from home page
    public String responseType { get; set; }
    public Boolean hasError { get; set; }
    public Evaluation_Response__c currResponse { get; set; }

    public boolean isIARole { get; set; }
    public boolean isCAFSS{get; set;}
    public string businessUnit {get; set;}
    public boolean cancreateCANS{ get; set;}
    public boolean rwLevel1{ get; set;}
    public boolean rwLevel3{ get; set;}
    public Boolean cmTierI { get; set; }
    public Boolean cmTierII { get; set; }
    public Boolean cmTierIII { get; set; }
    public Boolean cmDON { get; set; }
    public Boolean cduAZ { get; set; }

    Set<String> dupeCheck = new Set<String>();

    public class PBSWrapper {
        public ID pbsID { get; set; }   
        public ID saID { get; set; }
        public ID admID { get; set; }
        public ID apID { get; set; }    // plan
        public string pbsname { get; set; }
        public string program { get; set; }
        public string alias { get; set; }
        public string saName { get; set; }
        public date apEffDate { get; set; } // plan eff date
        public boolean isFavorite { get; set; } 
        public boolean hasRisk { get; set; }
        public boolean hasISSA { get; set; }
        public Date APTargetDate { get; set; }
        public boolean hasActionPlan { get; set; }
        public boolean needsAPAck { get; set; }
        public boolean needsRiskAck { get; set; }
        public ID ISSAId { get; set; }
        public ID RiskId { get; set; }
        public boolean needsISSAAck { get; set; }
        public ID bwID { get; set; }    // current behavior worksheet id 
        public ID swID { get; set; }    // current skills worksheet id
        public boolean hasBW { get; set; }  // if behavior worksheet is applicable (plan end date after today)
        public boolean hasSW { get; set; }  // if skills worksheet is applicable (plan end date after today)
        public string admState { get; set; }
        public string servState { get; set; }
        public boolean hasCANS { get; set; }
        public string cansName { get; set; }
        public ID cansID { get; set; }
        public ID cnaID { get; set; }
        public boolean hasCNA { get; set; }
        public string cnaName { get; set; }
        public ID cnaOwner { get; set; }
        public ID sdID { get; set; }
        public boolean hasShiftDoc { get; set; }
        public string sdName { get; set; }
        public ID sdOwner { get; set; }
        public string saRecType { get; set; }
        public string saStatus { get; set; }
        public Date saEnd { get; set; }
        public Boolean saEndWithin2Wks { get; set; }
        public boolean hasResidentialSA { get; private set; }
        public string flavor {get; set;}
        public string servAliasOpGrp { get; set; }
        
        // wrap the details for the PBS table listing
        public PBSWrapper ( ID pID, ID adID, ID sID, ID aID, string n, string p, string al, date ed, boolean f, boolean r, boolean i, boolean h, date apd, string admst, string slst, string sanm, string sastat, string flav) {
            pbsID = pID;
            saID = sID;
            admID = adID;
            apID = aID;
            pbsname = n;
            program = p;
            alias = al;
            apEffDate = ed;
            isFavorite = f;
            hasRisk = r;
            hasISSA = i;
            hasCANS = false;
            hasActionPlan = h;
            apTargetDate = apd;
            needsAPAck = false;
            needsRiskAck = false;
            needsISSAAck = false;
            bwID = null;
            swID = null;
            hasBW = false;
            hasSW = false;
            admState = admst;
            servstate = slst;
            saname = sanm;
            hasShiftDoc = false;
            hasCANS = false;
            hasCNA = false;
            saStatus = sastat;
            saEnd = null;
            saEndWithin2Wks = false;
            hasResidentialSA = false;
            flavor = flav;
            
        }
        
        
        // for equality checking within a set
        public Boolean equals(Object obj) {
            if (obj instanceof PBSWrapper) {
                //  system.debug('inside equals');
                PBSWrapper p = (PBSWrapper)obj;
                
                // note that isfavorite is not included in compare as it is not significant test for equality
                return ((pbsID == p.pbsID) && 
                        (saID == p.saID) &&
                        (apID == p.apID) &&
                        (pbsname == p.pbsname) &&
                        (alias == p.alias) &&
                        (apEffDate == p.apEffDate ) 
                       );
               
            }
            return false;
        }
        
        public Integer hashCode() {
            return pbsname.length();
        }
        
    }
    
    
    //Constructor
    public HomePageController(){

        //PRI-327, for CAFSS
        list<Tmn_User__c> tmnUser = [SELECT Id,operating_group__c,Business_Unit__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1]; //Using list to prevent system.query exception
        this.isCAFSS = false;
        if(tmnUser.size() > 0){
            this.businessUnit =  tmnUser[0].Business_Unit__c;
            this.isCAFSS = (tmnUser[0].Business_Unit__c != null && tmnUser[0].Business_Unit__c.startsWith('BU 008')) ? true : false;
        }
        //PBS object
        Schema.DescribeSObjectResult oSchema = Account.sObjectType.getDescribe();
        canSeePBS = oSchema.isAccessible();

        //Service Assignments
        Schema.DescribeSObjectResult oSchema1 = Service_Assignment__c.sObjectType.getDescribe();
        canAccessSA = oSchema1.isAccessible();

        peopletoServe = new Set<PBSWrapper>();
        currentSAList = new List<String>();
        currentPBSList = new List<String>();
        // default the active only check box to true
        activeSelList = new List<SelectOption>();
        activeSelList.Add(new SElectOption('Active Only', 'Active Only'));
        activeSelList.Add(new SElectOption('All', 'All'));
        
        evaluationToServiceAssignmentMap = new Map<ID, ID>();
        serviceAssignmentToSelectOptionMap = new Map<ID, List<SelectOption>>();     
        saNavOptionMap = new Map<ID, List<SelectOption>>(); 
        shiftDocMap = new Map<Id, Evaluation__c>();
        cnaWorkbookMap = new Map<Id, Evaluation__c>();
        hasShiftDocMap = new Map<Id, Boolean>();
        hasCnaWorkbookMap = new Map<Id, Boolean>();
        admissions = new set<id>();
        
         
        // get list of repeatables
        List<AggregateResult> evalRepeats = [
            SELECT category__c, sub_category__c, sub_sub_category__c,
                   eval_type__r.name type
              FROM eval__c
             WHERE (eval_type__r.name = 'Head To Toe'
                OR eval_type__r.name = 'CNA Workbook')
               AND eval_type__r.Category__c = 'Care Meridian'
               AND eval__c.field_name__c = 'isRepeatable'
               AND eval__c.visible__c = false
            GROUP BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c,
                     category__c, sub_category__c, sub_sub_category__c,
                     eval_type__r.name
            ORDER BY cat_seq_text__c, subcat_seq_text__c, subsubcat_seq_text__c
        ];
        cmShiftDocRepeatable = new List<String>();
        cnaWorkbookRepeatable = new List<String>();
        for (AggregateResult ag : evalRepeats){
            if (ag.get('type') == 'Head To Toe') {
                cmShiftDocRepeatable.add((string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c')));
            } else {
                cnaWorkbookRepeatable.add((string)ag.get('category__c') + '~' +  (string)ag.get('sub_category__c') + '~' + ( String.isBlank((string)ag.get('sub_sub_category__c')) ? '' : (string)ag.get('sub_sub_category__c')));
            }
        }

        PermissionSetAssignment[] assignments = [
            SELECT Id, PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
        ];
        Set<String> permissionSets = new Set<String>();
        for (PermissionSetAssignment assignment: assignments) {
            permissionSets.add(assignment.PermissionSet.Label);
        }
        permissionSetString = String.join(new List<String>(permissionSets), '~');
        if (permissionSets.contains('iServe - Tier I')) {
            cmTierI = true;
        } else {
            cmTierI = false;
        }
        if (permissionSets.contains('iServe - Tier II')) {
            cmTierII = true;
        } else {
            cmTierII = false;
        }
        if (permissionSets.contains('iServe - Tier III')) {
            cmTierIII = true;
        } else {
            cmTierIII = false;
        }
        if (permissionSets.contains('iServe - DON')) {
            cmDON = true;
        } else {
            cmDON = false;
        }
        
        if (permissionSets.contains('iServe - Tier I') || permissionSets.contains('iServe - Tier II') || permissionSets.contains('iServe - Tier III')) {
            canSeeCNAWorkbook = true;
        } else {
            canSeeCNAWorkbook = false;
        }
        if (permissionSets.contains('iServe - Tier II') || permissionSets.contains('iServe - Tier III')) {
            canSeeShiftDoc = true;
        } else {
            canSeeShiftDoc = false;
        }
        if (permissionSets.contains('ESD - Assessments Only')){
            cancreateCANS = true;
        } else {
            cancreateCANS = false;
        }
        if (permissionSets.contains('ESD - Notes - RW - Level 1')){
            rwLevel1 = true;
        } else {
            rwLevel1 = false;
        }
        if (permissionSets.contains('ESD - Notes - RW - Level 3')){
            rwLevel3 = true;
        } else {
            rwLevel3 = false;
        }
        
        if (permissionSets.contains('ESD - Notes - Clinical Data User - Arizona'))
            cduAZ = true;
        else
            cduAZ = false;

        Map<id,UserRole> rolemap =new Map<id,UserRole>([SELECT DeveloperName,Id FROM UserRole]);
        if((rolemap.get(UserInfo.getUserRoleId()).DeveloperName=='AZ_Phoenix_Clinical_Users'||rolemap.get(UserInfo.getUserRoleId()).DeveloperName=='AZ_Phoenix')&& OperatingGroup == 'Redwood' && os.AZ_OPT_Enabler__c==true){
          canCreateProgressNotes = true;
          canSeeShiftDoc = false;
          canSeeCNAWorkbook = false;
        }
        else
          canCreateProgressNotes =false;

        if (rolemap.get(UserInfo.getUserRoleID()).DeveloperName == 'IA')
            isIARole = true;
        else
            isIARole = false;


        oSchema = Progress_Note__c.sObjectType.getDescribe();
        canCreateNote = oSchema.isCreateable();

        checkTmnUserRecord();
        mineTasks();
        
    
    }
    
    // retrieve favorites list from the cloud or machine cookie (once only if cloud has no stored value)
    public void setPBSList() {
        
        ID uid = UserInfo.getUserid();
 
 
        //RPII-56 2016-02-01 changes storage of favorites cookie to user object in cloud.  for seamless transition, check standard cookie if user setting is blank, but only once
        User u = [ select id, favorite_PBS__c from User where id = :uid LIMIT 1];
        String pbsJoin = u.favorite_PBS__c;
         
         if ( string.isBlank( pbsJoin )) {
            //retrieve list of PBS given favorites string from browser cookie
            Cookie favoritePBSlist = ApexPages.currentPage().getCookies().get('favoritePBS-' + uid);
            if (favoritePBSList != null ){
                pbsJoin = favoritePBSList.getValue();
            }
            
            // save the machine value into the cloud
            updatePBSListCookie(pbsJoin );
            
            // clear the machine cookie so it won't overwrite cloud again
            ApexPages.currentPage().setCookies( 
            new Cookie[]{
                new Cookie(
                    'favoritePBS-' + UserInfo.getUserId(),
                    null, null, -1, false
                )
            });
         }
        
        List<String> favePBS = new List<String>();
        List<String> faveSA = new List<String>();

        searchResultPBS = '';
        searchResultSA = '';   
        searchresultisfav = true;     
        if ( pbsJoin != null ) {
            List<String> tmplist = pbsJoin.Split(';');
            
            for (String tmp : tmplist) { 
                // format of cookie string is PBS|SA;PBS|SA;    
                //system.debug('cookie string split: ' + tmp);            
                String[] moretmp = tmp.split('-');
                if (moretmp.size() == 2) {
                    favePBS.add(moretmp[0]);
                    searchresultPBS += moretmp[0] + ',';
                    faveSA.add(moretmp[1]);
                    searchresultSA += moretmp[1] + ',';
                }
            }
            system.debug('fAVE PBS:' + favePBS + ', faveSA:' + faveSA);
            setfocusPBS ( ); 
        }
            
        buildSearchExclusionList( faveSA, favePBS );
    }
    
    
    // exclude currently displayed PBSs and SAs from search
    private void buildSearchExclusionList( List<String> sa, List<String> pbs) {
        currentSAList.clear();
        currentPBSList.clear();
        
        currentSAList.addAll( sa );
        currentPBSList.addAll( pbs );
    }
    
    private void setPBSActions() {

        SelectOption[] optionList = new SelectOption[]{};
        
        for (PBSWrapper p : peopletoServe) {
            
            optionList = new SelectOption[]{};
            
            // ****************************************************************************************
            // START - set up daily actions list
            optionList.add(new SelectOption('', '--- Select ---'));

            //adding a wrapping clause here PRI-237, this may be requested for removal
            if (canSeeShiftDoc) {
                optionList.add(new SelectOption('createShiftDoc', 'Create New Shift Doc'));
                if (p.hasShiftDoc && p.sdOwner != UserInfo.getUserId()) {
                    for (String compositeKey: cmShiftDocRepeatable) {
                        String readableCompositeKey = compositeKey.replace('~', '/');
                        if (readableCompositeKey.endsWith('/')) {  // if a category has no sub sub category
                            readableCompositeKey = readableCompositeKey.substringBeforeLast('/');
                        }
                        optionList.add(new SelectOption(
                            'shiftDocAction-' + compositeKey,
                            'Add Activity Log Entry for ' + readableCompositeKey
                        ));
                    }
                }
                optionList.add(new SelectOption('', '-------------'));
            }
            if (canCreateProgressNotes) {
                optionList.add(new SelectOption('ViewSANoteLog', 'View SA Note Log'));
            }
            if (canSeeCNAWorkbook) {
                optionList.add(new SelectOption('createCNAWorkbook', 'Create New CNA Workbook'));
                if (p.hasCNA && p.cnaOwner == UserInfo.getUserId()) {
                    for (String compositeKey: cnaWorkbookRepeatable) {
                        String readableCompositeKey = compositeKey.replace('~', '/');
                        if (readableCompositeKey.endsWith('/')) {  // if a category has no sub sub category
                            readableCompositeKey = readableCompositeKey.substringBeforeLast('/');
                        }
                        optionList.add(new SelectOption(
                            'cnaWorkbookAction-' + compositeKey,
                            'Add Activity Log Entry for ' + readableCompositeKey
                        ));
                    }
                }
            }

            //PRI-327 Hastings and CAFSS homepage daily actions.
            if (isCAFSS || operatingGroup == 'Cambridge') {
                
                //PRI-351 
                optionList.add( new SelectOption('createNewCansAssesment', 'Create New CANS Assessment'));

            } 


            // Redwood HomePage Daily Actions
            if ( operatingGroup == 'Redwood' && !isCAFSS){

                if(rwLevel3){
                    if( p.admstate =='MN' || isIARole){
                        optionList.add( new SelectOption('/' + p.saId + '#Seizure_Tracking', 'Record Seizure'));
                        dupeCheck.add('Record Seizure');
                    }
                    if((p.hasActionPlan) && (p.servstate =='MN' || p.servstate =='IN' || p.servstate == 'CA'|| isIArole)){
                        optionList.add( new SelectOption('/' + p.apId + '#worksheets', 'View Behavior Data'));
                        dupeCheck.add('View Behavior Data');
                    }
                    if( p.hasActionPlan && (p.servstate =='MN' || p.servstate =='IN' || p.servstate == 'CA'|| isIArole)){
                        optionList.add( new SelectOption('/' + p.apId + '#worksheets', 'View Skill Data'));
                        dupeCheck.add('View Skill Data');
                    }
                    if( p.hasActionPlan && p.needsAPAck && (p.servstate =='MN' || p.servstate =='IN' || p.servstate == 'CA'|| isIArole)){
                        optionList.add( new SelectOption('/' + p.apId, 'Acknowledge Action Plan'));
                        dupeCheck.add('Acknowledge Action Plan');
                    }
                    if( p.admstate =='MN'){
                        if ( p.hasISSA && p.needsISSAAck) {
                            optionList.add( new SelectOption('/' + p.ISSAId, 'Acknowledge ISSA Assessment'));
                            dupeCheck.add('Acknowledge ISSA Assessment');
                        }
                    }
                    if( p.admstate=='MN' || p.admstate =='IN' ||  p.admstate == 'CA'|| isIArole){
                        if ( p.hasRisk && p.needsRiskAck) {
                            optionList.add( new SelectOption('/' + p.riskId, 'Acknowledge Risk Assessment'));
                            dupeCheck.add('Acknowledge Risk Assessment');
                        }
                    }
                    if(isIARole){
                        optionList.add( new SelectOption('createTimeLog', 'Create Time Log Entry'));
                        dupeCheck.add('Create Time Log Entry');
                        optionList.add( new SelectOption('IowaDailyDataSummary', 'Create Daily Data Summary'));
                        dupeCheck.add('Create Daily Data Summary');

                    }
                }

                if(rwLevel1){

                        if(isIARole){
                            if(!dupeCheck.Contains('Record Seizure')){
                                optionList.add( new SelectOption('/' + p.saId + '#Seizure_Tracking', 'Record Seizure'));
                            }
                            if(!dupeCheck.Contains('Create Daily Data Summary')){
                                optionList.add( new SelectOption('IowaDailyDataSummary', 'Create Daily Data Summary'));
                            }
                        }
                        if( p.hasActionPlan && ( p.servstate =='IN' || p.servstate == 'CA' || isIARole)){
                            if(!dupeCheck.Contains('View Behavior Data'))
                                optionList.add( new SelectOption('/' + p.apId + '#worksheets', 'View Behavior Data'));
                            if(!dupeCheck.Contains('View Skill Data'))
                                optionList.add( new SelectOption('/' + p.apId + '#worksheets', 'View Skill Data'));
                        }
                        if( p.hasActionPlan && p.needsAPAck && ( p.servstate =='IN' || p.servstate == 'CA' || isIARole)){
                            if(!dupeCheck.Contains('Acknowledge Action Plan')){
                                optionList.add( new SelectOption('/' + p.APId, 'Acknowledge Action Plan'));

                            }
                        }
                        if( p.admstate =='MN'){
                            if(!dupeCheck.Contains('Acknowledge ISSA Assessment')){
                                if ( p.hasISSA && p.needsISSAAck ) {
                                    optionList.add( new SelectOption('/' + p.issaId, 'Acknowledge ISSA Assessment'));
                                }
                            }
                        }
                        if( p.admstate =='MN' || p.admstate =='IN' || p.admstate == 'CA'|| isIArole){
                            if(!dupeCheck.Contains('Acknowledge Risk Assessment')){
                                if ( p.hasRisk && p.needsRiskAck ) {
                                    optionList.add( new SelectOption('/' + p.riskId, 'Acknowledge Risk Assessment'));
                                }
                            }
                        }
                        if(isIARole){
                            if(!dupeCheck.Contains('Create Time Log Entry')){
                                optionList.add( new SelectOption('createTimeLog', 'Create Time Log Entry'));
                            }
                        }

                }
                if(cancreateCANS && p.servstate =='WI'){
                    optionList.add( new SelectOption('createNewCansAssesment', 'Create new CANS Assessment'));
                }

            }
            serviceAssignmentToSelectOptionMap.put( p.saID, optionList);
            
        
            //**********************************************
            // START Navigation List
            
            Set<string> rwstates = new Set<string>{ 'CA','IA','IN','MN'};
            
            
            SelectOption[] navList = new SelectOption[]{};
            navList.add(new SelectOption('', '--- Select ---'));
            //system.debug('OP GRP: ' + p.servAliasOpGrp);
            
            if (  (p.servAliasOpGrp == 'Redwood' && rwstates.contains(p.servState)) || cduAZ || p.servAliasOpGrp == 'Care Meridian' || p.flavor == 'CAFSS' || (p.ServAliasOpGrp.Contains('Cambridge') && !canCreateCANS ))
                navList.add(new SelectOption(String.Format('/{0}#Plan', new String[]{p.saId}), 'Action Plan'));
            
            if ( !rwLevel1 || p.servState == 'IA' ) // everyone except level 1, unless in IA
                navList.add(new SelectOption( string.Format('/{0}', new String[]{p.admId}), 'Admission'));
            
            if ( (p.servAliasOpGrp == 'Care Meridian' && p.Flavor != 'Ludlow') || ( p.servAliasOpGrp == 'Redwood' && !rwLevel1 && !cduAZ && p.servState != 'CA' ) || p.flavor == 'CA FSS' )
                navList.add(new SelectOption(string.Format('/{0}#admissionDocuments', new String[]{p.admId}), 'Admission Packet'));
            
            if ( p.servAliasOpGrp == 'Care Meridian' || ( p.servAliasOpGrp == 'Redwood' && !cduAZ && p.flavor != 'CA FSS'))
                navList.add(new SelectOption(String.Format('/{0}#allergy', new String[]{p.pbsId}), 'Allergy'));
            
            if ( p.hasResidentialSA && !rwLevel1 ) // immunization and H&W have to concur
                navList.add(new SelectOption(string.Format('/{0}#healthwellchecklist', new String[]{p.admId}), 'Annual Health and Wellness Checklist')); 
            
            if ( ( rwLevel3 && rwstates.contains(p.servState) && p.flavor != 'CA FSS') || (p.servAliasOpGrp == 'Care Meridian' && p.Flavor != 'Ludlow'))
                navList.add(new SelectOption(string.format('/{0}#assistiveDevices', new String[]{p.pbsId}), 'Assistive Devices'));
            
            if ( isCAFSS || p.servAliasOpGrp == 'Care Meridian' || p.servAliasOpGrp == 'NeuroRestorative' || (p.servAliasOpGrp.Contains('Cambridge') && !canCreateCANS ) )  
                navList.add(new SelectOption(string.format('/{0}#auths', new String[]{p.saId}), 'Authorizations'));
            
            if ( p.servAliasOpGrp.Contains('Cambridge') || p.flavor == 'CA FSS' || canCreateCANS )  
                navList.add(new SelectOption(string.format('/{0}#CANS_Assessments', new String[]{p.admId}), 'CANS Assessments'));
            
            if ( p.servAliasOpGrp.Contains('Cambridge') && !canCreateCANS )
                navList.add(new SelectOption(string.format('/apex/ServAssignExpectedDocs?id={0}', new String[]{p.saID}), 'Case Documents'));
            
            if ( p.servAliasOpGrp == 'Care Meridian')   
                navList.add(new SelectOption(string.format('/{0}#caseManagementNotes', new String[]{p.saId}), 'Case Management Notes'));
            
            if ( rwLevel3 || p.servAliasOpGrp == 'Care Meridian' || p.flavor == 'CA FSS' )  
                navList.add(new SelectOption(string.format('/{0}#Associate_Diagnosis', new String[]{p.saId}), 'Diagnosis'));

            if ( p.servAliasOpGrp.Contains('Cambridge') && !canCreateCANS )
                navList.add(new SelectOption(string.format('/apex/ServAssignFidelityChecklist?id={0}', new String[]{p.saID}), 'Fidelity Checklist'));
            
            if ( ( p.servAliasOpGrp == 'Care Meridian' && cmTierIII ) || p.servAliasOpGrp == 'NeuroRestorative')    
                navList.add(new SelectOption(string.format('/{0}#Funding_Sources', new String[]{p.saId}), 'Funding Sources'));
            
            if ( p.hasResidentialSA && !rwLevel1  ) 
                navList.add(new SelectOption(string.format('/{0}#immunization', new String[]{p.pbsId}), 'Immunization')); // immunization and H&W have to concur
            
            if ( p.servAliasOpGrp == 'Redwood' && p.servState == 'MN' )
                navList.add(new SelectOption(string.format('/{0}#Asmt', new String[]{p.admId}), 'ISSA Assessment'));
            
            if ( p.servAliasOpGrp == 'Care Meridian') 
                navList.add(new SelectOption(string.format('/{0}#isolation', new String[]{p.saId}), 'Isolation Events'));
            
            if ( p.servAliasOpGrp == 'Care Meridian') 
                navList.add(new SelectOption(string.format('/{0}#Notes', new String[]{p.saId}), 'Narrative Shift Notes'));
                
            if ( p.servAliasOpGrp == 'Care Meridian' && p.Flavor != 'Ludlow') 
                navList.add(new SelectOption(string.format('/{0}#ShiftAssessments', new String[]{p.saId}), 'Nurses Shift Documentation'));
        
            if ( p.servAliasOpGrp == 'Redwood' && p.servState == 'IA' && p.hasRisk && p.hasActionPlan) 
                navList.add(new SelectOption(string.format('/apex/PlanOfCarePdf?Id={0}', new String[]{p.pbsId}), 'Plan of Care'));              

            if ( ( p.servAliasOpGrp.Contains('Cambridge')   && !canCreateCANS ) || p.flavor=='CA FSS' )
                navList.add(new SelectOption(string.format('/{0}#Notes',new String[]{ p.saID}), 'Progress Notes'));

            if ( p.servAliasOpGrp == 'Care Meridian' && p.Flavor != 'Ludlow') 
                navList.add(new SelectOption(string.format('/{0}#residentAssessment', new String[]{p.saId}), 'Resident Assessment'));
                
            if ( p.servAliasOpGrp == 'Care Meridian' && p.Flavor != 'Ludlow') 
                navList.add(new SelectOption(string.format('/{0}#Assessment_res', new String[]{p.saId}), 'Restraint Events'));
                
            if ( p.servAliasOpGrp == 'Redwood' && rwstates.contains(p.servState) && p.flavor != 'CA FSS')
                navList.add(new SelectOption(string.format('/{0}#Asmt', new String[]{p.admId}), 'Risk Assessment'));

            if ( p.servAliasOpGrp == 'Care Meridian' || ( p.servAliasOpGrp == 'Redwood' && (p.servState == 'MN' || p.servState == 'IA')) )
                navList.add(new SelectOption(string.format('/{0}#Assessment_res', new String[]{p.saId}), 'Seizures'));
                
            if (!rwLevel1 || p.servState == 'IA') // everyone except level 1, unless in IA
                navList.add(new SelectOption(string.format('/{0}', new String[]{p.saId}), 'Service Assignment'));
                
            if ( p.servAliasOpGrp == 'Redwood' && rwLevel1 && !isCAFSS && rwstates.contains(p.servState))
                navList.add(new SelectOption('/apex/shiftnote_summary_rpt', 'Shift Note Summary Report'));
            
            if ( ( p.servAliasOpGrp == 'Redwood' && rwLevel3 && rwstates.contains(p.servState) && !isCAFSS && !cduAZ ) ||  p.servAliasOpGrp == 'Care Meridian')
                navList.add(new SelectOption(string.format('/{0}#shiftSummaries', new String[]{p.saId}), 'Summaries'));
                
            if ( p.servAliasOpGrp == 'Care Meridian')
                navList.add(new SelectOption(string.format('/{0}#therapyDetails', new String[]{p.saId}), 'Therapy'));
            
            if ( p.servAliasOpGrp == 'Redwood' && p.servState == 'IA' ) 
                navList.add(new SelectOption(string.format('/{0}#TimeLog', new String[]{p.saId}), 'Time Log Entry'));   
            
            if ( cduAZ && p.servstate == 'AZ')
                navList.add(new SelectOption(String.Format('/apex/Progress_Notes_Log?PBSID={0}&pbsname={1}}&saID={2}&admission={3}', new String[]{p.pbsId,p.pbsName,p.saId, p.admId}), 'View All Notes Log'));
            
            
            saNavOptionMap.put( p.saID, navList);
            
            // END Navigation List
            //************************************************      
        
        
            
        } // end For loop
         

        // add activity log entries         
        List<AggregateResult> responses = [
            SELECT What_Id__c, Eval__r.Category__c cat, Eval__r.Sub_Category__c subCat,
                   Eval__r.Sub_Sub_Category__c subSubCat, Eval__r.Eval_Type__r.Name type
              FROM Eval_Value__c
             WHERE What_Id__c IN :evaluationToServiceAssignmentMap.keySet()
               AND Eval_Section_Type__c != 'Activity Log'
            GROUP BY Eval__r.cat_seq_text__c, Eval__r.subcat_seq_text__c,
                     Eval__r.subsubcat_seq_text__c, Eval__r.category__c,
                     Eval__r.sub_category__c, Eval__r.Sub_Sub_Category__c,
                     What_Id__c, Eval__r.Eval_Type__r.Name
            ORDER BY Eval__r.Eval_Type__r.Name DESC, Eval__r.cat_seq_text__c,
                     Eval__r.subcat_seq_text__c, Eval__r.subsubcat_seq_text__c
        ];
        Boolean shiftDocHeaderAdded = false;
        Map<Id, Integer> indexMap = new Map<Id, Integer>();
        for (AggregateResult response: responses) {
            String compositeKey = response.get('cat') + '~' + response.get('subCat') + '~' + (String.isBlank((string) response.get('subSubCat')) ? '' : (string) response.get('subSubCat'));
            if (response.get('type') == 'Head To Toe' && !new Set<String>(cmShiftDocRepeatable).contains(compositeKey)) {  // Only add Activity Log Entry for repeatable sections/subsections/subsubsections
                continue;
            }
            Id serviceAssignmentId = evaluationToServiceAssignmentMap.get((Id) response.get('What_Id__c'));
            Boolean isShiftDocOwner = hasShiftDocMap.get(serviceAssignmentId) && shiftDocMap.get(serviceAssignmentId).OwnerId == UserInfo.getUserId();
            optionList = serviceAssignmentToSelectOptionMap.get(serviceAssignmentId);
            if (!indexMap.containsKey(serviceAssignmentId)) {
                indexMap.put(serviceAssignmentId, 1);
            }
            if (response.get('type') == 'Head To Toe' && canSeeShiftDoc && isShiftDocOwner) {
                optionList.add(indexMap.get(serviceAssignmentId),  // Add before the cna workbook stuff
                    new SelectOption('shiftDocAction-' + compositeKey,
                        'Add Activity Log Entry for ' + response.get('cat') + '/' + response.get('subCat') + (String.isBlank((string) response.get('subSubCat')) ? '' : '/ ' + (string) response.get('subSubCat'))
                    )
                );
                indexMap.put(serviceAssignmentId, indexMap.get(serviceAssignmentId) + 1);
            }
            
            serviceAssignmentToSelectOptionMap.put( serviceAssignmentId, optionList);
        }
            
   
    }
    
    // sets lists of assessments and acknowledgments based on admissions in scope on the page   
    private void setAdmissionAssessments() {
        
        // get the list of assessments (Risk, ISSA, CANS) for the admissions
        Assessment__c[] assmts = [select id, name, type__c, assessment_type__r.name, admission__c from assessment__c where admission__c in :admissions
                                  and 
                                  ((( type__c = 'ISSA' or assessment_type__r.name = 'Risk') and status__c = 'Active Final')
                                  OR (  assessment_type__r.name = 'CANS' and status__c = 'Open'))
                                  ];
        
        Map<Id, Assessment__c> mapAsmt = new Map<Id, Assessment__c>( assmts);
        
        // put into map - key is admission + assessment type
        for ( assessment__c a : assmts ) {
            string typestr = (String.isBlank(a.type__c) ? a.assessment_type__r.name  : a.type__c );
            String idtype = a.admission__c + typestr; 
            admAssess.put ( idtype, a.id );
        }   
        //system.debug('ASSESSMENTS:' + admAssess);
        
        // get list of any acknowledgments by this user on things on this admission 
        // action plans are on SA level, and assessments are on the admission level
        Acknowledgment__c[] acks = [ select id, action_plan__c, assessment__c from acknowledgment__c 
                                    where (action_plan__r.service_assignment__r.admission__c in :admissions or assessment__r.admission__c in :admissions)    
                                    and user__c = :userInfo.getUserId()];
        
        // acknowledgment has either the action plan or assessment field filled in - check based on the type                            
        for ( Acknowledgment__c a : acks ) {
            if ( a.action_plan__c != null )
                setAcks.add( a.action_plan__c );
            else if ( a.assessment__c != null)
                setAcks.add( a.assessment__c );
            
        }
        
        // go through the PBS List to update the settings for Risk, ISSA, and CANS existence and need to acknowledge
        for ( PBSWrapper p : peopletoServe ) {
            
            if ( p.hasActionPlan )
                p.needsAPAck = !setAcks.contains( p.APId );
            
            if ( admAssess.keyset().contains( p.admID + 'Risk')) { 
                p.hasRisk = true;
                p.needsRiskAck = !setAcks.contains( admAssess.get(p.admID + 'Risk'));
                p.riskID = admAssess.get(p.admID + 'Risk');
            }
            
            if ( admAssess.keyset().contains( p.admID + 'ISSA')) {
                p.hasISSA = true;
                p.needsISSAAck = !setAcks.contains( admAssess.get(p.admID + 'ISSA'));
                p.ISSAId = admAssess.get(p.admID + 'ISSA');
            }
            if ( admAssess.keyset().contains( p.admID + 'CANS')) {
                p.hasCANS = true;
                p.cansName = mapAsmt.get( admAssess.get(p.admID+ 'CANS')).name;
                p.cansID = admAssess.get( p.admID + 'CANS');
            }
            
            
        }
        
    }
    
    // sets lists of skills and behavior worksheets based on plans in scope on the page 
    private void setPlanWorksheets() {
        
        
        //system.debug('LIST OF PLANS IS: ' + plans);
        
        // get the list of worksheets behavior/skills for this calendar month and year if behavior
        Map<ID, Action_Plan_Worksheet__c> wmap = new Map<ID, Action_Plan_Worksheet__c>([select id, recordtype.developername, start_date__c, action_plan__c from action_plan_worksheet__c 
                                                                                        where action_plan__c in :plans 
                                                                                        and (( start_date__c = THIS_MONTH and recordtype.developername = 'Monthly_Behavior_Result')
                                                                                             or ( start_date__c = THIS_WEEK and recordtype.developername = 'Weekly_Skill_Result' ))]);
        
        // put into map - key is actionplanid + worksheet type
        String wtype = '';
        for ( Action_Plan_Worksheet__c w : wmap.values() ) {
            if ( w.recordtype.developername.contains('Skill') )
                wtype = 'Skill';
            else if ( w.recordtype.developername.contains('Behavior'))
                wtype = 'Behavior';         
            
            String idtype = w.action_plan__c + wtype; 
            apWksht.put ( idtype, w.id );
            
        }   
        system.debug('worksheets' + apWksht);
        // go through the PBS List to update the settings for Risk and ISSA existence and need to acknowledge
        Date wksheetEnd;
        Action_Plan_Worksheet__c aw; 
        ID wID;
        for ( PBSWrapper p : peopletoServe ) {
            
            // only if current action plan on this PBS row
            if ( p.hasActionPlan) { 
                
                
                // BEHAVIOR - monthly           
                // if there is a behavior worksheet for the current month, grab ID 
                if ( apWksht.keyset().contains( p.apId + 'Behavior')) {
                    wID = apWksht.get( p.apID + 'Behavior'); 
                    aw = wmap.get( wID);
                    p.hasBW = true;
                    p.bwID = aw.Id;
                }
                
                // SKILLS - weekly
                // if there is a skills worksheet for this play, check what week            
                if ( apWksht.keyset().contains( p.apID + 'Skill')) {
                    wID = apWksht.get(p.apId + 'Skill');
                    aw = wmap.get( wID );
                    p.hasSW = true;
                    p.swID = aw.Id;
                    
                } 
                
                // allow creation of worksheets if there is not one and today is before the Action Plan target date
                if ( Date.today() <= p.apTargetDate ) {  
                    if ( !p.hasSW ) p.hasSW = true;
                    if ( !p.hasBW ) p.hasBW = true;
                    
                }
            }            
        }
        
    }


    public String getOperatingGroup() {
        return operatingGroup;
    }


    //Wrapper class for Approvals
    public List<wrapper> getListApprovals(){
        if(Refresh==false){
            gSchema = Schema.getGlobalDescribe();
            sObjNamesMap = new Map<String,String>{};
            sObjNamesSet = gSchema.keyset();
            for(String sobj:sObjNamesSet){
                Schema.DescribeSObjectResult oSchema = gSchema.get(sobj).getDescribe();
                String tempName = oSchema.getLabel();
                String tempPrefix = oSchema.getKeyPrefix();
                sObjNamesMap.put(tempPrefix, tempName);
            }

            for(ProcessInstanceWorkitem app:[select Id,ProcessInstanceId,CreatedDate,ActorId,CreatedById,CreatedBy.Name,ProcessInstance.LastModifiedBy.Name,ProcessInstance.TargetObject.Name,ProcessInstance.LastModifiedById,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ActorId=:UserInfo.getUserId() order by CreatedDate desc limit 1000]){
                String sub = app.ProcessInstance.TargetObjectId;
                String IdType = sub.substring(0,3);
                String Type = sObjNamesMap.get(IdType);

                AppWrapper.add(new wrapper(app.Id,app.ProcessInstance.TargetObjectId,app.ProcessInstance.LastModifiedById,app.ProcessInstance.LastModifiedBy.Name,app.CreatedDate,app.ProcessInstance.TargetObject.Name,Type));
            }
            Refresh = true;
        }
        return AppWrapper;
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

    public void singleInsert() {
        evalSecId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
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
        Id userId = UserInfo.getUserId();
        String query ='select id, subject,WhatId,What.Name,WhoId,Who.Name,status,RecordTypeId, ActivityDate, Priority, CreatedDate from Task where OwnerId=:userId and status!=\'Completed\'';
        String orderStatement = '';
        // NEVAL-56
        Map<String, String> colNumToFieldMap = new Map<String, String>{
            '0' => '',
            '1' => 'CreatedDate',
            '2' => 'Subject',
            '3' => 'Priority',
            '4' => 'Status',
            '5' => 'ActivityDate',
            '6' => 'Id',
            '7' => 'What.Name'
        };
        if (sortColumn != '' && sortColumn != null && sortOrder != '' && sortOrder != null) {
            orderStatement = ' order by ' + colNumToFieldMap.get(sortColumn) + ' ' + sortOrder;
            if (sortOrder.toLowerCase() == 'asc') {  // Make sure null values are sorted differently for different sort order (by default, it's nulls first)
                orderStatement += ' nulls last';
            }
        } else {
            orderStatement = ' order by ActivityDate desc, Priority';
        }
        if(viewstsk==null || viewstsk=='All Open'){
            query+= orderStatement + ' limit 25';
        }
        else if (viewstsk=='Overdue'){
            query+='and ActivityDate<TODAY' + orderStatement + ' limit 25';
        }else if (viewstsk=='Today'){
            query+='and ActivityDate=TODAY' + orderStatement + ' limit 25';
        }else if (viewstsk=='Today+Overdue'){
            query+='and ActivityDate<=TODAY' + orderStatement + ' limit 25';
        }else if (viewstsk=='Tomorrow'){
            query+='and ActivityDate=TOMORROW' + orderStatement + ' limit 25';
        }else if (viewstsk=='Next 7 Days'){
            query+='and ActivityDate=NEXT_WEEK' + orderStatement + ' limit 25';
        }else if (viewstsk=='Next 7 Days+Overdue'){
            query+='and ActivityDate<=NEXT_WEEK' + orderStatement + ' limit 25';
        }else if (viewstsk=='This Month'){
            query+='and ActivityDate=THIS_MONTH' + orderStatement + ' limit 25';
        }else {
            query+= orderStatement + ' limit 25';
        }

        populateTasks = database.query(query);

        // We use the following map to display the name of tasks, because tasks
        // associated with Referrals cannot have their WhoId set to the Person
        // Being Referred record, so we need to construct the names manually
        // here
        taskToNameMap = new Map<Id, String>();
        Set<Id> whatIdSet = new Set<Id>();
        for (Task task: populateTasks) {
            if (task.WhoId != null) {
                taskToNameMap.put(task.Id, '<a href="/' + task.WhoId + '">' + task.Who.Name + '</a>');
            } else {
                whatIdSet.add(task.WhatId);
            }
        }
        Map<Id, Referral__c> referrals = new Map<Id, Referral__c>([
            SELECT Id, Person_Being_Referred__r.Full_Name__c
            FROM Referral__c
            WHERE Id IN :whatIdSet
        ]);
        Set<Id> referralIdSet = referrals.keySet();
        for (Task task: populateTasks) {
            if (referralIdSet.contains(task.WhatId)) {
                taskToNameMap.put(task.Id, '<a href="/' + task.WhatId + '">' + referrals.get(task.WhatId).Person_Being_Referred__r.Full_Name__c + '</a>');
            } else if (task.WhoId == null) {  // Do not override the entry from above if WhoId != null
                taskToNameMap.put(task.Id, '');
            }
        }
    }

    public void getSearchResults() {
        if (String.IsBlank(frstName ) && String.IsBlank(LstName) && String.IsBlank(Prgm)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                'You have to specify either a First Name or Last Name or Program')
            );
            return;
        }
        OneAppSearchController searchController = new OneAppSearchController( frstName, LstName, Prgm );
        searchController.excludeSAList = currentSAList;
        searchController.excludePBSList = currentPBSList;
        
        
        // only search PBR if user has access to view referrals
        Schema.DescribeSObjectResult oSchema1 = Referral__c.sObjectType.getDescribe();
        boolean searchPBR = oSchema1.isAccessible();
        searchResultList = searchController.getSearchResults(true, searchPBR, false, (activeChoice == 'Active Only'));
    }

    // this sets the list of favorites on the home page from search results or starring/unstarring on the home page
    public void setfocusPBS() {
        
        List<String> searchPBS = searchResultPBS.split(',');
        List<String> searchSA = searchResultSA.split(',');

        if (searchResultPBS.length() == 0)
            return;
        
        // get the requested records
        List<Service_Assignment__c> focusPBSList = [
            SELECT Id, Person_Being_Served__c, person_Being_served__r.name, 
            admission__c, Service_Location__r.location_nickname__c,  service_location__r.state__c,
            service_location__r.alias_lookup__r.Alias_Operating_Group__c,
            Service_Location__r.Alias__c, admission__r.state__c, name, recordtype.developername,
            status__c, end_date__c, service_location__r.tmn_scope__c,Flavor__c,
            (select id, effective_date__c, target_date__c, Status__c from action_plans__r where status__c = 'Active Final' order by finalized_date__c desc LIMIT 1),
            (SELECT Id, Name, Status__c, RecordType.Name, OwnerId FROM Evaluations__r WHERE RecordType.Name = 'CMShiftAssessment' OR RecordType.Name = 'CNA Workbook' ORDER BY CreatedDate DESC)
            FROM Service_Assignment__c
            WHERE Person_Being_Served__c in :searchPBS
            AND ID in :searchSA
            //AND    status__c = 'Active'
           ];
        
        string newcookie = '';
        
        // while looping, construct the cookie string of favorites and search exclusions
        List<String> excludeSA = new List<String>();
        List<String> excludePBS = new List<String>();
        Set<PBSWrapper> pbsAdded = new Set<PBSWrapper>();
        
        for ( Service_Assignment__c focusPBS : focusPBSList ) {
            
            // make sure the PBS/SA still is active 
            Boolean hasActionPlan = ( focusPBS.Action_Plans__r.size() > 0 );
            //ID pID, ID sID, ID aID, string n, string p, string al, date ed    
            PBSWrapper thisPBS = new PBSWrapper( focusPBS.person_being_served__c, 
                                                focusPBS.admission__c,
                                                focusPBS.id,
                                                hasActionPlan ? focusPBS.Action_Plans__r[0].id : null, 
                                                focusPBS.person_being_served__r.name, 
                                                focusPBS.service_location__r.alias__c + (( focusPBS.service_location__r.location_nickname__c != null ) ? ' - ' + focusPBS.service_location__r.location_nickname__c : ''),
                                                focusPBS.service_location__r.alias__c,
                                                hasActionPlan? focusPBS.Action_Plans__r[0].effective_date__c : null,
                                                searchResultIsFav, // is fav
                                                false, // has risk
                                                false, // has ISSA
                                                hasActionPlan,
                                                hasActionPlan ? focusPBS.Action_Plans__r[0].target_date__c : null,
                                                focusPBS.admission__r.state__c,
                                                focusPBS.service_location__r.state__c,
                                                focusPBS.name,
                                                focusPBS.status__c,
                                                focusPBS.Flavor__c
                                               );
            
            thispbs.saRecType = focusPBS.recordtype.developername;
            if ( focusPBS.status__c != 'Active') {
                thispbs.saEnd = focusPBS.end_date__c;
                thispbs.saEndWithin2Wks = ( focusPBS.end_date__c >= Date.Today().addDays(-14));
            }
            if (focusPBS.service_location__r.tmn_scope__c == 'Residential'){
                thispbs.hasResidentialSA = true;
            }
            thispbs.servAliasOpGrp = focusPBS.service_location__r.alias_lookup__r.Alias_Operating_Group__c ;
                
            // if already there, remove it to make sure the favorite setting is correct
            for ( PBSWrapper p : peopleToServe ) {
                if ( p.Equals( thisPBS ) ) {
                    peopleToServe.Remove(p);
                    
                    // remove from list of admissions too
                    admissions.remove(p.admId);
        
                } else {    // maintain the cookie for what's already there - we are resetting these lists
                    // only maintain list if item is active
                    if ( p.saStatus == 'Active' && p.isFavorite && !pbsAdded.contains(p)) {
                        newcookie += p.pbsID + '-' + p.saID + ';';
                        system.debug('adding ' + p.pbsID + ', ' + p.saID + ' to cookie string');
                        
                        excludeSA.add(p.saID);
                        excludePBS.add(p.pbsID);
                        pbsAdded.Add(p);
                    }
           
                }
        
            }
            
            // if it's a favorite, put it back into the list.  if it's not, it will stay on the home page until refreshed 
            // only active SA can remain favorited.  others will fall off list with next refresh
            if (thisPBS.isFavorite && (thisPBS.saStatus == 'Active')) {
                newcookie += thisPBS.pbsID + '-' + thisPBS.saID + ';';
                excludeSA.add(thisPBS.saID);
                excludePBS.add(thisPBS.pbsID);
            }
            
            hasShiftDocMap.put( thisPBS.saID, false);
            hasCNAWorkbookMap.put( thisPBS.saID, false);
            
            // Get the latest shift doc/CNA Workbook
            for (Evaluation__c eval: focusPBS.Evaluations__r) {
                if ( !thisPBS.hasShiftDoc  && eval.RecordType.Name == 'CMShiftAssessment' && eval.Status__c == 'Draft') {
                    thisPBS.sdName = eval.name;
                    thisPBS.sdID = eval.Id;
                    thisPBS.hasShiftDoc = true;
                    thisPBS.sdOwner = eval.ownerid;
                    hasShiftDocMap.put( thisPBS.saID, true);
                    shiftDocMap.put( thisPBS.saID, eval);
                    evaluationToServiceAssignmentMap.put(eval.id, thisPBS.saID);    // keep this inside the If becuase we only want latest
                }
                if ( !thisPBS.hasCNA && eval.RecordType.Name == 'CNA Workbook' && eval.Status__c == 'Draft') {
                    thisPBS.cnaName = eval.name;
                    thisPBS.cnaID = eval.id;
                    thisPBS.hasCNA = true;
                    thisPBS.cnaOwner = eval.ownerid;
                    hasCNAWorkbookMap.put( thisPBS.saID, true);
                    CNAWorkbookMap.put( thisPBS.saID, eval );
                    evaluationToServiceAssignmentMap.put(eval.id, thisPBS.saID);  // keep this inside the If becuase we only want latest
                }
            }

            // add the PBS to the list
            peopletoServe.add( thisPBS );
            admissions.add( thisPBS.admId);
            if ( hasActionPlan )
                plans.add( thisPBS.apID);

       }       
         
        // get the list of assessments for these people's admissions and acknowledgments
        setAdmissionAssessments();
        
        // get worksheets - THIS IS FOR DSP ONLY
        // setPlanWorksheets();

        // set actions
        setPBSActions();
        
        // exclude starred pbs/sa so we don't show in search                                
        buildSearchExclusionList( excludeSA, excludePBS);
        
        // rebuild cookie - this will handle removal of favorites too
        updatePBSListCookie( newcookie );
    }



    // update/renew the list of favorites   
    // RPII-56 - 2016-02-01: changing from storing cookie to storing in the cloud on User object
    public void updatePBSListCookie( string newval) {
        
        User u = [ select id, favorite_PBS__c from user where id = :UserInfo.getUserId() LIMIT 1];
        u.favorite_PBS__c = newval;
 //       system.debug( 'length of favorite list = ' + newval.length());
        try {
            update u;
        } catch (Exception e ) { throw(e);}
        
    }
            
    
    
    // turns favorite status on/off for selected row
    public void toggleFavorite ( ) {
        
        boolean newFavVal = searchResultIsFav;
        ID saToToggle = searchResultPBS;
        ID pbsToToggle = searchResultSA;
        
        // for things that aren't current favorite this will work
        setfocusPBS();
    }
    
    
    // START: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.
    public class TMN_User_Exception extends Exception {}

    public void checkTmnUserRecord() {
        String usersId = UserInfo.getUserId();
        List<TMN_User__c> tmnUserRecords = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :usersId LIMIT 1 ];

        Integer countTmnUserRecords = 0;
        for(TMN_User__c tmnu : tmnUserRecords) {
            countTmnUserRecords++;
        }

        if(countTmnUserRecords==0) {
            throw new TMN_User_Exception('ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.');
        }
    }
    // END: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.

    // IADAY-9 - to support creation of new plan from home page
    public String currsaID { get; set; }
    public pagereference NewPlan( ){

        // we only come into this function if there is no active final plan
        // find out if there's an inactive draft we can view
        List<Action_Plan__c> aplist = [ select id, status__c from Action_Plan__c where status__c = 'Inactive Draft' and service_assignment__c = :currsaID order by status__c, lastmodifieddate desc  LIMIT 1];


        Action_plan__c AP;

        // if an inactive plan exists, take them to that page to view
        if ( aplist.size() == 1 ) {
            AP = aplist[0];
        } else {

            AP = new Action_plan__c();
            AP.Service_Assignment__c = currsaID;
            insert AP;
        }

        PageReference ref =  new ApexPages.StandardController(AP).view() ;
        ref.getparameters().put('retURL', Apexpages.CurrentPage().getURL());
        return ref;

    }

    public void newResponse() {
        responseType = 'Time Log';
        currResponse = new Evaluation_Response__c( recordtypeID = Utility.getEvaluationResponseRecordType(responseType), service_assignment__c = serviceAssignmentIDforAction);
    }

    public pageReference saveResponse() {

        saveRes(false);

        return null;
    }
    public pageReference saveFinalResponse() {

        saveRes(true);

        return null;
    }    
    public void saveRes(boolean finalize){
    
        hasError = false;

        // check for required fields
        Map<string, string> columnsToHeadersMap = new Map<String, String>();
        columnsToHeadersMap.put('start_date_time__c','Start Date/Time');
        columnsToHeadersMap.put('end_date_time__c','End Date/Time');
        columnsToHeadersMap.put('tmn_user__c','Accompanied By');
        columnsToHeadersMap.put('location__c','Location');
        columnsToHeadersMap.put('service_type__c','Service Type');

        for(string rCol : new List<String>{'start_date_time__c', 'tmn_user__c', 'location__c', 'service_type__c'}){
            if(currResponse.get(rCol) == null){
                currResponse.addError( columnsToHeadersMap.get(rcol) + ' is required' );
                hasError = true;
            }
        }


        //system.debug('CURR:' + currResponse);


        // IADAY-10 - date rules
        if ( responseType == 'Time Log') {
            // compare start and end dates
            if ( currResponse.End_Date_Time__c != null ) {
                // end date after start
                if((currResponse.Start_Date_Time__c > currResponse.End_Date_Time__c) ){
                    currResponse.addError( 'End date must be after the start date.' );
                    hasError = true;
                }
                // must be same day
                if (currResponse.Start_date_Time__c.Date() != currResponse.End_Date_Time__c.Date()) {
                    currResponse.addError('Start and End times must occur on the same day.');
                    hasError = true;
                }
                // must be different
                if (currResponse.Start_Date_Time__c == currResponse.End_Date_Time__c ) {
                    currResponse.addError('Start and End times must be different.');
                    hasError = true;
                }
            }
            // can't be in the future
            if(currResponse.Start_Date_Time__c > DateTime.now() || currResponse.End_Date_Time__c > DateTime.now()  ){
                    currResponse.addError( 'Date and time cannot be in future.' );
                    hasError = true;
            }
            if(finalize && currResponse.End_Date_Time__c == null){
                    currResponse.addError( 'End Date/Time is Required to Finalize' );
                    hasError = true;            
            }

            if (! hasError ) {
                // check for date overlap with another event
                List<Evaluation_Response__c> otherTimeLogs = [ select id, start_date_time__c, end_date_time__c from evaluation_response__c where RecordTypeId = :Utility.getEvaluationResponseRecordType(responseType) and id != :currResponse.Id and service_assignment__c = :currResponse.service_assignment__c and disregard__c = false];
                for ( Evaluation_Response__c tl : otherTimeLogs ) {
                    if ( checkOverlap( tl.start_date_time__c, tl.end_date_time__c, currResponse.start_date_time__c, currResponse.end_date_time__c) ) {
                        currResponse.addError('A time log entry already exists for that time.  Please correct your entry.');
                        hasError = true;
                        break;
                    }
                }
            }

        } // end IADAY-10
        try {
            if(!hasError){
                //system.debug('CURR:' + currResponse);
                if(finalize){
                    currResponse.Status__c = 'Final';
                }
                    upsert currResponse;
                    newResponse();
                
            }
        } catch (DMLException ex) {
            hasError = true;
            system.debug(ex);
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }    
    
    
    }

    @TestVisible private boolean checkOverlap ( DateTime s1, DateTime e1, DateTime s2, DateTime e2) {

        Boolean overlaps = false;
        system.debug( 'Times:' + s1 + e1 + s2 + e2);
        if ( e1 == null ) // first set is not a range - can't compare
            return overlaps;

        if ( s2 >= s1 && s2 <= e1 ) // starts within first timeframe
            overlaps = true;
        else {
            if ( e2 != null ) {
                if ( e2 > s1 && e2 < e1 ) // ends within first timeframe
                    overlaps = true;
                else if ( s2 < s1 && e2 > e1) // covers first time span
                    overlaps = true;
            }
        }

        return overlaps;
    }
    
    public id getCANsID(){
       Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'CANS' limit 1];
       return type.id;

    }
    
}