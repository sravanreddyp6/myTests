public class CNANoteInput implements AnotoFormHandler{
	
	private ID evaluationID; 
	private List<Boolean> processedDT;
	private List<Boolean> processedBP;
	private List<Boolean> processedTemp;
	
    public string handle(Id recordId, String fileType, Blob fileContent, RestRequest req, RestResponse response){
    	
    	evaluationID = recordId;
    	
        try {
            if (filetype == 'xml') {
                process(fileContent.toString());
                response.statusCode = 200;
                return 'Successful';
            }
            response.statusCode = 501;
            return 'Not Supported';
        }
        catch (Exception excp){
            response.statusCode = 500;
            return 'FAILED';
        }
        
        
    }

    public boolean process(string xml){
        Dom.Document reader = new Dom.Document();
        reader.load(xml);
        system.debug('inside process');
        processedDT = new List<Boolean>{ false, false, false};
        processedBP = new List<Boolean>{ false, false, false};
        processedTemp = new List<Boolean>{ false, false, false};
        
        Dom.XmlNode[] children = reader.getRootElement().getChildElements();
        system.debug( children.size());
        
        EvalValueManager manager = new EvalValueManager();
        manager.LoadEvalItems();
        
        
        for(Dom.XmlNode child: children ){
            if (child.getName() != 'field') {
                continue;
            }
            
            EvalValueNodeName nodename = new EvalValueNodeName (child.getAttributeValue('name', null), child.getText());
            if ( nodename.IsValid ) {
            	
	            Map<String, String> evmap = manager.mapNodes.get( nodename.repeatNum);
	            if ( evmap == null )
	            	evmap = new Map<String, String>();
	            evmap.put( nodename.htmlID, nodename.nodevalue );	
	            manager.mapNodes.put( nodename.repeatNum, evmap);
            
            system.debug('putting ' + nodename.htmlID + ' in #' + nodename.repeatNum + ' with value ' + nodename.nodevalue);
            }
        }
        
        system.debug( manager.mapnodes);
        
        
        
        // now iterate through the nodes - should be list of 3 repeaters
        for ( integer i : manager.mapNodes.keyset() ) {
		 	// generate the unique id for the evaluation response
        	string evalSectionId =  Userinfo.getUserId()+'-'+DateTime.now().getTime();
		 	
		 	Map<string, string> evList = manager.mapnodes.get(i);
		 	system.debug('list of items for round ' + i + ': ' + evList);
        	for ( string htmlID : evList.keyset()) {

                system.debug('Node:' + htmlID );
                string value = evList.get(htmlID);
                
				if ( !String.IsEmpty( value) ) {                  
                Eval_Value__c ev = new Eval_Value__c();
                try {
                	
                	Eval__c ei = new Eval__c();
                	
					ev.eval_Section_Id__c = evalSectionId;
					ev.Eval_Section_Type__c = 'CNA Workbook';
					ev.what_id__c = evaluationID;
					ev.what_id_object__c = 'Evaluation__c';
					
					// some fields are handled specially as parts of a single db field.  ignore the parts and allow the special handling to occur
					if ( htmlID == 'signsBP2' || htmlID == 'signsTime' || htmlID == 'signsTempPoints') 
						continue;
					              
	                if ( htmlID == 'signsBP1') {
	                	
	                	system.debug('handling BP');
	                	
	                	//special handling for BP - need to create xxx/xxx string
	                	if (! processedBP[i]) {
	                	
							try {	                
			                	string topBP= value;
				                string bottomBP = evlist.get('signsBP2');
			                	system.debug( 'BP:' + topBP + '/' + bottomBP);
			                	ei = manager.mapFieldsByName.get('signsBP');
								if ( ei != null ) {
										ev.eval__c = ei.Id;
								}
								
								// construct a string value from the top string and bottom string
								system.debug( 'BP TOP AND BOTTOM: ' + topBP + ' ' + bottomBP);
								ev.text_under_250__c = topBP + '/' + bottomBP;
								system.debug('BP eval value is:' + ev);
								manager.UpdateObject(ev);
							
								processedBP(i, true);
							} catch (Exception ex) {
								system.debug(ex);
								
							}   
		                }
		                continue;
	                }
	                
	                
	                if ( htmlID == 'signsDate') {
	
	                	if (! processedDT[i]) {
		                 	string signsdt = value;
		                 	
		                 	string signstm = evList.get('signsTime');
		                 	
		                	if ( signsdt.length() < 8 || signstm.length() < 4 )
		                		continue;

							// convert time to 12 hour
							integer hr = Integer.valueOf( signstm.substring( 0, 2));
							string ampm = 'am';
							if ( hr > 12 ) {
								hr = hr - 12;
								ampm = 'pm';
							}
								
							ei = manager.mapFieldsByName.get('signsDateTime');
							if ( ei != null ) {
								ev.eval__c = ei.Id;
							}
							
							// construct a datetime value from the date string and time string
							system.debug( 'DATE AND TIME ARE: ' + signsdt + ' ' + signstm);
							datetime dtSigns = DateTime.parse( signsdt.substring(0, 2) + '/' + signsdt.substring(2, 4) + '/' + signsdt.substring(4) + ' ' + hr + ':' + signstm.substring(2, 4) + ' ' + ampm); 
							ev.date_time__c = dtSigns;
							manager.UpdateObject(ev);
							system.debug('date time  eval value is:' + ev);
							processedDateTime(i, true);   
	                	}
	                	continue; 
	                }

					if ( htmlID == 'signsTemp') {
	
	                	if (! processedtemp[i]) {
		                 	string signstmp = value;
		                 	
		                 	string signspt = evList.get('signstempPoints');
		                 	system.debug( 'POINT VALUE IS: ' + signspt );
		                 	try { 
		                 		integer j = integer.valueOf( signspt );
		                 	}
		                 	catch( exception e) {
		                 		signspt = '0'; 
		                 	}
		                 	
							ei = manager.mapFieldsByName.get('signsTemp');
							if ( ei != null ) {
								ev.eval__c = ei.Id;
							}
						
							// construct a string value from the top string and bottom string
							system.debug( 'TEMP IS: ' + signstmp + '.' + signspt);
							ev.text_under_250__c = signstmp + '.' + signspt;
							system.debug('Temperature eval value is:' + ev);
							manager.UpdateObject(ev);
							processedtemp(i, true);   
	                	}
	                	continue; 
	                }
                	ei = manager.mapFieldsByName.get(htmlid);	// get the field 
               		ev.eval__c = ei.Id;
	                
	                // otherwise process field as-is 
	                // figure out what field the value should be placed in based on the type
					if ( ei.Field_Type__c == 'Boolean'){
						if (ei.Field_Sub_Type__c == 'Checkbox' || ei.Field_Sub_Type__c == 'Radio') {
							ev.Boolean__c = ( value == '1');
						}
						else if (ei.Field_Sub_Type__c == 'Dropdown')
							ev.Text_Under_250__c = value;
					}
					else if (ei.Field_Type__c == 'Int'){
						ev.Number_No_Decimal__c = Integer.valueOf(value);
					}
					else if (ei.Field_Type__c == 'Date'){
						ev.Date_Time__c = Datetime.newInstance(Date.parse(value), Time.newInstance(0,0,0,0));
					}
					else if (ei.Field_Type__c == 'Datetime' ){
	                    ev.Date_Time__c = Datetime.parse(value);
	                }
					else if (ei.Field_Type__c == 'String' || ei.Field_Type__c == 'ID' || 
							 ei.Field_Type__c == 'Multiselect' || ei.Field_Type__c == 'Dropdown' || ei.Field_Type__c == 'Double' || 
							 ei.Field_Type__c == 'Currency'){
						if ( ei.length__c > 250 )
							ev.Text_Over_250__c = value;
						else
							ev.Text_Under_250__c = value;
					}
					else if (ei.Field_Type__c == 'Hidden'){
	                    if (ei.Field_Sub_Type__c == 'Boolean') {
	                        ev.Boolean__c = Boolean.valueOf(value);
	                    }
	                    else if (ei.Field_Sub_Type__c == 'String') {
	                    	ev.Text_Over_250__c = value;
	                    }
	                }
		                
	                manager.UpdateObject(ev);
                } catch( exception e) {
                	system.debug(e);
                }
                
            }	// valid nodename
        } // for node
        }
        manager.Finish();
        return true;
    }

	private void processedDateTime( integer index, boolean done) {
		processedDT[index] = done;
	}
	private void processedBP( integer index, boolean done) {
		processedBP[index] = done;
	}
	private void processedTemp( integer index, boolean done) {
		processedTemp[index] = done;
	}
	
	
    public class EvalValueManager {
    
        public Map<integer, Map<string, string>> mapNodes { get ; set ;}
        public Map<String, Eval__c> mapFieldsByName { get; private set;}
        public List<Eval_Value__c> listtoInsert { get; private set; }

		public void LoadEvalItems() {
			system.debug('inside evalvaluemanager load items');
			
			// need to get the list of possible fields for this evaluation type
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
				 where eval_type__r.name = 'CNA Workbook'
				   and visible__c = true
				order by category_sequence__c, sub_category_sequence__c, field_sequence__c
			];
			
			system.debug( 'NUMBER OF FIELDS FOR THIS EVAL: ' + listEvalItems.size());
			// create a map by ID
			Map<ID, Eval__c> mapEvalItems = new Map<ID, Eval__c>(listEvalItems);
			
			// create a map by fieldname
			mapFieldsByName = new Map<String, Eval__c>();
			for ( Eval__c e : listEvalItems ) {
				mapFieldsByName.put( e.htmlid__c, e );
			}
			
			mapnodes = new Map<integer, map<string, string>>();
			listtoInsert = new List<Eval_Value__c>();
			
	    }
		
		public void UpdateObject( Eval_value__c ev ) {
			listtoInsert.Add(ev);
		}
			
	    public void Finish(){
	        Database.SaveResult[] results = Database.insert(listtoInsert, false);
	        for (Database.SaveResult sr : results) {
	            if (sr.isSuccess()) {
	                // Operation was successful, so get the ID of the record that was processed
	                // System.debug('Successfully inserted account. Result ID: ' + sr.getId());
	            }
	            else {
	                // Operation failed, so get all errors
	                for(Database.Error err : sr.getErrors()) {
	                    System.debug('The following error has occurred for result record: ' + sr.getId());
	                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                    System.debug('Result fields that affected this error: ' + err.getFields());
	                }
	            }
	        }
	    }
    }

    public class EvalValueNodeName {
        public boolean isValid {get; private set;}
        public string htmlId {get; private set;}
        public string NodeName {get; private set;}
        public integer repeatNum { get; private set;}
		public string nodeValue { get; private set;}
        public EvalValueNodeName (string nodeName, string value){
        	
            if (!nodeName.startsWith('eval')){
                isValid = false; 
                return;
            }

			this.nodeValue = value;
			
            // consider putting in cat~subcat to get to unique field
            this.nodename = nodename;
            string[] parts = nodeName.split('-');
            
            this.htmlID= parts[1];	// htmlid of the field plus repeater # (drop off the "eval" prefix)
             
            string[] repeat  = this.htmlID.split('_');
            if (repeat.size() > 1)
            	this.repeatNum = Integer.valueOf(repeat[1]);
            else	
            	this.repeatNum = 0;
            
            // node name should now map to htmlid on the field name map
            isValid = true;
            this.htmlID = repeat[0];
        }

    }
}