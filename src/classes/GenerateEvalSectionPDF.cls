public with sharing class GenerateEvalSectionPDF {

	public string cat {get; set;}
	public string subcat{get; set;}
	public string subsubcat{get; set;}
	public string evalname{get; set;}
	public string opGrp {get;set;}
	public ID evaluationID { get; set;}
	public string evalSectionId { get; set;}
	public string evalSecType { get; set;}
	public string uniqueID{ get; set; }

	public static Map<ID, Eval__c> mapEvalItems;
	public static Map<String, Map<ID, Eval_Value__c> > mapEntryValues;
	public transient Map<String, EntryWrapper> mapEntries {get; set;}
	public transient List<String> listEntries {get;set;}
	public transient Map<String, Boolean> notApplicableSectionMap { get; set; }
	public transient Map<String, List<string>> mapEntryHTML{ get; set;}

	public static Evaluation__c thiseval { get; private set;}

	public transient List<GenerateGoalObjPDF.ObjectiveWrapper> objectives { get; set; }
	public transient Contact pbsObj {get;set;}

	@TestVisible
	private Evaluation_Response__c[] getAnnotations(String annotationType) {
		String annotationRecType= annotationType != null && annotationType.contains('Neuro') ? 'NeuroAnnotation': 'Annotation';
		return [
			SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c, Annotation_Y__c,
			       Annotation_Source__c, Annotation_Shape__c, Annotation_Text__c
			  FROM Evaluation_Response__c WHERE Evaluation__c=:evaluationId
			   AND RecordType.Name =: annotationRecType
		];
	}

	public Assessment__c[] assessments {
		get {
			return [SELECT Id, Name FROM Assessment__c WHERE Evaluation__c =:evaluationID AND Status__c != 'Disregard'];
		}
		set;
	}

	public GenerateEvalSectionPDF( ) {
		mapEvalItems = new Map<ID, Eval__c>();

		mapEntryValues = new Map<String, Map<ID, Eval_Value__c> > ();
		evaluationID = ApexPages.currentPage().getParameters().get('evalID');
		evalname=ApexPages.currentPage().getParameters().get('evalname');
		opGrp = ApexPages.currentPage().getParameters().get('opGrp');
		cat=ApexPages.currentPage().getParameters().get('cat');
		subcat = ApexPages.currentPage().getParameters().get('subCat');
		listEntries = new List<string>();
		notApplicableSectionMap = new Map<String, Boolean>();
		mapEntries = new Map<String, EntryWrapper>();
		mapEntryHTML = CreateFieldControls();

		approvalHistory = new List<ProcessInstanceHistory>();

		thisEval = [
			SELECT id, name, shift_start_time__c, shift_end_time__c, status__c,
			       head_to_toe_status__c, owner.name,
			       ServiceAssignment__r.Admission__r.Person_Being_Served__c
			  FROM evaluation__c
			 WHERE id = :evaluationID
			 LIMIT 1];

		if (thisEval.shift_start_time__c != null && thisEval.shift_end_time__c != null) {
			GenerateGoalObjPDF goalscontroller = new GenerateGoalObjPDF();
			goalscontroller.init( evaluationID );
			objectives = goalscontroller.objectives;
		}
		pbsObj = [
			SELECT Id, FirstName, LastName, Birthdate, PBS_Identifier__c,Avatar_ID__c
			  FROM Contact
			  WHERE id=:thisEval.ServiceAssignment__r.Admission__r.Person_Being_Served__c
		];
		// Naming the PDF in case this controller is used for the PDF page
		String file = thisEval.Name + '.pdf';
		file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
		// Assigns the Shift Assessment Name to the PDF dynamically. Doesn't work with Chrome when Adboe Reader plugin is enabled.
		Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');
	}

	public Map<string, List<string>> CreateFieldControls () {
		// get the list of controls for this eval
		List<String> htmlcontrols = new List<String>();
		String query =
			'SELECT id, htmlid__c, field_name__c, category__c, category_sequence__c, ' +
			'       sub_category__c, sub_sub_category__c, eval_type__r.name, Field_Type__c, ' +
			'       Field_Sub_Type__c, length__c ' +
			' FROM eval__c  ' +
			'WHERE eval_type__r.name = :evalname ' +
			'  AND field_name__c != \'isValid\' and field_name__c != \'ErrorMsg\' and visible__c = true ';	// don't want sections with only errors in them

		if ( !String.isEmpty(cat))
			query += ' AND category__c =:cat';

		if ( !String.isEmpty(subcat))
			query += ' AND sub_category__c = :subcat';

		query += ' ORDER BY cat_seq_text__c, subcat_seq_text__c, field_sequence__c';
		List<Eval__c> listEvalItems = Database.Query( query );

		// create a map for easy access
		mapEvalItems = new Map<ID, Eval__c>(listEvalItems);

		// also create a map of fields in a section by storing the field list by composite key of category~subcat~subcat
		Map<String, List<Eval__c>> mapEvalItemsbyCat = new Map<string, List<Eval__c>>();
		String compkey = '';
		List<Eval__c> eitems;
		List<String> listSections = new List<String>();
		for ( Eval__c ei : listEvalItems) {

			compkey = ei.category__c + '~' + ei.sub_category__c + '~' + ei.sub_sub_category__c;
			if ( mapEvalItemsbyCat.get(compkey) == null ) {
				eitems = new List<Eval__c>{ei};
				mapEvalItemsbyCat.put( compkey, eitems);
				listSections.add( compkey);
			}
			else
				mapEvalItemsbyCat.get(compkey).add( ei);

		}
		//system.debug( 'EVAL ITEMS BY CATSUB:' + mapEvalItemsbyCat);

		// get any populated values for this eval and section
		List<Eval_Value__c> listEvalValues = [
			SELECT eval_section_id__c, id, boolean__c, currency__c, date_time__c,
			       number_no_decimal__c, text_over_250__c, text_under_250__c, eval__c,
			       eval__r.category__c, eval__r.sub_category__c, eval__r.sub_sub_category__c,
			       owner.name, createddate, eval_section_type__c, eval__r.htmlid__c
			  FROM eval_value__c
			 WHERE eval__c in :listEvalItems
			   AND what_id__c = :evaluationID
			   AND what_id_object__c = 'Evaluation__c'
			   AND eval__r.Field_name__c != 'Dummy Value' //Exclude Restraint Reduction fields - Confirm With Bridget - Sravan 04/17/2015
			ORDER BY eval__r.cat_seq_text__c, eval__r.subcat_seq_text__c,
			         eval__r.subsubcat_seq_text__c, eval_section_id__c, createddate
		];

		system.debug( 'EVAL VALUES' + listEvalValues);

		// create a map by eval id
		Map <ID, Eval_Value__c>mapEvalValues;
		String entrycompkey='';

		// create a list of entries by composite key
		Map<String, Set<string>> mapEntryIndex = new Map<string, Set<string>>();

		String curritem = '';
		mapEvalValues = new Map<ID, Eval_Value__c>();

		for ( Eval_Value__c ev: listEvalValues ) {

			if ( ev.eval_section_id__c != curritem ) {
				listEntries.add( ev.eval_section_id__c);	// add to list of entries
				notApplicableSectionMap.put(ev.Eval_Section_Id__c, false);
				curritem = ev.eval_section_id__c;
				mapEvalValues = new Map<ID, Eval_Value__c>();
			}
			if (ev.Eval__r.HtmlId__c == 'NotApplicable' && ev.Boolean__c) {
				notApplicableSectionMap.put(ev.Eval_Section_Id__c, true);
			}

			mapEvalValues.put( ev.eval__c, ev);
			mapEntryValues.put( ev.eval_section_id__c, mapEvalValues);

			entrycompkey = ev.eval__r.category__c + '~' + ev.eval__r.sub_category__c + '~' + ev.eval__r.sub_sub_category__c;

			mapEntries.put( ev.eval_section_id__c, new EntryWrapper( entrycompkey, ev.eval_section_id__c, ev.owner.name, ev.createddate, ev.eval__r.category__c, ev.eval__r.sub_category__c, ev.eval_section_type__c));


			// make a map of entries keyed by section/sub/sub key
			if ( mapEntryIndex.get( entrycompkey ) == null ) {
				mapEntryIndex.put( entrycompkey, new Set<String>());

			}
			mapEntryIndex.get( entrycompkey ).add( ev.eval_section_id__c );

		}

		String newHTMLfld = '';
		String strval = '';

		htmlControls = new List<String>();
		Integer totalCounter = 0;
		Integer listCounter = 0;
		Map<string, LIst<string>> mapEvalEntryHTML = new Map<String, List<string>>();


		// for each category/sub/subsub
		for ( String sectionkey : listSections) {
			// for each entry in this section
			if ( mapEntryIndex.get(sectionkey) != null ) {
				for ( String entryId : mapEntryIndex.get(sectionkey) ) {
					htmlControls = new List<String>();

					// for each field in this category/sub/sub
					for( Eval__c e : mapEvalItemsbyCat.get(sectionkey) ){
						try {
							mapEvalValues = mapEntryValues.get(entryID);
							newHTMLfld = '';
							strval = '';

							if ( e.Field_Type__c == 'Hidden' )  {
								newHTMLfld += '<div id="' + e.htmlid__c + '" style="display: none;">';
								if (mapEvalValues.ContainsKey( e.id )) {
									if (e.Field_Sub_Type__c == 'String')
										newHTMLfld += mapEvalValues.get(e.id).text_over_250__c;
								}
								newHTMLfld +=  '</div>';
							} else if ( e.Field_Type__c == 'Boolean' )  { // Boolean can be Checkbox, Radio, or Dropdown
								if ( e.Field_Sub_Type__c == 'Checkbox') {
									newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
									// insert value
									if ( mapEvalValues.ContainsKey( e.id ))
										if ( mapEvalValues.get(e.id).boolean__c)
											newHTMLFld += 'Yes';
										else
											newHTMLFld += 'No';
									newHTMLfld += '</div>';
								} else if (e.Field_Sub_Type__c == 'Dropdown') {
									// Boolean dropdown values = --None--, Yes, No
									newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
									if ( mapEvalValues.ContainsKey( e.id )) {
										strval = mapEvalValues.get( e.id).Text_Under_250__c;
									}
									if (strval == '1')
										newHTMLfld += 'Yes';
									else if (strval == '0')
										newHTMLfld += 'No';
									newHTMLfld += '</div>';
								} //TODO: output radio buttons for Radio type
							} else if (e.Field_Type__c=='String') {
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								if (mapEvalValues.ContainsKey( e.id )) {
									if ( e.length__c > 250 )
										strVal = mapEvalValues.get(e.id).text_over_250__c;
									else
										strVal = mapEvalValues.get(e.id).text_under_250__c;

									if (strVal != null && strVal != '')
										newHTMLfld += strVal;
								}
								newHTMLfld +=  '</div>';
							} else if (e.Field_Type__c == 'Int'){
								if ( mapEvalValues.ContainsKey( e.id ))
									strVal = String.valueOf(mapEvalValues.get(e.id).Number_No_Decimal__c);
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								newHTMLfld += strVal;
								newHTMLfld += '</div>';
							} else if (e.Field_Type__c == 'DropDown' || e.Field_Type__c == 'Double') {

								// get the value
								if ( mapEvalValues.ContainsKey( e.id ))
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

							}  else if (e.Field_Type__c == 'Date') {
								newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								if (mapEvalValues.ContainsKey( e.id ))
									newHTMLfld += mapEvalValues.get(e.id).date_time__c.Date().format(); // output date format
								newHTMLfld +=  '</div>';
							} else if (e.Field_Type__c == 'Datetime') {
								newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								if (mapEvalValues.ContainsKey( e.id ))
									newHTMLfld += Utility.getMilitarytime(mapEvalValues.get(e.id).date_time__c); // output date format
								newHTMLfld +=  '</div>';
							} else if (e.Field_Type__c == 'Multiselect') {

								if ( mapEvalValues.ContainsKey( e.id )){
									if ( e.length__c > 250 )
										strVal = mapEvalValues.get(e.id).Text_Over_250__c;
									else
										strval = mapEvalValues.get(e.id).Text_Under_250__c;
								}
								//system.debug( e.id + ' - multiselect -' + selectedVals);
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								newHTMLfld += strval;
								newHTMLfld +=  '</div>';
							} else if (e.field_type__c == 'BodyMap') {
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								newHTMLfld += '<div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
								newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' + GetResourceURL(e.field_sub_type__c) + '?' + entryID + '" id="bodyMap' + entryID + '" />';

								Integer i=1;
								for (Evaluation_Response__c annotation : getAnnotations(e.field_sub_type__c)){
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
								for (Evaluation_Response__c annotation : getAnnotations(e.field_sub_type__c)){
									newHTMLfld += '<tr><td>' + j + '</td><td>' + annotation.Annotation_Text__c + '</td></tr>';
									++j;
								}
								newHTMLfld +='</tbody></table></div>';
								newHTMLfld +=  '</div>';

							} else if ( e.field_type__c == 'Image') {
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								newHTMLfld += '<div style="display: table-row;">';
								newHTMLfld += '<img id="' + e.htmlid__c + '"  name="' + e.id + '"';
								newHTMLfld += ' src="' + GetResourceURL(e.field_sub_type__c) + '" />';
								newHTMLfld +=  '</div>';
							} else if ( e.field_type__c == 'Slider') {
								newHTMLfld += '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
								newHTMLfld += '<div id="' + e.htmlid__c + '" name="' + e.id + '" />';
								newHTMLfld +=  '</div>';
							}

							//EC-169 the questions 1 through 10 do NOT apply to the section if section Type is an activity log
							if (mapEntries.get(entryId).entryType == 'Activity Log' && e.htmlid__c.contains('HeadtoToeDiagnosticsIVQuestion')) continue;

							htmlControls.add(newHtmlFld);
							mapEvalEntryHTML.put( entryId, htmlControls );
						} catch( Exception ex) {
							System.Debug( ex);
						}
					}
				}
			}
		}
		system.debug('HTML IS:' + mapEvalEntryHTML);
		return mapEvalEntryHTML;
	}

	public static String GetResourceURL(String resourceName) {

		List<StaticResource> resourceList = [
			SELECT Name, NamespacePrefix, SystemModStamp
			  FROM StaticResource
			 WHERE Name = :resourceName
		];

		if (resourceList.size() == 1) {
			String namespace = resourceList[0].NamespacePrefix;
			return '/resource/'
					+ resourceList[0].SystemModStamp.getTime() + '/'
					+ (namespace != null && namespace != '' ? namespace + '__' : '')
					+ resourceName;
		} else return '';

	}

	public class EntryWrapper {
		public string compositeKey { get; set;}
		public string entryid{get;set;}
		public string cat {get;set;}
		public string subcat {get;set;}
		public string owner { get; set;}
		public string created {get;set;}
		public string entryType { get; set;}

		public EntryWrapper( string key, string eid, string eown, datetime ecr, string ecat, string esubcat, string secType ) {
			compositeKey = key;
			entryid = eid;
			cat = ecat;
			subcat = esubcat;
			owner = eown;
			created = Utility.getMilitarytime(ecr);
			entryType = secType;
		}
	}

	public Transient List<ProcessInstanceHistory> approvalHistory;
	public List<ProcessInstanceHistory> getApprovalHistory () {
		List<ProcessInstance> pi = [
			SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate
			              FROM StepsAndWorkitems
			            ORDER BY createddate desc)
			  FROM ProcessInstance where targetobjectid = :evaluationID
			ORDER BY createddate desc];

		for ( ProcessInstance p : pi ) {
			approvalHistory.addAll (p.stepsandworkitems);
		}
		return approvalHistory;
	}
}