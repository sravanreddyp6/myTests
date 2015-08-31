public with sharing class TurnsChartController {
	
private ID evalID;
public ID getEvalID() {
	return this.evalID;
}
public void setEvalID(ID value) { 
	this.evalID = value; 
	getTurnsData(value); 
}

public transient List<string> turnsChartkeys { get; set; }
public transient Set<String> turnsInnerKeys { get; set; }
public Map< string, Map<string, List<turnsPanel>>> turnsChart { get; private set;} 
public void TurnsChartController() {

}


public class evalPanel {

	public datetime starttime { get; set;} 
	public datetime endtime { get; set; }
	public string splints { get; set;}
	public string prosthetics { get; set; }
	public string orthotics { get; set; }
	public string elastic { get; set; }
	public string position { get; set; }
	public string restraints { get; set; }
	public string lastmodifiedby { get; set; }
	public datetime lastmodifieddate { get; set; }
	
	public Set<String> spanHours { get; private set;}
	
	public evalPanel() {
		spanHours = new Set<string>();
	}


	public void getTimeSpan() {
		if ( starttime == null || endtime == null)
			return;
			
		// for each hour between start and end time, calculate the span
		// the hour method converts to user's timezone
		Integer StartHour = starttime.hour(); 
		Integer EndHour = ( endtime.minute() == 0) ? endtime.hour() : endtime.hour() + 1;

		DateTime shStart = DateTime.newInstance( starttime.date(), Time.newInstance( StartHour, 0, 0, 0 ));
		DateTime shEnd = DateTime.newInstance( endtime.date(),  Time.newInstance( EndHour, 0, 0, 0 ));

		// map of values for each hour in the panel
		for ( datetime h = shStart; h <= shEnd; h = h.addHours(1) ) {
			spanHours.add( h.format('MM/dd HH:00'));		
			}
		
	}	
}

public class turnsPanel {
	public integer starthour { get; set; }
	public integer endhour { get; set; }
	public string turnVal { get; set; }
	public string lastmodby { get;  set; }
	public datetime lastmod { get; set; }
	public turnsPanel () {
		starthour = -1;
		endhour = -1;
	}
}


private void getTurnsData( ID evalId ) { 

// only want to map data from full panels
List<AggregateResult> fullSections = [select eval_section_id__c
										from eval_value__c
										where what_id_object__c = 'Evaluation__c'
										and what_id__c = :evalID
										and eval__r.category__c = 'Turns'
										and eval__r.field_name__c = 'IsValid'
										and boolean__c = true
										group by eval_section_id__c];


	
// a map of complete sections, keyed by section id
Map<String, evalPanel> complete = new Map<String, evalPanel>();
for ( AggregateResult av : fullSections ) {
	complete.put( (string)av.get('eval_section_id__c'), new evalPanel());
}

// get the recorded data for the full panels
List<Eval_value__c> turnsData = [select id, eval_section_id__c, eval__r.field_name__c, text_under_250__c, text_over_250__c, date_time__c, lastmodifiedby.name, lastmodifieddate 
									from eval_value__c
									where what_id_object__c = 'Evaluation__c'
									and what_id__c = :evalID
									and eval__r.category__c = 'Turns'
									and eval__r.field_name__c != 'IsValid'
									and eval_section_id__c in :complete.keyset()
									order by eval_section_id__c, eval__r.field_sequence__c];

// format the rows into a panel format and add to the correct section by section id
for (Eval_value__c turn : turnsData ) {
	evalPanel tmp = complete.get(turn.eval_section_id__c);
	string fieldname = turn.eval__r.field_name__c.toLowerCase();
		
	if ( fieldname == 'start date/time')
		tmp.starttime = turn.date_time__c;
	else if ( fieldname == 'end date/time')
		tmp.endtime = turn.date_time__c;
	else if ( fieldname == 'splints') 
		tmp.splints = turn.text_under_250__c;
	else if ( fieldname == 'prosthetics')
		tmp.prosthetics = turn.text_under_250__c;
	else if ( fieldname == 'orthotics')
		tmp.orthotics = turn.text_under_250__c;
	else if ( fieldname == 'elastic hose')
		tmp.elastic = turn.text_under_250__c;
	else if ( fieldname == 'positioning')
		tmp.position = turn.text_under_250__c;
	else if ( fieldname == 'restraints')
		tmp.restraints = turn.text_under_250__c;
	
	if ( tmp.lastmodifiedby == null ) {
		tmp.lastmodifiedby = turn.lastmodifiedby.name;
		tmp.lastmodifieddate = turn.lastmodifieddate;	
	}
	
	tmp.getTimeSpan();
	
	complete.put(turn.eval_section_id__c, tmp );
	
}


// make an array for shift hours - one entry per hour per field
turnsChart =  new Map<string, Map<string, List<turnsPanel>>>();

// get start and end time of shift
Evaluation__c shift = [ select id, shift_start_time__c, shift_end_time__c from evaluation__c where id = :evalID LIMIT 1];
// the hour method converts to user's timezone
Integer shiftStartHour = shift.shift_start_time__c.hour(); 
Integer shiftEndHour = ( shift.shift_end_time__c.minute() == 0) ? shift.shift_end_time__c.hour() : shift.shift_end_time__c.hour() + 1;

DateTime shStart = DateTime.newInstance( shift.shift_start_time__c.date(), Time.newInstance( shiftStartHour, 0, 0, 0 ));
DateTime shEnd = DateTime.newInstance( shift.shift_end_time__c.date(),  Time.newInstance( shiftEndHour, 0, 0, 0 ));
system.debug( 'Start:' + shStart + ', End: ' + shEnd);

// map of values for each hour in the shift.  these are the rows in the chart whose columns are shift hours
for ( datetime h = shStart; h <= shEnd; h = h.addHours(1) ) {

Map<string, List<turnsPanel>> vals = new Map<string, List<turnsPanel>>();
	vals.put('Splints', new List<turnsPanel>());
	vals.put('Prosthetics', new List<turnsPanel>());
	vals.put('Orthotics', new List<turnsPanel>());
	vals.put('Elastic Hose', new List<turnsPanel>());
	vals.put('Positioning', new List<turnsPanel>());
	vals.put('Restraints', new List<turnsPanel>());
	
	turnsChart.put( h.format('MM/dd HH:00'), vals);
}

// now iterate through entries and place them in the correct cell in the chart that is turns type by shift hour
for ( string ck : complete.keyset()) {

	evalPanel p = complete.get( ck );

	Map<string, List<turnsPanel>> turnep = null;
	
	for ( string j  : turnsChart.keyset() ) {

		if ( p.spanHours.contains(j)) {	 
		if ( turnsChart.get(j) != null ) {

			 turnep = turnsChart.get(j);
			 
			 for ( String sec : turnep.keyset() ) {
			 	turnsPanel newturn = new turnsPanel();
				newturn.lastmodby = p.lastmodifiedby;
				newturn.lastmod = p.lastmodifieddate;
			 	if ( sec == 'Splints')
			 		newturn.turnval = p.splints;
			 	else if ( sec == 'Prosthetics')
			 		newturn.turnval = p.prosthetics;
			 	else if ( sec == 'Orthotics')
			 		newturn.turnval = p.orthotics;
			 	else if ( sec == 'Elastic Hose')
			 		newturn.turnval = p.elastic;
			 	else if ( sec == 'Positioning')
			 		newturn.turnval = p.position;
			 	else if ( sec == 'Restraints')
			 		newturn.turnval = p.restraints;
				
				// add this new panel to the list of panels for this turn type
				List<turnsPanel> tp = turnep.get(sec);
				
				tp.add(newturn);
				turnep.put(sec, tp);
			 
			 }
		}
		}
	
	}

}
turnsChartKeys = new List<string>();
turnsChartKeys.Addall( turnsChart.keyset());
turnsChartKeys.Sort();

turnsInnerKeys = turnsChart.get(turnsChartKeys[0]).keyset();

//system.debug( turnsChart );

}
	
	

}