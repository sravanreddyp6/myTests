public with sharing class DataCreate {
	private map<string, sobject> pseudonyms = new map<string, sobject>();
	private List<DelayedReference> DelayedReferences = new List<DelayedReference>();
	
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
	
	public integer FixReferences(){
		List<DelayedReference> unresolved = new List<DelayedReference>();
		
		for(DelayedReference ref: DelayedReferences){
			if (pseudonyms.containskey(ref.ReferencedPseudonym)){
				ref.Origin.put(ref.fieldName, pseudonyms.get(ref.ReferencedPseudonym));
			} else {
				unresolved.Add(ref);
			}
		}
		DelayedReferences = unresolved;
		return unresolved.size();
	}
	
	public SObject PutPseudonym(string pseudonym, SObject obj){
		Pseudonyms.Put(pseudonym, obj);
		return obj;
	}
	
	public SObject GetPseudonym(string pseudonym){
		return Pseudonyms.containskey(pseudonym) ? pseudonyms.get(pseudonym) : null;
	}
	
	public Set<string> GetPseudonyms() {
		return Pseudonyms.keyset();
	}
	
	public static map<string, list<string>> Requirements(string classname){
		List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects(new List<string>{classname});
		
		if (describelist.size() == 0){
			throw new DataCreateException('Unknown class');
		}
		
		Schema.DescribeSObjectResult info = describelist[0];
		map<string, list<string>> mapresult = new map<string, list<string>>();
		
		BuildRequirements(info, mapresult);
		return mapresult;			
	}
	
	private static void BuildRequirements(Schema.DescribeSObjectResult info, map<string, list<string>> mapresult){
		Map<string,Schema.SObjectField> Fmap = info.fields.getmap();
		list<string> requiredFields = new list<string>();
		mapresult.Put(info.Name, requiredFields);
		
		for(string fieldname: Fmap.keyset()){
			Schema.DescribeFieldResult fieldinfo = fmap.get(fieldname).getdescribe();
			if (!fieldinfo.isNillable() && !fieldinfo.isDefaultedOnCreate()){
				requiredFields.Add(fieldinfo.Name);
				List<Schema.sObjectType> parents = fieldinfo.getReferenceTo();
				for(Schema.sObjectType parent:parents){
					if (!mapresult.containskey(parent.getdescribe().Name)){
						BuildRequirements(parent.getdescribe(), mapresult);
					}
				}
			}
		}		
	}
	
	public class DataCreateException extends Exception{
	}
	
	private class DelayedReference {
		public SObject Origin {get;set;}
		public string FieldName {get;set;}
		public string ReferencedPseudonym {get;set;}
		
		public DelayedReference(Sobject origin, string fieldname, string pseudonym){
			this.origin = origin;
			this.FieldName = fieldname;
			this.ReferencedPseudonym = pseudonym;
		}
	}
}