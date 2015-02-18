public with sharing class GenerateEvalComponent {

	public List<string> ctlList {get { return CreateFieldControls();} set;}
	public string cat {get; set;}
	public string subcat{get; set;}
	public string subsubcat{get; set;}
	public string evalname{get; set;}
	public SObject fullobj{ get; set;}
	public ID evaluationID { get; set;}
	public ID pbsID { get; set;}

	public static Map<ID, Eval__c> mapEvalItems;
	public static Map<ID, Eval_Value__c> mapEvalValues;

	public GenerateEvalComponent( ) {
		mapEvalItems = new Map<ID, Eval__c>();
		mapEvalValues = new Map<ID, Eval_Value__c>();
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
		List<Eval__c> listEvalItems = [
			select id,
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
		];

		// create a map by eval id
		mapEvalValues = new Map<ID, Eval_Value__c>();
		for ( Eval_Value__c ev: listEvalValues )
			mapEvalValues.put( ev.eval__c, ev);

		system.debug( 'Populated values:' + mapEvalValues );
		String newHTMLfld = '';
		String strval = '';
		for( Eval__c e : listEvalItems ){
			try {
				newHTMLfld = '';
				strval = '';

				if ( e.eval_field_type__r.name == 'Boolean' )  { // Boolean can be Checkbox, Radio, or Dropdown
					if ( e.eval_field_type__r.html_element__c == 'Check') {
						newHTMLfld = '<input id="' + e.htmlid__c + '" name="' + e.id + '" type="checkbox" value="' + 1 + '"';

						// insert value
						if ( mapEvalValues.ContainsKey( e.id ))
							if ( mapEvalValues.get(e.id).boolean__c)
								newHTMLFld += ' checked ';

						newHTMLfld += '><span class="labelCol">' + e.field_name__c + '</span>';
					} else if (e.eval_field_type__r.html_element__c == 'Dropdown') {
						// Boolean dropdown values = --None--, Yes, No
						newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><select id="' + e.htmlid__c + '" name="' + e.id + '">';
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
					} //TODO: output radio buttons for Radio type
				} else if (e.eval_field_type__r.name=='String') {
					newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><input id="' + e.htmlid__c + '"  name="' + e.id + '" type="text" ';
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
					newHTMLfld = '<label class="labelCol">' + e.field_name__c + '</label><select id="' + e.htmlid__c + '"  name="' + e.id + '">';
					newHTMLfld += '<option value="">-- None --</option>';
					for ( Eval_Drop_Down__c thisdd : dropdownopts) {
						newHTMLFld += '<option value="' + thisdd.option_value__c + '"';
						if ( strval ==  thisdd.option_value__c )
							newHTMLFld += ' selected ';

						newHTMLFld += '>' + thisdd.option_name__c + '</option>';
					}
					newHTMLfld += '</select>';
				} //TODO: Complete output for other types - currency, number, datetime

				htmlControls.Add( newHTMLfld);
			}
			catch( Exception ex)
			{
				System.Debug( ex);
			}
		}

		return htmlControls;
	}


	@RemoteAction
	public static void saveFields(ID evalId, String EvalType, String jsonForm) {

		Map<String,String> formData = (Map<String, String>) JSON.deserializeUntyped(jsonForm);
		List<Eval__c> newValues = new List<Eval__c>();

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
			}	else  {
				ev = new Eval_Value__c();
				ev.eval__c = (ID)f;
			}

			// put the value in the right place
			if ( ei.field_type__r.name == 'Boolean')
				if (ei.eval_field_type__r.html_element__c == 'Check' || ei.eval_field_type__r.html_element__c == 'Radio') {
					if ( formData.get(f) == '1')
						ev.Boolean__c = true;
					else
						ev.Boolean__c = false;
				}
				else if (ei.eval_field_type__r.html_element__c == 'Dropdown')
					ev.Text_Under_250__c = formData.get(f);
				else if (ei.field_type__r.name == 'Dropdown')
					ev.Text_Under_250__c = formData.get(f);
			//TODO: Fill in other field types with value in correct place

			//TODO: If value is blanked out, delete the eval field value item

			ev.what_id__c = evalID;
			ev.what_id_object__c = evalType;
			newValues.add(ev);
		}
		upsert newValues;
	}

}