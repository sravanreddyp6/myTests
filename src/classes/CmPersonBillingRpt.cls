public with sharing class CmPersonBillingRpt {
    transient public String pbsId {get; set;}
    transient public String pbsName {get; set;}
    transient public Service_Assignment__c pbsObj {get;set;}
    transient public date StartDate {get; set;}
    transient public date EndDate {get; set;}
    
    transient public map<Id, Evaluation__c> evaluationsMap {get; set;}
    transient public list<Id> nsdEvalIds {get; set;}
    transient public list<Id> cnaEvalIds {get; set;}
    
    transient public map<Id, Action_Summary__c> summariesMap {get; set;}     
    transient public list<Id> summaryIds {get; set;}
    transient public map<Id, String> summaryHTMLSource {get; set;}
    
    //map with the ordered list of eval section Ids. 
    transient public map<Id, list<String>> evalValues{get; set;}
    //map with the data fields for each section. 
    transient public map<String, EvalValWrapper> evalSectionsMap {get; set;}
    
    public CmPersonBillingRpt(){
        evaluationsMap = new map<Id, Evaluation__c>();
        nsdEvalIds = new list<Id>();
        cnaEvalIds = new list<Id>();
        
        summariesMap = new map<Id, Action_Summary__c>();
        summaryIds = new list<Id>();
        
        this.pbsId = ApexPages.CurrentPage().getParameters().get('Id');
        this.StartDate = Date.parse(ApexPages.CurrentPage().getParameters().get('StartDate'));
        this.EndDate = Date.parse(ApexPages.CurrentPage().getParameters().get('EndDate'));

        list<Service_Assignment__c> sa = [SELECT  id, person_being_served__r.id, person_being_served__r.LastName, person_being_served__r.FirstName, person_being_served__r.Middle_Name__c, person_being_served__r.Avatar_ID__c,
                                                  person_being_served__r.Birthdate, person_being_served__r.PBS_Identifier__c,
		                                          Service_Location__r.Name, Service_Location__r.Street__c, Service_Location__r.City__c, Service_Location__r.State__c, Service_Location__r.Zip__c,
		                                          Service_Location__r.Setting__c, Service_Location__r.Phone__c, 
		                                          person_being_served__r.Marital_Status__c, person_being_served__r.Gender__c, person_being_served__r.Age__c,
		                                          (SELECT Id, Name, RecordType.Name, Shift_Start_time__c, Shift_end_time__c, Status__c, Head_to_Toe_Status__c, owner.name
		                                             FROM Evaluations__r
		                                            WHERE ((RecordType.Name = 'CMShiftAssessment' AND Head_to_toe_Status__c = 'Final') OR (RecordType.DeveloperName = 'CNA_Workbook' AND Status__c = 'Final') ) 
		                                              AND Shift_Start_time__c >= : StartDate AND Shift_End_time__c <= : EndDate.addDays(1)
		                                            ORDER BY Shift_Start_time__c NULLS LAST),
		                                          (SELECT ID, Name, Start_Date__c, End_Date__c, Status__c                                        
		                                            FROM Action_Summaries__r 
		                                           WHERE Status__c = 'Final' 
		                                             AND Start_Date__c >= : StartDate  AND End_Date__c <= : EndDate
		                                           ORDER BY Start_Date__c NULLS LAST)
                                          FROM    Service_Assignment__c
                                         WHERE    Person_Being_Served__c = : pbsId
                                         ORDER    BY SA_Start_DateTime__c DESC NULLS LAST];
        
        this.pbsName = sa[0].person_being_served__r.LastName + ', ' + 
            (String.isBlank(sa[0].person_being_served__r.FirstName) ?  '' : sa[0].person_being_served__r.FirstName) + ' ' + 
            (String.isBlank(sa[0].person_being_served__r.Middle_Name__c) ?  '' : sa[0].person_being_served__r.Middle_Name__c) +
            (String.isBlank(sa[0].person_being_served__r.Avatar_ID__c) ?  '' : '(' + sa[0].person_being_served__r.Avatar_ID__c + ')' ) ;
        
        this.pbsObj = sa[0];
        for (Service_Assignment__c s : sa) {
            for (Evaluation__c eval : s.Evaluations__r) {
                evaluationsMap.put(eval.Id, eval);
                if (eval.RecordType.Name == 'CMShiftAssessment') nsdEvalIds.add(eval.Id);
                else cnaEvalIds.add(eval.Id);
            }
            for (Action_Summary__c summary : s.Action_Summaries__r) {
                summariesMap.put(summary.Id, summary);
                summaryIds.add(summary.Id);
            }
        }
        
        //prepare eval Values wrapper
        evalValues = new map<Id, list<String>>();
        evalSectionsMap = new map<String, EvalValWrapper>(); 
        for (Eval_Value__c ev: [SELECT   what_id__c, eval_section_id__c, eval_section_type__c, createddate, id, boolean__c, date_time__c, number_no_decimal__c, text_over_250__c, text_under_250__c, 
                                         eval__c, eval__r.Field_Type__c, eval__r.Field_Sub_Type__c, eval__r.Field_Name__c, eval__r.Length__c, eval__r.htmlid__c,
                                         eval__r.eval_type__r.Name , eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c, owner.name 
                                  FROM   eval_value__c
                                 WHERE   what_id__c = :evaluationsMap.keySet()
                                   AND   what_id_object__c = 'Evaluation__c'
                                   AND   eval__r.Field_Name__c NOT IN ('Dummy Value', 'isValid', 'ErrorMsg')
                                   AND   eval__r.visible__c = true
                                 ORDER   BY what_id__c, eval__r.cat_seq_text__c, eval__r.subcat_seq_text__c, eval__r.subsubcat_seq_text__c, eval__r.Field_Sequence__c, createddate]){
        	EvalValWrapper evalVal;
        	if (! evalSectionsMap.containsKey(ev.eval_section_id__c) ){
        		evalVal = new EvalValWrapper(ev);
        		evalSectionsMap.put(ev.eval_section_id__c, evalVal);
        	
                if(! evalValues.containsKey(ev.what_id__c)) evalValues.put(ev.what_id__c, new list<String>());
                evalValues.get(ev.what_id__c).add(ev.eval_section_id__c);
        	}
        	//evalSectionsMap.get(ev.eval_section_id__c).strEvalSections.add(getEvalValStr(ev));
        	evalSectionsMap.get(ev.eval_section_id__c).mapEvalValues.put(ev.eval__c, ev);	
        }        

        buildResourceMap();  
        buildMapEvalItems();
        buildEvalResposesMap();
        //buildCnaApprovalHistoryMap(); -- Kate said this need not be on the billing report, leaving it here in case if that changes.
                
        // Parse the Eval_Value__c to the list of strings.
        for (String evalSec : evalSectionsMap.keySet()){
        	EvalValWrapper evalSecVal = evalSectionsMap.get(evalSec);        	
        	evalSecVal.prepareEvalValStr(this);
            if (evalSecVal.evalType.equalsIgnoreCase(evalSecVal.entryType) && evalSecVal.entryType.equalsIgnoreCase('CNA Workbook') && evalSecVal.cat == 'Turns' && evalSecVal.subcat == 'Details') {
               evalSecVal.prepareTurnsDetails();    
            }
        }


        
        //get the HTML for all the weekly Summaries        
        summaryHTMLSource = new map<id, String>();
        PageReference pdf = Page.ActionSummaryReportPDFV2Html; 
        for(Id i : summaryIds) {
        	if (!summaryHTMLSource.containsKey(i)) {
        		pdf.getParameters().put('id',i);
        		summaryHTMLSource.put(i, Test.isRunningTest() ? 'TEST' : pdf.getContent().toString());
        	}
        }
        
        // Naming the PDF in case this controller is used for the PDF page
        String file = sa[0].person_being_served__r.FirstName + ' ' + sa[0].person_being_served__r.LastName + '  ' + StartDate.format() + ' to ' + EndDate.format() + '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');                        
        
    }
    
    
    transient public map<String, String> resourceMap = new map<String, String>();
    private void buildResourceMap() {
        for (StaticResource sr : [ SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource 
                                          WHERE Name IN ('NeurotabBodyNoGrid' , 'WholeBodyNoGrid' , 'Wongbakerfaces') ] )
	        {resourceMap.put(sr.Name,
	            '/resource/' + sr.SystemModStamp.getTime() + '/'+ (sr.NamespacePrefix != null && sr.NamespacePrefix != '' ? sr.NamespacePrefix + '__' : '') + sr.Name );
	        }
    }
    transient public map<string, list<Eval__c>> mapEvalItems = new map<String, list<Eval__c>>();
    private void buildMapEvalItems() {
    	String sectionKey='';
        for (Eval__c eval: [ SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c, sub_category__c, sub_category_sequence__c,
                                    eval_type__r.name, Field_Type__c, Field_Sub_Type__c, field_sequence__c, required__c, Length__c
                               FROM eval__c
                              WHERE eval_type__r.name IN ('Head to Toe', 'CNA Workbook') 
                                AND visible__c = true AND Field_Type__c != 'Hidden'
                               ORDER BY eval_type__r.name, category_sequence__c, sub_category_sequence__c, field_sequence__c ]) {
            sectionKey = eval.eval_type__r.name + eval.category__c + eval.sub_category__c;            
            if (! mapEvalItems.containsKey(sectionKey) ) mapEvalItems.put(sectionKey, new list<Eval__c>());
            mapEvalItems.get(sectionKey).add(eval);
        }
    }

    transient public map<Id, map<String, list<Evaluation_Response__c>>> mapEvalResposes = new map<Id, map<String, list<Evaluation_Response__c>>>();
    public map<Id, map<String, list<Evaluation_Response__c>>> getMapEvalResposes(){
    	return this.mapEvalResposes;
    }
    transient public map<String, list<String>> mapEvalResposeFlds = new map<String, list<String>>();
    public map<String, list<String>> getmapEvalResposeFlds(){
        return this.mapEvalResposeFlds;
    }    
    transient public map<String, String> mapEvalResposeFldLbls = new map<String, String>();
    public map<String, String> getmapEvalResposeFldLbls(){
        return this.mapEvalResposeFldLbls;
    }
    transient public String mapEvalResposesCmponentsStr {get;set;}
    private void buildEvalResposesMap() {
    	mapEvalResposesCmponentsStr = '';
        set<String> queryEvalResposeFlds = new set<String>();
        map<String, map<String,String>> mapEvalResposeFldsCstmLbls = new map<String, map<String,String>>();
    	Set<String> evalResponsesTypes = new Set<String>{'Late Entry Note', 'Wound Detail', 'Pressure Ulcer Detail'};
        String fieldSetLbl='';
        String fieldName='';
        String fieldLbl='';

        List<Schema.FieldSet> allFieldSets = Schema.SObjectType.Evaluation_Response__c.FieldSets.getMap().values();
        for (Schema.FieldSet fieldSet: allFieldSets) {
        	fieldSetLbl = fieldSet.getLabel();
        	if (!evalResponsesTypes.contains(fieldSetLbl)) continue;
            if (!mapEvalResposeFlds.containsKey(fieldSetLbl)) { 
                mapEvalResposeFlds.put(fieldSetLbl, new list<String>());
                mapEvalResposeFldsCstmLbls.put(fieldSetLbl, new map<String, String>());
            }
            for (Schema.FieldSetMember column: fieldSet.getFields()) {
            	fieldName = column.getFieldPath();
            	fieldLbl = column.getLabel();
            	mapEvalResposeFlds.get(fieldSetLbl).add(fieldName);
            	queryEvalResposeFlds.add(fieldName);
            	mapEvalResposeFldLbls.put(column.getFieldPath(), column.getLabel());
            }            
        }
        //populate any custom lables
        mapEvalResposeFldsCstmLbls.get('Pressure Ulcer Detail').put('Exudate_Type_Odor_Amount__c','Exudate Type/ Odor/ Amount');
    	// since this is the only field with a custom label, overwrite it in field lables...
    	mapEvalResposeFldLbls.put('Exudate_Type_Odor_Amount__c','Exudate Type/ Odor/ Amount');
    	
        for (Evaluation__c eval: [SELECT Id, (SELECT  ID, RecordType.Name, Annotation_Height__c, Annotation_Width__c,
                                                                           Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                                                                           Annotation_Shape__c, Annotation_Text__c,
                                                                                Late_Entry_Note__c, LastModifiedByID, LastModifiedDate,
                                                                           Time_Observed__c, Wound_Type__c, Wound_Description__c, Location__c,
                                                                                Decubity_stage__c, Decubity_Measurement__c, Depth__c, Exudate_Type_Odor_Amount__c,
                                                                                Tunneling_in_cm__c, Undermining_in_cm__c, Surrounding_Tissue_Color_and_Condition__c,
                                                                                Associated_Pain__c, Treatment__c
                                                FROM  Evaluation_Responses__r)
                                    FROM Evaluation__c
                                   WHERE Id IN :evaluationsMap.keySet() ]) {
            mapEvalResposes.put(eval.id, new map<String, list<Evaluation_Response__c>>() );
            for(Evaluation_Response__c evalRes : eval.Evaluation_Responses__r ){
            	if(!mapEvalResposes.get(eval.id).containsKey(evalRes.RecordType.Name)) mapEvalResposes.get(eval.id).put(evalRes.RecordType.Name, new list<Evaluation_Response__c>());
            	mapEvalResposes.get(eval.id).get(evalRes.RecordType.Name).add(evalRes);
            }
            
        }

        for(String rspnseType : evalResponsesTypes){
        	for(Id parentEval : mapEvalResposes.keySet()){
        		list<Evaluation_Response__c> responseList = mapEvalResposes.get(parentEval).containsKey(rspnseType) ? mapEvalResposes.get(parentEval).get(rspnseType) : null ;		
        		if (responseList != null && responseList.size() > 0){
        			mapEvalResposesCmponentsStr += parentEval + '~' + rspnseType;
        		}
        	}
        }
        
    }
    
    transient public map<id, list<ProcessInstanceHistory>> cnaApprovalHistoryMap {get;set;}
    private void buildCnaApprovalHistoryMap() {
    	cnaApprovalHistoryMap = new map<id, list<ProcessInstanceHistory>>();
        for (Id cna : cnaEvalIds) {
            cnaApprovalHistoryMap.put(cna, new list<ProcessInstanceHistory>());
        }        
        for ( ProcessInstance p : [SELECT Id, targetobjectid, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate 
                                                                 FROM StepsAndWorkitems ORDER BY createddate desc)
                                      FROM ProcessInstance
                                     WHERE targetobjectid IN :cnaEvalIds
                                     ORDER BY createddate desc] ) {
            cnaApprovalHistoryMap.get(p.targetobjectid).addAll(p.stepsandworkitems);
        }
    }
    
        
    public class EvalValWrapper {
        public string entryid {get;set;}
        public string evalType {get;set;}
        public Id parentEval {get;set;}
        public string cat {get;set;}
        public string subcat {get;set;}
        public string owner { get;set;}
        public string created {get;set;}
        public string entryType {get;set;}  // Head to Toe, Activity Log, CNA Workbook.... 
        public map<ID, Eval_Value__c> mapEvalValues {get;set;}
        public list<String> strEvalSections {get;set;}
        public EvalValWrapper(Eval_Value__c val) {
            entryid = val.eval_section_id__c;
            evalType = val.eval__r.eval_type__r.Name;
            parentEval = val.what_id__c;
            cat = val.eval__r.category__c;
            subcat = val.eval__r.sub_category__c;
            owner = val.owner.name;
            created = Utility.getMilitarytime(val.createddate);
            entryType = val.eval_section_type__c;
            strEvalSections = new list<String>();
            mapEvalValues = new map<ID, Eval_Value__c>();
        }

        transient public TurnsChartController turnsChartComp {get;set;}
        public void prepareTurnsDetails() {
            this.turnsChartComp = new TurnsChartController();
            turnsChartComp.setEvalID(this.parentEval); 
        }
                
        public void prepareEvalValStr(CmPersonBillingRpt parentObj){
            String newHTMLfld= '';
            String strval= '';
            system.debug('preparing string eval values for: ' + this.evalType+this.cat+this.subcat );
            if (parentObj.mapEvalItems.containsKey(this.evalType+this.cat+this.subcat))
            for( Eval__c e : parentObj.mapEvalItems.get(this.evalType+this.cat+this.subcat) ){
                newHTMLfld = '';
                strval = '';
                if ( e.Field_Type__c == 'Hidden' && mapEvalValues.ContainsKey( e.id ))  {
                    newHTMLfld = '<div id="' + e.htmlid__c + '>';
                    if (e.Field_Sub_Type__c == 'String')
                          newHTMLfld += mapEvalValues.get(e.id).text_over_250__c;
                  newHTMLfld +=  '</div>';
                } else if ( e.Field_Type__c == 'Boolean' && mapEvalValues.ContainsKey( e.id ))  {
                    if ( e.Field_Sub_Type__c == 'Checkbox') {
                        newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                        if ( mapEvalValues.get(e.id).boolean__c)
                            newHTMLFld += 'Yes';
                        else
                            newHTMLFld += 'No';
                        newHTMLfld += '</div>';
                    } else if (e.Field_Sub_Type__c == 'Dropdown') {
                        newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                        strval = mapEvalValues.get( e.id).Text_Under_250__c;
                        if (strval == '1')
                            newHTMLfld += 'Yes';
                        else if (strval == '0')
                            newHTMLfld += 'No';
                        newHTMLfld += '</div>';
                    } 
                } else if (e.Field_Type__c=='String' && mapEvalValues.ContainsKey( e.id )) {
                    newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    if ( e.length__c > 250 )
                        strVal = mapEvalValues.get(e.id).text_over_250__c;
                    else
                        strVal = mapEvalValues.get(e.id).text_under_250__c;
                    newHTMLfld += strVal;
                    newHTMLfld +=  '</div>';
                } else if (e.Field_Type__c == 'Int' && mapEvalValues.ContainsKey( e.id ) ){
                    strVal = String.valueOf(mapEvalValues.get(e.id).Number_No_Decimal__c);
                    newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += strVal;
                    newHTMLfld += '</div>';                    
                } else if ((e.Field_Type__c == 'DropDown' || e.Field_Type__c == 'Double') && mapEvalValues.ContainsKey( e.id )) {
                    strVal = mapEvalValues.get(e.id).text_under_250__c;
                    newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += strVal;
                    if ( e.htmlid__c == 'weightAtAdmission' || e.htmlid__c == 'kg') {
                        Double kg=Double.valueOf( strval.trim());
                        Double kgtolbs = kg*2.2046226218488;
                        Double newlb = (Math.floor(kgtolbs));
                        Double newoz = Math.round(((kgtolbs- newlb) * 1600) / 100);
                            newHTMLfld += ' kg<br />';
                            newHTMLfld += '(' + newlb + ' lb ';
                            newHTMLfld += newoz + ' oz)';
                    }  else if ( e.htmlid__c == 'heightAtAdmission') {
                        Double cm = Double.valueOf( strVal.trim());
                        Double inches = cm/2.54;
                        Double newft = Math.floor(inches/12);
                        Double newinch = Math.Round(( inches - (newft*12))*100)/100;
                        newHTMLfld += ' cm<br />';
                        newHTMLfld += '(' +  newft + ' ft ';
                        newHTMLfld += newinch + ' in)';
                    }
                    newHTMLfld += '</div>';
                }  else if (e.Field_Type__c == 'Date' && mapEvalValues.ContainsKey( e.id )) {
                    newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += mapEvalValues.get(e.id).date_time__c.Date().format(); // output date format 
                    newHTMLfld +=  '</div>';
                } else if (e.Field_Type__c == 'Datetime' && mapEvalValues.ContainsKey( e.id )) {
                    newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += Utility.getMilitarytime(mapEvalValues.get(e.id).date_time__c); // output date format
                    newHTMLfld +=  '</div>';
                } else if (e.Field_Type__c == 'Multiselect' && mapEvalValues.ContainsKey( e.id )) {
                    if ( e.length__c > 250 ) strVal = mapEvalValues.get(e.id).Text_Over_250__c;
                    else strval = mapEvalValues.get(e.id).Text_Under_250__c;
                    newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += strval;
                    newHTMLfld +=  '</div>';
                } else if (e.field_type__c == 'BodyMap' ) {
                	String annotationRecType = e.field_sub_type__c != null && e.field_sub_type__c.contains('Neuro') ? 'NeuroAnnotation': 'Annotation';
                	if (!parentObj.mapEvalResposes.containsKey(this.parentEval)) continue;
                	if (!parentObj.mapEvalResposes.get(this.parentEval).containsKey(annotationRecType)) continue;  
                	
                    newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += '<div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
                    newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' + parentObj.resourceMap.get(e.field_sub_type__c) + '?' + this.entryid + '" id="bodyMap' + this.entryid + '" />';
                    
                    Integer i=1;
                    for (Evaluation_Response__c annotation : parentObj.mapEvalResposes.get(this.parentEval).get(annotationRecType)){
                        newHTMLfld += '<div class="annotation-number" style="pointer-events: none; position: absolute; text-align: center; '; 
                        newHTMLfld += 'left: ' + annotation.Annotation_X__c * 100 + '%;';
                        newHTMLfld += 'width: ' + annotation.Annotation_Width__c * 100 + '%;';
                        newHTMLfld += 'top: ' + annotation.Annotation_Y__c * 100 + '%;';
                        newHTMLfld += 'height: ' + annotation.Annotation_Height__c * 100 + '%;';
                        newHTMLfld += 'border: 1px black solid;"><span style="color: red; font-size: 1.5em;">';
                        newHTMLfld += i;
                        newHTMLfld += '</span></div>';
                        ++i;
                    }
                   newHTMLfld += '</div>';                    
                   newHTMLfld += '<div style="margin-left: 420px; height: 298px; overflow: auto;">';
                   newHTMLfld += '<table id="annotations">';
                   newHTMLfld += '<tbody>';
                   Integer j=1;
                   for (Evaluation_Response__c annotation : parentObj.mapEvalResposes.get(this.parentEval).get(annotationRecType)){
                        newHTMLfld += '<tr><td>' + j + '</td><td>' + annotation.Annotation_Text__c + '</td></tr>';
                        ++j;
                   }
                   newHTMLfld +='</tbody></table></div>';
                   newHTMLfld +=  '</div>';
                                       
                }
//                 else if ( e.field_type__c == 'Image') {
//                    newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
//                    newHTMLfld += '<div style="display: table-row;">';
//                    newHTMLfld += '<img id="' + e.htmlid__c + '"  name="' + e.id + '"';
//                    newHTMLfld += ' src="' + parentObj.resourceMap.get(e.field_sub_type__c) + '" />';
//                    newHTMLfld +=  '</div>';
//                }
                
               if (newHtmlFld != '')  this.strEvalSections.add(newHtmlFld);
               
            }
        }
        
    }   
    
}