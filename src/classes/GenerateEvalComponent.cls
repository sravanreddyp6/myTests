public with sharing class GenerateEvalComponent {


	public List<string> ctlList {get { return CreateFieldControls();} set;}
	public string cat {get; set;}
	public string subcat{get; set;} 
	public string subsubcat{get; set;}
	public string evalname{get; set;}
	public SObject fullobj{ get; set;}
	public ID evaluationID { get; set;}
	public ID pbsID { get; set;}
	
	public GenerateEvalComponent( ) {
		
	}
	
	
	public List<string> CreateFieldControls () {
		
	Map<ID, List<Eval_Drop_Down__c>> ddOptions = new Map<ID, List<Eval_Drop_Down__c>>();
	List<Eval_Drop_Down__c> dd = [ select whatid__c, option_name__c, option_value__c from eval_drop_down__c where What_Id_Object__c = 'Eval__c' order by whatid__c ];
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
	List<Eval__c> lstEvalItems = [select	id, 
											htmlid__c,
											field_name__c,
											category__c, 
											category_sequence__c, 
											sub_category__c,
											sub_category_sequence__c, 
											eval_type__r.name, 
											eval_field_type__r.name, 
											eval_field_type__r.html_element__c,
											field_sequence__c,
											required__c
									from 
											eval__c
									where 	
											eval_type__r.name = :evalname 
									and 	category__c =:cat 
									and 	sub_category__c = :subcat 
									and		visible__c = true
									order by 
											category_sequence__c, sub_category_sequence__c, field_sequence__c];
		 
		// get any populated values for this eval and section
		List<Eval_Value__c> listEvalValues = [ select id, boolean__c, currency__c, date_time__c, number_no_decimal__c, text_over_250__c, text_under_250__c, eval__c from eval_value__c
												where eval__c in :lstEvalItems
												and	what_id__c = :evaluationID
												and	what_id_object__c = 'Evaluation__c'];
		
		// create a map by eval id
		Map<ID, Eval_Value__c> mapEvalValues = new Map<ID, Eval_Value__c>();
		for ( Eval_Value__c ev: listEvalValues ) 
			mapEvalValues.put( ev.eval__c, ev);
		
		system.debug( 'Populated values:' + mapEvalValues );										 
		String newHTMLfld = ''; 
		String strval = '';
		for( Eval__c e : lstEvalItems ){
			try {
				newHTMLfld = '';
				strval = '';
				
				if ( e.eval_field_type__r.name == 'Boolean' )  {
					if ( e.eval_field_type__r.html_element__c == 'Check') {
						newHTMLfld = '<input id="' + e.htmlid__c + '" type="checkbox" name="' + e.field_name__c + '" value="' + 1 + '"';
						
						// insert value
						if ( mapEvalValues.ContainsKey( e.id )) 
							if ( mapEvalValues.get(e.id).boolean__c)
								newHTMLFld += ' checked ';
								
						newHTMLfld += '><span class="labelCol">' + e.field_name__c + '</span>';
					}
					else if (e.eval_field_type__r.html_element__c == 'Dropdown') {
						// Boolean dropdown values = --None--, Yes, No
						newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><select id="' + e.htmlid__c + '" >';
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
						newHTMLfld += '</select>';
					}
  				} else if (e.eval_field_type__r.name=='String') {
  						newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><input id="' + e.htmlid__c + '" type="text" name="' + e.field_name__c + '"';
  						if (mapEvalValues.ContainsKey( e.id )) {
  							newHTMLfld += 'value="' ;
  							if ( e.eval_field_type__r.length__c > 250 )
  								newHTMLfld += mapEvalValues.get(e.id).text_under_250__c;
  							else
  								newHTMLfld += mapEvalValues.get(e.id).text_over_250__c;
  								
  							newHTMLfld	+= '"';
  						}	
  						newHTMLfld +=  '/>'; 
				} else if (e.eval_field_type__r.name == 'DropDown') {
					
					// get the value
					if ( mapEvalValues.ContainsKey( e.id )) 
							strVal = mapEvalValues.get(e.id).text_under_250__c;
							
					// get the options
					List<Eval_drop_Down__c> dropdownopts = ddOptions.get( e.id);
					newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><select id="' + e.htmlid__c + '" >';
					newHTMLfld += '<option value="">-- None --</option>';
					for ( Eval_Drop_Down__c thisdd : dropdownopts) {
						newHTMLFld += '<option value="' + thisdd.option_value__c + '"';
						if ( strval ==  thisdd.option_value__c )
							newHTMLFld += ' selected ';
					
						newHTMLFld += '>' + thisdd.option_name__c + '</option>';
					}
					newHTMLfld += '</select>';
				}
				
				htmlControls.Add( newHTMLfld);
			} 
			catch( Exception ex)
			 { System.Debug( ex); }	
			 
			  
		}
		
		return htmlControls;
	}
	
	/*
	@RemoteAction
    public static void addOrModifyEvalItem(ID evalId, String evalItemType, , String evaluationId) {
        Eval_Value__c evalVal
        if (evalID!=null) {
            annotation = [
                SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
            ];
        } else {
            annotation = new Evaluation_Response__c();
            annotation.Evaluation__c = evaluationId;
            annotation.RecordTypeId = Utility.getEvaluationResponseRecordType('Annotation');
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
    
*/
}