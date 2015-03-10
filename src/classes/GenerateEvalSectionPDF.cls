public with sharing class GenerateEvalSectionPDF {

	public List<string> ctlList {get { return CreateFieldControls();} private set;}
	public string cat {get; set;}
	public string subcat{get; set;}
	public string subsubcat{get; set;}
	public string evalname{get; set;}
	public ID evaluationID { get; set;}
	public ID pbsID { get; set;}
    public string evalSectionId { get; set;}
    public string evalSecType { get; set;}
    public string uniqueID{ get; set; }

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

	public GenerateEvalSectionPDF( ) {
		mapEvalItems = new Map<ID, Eval__c>();
		mapEvalValues = new Map<ID, Eval_Value__c>();
	}

	public List<string> CreateFieldControls () {

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
			       length__c
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
		for( Eval__c e : listEvalItems ){
			try {
				newHTMLfld = '';
				strval = '';
				
                if ( e.Field_Type__c == 'Boolean' )  { // Boolean can be Checkbox, Radio, or Dropdown
                    if ( e.Field_Sub_Type__c == 'Checkbox') {
                        newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '" class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                        // insert value
                        if ( mapEvalValues.ContainsKey( e.id ))
                            if ( mapEvalValues.get(e.id).boolean__c)
                                newHTMLFld += 'Yes';
                            else
                            	newHTMLFld += 'No';
                        newHTMLfld += '</div>';
                    } else if (e.Field_Sub_Type__c == 'Dropdown') {
                        // Boolean dropdown values = --None--, Yes, No
                        newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
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
                    newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    if (mapEvalValues.ContainsKey( e.id )) {
                        if ( e.length__c > 250 )
                            strVal = mapEvalValues.get(e.id).text_over_250__c;
                        else
                            strVal = mapEvalValues.get(e.id).text_under_250__c;

                        if (strVal != null && strVal != '')
                            newHTMLfld += strVal;
                    }
                    newHTMLfld +=  '</div>';
                } else if (e.Field_Type__c == 'DropDown') {
                    // get the value
                    if ( mapEvalValues.ContainsKey( e.id ))
                        strVal = mapEvalValues.get(e.id).text_under_250__c;
                    newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
					newHTMLfld += strVal;
					newHTMLfld += '</div>';
                }  else if (e.Field_Type__c == 'Date') {
					newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
					if (mapEvalValues.ContainsKey( e.id )) 
                        newHTMLfld += mapEvalValues.get(e.id).date_time__c; // output date format 
                    newHTMLfld +=  '</div>';
				} else if (e.Field_Type__c == 'Datetime') {
                    newHTMLfld = '<div style="display: table-row;"><label for="' + e.htmlid__c + '"  class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
                    if (mapEvalValues.ContainsKey( e.id )) 
                        newHTMLfld += mapEvalValues.get(e.id).date_time__c; // output date format
                    newHTMLfld +=  '</div>';
                } else if (e.Field_Type__c == 'Multiselect') {
                	
                    if ( mapEvalValues.ContainsKey( e.id )){
	                	if ( e.length__c > 250 )
	                       strVal = mapEvalValues.get(e.id).Text_Over_250__c;
	                    else
	                       strval = mapEvalValues.get(e.id).Text_Under_250__c;
                    }
                    //system.debug( e.id + ' - multiselect -' + selectedVals);
                	newHTMLfld = '<div style="display: table-row;"><label class="labelCol" style="display: table-cell;">' + e.field_name__c + '</label>';
	                newHTMLfld += strval;
                    newHTMLfld +=  '</div>';
                } else if (e.field_type__c == 'BodyMap') {
       				newHTMLfld = '<div style="position: relative; float: left; margin-left: 80px; margin-bottom: 10px;">';
                	newHTMLfld += '<img width="318" height="298" style="float: left; border: 3px solid #ECECEC;" src="' +  GetResourceURL('WholeBodyNoGrid') + '?' + uniqueID +'" id="bodyMap' + uniqueID + '" />';
                	newHTMLfld += '</div>';
                    newHTMLfld += '<div style="margin-left: 420px; height: 298px; overflow: auto;">';
                    newHTMLfld += '<table id="annotations' + + uniqueID + '">';
                    newHTMLfld += '<tbody></tbody></table></div>';
                }
                
				htmlControls.Add( newHTMLfld);
			}
			catch( Exception ex)
			{
				System.Debug( ex);
			}
		}
		system.debug('HTML IS:' + htmlControls);
		return htmlControls;
	}
	
	public class FormKeyVal{
		public Id name;
		public String value; 
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