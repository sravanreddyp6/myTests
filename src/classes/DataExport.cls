public with sharing class DataExport {
	private Map<String, Schema.SObjectType> describeMap = Schema.getGlobalDescribe();
	private list<sObject> waitingObjects;
	
	////////////////////////////////////////////////////////////
	// Top Level call to generate the xml file
	// Queries all fields for the objects
	// Uses relations to find other objects to export
	// Uses the ExportCollection to hold the objects
	// Uses a queue to do a breadth first traversal of tree but this is insufficient to get the 
	//   order right so implemented a Directed Acyclic Graph in ExportCollection.
	// objects emmitted class at a time.
	// Uses the Id itself as the pseudonym.  This makes the logic a little simpler during generate since there is no
	//   reverse lookup during the generate.
	
	public string Export(sObject obj){
		ExportCollection exports = new ExportCollection(describeMap);
		sObject fullObj;
		
		if (obj instanceof Contact){
			list<sObject> fullobjs = FullyPopulateRelated(obj, 'personcontactid', describeMap.get('Account').getDescribe());
			if (fullobjs.size() > 0){
				fullobj = fullobjs[0];
				exports.AddIsNew(fullObj);
			}
		} 
		
		Schema.DescribeSObjectResult info = exports.getDescribe(obj.getsObjectType());
		fullObj = FullyPopulate(obj, info);
		
		
		exports.AddIsNew(fullObj);
		
		waitingobjects = new list<sObject>();
		waitingobjects.Add(fullObj);
		
		while (waitingobjects.size() > 0){ 
			FollowRelations(waitingObjects.remove(0), exports);
		}
		
		string outstring = '<objects>\n';
		for(SObjectType oType: exports.getTypes()){
			for(SObject itobj: exports.getObjects(oType)){
				outstring += ExportInternal(itobj, oType, exports );
			}
		} 
		return outstring + '</objects>\n';
		
	}
	
	///////////////////////////////////////////////////
	// This used to be a recursive function but now that it uses the queue probably would be 
	// better with the iteration within the function
	
	private void FollowRelations(SObject obj, ExportCollection exports){
		Schema.DescribeSObjectResult info = exports.getDescribe(obj.getsObjectType());
		//need to find all the detail objects and persist them recursively - should bulkify this too
		for(Schema.ChildRelationship childRel: info.ChildRelationships){
			Schema.DescribeSObjectResult childinfo = exports.getDescribe(childRel.getChildSObject());
			if (childinfo.name.endsWith('__c')){
				Schema.DescribeFieldResult invField = childRel.getField().getDescribe();
// this would limit dependencies to master-detail links 
//				if (!invField.isnillable() && !invfield.isdefaultedOnCreate()){
				if (info.sObjectType != childinfo.sObjectType){
					exports.AddDependency(info.sObjectType, childinfo.sObjectType);
				}
				for(sobject child: FullyPopulateRelated(obj, childrel.getField().getdescribe().name, childinfo)){
					if (exports.AddIsNew(child)) {
						waitingobjects.add(child);
					}
				}
			}
		}
	}
	
	//////////////////////////////////////////////////
	// Object emmitter
	// largly generic but does have special handlin gfor the dedupe of Contacts.  When the a duplication is found the original 
	// record is used.  In this scenario the pseudonym is not set correctly in the Creator utility so we add a pseudonym expression
	// so theat the pseudonym value is refreshed.
	// Not sure that the logic that decides which fields to write is correct there might be more or less.  Maybe put more smarts into the
	// DataCreate utility?
	 
	public string ExportInternal(sObject fullObj, SObjectType oType, ExportCollection exports){ 
		Schema.DescribeSObjectResult info = exports.getDescribe(oType);
		string pseudonymsstring = '';
		string outstring = '   <object classname="' + info.Name + '" pseudonym="' + fullObj.Id + '" ';
		
		Map<string,Schema.SObjectField> Fmap = info.fields.getmap();
		Schema.SObjectField upsertfield = null;

		string fieldsstring = '';
		string recordtypestring = ''; 
		for(string fieldname:Fmap.keyset()){
			if (fieldname == 'recordtypeid'){
				recordtypestring = ' recordtype="' + info.getrecordtypeinfosbyid().get((id)fullObj.get(fieldname)).name + '"';
			} else {
				Schema.Describefieldresult fieldinfo = Fmap.get(fieldname).getdescribe();
				if (!fieldinfo.isnillable() 
					&& !fieldinfo.isDefaultedOnCreate() 
					&& fieldinfo.GetReferenceTo() != null 
					&& fieldinfo.getReferenceTo().size() > 0 
					&& !exports.pseudonymExists((string)fullObj.get(fieldname))){
					pseudonymsstring += '   <pseudonym name="' + fullObj.get(fieldname) + '" ' 
						+ 'classname="' + fieldinfo.GetReferenceTo()[0].getDescribe().Name + '" ' 
						+ 'where="Id =\'' + fullObj.get(fieldname) + '\'"/>\n';
					exports.AddPseudonym((string)fullObj.get(fieldname));
				}
				if ((fieldinfo.isupdateable() || fieldinfo.iscreateable() ) && 
					(//fullObj.get(fieldname) != null ||
					 fullObj.get(fieldname) != fieldinfo.DefaultValue)){
					fieldsstring += '      <field name="' + fieldname + '">' +	DataConvert.toString(fullObj.get(fieldname)) + '</field>\n';
				}
			}
		}
		outstring += recordtypestring + '>\n';
		outstring += fieldsstring;
		outstring += '   </object>\n';
		// We dedupe Contacts so make sure the psuedonym is correct for Contacts
		if (info.Name == 'Contact'){
			outstring += '   <pseudonym name="' + fullObj.Id + '" classname="Contact" where="Id=:' + fullObj.Id + '.Id"/>\n';
		}
		exports.AddPseudonym(fullObj.Id);
		return pseudonymsstring + outstring;
	}

// A snippet to printout some of the Describe object
//{
//	Schema.DescribeSObjectResult desc1 = new Authorization_ServiceCode_JO__c().getsobjecttype().getdescribe();
//    system.debug(desc1.name);
// 		Map<string,Schema.SObjectField> Fmap = desc1.fields.getmap();
//		for(string fieldname:Fmap.keyset()){
//			Schema.Describefieldresult fieldinfo = Fmap.get(fieldname).getdescribe();
//			system.debug('Field:' + fieldname + 'isUpdateable:' + fieldinfo.isupdateable() + ' Createable:' + fieldinfo.iscreateable());
//		}
//}
	
	private sObject FullyPopulate(sObject obj, Schema.DescribeSObjectResult describe){
		String query = 'SELECT ';
		Id objId = obj.Id;

		Map<string,Schema.SObjectField> Fmap = describe.fields.getmap();
        query += String.Join(new list<string>(fmap.keyset()), ', ') + ' FROM ' + describe.name + ' Where ID =:objID';  
        System.debug(obj.Id + ':' + query);  
        return Database.query(query);		
	}
	
	private list<sObject> FullyPopulate(list<sObject> objs, Schema.DescribeSObjectResult describe){
		list<id> objIds = new list<id>();
		for(sObject obj: objs){
			objids.add(obj.Id);
		}
		String query = 'SELECT ';

		Map<string,Schema.SObjectField> Fmap = describe.fields.getmap();
        query += String.Join(new list<string>(fmap.keyset()), ', ') + ' FROM ' + describe.name + ' Where ID in :objIds';    
        return Database.query(query);		
	}
	
	private list<sObject> FullyPopulateRelated(sObject obj,string invRelName,  Schema.DescribeSObjectResult describe){
		String query = 'SELECT ';
		Id objId = obj.Id;

		Map<string,Schema.SObjectField> Fmap = describe.fields.getmap();
        query += String.Join(new list<string>(fmap.keyset()), ', ') + ' FROM ' + describe.name + ' Where ' + invRelName + ' = :objId';    
        return Database.query(query);		
	}
	
    // Collection of objects with associated describe info ready for export
    private class ExportCollection {
    	private Map<string, SObjectType> gd;
    	private map<SObjectType, ExportClassCollection> innerData = new map <SObjectType, ExportClassCollection>();
    	// typeOrder no longer used, the DAG topo order is used instead.
    	// if the Dependencies are reduced to master-detail then this might be a good way to give the DAG order a more intuitive
    	// ordering.  
    	private list<SObjectType> typeOrder = new list<SObjectType>();
    	private map<string, string> pseudonyms = new map<string, string>();
    	private list<Dependency> deps = new list<Dependency>();
    	
    	public ExportCollection(Map<string, SObjectType> mapdescribe){
    		gd = mapdescribe;
    	}
    	
    	// The IsNew part prevents objects being expanded multiple times 
    	public boolean AddIsNew(SObject newobj){
    		SObjectType oType = newobj.getSObjectType();
    		return CollectionForType(oType).AddIsNew(newobj);
    	} 
    	
    	public Schema.DescribeSObjectResult getDescribe(SObjectType oType){
    		return CollectionForType(oType).getDescribe();
    	}
    	
    	// Do a Topological sort on the dependency tree
    	// algorithm from Wikipedia :-)
    	public list<SObjectType> getTypes() {
    		list<SObjectType> torder = new list<SObjectType>();
    		set<DAGnode> nodependencies = new set<DAGnode>();

    		map<sObjectType, DagNode> dag = BuildDag();
    		for(sObjectType oType: dag.keyset()){
    			DAGNode node = dag.get(oType);
    			if (node.Parents.size() == 0){
    				nodependencies.add(node);
    			}
    		}
    		while (nodependencies.size()>0){
    			DAGNode node = new list<DAGNode>(nodependencies)[0];
    			nodependencies.remove(node);
    			torder.Add(node.oType);
	    		for(Dependency dep: new list<Dependency>(node.children)){
	    			DAGNode m = dep.child;
	    			m.Parents.remove(dep);
	    			if (m.Parents.size() == 0){
	    				nodependencies.add(m);
	    			}
	    			dep.child = null;
	    			dep.parent = null;
	    		}
	    		node.children = new set<Dependency>();
    		}
    		return torder;
    	}
    	
    	public list<SObject> getObjects(SObjectType oType){
    		return CollectionForType(oType).getObjects();
    	}
    	
    	public boolean pseudonymExists(string name){
    		return pseudonyms.ContainsKey(name);
    	}
    	
    	public void AddPseudonym(string name){
    		pseudonyms.Put(name, name);
    	}
    	
    	public void AddDependency(SObjectType master, SObjectType detail)
    	{
    		deps.add(new Dependency(master, detail));
    	}
    	
    	private ExportClassCollection CollectionForType(SObjectType oType){
    		if (innerData.ContainsKey(oType)){
    			return innerData.get(oType);
    		}
    		ExportClassCollection coll = new ExportClassCollection(oType);
    		innerData.Put(oType, coll);
    		typeOrder.Add(oType);
    		return coll;
    	}
    	
    	// DAG is done at the class level not the object level.  One case where this is an issue is with class references to
    	// itself.  These are not added to the DAG to prevent the cycle.  The down side is that the objects within a class are 
    	// not ordered based on links between then.  The Fixup references functionality is required to fix up this scenario.
    	private map<sObjectType,DAGNode> BuildDAG() {
    		map<sObjectType,DAGNode> dag = new map<sObjectType,DAGNode>();
    		for(sObjectType nodedata: innerdata.keyset()){
    			DAGNode node = new DAGNode();
    			node.oType = nodedata;
    			dag.Put(nodedata, node);
    		}
    		for(Dependency dep: deps){
    			system.debug('Dependency:' + dep.Master.getDescribe().Name + '->' + dep.detail.getDescribe().Name);
    			dep.child = dag.get(dep.Detail);
    			dep.parent = dag.get(dep.Master);
   				if (dep.child != null && dep.Parent != null){
	    			dep.Child.parents.Add(dep);
	     			dep.Parent.children.Add(dep);
   				}
    		}
    		
    		return dag;
    	}
    	
    }
    
    ///////////////////////////////////////////////////////////////////
    // Collection of objects of single class with associated describe info ready for export
    private class ExportClassCollection {
    	private list<sObject> objects = new list<sObject>();
    	private Schema.DescribeSObjectResult metadata;
    	public SObjectType oType;
    	
    	public ExportClassCollection(SObjectType objType){
    		oType = objType;
    		metadata = objType.getDescribe();
    	}
    	
    	public boolean AddIsNew(SObject newobj){
    		if (!(newobj.getSObjectType() == oType)){
    			throw new DataExportException('object of wrong type');
    		}
    		if (Contains(newobj)){
    			return false;
    		} else {
    			objects.Add(newobj);
    		}
    		return true;
    	}
    	
    	public boolean Contains(SObject obj){
    		for(SObject itObject: objects){
    			if (itObject.Id == obj.Id){
    				return true;
    			}
    		}
    		return false;
    	}
    	
    	public Schema.DescribeSObjectResult getDescribe(){
    		return metadata;
    	}
    	
    	public list<SObject> getObjects(){
    		return new list<SObject>(objects);
    	}
    }
    
    ///////////////////////////////////////////////
    public class DataExportException extends Exception{
    }
    
    // Used by the top-level export class and by the DAG functionality - maybe not very 'single-responsiblity'?
	private class Dependency{
		public SObjectType Master {get;set;}
		public SObjectType Detail {get;set;}
		public DAGNode parent {get;set;}
		public DAGNode child {get;set;}
		
		public Dependency(SObjectType mType, sObjectType dType){
			Master = mType;
			Detail = dType;
		}
	}
	
	private class DAGNode {
		public set<Dependency> parents = new set<Dependency>();
		public set<Dependency> children = new set<Dependency>();
		public SObjectType oType;
	}
}