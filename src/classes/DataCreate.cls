public with sharing class DataCreate {
    private map<string, sobject> pseudonyms = new map<string, sobject>();
    private List<DelayedReference> DelayedReferences = new List<DelayedReference>();
    private integer DMLCount = 0;
    
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
        Schema.SObjectField upsertfield = null;
        for(string fieldname:fieldmap.keyset()){
            if (fmap.containsKey(fieldname)){
                PutWithCast(newobj, fmap.get(fieldname).getdescribe(),fieldmap.get(fieldname));
                if (fmap.get(fieldname).getdescribe().isIdLookup()){
                    upsertfield = fmap.get(fieldname);
                }
            }
        }
        
        UpsertObject(newobj, upsertfield, classname);
        return newobj;
    }
    
    public void UpsertObject(SObject updobj, Schema.Sobjectfield upsertfield, string classname){
        if (upsertfield != null){
            try {
                database.upsert(updobj, upsertfield);
                DmlCount++; 
                System.Debug('DML Count ' + DmlCount);
            } 
            catch (DmlException excp){
                DataCreateException newexcp = new DataCreateException('Whilst upserting '+ classname + '.' 
                	+ updobj.get(upsertfield.getdescribe().name ) + ':' + excp.GetDmlMessage(0));
                newexcp.initCause(excp);
                throw newexcp;
            }
        } else {
            try {
                insert updobj;
                DmlCount++; System.Debug('DML Count ' + DmlCount);
            } catch (System.DmlException excp){
                if (excp.getDmlType(0) == StatusCode.DUPLICATE_VALUE){
                    updobj.Id = ParseIdFromDuplicateMessage(excp.GetDmlMessage(0));
                    if (updobj.Id != null ){
	                    try {
	                        update updobj; 
	                        DmlCount++; System.Debug('DML Count ' + DmlCount);
	                        return;
	                    } catch (System.DmlException excp1) {
	                        DataCreateException newexcp = new DataCreateException('Whilst updating '+ classname + '.' 
	                        	+ updobj.Id + ':' + excp.GetDmlMessage(0));
	                        newexcp.initCause(excp);
	                        throw newexcp;
	                    }
                    }
                } 
                DataCreateException newexcp = new DataCreateException('Whilst inserting '+ classname + ':' 
                	+ excp.GetDmlMessage(0));
                newexcp.initCause(excp);
                throw newexcp;
            }
        }
    	
    }
    
    public integer FixReferences(){
        List<DelayedReference> unresolved = new List<DelayedReference>();
        List<SObject> updates = new List<Sobject>();
        
        for(DelayedReference ref: DelayedReferences){
            if (pseudonyms.containskey(ref.ReferencedPseudonym)){
                ref.Origin.put(ref.fieldName, pseudonyms.get(ref.ReferencedPseudonym).id);
                updates.Add(ref.Origin);
            } else {
                unresolved.Add(ref);
            }
        }
        update updates;
        DelayedReferences = unresolved;
        return unresolved.size();
    }
    
    public SObject PutPseudonym(string pseudonym, SObject obj){
        Pseudonyms.Put(pseudonym, obj);
        return obj;
    }
    
    public SObject PutPseudonym(string pseudonym, string classname, string whereclause){
        list<SObject> objs = database.query('select id from ' + classname + ' where ' + whereclause + ' limit 1');
        DmlCount++; System.Debug('DML Count ' + DmlCount);
        if (objs.size() > 0){
            Pseudonyms.Put(pseudonym, objs[0]);
            return objs[0];
        }
        return null;
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
    
    public integer ProcessXml(string xml){
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        integer objCount = 0;
        
        for(Dom.XmlNode objnode: doc.getRootElement().getChildElements()){
            SObject newobj;
            system.debug('Node: ' + objnode.getName() + ':' + objnode.GetAttributeValue('classname', ''));
            if (objnode.getName() == 'object'){
                map<string,Object> fieldmap = new map<string,Object>();
                for(Dom.XmlNode fieldnode: objnode.getChildElements()){
                    system.debug('Field Node: ' + fieldnode.getName() + ':' + fieldnode.getAttributeValue('name', ''));
                    fieldmap.Put(fieldnode.getAttributeValue('name', ''), fieldnode.getText());
                }
                string pseudonym = objnode.getattributeValue('pseudonym', '');
                if (pseudonym == null) {
                    newobj = CreateObject(objnode.GetAttributeValue('classname', ''), fieldmap);
                } else {
                    newobj = CreateObject(objnode.GetAttributeValue('classname', ''), fieldmap, pseudonym);
                }
                objCount++;
            } else if (objnode.getname() == 'pseudonym'){
                PutPseudonym(objnode.GetAttributeValue('name', ''), 
                    objnode.GetAttributeValue('classname', ''),
                    ReplacePseudonymIds(objnode.GetAttributeValue('where', '')));
            }
            
        }
        FixReferences();
        
        return objCount;
    }
    
    private string ReplacepseudonymIds(string whereClause){
        for(string key:GetPseudonyms()){
            whereClause = whereClause.replace(':' + key + '.Id', '\'' + GetPseudonym(key).Id + '\'');
        }
        return whereClause;
    }
    
    public integer ProcessXmlDocument(Document doc){
        return ProcessXml(doc.Body.toString());
    }
    
    @future
    public static void FutureProcessDocument(string docname){
        Document doc = [select Body from Document where developername = :docname limit 1];
        DataCreate c = new DataCreate();
        c.ProcessXml(doc.Body.toString());
        
    }
    
    private void PutWithCast(SObject newobj, Schema.DescribeFieldResult fielddescribe, object value){
        if (fielddescribe.getType() == Schema.DisplayType.Reference){
            if (pseudonyms.containskey((string)value)){
                newobj.put(fielddescribe.Name, pseudonyms.get((string)value).id);
            } else {
                DelayedReferences.Add(new DelayedReference(newobj,fielddescribe.Name, (string)value));
            }
        } else if (fielddescribe.getType() == Schema.DisplayType.Date){
            newobj.put(fielddescribe.Name, DataConvert.ToDate(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.DateTime){
            newobj.put(fielddescribe.Name, DataConvert.ToDateTime(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Time){
            newobj.put(fielddescribe.Name, DataConvert.ToTime(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Boolean){
            newobj.put(fielddescribe.Name, DataConvert.ToBoolean(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Currency){
            newobj.put(fielddescribe.Name, DataConvert.ToDecimal(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Double){
            newobj.put(fielddescribe.Name, DataConvert.ToDouble(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Integer){
            newobj.put(fielddescribe.Name, DataConvert.ToInteger(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.String){
            newobj.put(fielddescribe.Name, DataConvert.ToString(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.TextArea){
            newobj.put(fielddescribe.Name, DataConvert.ToString(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.URL){
            newobj.put(fielddescribe.Name, DataConvert.ToString(value));
        } else if (fielddescribe.getType() == Schema.DisplayType.Email){
            newobj.put(fielddescribe.Name, DataConvert.ToString(value));
        } else {
            newobj.put(fielddescribe.Name, value);
        }
    }
    
    private Id ParseIdFromDuplicateMessage(string msg){
        string match = msg.substringAfterLast('record with id: ');
        system.debug(msg + 'Match Id: ' + match);
        if (match instanceof ID){
        	return (Id)match;
        }
        return null; 
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
    
    private class DelayedPseudonym {
        public string FieldName {get;set;}
        public string Pseudonym {get;set;}
        
        public DelayedPseudonym(string fieldname, string pseudonym){
            this.FieldName = fieldname;
            this.Pseudonym = pseudonym;
        }
    }
    
}