public with sharing class FieldPrintTransform {

	public Map<String, Component.Apex.OutputPanel> ctlMap {get; set;}
	private string objectName;
	public SObject fullobj{ get; set;}
	
	public FieldPrintTransform( ApexPages.StandardController controller ) {
		
			objectName = controller.getRecord().getSObjectType().getDescribe().getName();
			
			ctlMap = CreateFieldControls( objectName, controller );
			if (ctlMap != null )
				System.Debug( ctlMap);
			
	}
	public Map<String, Component.Apex.OutputPanel> CreateFieldControls ( string classname, ApexPages.StandardController controller ) {
		System.Debug('loading map for:' + classname);
		Map<String, Component.Apex.OutputPanel> cmap = new Map<String, Component.Apex.OutputPanel>();
		
		List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects( new List<String>{classname});
		if (describelist.size() == 0){
			return null;
		}
		 
		// need to get value for all fields - they are not in scope from VF page being dynamic
		Schema.DescribeSObjectResult info = describelist[0];
		Map<string,Schema.SObjectField> fmap = info.fields.getmap();
		
		Schema.DescribeFieldResult fielddescribe;
		ID theID = controller.getID();
		String query = 'SELECT ' +  String.Join(New List<String>(fmap.keyset()), ', ') + ' FROM ' + objectName + ' Where ID = :theID';
		system.debug( query );
		fullobj  = Database.query(query);
		
		for(string fieldname:fmap.keyset()){
			Component.Apex.OutputPanel op = new Component.Apex.OutputPanel();
			
			fielddescribe = fmap.get(fieldname).getdescribe();
			
			try {
				
				Component.Apex.OutputLabel outLbl = new Component.Apex.OutputLabel( value=fielddescribe.getLabel(), styleClass='label');
				
				op.childComponents.Add( outLbl);
				
				if ( fielddescribe.getType() == Schema.DisplayType.Boolean &&  !(Boolean.valueOf(fullobj.get(fieldname))) )  {
					// only show no if false - put that back in
					Component.Apex.OutputText outTxt = new Component.Apex.OutputText( value='No', label=fielddescribe.getLabel());
					op.childComponents.Add( outTxt );
					
				} else {
					Component.Apex.OutputField outFld = new Component.Apex.OutputField();
					outFld.expressions.value = '{!' + objectName + '.' + fieldname +'}';
					op.childComponents.Add( outFld);
				}
				
				cmap.put( fieldname, op);
			} 
			catch( Exception e)
			 { System.Debug( e ); }	
			 
			  
		}
		
		return cmap;
	}
	
}