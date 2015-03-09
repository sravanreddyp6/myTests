/* 
  Add comments here about what type of fields are not yet handelled. 
*/
public with sharing class GenerateEvalComponent {

	public List<string> ctlList {get { return CreateFieldControls();} private set;}
	public string cat {get; set;}
	public string subcat{get; set;}
	public string subsubcat{get; set;}
	public string evalname{get; set;}
	public ID evaluationID { get; set;}
	public ID pbsID { get; set;}
    public string evalSectionId { get; set;}
    public string evalSecType { get; set;}

	public static Map<ID, Eval__c> mapEvalItems;
	public static Map<ID, Eval_Value__c> mapEvalValues;
	    public Evaluation_Response__c[] annotations { set;
        get {
            return [
                SELECT ID, Annotation_Height__c, Annotation_Width__c,
                       Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                       Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluationId
                 AND RecordType.Name='Annotation'
            ];
        }
    }

	public GenerateEvalComponent( ) {
		mapEvalItems = new Map<ID, Eval__c>();
		mapEvalValues = new Map<ID, Eval_Value__c>();
	}

	public List<string> CreateFieldControls () {

		Map<ID, List<Eval_Drop_Down__c>> ddOptions = new Map<ID, List<Eval_Drop_Down__c>>();
		List<Eval_Drop_Down__c> dd = [ select whatid__c, option_name__c, option_value__c, Dependent_Fields__c, visibility_row_rules__c, visibility_rules__c from eval_drop_down__c where What_Id_Object__c = 'Eval__c' order by whatid__c, Sequence__c ];
		List<Eval_Drop_Down__c> newdd;
		for ( Eval_Drop_Down__c edd : dd ) {
			if ( ddOptions.ContainsKey( edd.whatid__c)) {
				if ( (newdd = ddOptions.get(edd.whatid__c)) == null )
					newdd = new List<Eval_Drop_Down__c>();
			} else {
				newdd = new List<Eval_Drop_Down__c>();
			}
			newdd.Add( edd);
			ddOptions.put( edd.whatid__c, newdd);

		}

		// get the list of controls for this type, category, and subcategory
		List<String> htmlcontrols = new List<String>();
		List<Eval__c> listEvalItems = [
			select id,
			       htmlid__c,
			       field_name__c,
			       category__c,
			       category_sequence__c,
			       sub_category__c,
			       sub_category_sequence__c,
			       eval_type__r.name,
			       Field_Type__c,
			       Field_Sub_Type__c,
			       field_sequence__c,
			       required__c,
			       Length__c,
			       visibility_rules__c,
			       visibility_row_rules__c,
			       Dependent_Fields__c
			  from eval__c
			 where eval_type__r.name = :evalname
			   and category__c =:cat
			   and sub_category__c = :subcat
			   and visible__c = true
			order by category_sequence__c, sub_category_sequence__c, field_sequence__c
		];
		// create a map for easy access
		mapEvalItems = new Map<ID, Eval__c>(listEvalItems);

        // get any populated values for this eval and section
        List<Eval_Value__c> listEvalValues = [
            select id, boolean__c, currency__c, date_time__c, number_no_decimal__c, text_over_250__c, text_under_250__c, eval__c from eval_value__c
             where eval__c in :listEvalItems
               and what_id__c = :evaluationID
               and what_id_object__c = 'Evaluation__c'
               and eval_Section_Id__c = :evalSectionId
        ];

        // create a map by eval id
        mapEvalValues = new Map<ID, Eval_Value__c>();
        for ( Eval_Value__c ev: listEvalValues )
            mapEvalValues.put( ev.eval__c, ev);

        system.debug( 'Populated values:' + mapEvalValues );
		String newHTMLfld = '';
		String strval = '';
		String reqfldHTML = '';
		for( Eval__c e : listEvalItems ){
			try {
				newHTMLfld = '';
				strval = '';
				
				if (e.Required__c) {
				    reqfldHTML = '<div class="requiredInput" style="display: table-cell;"><div class="requiredBlock"></div>';
				} else {
                    reqfldHTML = '<div style="display: table-cell;">';
				}

                if ( e.Field_Type__c == 'Hidden' )  {
                	newHTMLfld = '<input id="' + e.htmlid__c + '" name="' + e.id + '" type="hidden" ';  
                	if (mapEvalValues.ContainsKey( e.id )) {
                        newHTMLfld += 'value="' ;
	                	if (e.Field_Sub_Type__c == 'Boolean') {
	                        newHTMLfld += mapEvalValues.get(e.id).boolean__c;
	                    }
	                    else if (e.Field_Sub_Type__c == 'String') {
	                        newHTMLfld += mapEvalValues.get(e.id).Text_Over_250__c;
	                    }
                	}
                    newHTMLfld += '"/>'; 
                                              
                } else if ( e.Field_Type__c == 'Boolean' )  { // Boolean can be Checkbox, Radio, or Dropdown
                    if ( e.Field_Sub_Type__c == 'Checkbox') {
                        newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label><input id="' + e.htmlid__c + '" name="' + e.id + '" type="checkbox" value="' + 1 + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '"';

                        // insert value
                        if ( mapEvalValues.ContainsKey( e.id ))
                            if ( mapEvalValues.get(e.id).boolean__c)
                                newHTMLFld += ' checked ';

                        newHTMLfld += '/></div>';
                    } else if (e.Field_Sub_Type__c == 'Dropdown') {
                        // Boolean dropdown values = --None--, Yes, No
                        newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                        newHTMLfld += reqfldHTML;
                        newHTMLfld += '<select  id="' + e.htmlid__c + '" name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '">';
                        newHTMLfld += '<option value="">-- None --</option>';
                        if ( mapEvalValues.ContainsKey( e.id )) {
                            strval = mapEvalValues.get( e.id).Text_Under_250__c;
                        }
                        newHTMLfld += '<option value="1"';
                        if (strval == '1')
                            newHTMLfld += ' selected';
                        newHtmlfld += '>Yes</option>';
                        newHTMLfld += '<option value="0"';
                        if (strval == '0')
                            newHTMLfld += ' selected';
                        newHTMLfld += '>No</option>';
                        newHTMLfld += '</select></div></div>';
                    } //TODO: output radio buttons for Radio type
                } else if (e.Field_Type__c=='String') {
                    newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += reqfldHTML;
                    newHTMLfld += '<input  id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
                    if (mapEvalValues.ContainsKey( e.id )) {
                        newHTMLfld += 'value="' ;
                        if ( e.length__c > 250 )
                            strVal = mapEvalValues.get(e.id).text_over_250__c;
                        else
                            strVal = mapEvalValues.get(e.id).text_under_250__c;

                        if (strVal != null && strVal != '')
                            newHTMLfld += strVal;
                            
                            newHTMLfld += '"';
                    }
                    newHTMLfld +=  '/></div></div>';
                } else if (e.Field_Type__c == 'DropDown') {

                    // get the value
                    if ( mapEvalValues.ContainsKey( e.id ))
                        strVal = mapEvalValues.get(e.id).text_under_250__c;

                    // get the options
                    List<Eval_drop_Down__c> dropdownopts = ddOptions.get( e.id);
                    newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += reqfldHTML;
                    newHTMLfld += '<select id="' + e.htmlid__c + '"  name="' + e.id + '" data-visibility-row-rules="' + e.visibility_row_rules__c + '" data-visibility-rules="' + e.visibility_rules__c + '" data-rules="' + e.Dependent_Fields__c + '">';
                    newHTMLfld += '<option value="">-- None --</option>';
                    for ( Eval_Drop_Down__c thisdd : dropdownopts) {
                        newHTMLFld += '<option value="' + thisdd.option_value__c + '"';
                        if ( strval ==  thisdd.option_value__c )
                            newHTMLFld += ' selected ';

                        newHTMLFld += '>' + thisdd.option_name__c + '</option>';
                    }
                    newHTMLfld += '</select></div></div>';
                }  else if (e.Field_Type__c == 'Date') {
					newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += reqfldHTML;
                    newHTMLfld += '<input class="datepicker" ' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
					if (mapEvalValues.ContainsKey( e.id )) {
                        newHTMLfld += 'value="' + mapEvalValues.get(e.id).date_time__c;
                        newHTMLfld  += '"';
                    }
                    newHTMLfld +=  '/></div></div>';
				} else if (e.Field_Type__c == 'Datetime') {
                    newHTMLfld = '<div style="display: table-row;"><label id="' + e.htmlid__c + 'Label" for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    newHTMLfld += reqfldHTML;
                    newHTMLfld += '<input class="datetimepicker" ' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
                    if (mapEvalValues.ContainsKey( e.id )) {
                        newHTMLfld += 'value="' + mapEvalValues.get(e.id).date_time__c;
                        newHTMLfld  += '"';
                    }
                    newHTMLfld +=  '/></div></div>';
                } else if (e.Field_Type__c == 'Multiselect') {
                	String selectedVals;
                    if ( mapEvalValues.ContainsKey( e.id )){
	                	if ( e.length__c > 250 )
	                       selectedVals = mapEvalValues.get(e.id).Text_Over_250__c;
	                    else
	                       selectedVals = mapEvalValues.get(e.id).Text_Under_250__c;
                    }
                    
                	if ( e.Field_Sub_Type__c == 'Checkbox') {
	                	newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label><br/>';
	                	// get the options
	                    List<Eval_drop_Down__c> dropdownopts = ddOptions.get(e.id);
	                    for ( Eval_Drop_Down__c thisdd : dropdownopts) {
		                	newHTMLfld += '<input id="' + e.htmlid__c+thisdd.Option_Value__c.replaceAll('\\s','') + '" name="' + e.id + '" type="checkbox" value="' + thisdd.Option_Value__c + '" data-visibility-row-rules="' + thisdd.visibility_row_rules__c + '" data-visibility-rules="' + thisdd.visibility_rules__c + '" data-rules="' + thisdd.Dependent_Fields__c + '"';
		                	
			                // insert value
	                        if ( mapEvalValues.ContainsKey( e.id ))
	                            if ( selectedVals.contains(thisdd.Option_Value__c))
	                                newHTMLFld += ' checked ';
                                
	                        newHTMLfld += '/>&nbsp<span>' + thisdd.Option_Name__c + '</span><br/>';
	                    }
	                    newHTMLfld +=  '</div>';
                	}else{
                		//ToDo: Regular multiselect. 
                	}
                } else if (e.field_type__c == 'BodyMap') {
                	
       				newHTMLfld = '<div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
                	newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' +  GetResourceURL('WholeBodyNoGrid') + '?' + evalSectionId + '" id="bodyMap' + evalSectionID + '" />';
                	newHTMLfld += '</div>';
                    newHTMLfld += '<div style="margin-left: 420px; height: 298px; overflow: auto;">';
                    newHTMLfld += '<table id="annotations">';
                    newHTMLfld += '<tbody></tbody></table></div>';
                    
                	
                }
                
                
				htmlControls.Add( newHTMLfld);
			}
			catch( Exception ex)
			{
				System.Debug( ex);
			}
		}

		return htmlControls;
	}
	
	public class FormKeyVal{
		public Id name;
		public String value; 
	}

	@RemoteAction
	public static void saveFields(ID evalId, String evalSectionId, String evalSectionType, String EvalType, String cat, String subcat, String jsonForm) {
		
		mapEvalItems = new Map<ID, Eval__c>([ select   id,
												       htmlid__c,
												       field_name__c,
												       category__c,
												       category_sequence__c,
												       sub_category__c,
												       sub_category_sequence__c,
												       eval_type__r.name,
												       Field_Type__c,
												       Field_Sub_Type__c,
												       field_sequence__c,
												       required__c,
												       length__c
												  from eval__c
												 where eval_type__r.name = :EvalType
												   and category__c =:cat
												   and sub_category__c = :subcat
												   and visible__c = true
												order by category_sequence__c, sub_category_sequence__c, field_sequence__c]);
		
		// get any populated values for this eval and section
		List<Eval_Value__c> listEvalValues = [
			select id, boolean__c, currency__c, date_time__c, number_no_decimal__c, text_over_250__c, text_under_250__c, eval__c from eval_value__c
			 where eval_Section_Id__c = :evalSectionId
			   and what_id__c = :evalId
			   and what_id_object__c = 'Evaluation__c'
		];

		// create a map by eval id
		mapEvalValues = new Map<ID, Eval_Value__c>();
		for ( Eval_Value__c ev: listEvalValues )
			mapEvalValues.put( ev.eval__c, ev);

		//Map<String,Object> formData = (Map<String, Object>) JSON.deserializeUntyped(jsonForm);		
		list<FormKeyVal> objs = (list<FormKeyVal>) JSON.deserialize(jsonForm, list<FormKeyVal>.class);
		Map<String,String> formData = new map<String, String>();
		String oldMapVal;
		for(FormKeyVal d : objs){
			 oldMapVal = formData.put(d.name, d.value);
			 if (oldMapVal != null && oldMapVal != '')
			     formData.put(d.name, oldMapVal +';'+ formData.get(d.name));
		}

		List<Eval_Value__c> newValues = new List<Eval_Value__c>();
		List<Eval_Value__c> delValues = new List<Eval_Value__c>();
		// use the values already on the eval
		// check if data has changed
		Eval_Value__c ev;
		for ( String f : formData.Keyset()) {

			// get the eval item from the map so we know what type, etc.
			Eval__c ei = mapEvalItems.get((ID)f);

			// construct new eval_value object
			if ( mapEvalValues.containsKey( (ID)f ))  {
				// value exists - need to update value
				ev = mapEvalValues.get((ID)f);
			}	else {
					ev = new Eval_Value__c();
					ev.eval__c = (ID)f;
					ev.eval_Section_Id__c = evalSectionId;
					ev.Eval_Section_Type__c = evalSectionType;
					ev.what_id__c = evalID;
					ev.what_id_object__c = 'Evaluation__c';
			}

			if (formData.get(f) != null && formData.get(f) != '') {
				// put the value in the right place
				if ( ei.Field_Type__c == 'Boolean'){
					if (ei.Field_Sub_Type__c == 'Checkbox' || ei.Field_Sub_Type__c == 'Radio') {
						if ( formData.get(f) == '1')
							ev.Boolean__c = true;
						else
							ev.Boolean__c = false;
					}
					else if (ei.Field_Sub_Type__c == 'Dropdown')
						ev.Text_Under_250__c = formData.get(f);
				}
				else if (ei.Field_Type__c == 'Int'){
					ev.Number_No_Decimal__c = Integer.valueOf(formData.get(f));
				}
				else if (ei.Field_Type__c == 'Date'){
					ev.Date_Time__c = Datetime.newInstance(Date.parse(formData.get(f)), Time.newInstance(0,0,0,0));
				}
				else if (ei.Field_Type__c == 'Datetime' ){
                    ev.Date_Time__c = Datetime.parse(formData.get(f));
                }
				else if (ei.Field_Type__c == 'String' || ei.Field_Type__c == 'ID' || 
						 ei.Field_Type__c == 'Multiselect' || ei.Field_Type__c == 'Dropdown' || ei.Field_Type__c == 'Double' || 
						 ei.Field_Type__c == 'Currency'){
					if ( ei.length__c > 250 )
						ev.Text_Over_250__c = formData.get(f);
					else
						ev.Text_Under_250__c = formData.get(f);
				}
				else if (ei.Field_Type__c == 'Hidden'){
                    if (ei.Field_Sub_Type__c == 'Boolean') {
                        ev.Boolean__c = Boolean.valueOf(formData.get(f));
                    }
                    else if (ei.Field_Sub_Type__c == 'String') {
                    	ev.Text_Over_250__c = formData.get(f);
                    }
                }
                
				newValues.add(ev);
			}
			else if (ev.id != null ) {
				delValues.add(ev);
			}

		}
		delete delValues;
		upsert newValues;
	}
	
	
	@RemoteAction
    public static Evaluation_Response__c addOrModifyAnnotation(ID annotationId, String source, Decimal x, Decimal y, Decimal Width, Decimal Height, String Shape, String Text, String evaluationId) {
        Evaluation_Response__c annotation;
        if (annotationId!=null) {
            annotation = [
                SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
            ];
        } else {
            annotation = new Evaluation_Response__c();
            annotation.Evaluation__c = evaluationId;
            annotation.RecordTypeId = source.contains('Neurotab') ? Utility.getEvaluationResponseRecordType('NeuroAnnotation'): Utility.getEvaluationResponseRecordType('Annotation');
        }
        annotation.Annotation_Height__c = Height;
        annotation.Annotation_Width__c = Width;
        annotation.Annotation_X__c = x;
        annotation.Annotation_Y__c = y;
        annotation.Annotation_Source__c = Source;
        annotation.Annotation_Shape__c = Shape;
        annotation.Annotation_Text__c = Text;
        System.debug('Annotation to upsert: ' + annotation);
        upsert annotation;
        return annotation;
    }
    
     
    @RemoteAction
    public static void deleteAnnotation(ID annotationId) {
        delete [
            SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
        ];
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


}