public with sharing class DataCreate {
	private map<string, sobject> pseudonyms = new map<string, sobject>();
	
	public SObject CreateObject(string classname, map<string, object> fieldmap, string pseudonym){
		SObject sobj = CreateObject(classname, fieldmap);
		pseudonyms.Put(pseudonym, sobj);
		return sobj;	
	}

	public SObject CreateObject(string classname, map<string, object> fieldmap){
		List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects(new List<string>{classname});
		
		if (describelist.size() == 0){
			throw new DataCreateException('Unknown class');
		}
		
		Schema.DescribeSObjectResult info = describelist[0];
		if (!info.isCreateable()){
			throw new DataCreateException('class not createable');
		}
		
		SObject newobj = info.getSobjectType().newSObject();
		
		Map<string,Schema.SObjectField> Fmap = info.fields.getmap();
		for(string fieldname:fieldmap.keyset()){
			if (fmap.containsKey(fieldname)){
				Schema.SObjectField F = fmap.get(fieldname);
				if (f.getdescribe().getType() != Schema.DisplayType.Reference){
					newobj.put(fieldname, fieldmap.get(fieldname));
				} else {
					if (pseudonyms.containskey((string)fieldmap.get(fieldname))){
						newobj.put(fieldname, pseudonyms.get((string)fieldmap.get(fieldname)).id);
					}
				}
			}
		}
		insert newobj;
		return newobj;
	}
	
	public class DataCreateException extends Exception{
	}
}