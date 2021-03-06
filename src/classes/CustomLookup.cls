public class CustomLookup {

    Map<String, Schema.SObjectType> gd;
    
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AssignedTo Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public String SearchFields{
        get;
        set{
            if(value!= null && value != ''){
                SearchFields = value.ToLowerCase();
            }
        }
    }
    public String returnFields{
        get;
        set{
            if(value != null && value != ''){
                returnFields = value.ToLowerCase();
            }
        }
    }
    public String objectType{
        get;
        set{
            system.assertNotEquals(gd.get(value),Null);
            objectType = value;
        }
    }
    
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Other Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public FieldWrapper nameField{
        get{
            if(nameField == null){
                nameField= new FieldWrapper();
                Schema.DescribeFieldResult describe = gd.get(objectType).getDescribe().fields.getMap().get('name').getDescribe();
                nameField.name = describe.Name;
                nameField.label = describe.Label;
                nameField.fieldType = describe.getType().name();
            }
            return nameField;
        }
        set;
    }
    public List<FieldWrapper> fields {
        set;
        get{
            if(fields == null || fields.isEmpty()){
            Set<String> tmp;
            if(fields ==  null){
                fields = new List<FieldWrapper>();
                if(searchfields != null && searchfields != 'null' && searchfields != '' ){
                    tmp = new Set<String>(searchfields.remove(' ').split(','));
                }else{
                    tmp = new Set<String>();
                }
                tmp.remove('name');
                Map<String, Schema.SObjectField> fMap = gd.get(objectType).getDescribe().fields.getMap();
                FieldWrapper fw;
                String field;
                List<String> tmp2= searchfields.remove(' ').split(',');
                //for(String field: searchfields.remove(' ').split(',')){
                for(Integer count =0; count<tmp2.size(); count++){
                    field=tmp2[count];
                    if(tmp.contains(field)){
                    System.AssertEquals(fmap.keyset().contains(field),true);
                    if((fmap.get(field).getDescribe().getType() == Schema.DisplayType.Combobox ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.Double ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.Email ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.EncryptedString ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.Percent ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.Phone ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.Picklist ||
                        fmap.get(field).getDescribe().getType() == Schema.DisplayType.String) &&
                        fmap.get(field).getDescribe().isAccessible() == true &&
                        fmap.get(field).getDescribe().isFilterable() == true
                    ){
                        fw = new FieldWrapper();
                        fw.name = fmap.get(field).getDescribe().Name;
                        fw.label = fmap.get(field).getDescribe().Label;
                        fw.fieldType = fmap.get(field).getDescribe().getType().name();
                        fields.add(fw);
                    }
                    }
                }
            }
            }
            return fields;
        }
    }
    
    public List<FieldWrapper> rfields {
        set;
        get{
            if(rfields == null || rfields.isEmpty()){
            Set<String> tmp;
            if(rfields ==  null){
                rfields = new List<FieldWrapper>();
                if(returnfields != null && returnfields != 'null' && returnfields != '' ){
                    tmp = new Set<String>(returnFields.remove(' ').split(','));
                }else{
                    tmp = new Set<String>();
                }
                tmp.remove('name');
                tmp.remove('id');
                Map<String, Schema.SObjectField> fMap = gd.get(objectType).getDescribe().fields.getMap();
                FieldWrapper fw;
                for(String field: tmp){
                    System.AssertEquals(fmap.keyset().contains(field),true);
                    if(fmap.get(field).getDescribe().isAccessible() == true
                    ){
                        fw = new FieldWrapper();
                        fw.name = fmap.get(field).getDescribe().Name;
                        fw.label = fmap.get(field).getDescribe().Label;
                        rfields.add(fw);
                    }
                }
            }
            }
            return rfields;
        }
    }
    
    // 2014-12-06 - for EB-270 - need to return the fields in the order specified so use a list instead of map
    public List<FieldWrapper> rfieldsOrdered {
        set;
        get{
            if(rfieldsOrdered == null || rfieldsOrdered.isEmpty()){
            List<String> tmp;
            if(rfieldsOrdered ==  null){
                rfieldsOrdered = new List<FieldWrapper>();
                if(returnfields != null && returnfields != 'null' && returnfields != '' ){
                    tmp = new List<String>(returnFields.remove(' ').split(','));
                }else{
                    tmp = new List<String>();
                }
                //tmp.remove('name');
                //tmp.remove('id');
                Map<String, Schema.SObjectField> fMap = gd.get(objectType).getDescribe().fields.getMap();
                FieldWrapper fw;
                for(String field: tmp){
                    System.AssertEquals(fmap.keyset().contains(field),true);
                    if(fmap.get(field).getDescribe().isAccessible() == true
                    ){
                        fw = new FieldWrapper();
                        fw.name = fmap.get(field).getDescribe().Name;
                        fw.label = fmap.get(field).getDescribe().Label;
                        rfieldsOrdered.add(fw);
                    }
                }
            }
            }
            return rfieldsOrdered;
        }
    }
    public String nameValue{get;set;}
    //public List<sObject> searchResult {get;set;}
    
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Query Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public String Query {
        get{
            if(query == '' || query == null){
            query='select Id, Name ';
            for(FieldWrapper fw:rfields){
                query+=','+fw.Name+' ';
            }
            query+= ' From '+objectType+' ';
            }
            return query;
        }
        set;
    }
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    
    public void Search(){
        String queryFilter='Where ';
        
        String stringTemp='';
        Date dateTemp;
        Time timeTemp;
        DateTime dateTimeTemp;
        Id idTemp;
        Double doubleTemp;
        showMsg = false;
        Boolean paramEntered = false; //Check whether user entered a param or not.
       // string OpGrpforCambridge ='';

		// 2014-12-05 EB-273 - modify location search to only retrieve Active locations
        String operatinggroup = [select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].operating_group__c;
		if (objectType == 'Service_Location__c') {
	        /*if (operatinggroup == 'NeuroRestorative') {
	            queryFilter += 'FacilityId__c = 20 and ';
	        } else if (operatinggroup == 'Care Meridian' || operatinggroup == 'CareMeridian'){
				queryFilter += 'FacilityId__c = 13 and ';
	        }*/
	        if(operatinggroup == 'Care Meridian' || operatinggroup == 'CareMeridian'){
	        	string opforCM = '\'%' +'Meridian'+ '%\'';
	        	queryFilter += 'Alias_lookup__r.Alias_Operating_Group__c LIKE '+opforCM+' and ';
	        }
	        else if(operatinggroup == 'Cambridge' || operatinggroup == 'Hastings'){
	        	string OpGrpforCambridge = '\'%' +'Cambridge'+ '%\'';
	        	string OpGrpforHastings = '\'%' +'Hastings'+ '%\'';
	        	
	        	queryFilter += '(Alias_lookup__r.Alias_Operating_Group__c LIKE '+OpGrpforCambridge+' OR Alias_lookup__r.Alias_Operating_Group__c LIKE '+OpGrpforHastings+') and ';
	        }
	        else {
	            queryFilter += 'Alias_lookup__r.Alias_Operating_Group__c =:operatinggroup and ';
	        }
	        queryFilter += 'Status__c = \'Active\' and ';
		}
        if(namefield.value!='' && namefield.value!=null && (namefield.value.length()>2 || (namefield.value.length() ==2 && !namefield.value.contains('*')))){
        	paramEntered = true;
            if(namefield.value.contains('*')){
                queryFilter+=' '+namefield.Name+' like \''+String.escapeSingleQuotes(namefield.value.replace('*','%'))+'\' and ';
            }else{
                stringTemp = namefield.value;
                queryFilter+=' '+namefield.name+' = \'' + stringTemp+ '\' and ';
            }
        }

        for(FieldWrapper field: fields){
            if(field.value!='' && field.value!=null) { // && (field.value.length()>2 || (field.value.length() ==2 && !field.value.contains('*')))){
            	if(!paramEntered){
            		paramEntered = true;
            	}
                if(field.fieldType.equalsIgnoreCase(Schema.DisplayType.Double.name()) || field.fieldType.equalsIgnoreCase(Schema.DisplayType.Percent.name())){
                    try{
                        doubleTemp = null;
                        doubleTemp = Double.valueOf(field.value);
                    }catch(Exception e){
                    
                    }
                    if(doubleTemp != null){
                        queryFilter+=' '+field.name+' = ' + doubleTemp + ' and ';
                    }
                }else{
                    if(field.value.contains('*')){
                        queryFilter+=' '+field.Name+' like \''+String.escapeSingleQuotes(field.value.replace('*','%'))+'\' and ';
                    }else{
                        stringTemp=field.value;
                        queryFilter+=' '+field.name+' = \'' + stringTemp + '\' and ';
                    }
                }
            }
         
        }
        
        if((!queryFilter.equalsIgnoreCase('Where ')) && (paramEntered)){
            queryFilter = queryFilter.removeEnd('and ');
            system.debug('$$$$$wholeQuery '+query+queryFilter+' Order By Name LIMIT 250');
            System.debug('stringTemp: ' + stringTemp);
            tmpResult = Database.query(query+queryFilter+' Order by State__c asc, Name asc, ProgramId__c asc LIMIT 100');
            countTotalRecords=tmpResult.size();
            if(countTotalRecords == 0){
            	showMsg = true;
				Apexpages.addmessage(new apexpages.Message(Apexpages.Severity.INFO,'No results found matching the search criteria.'));
			}
        }else{
        	tmpResult = null;
        	countTotalRecords = 0;
        	showMsg = true;
        	Apexpages.addmessage(new apexpages.Message(Apexpages.Severity.INFO,'Please use at least one parameter to search.'));
        	//return;
        }
    }
    
    
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pagination Properties and Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public Integer OffsetSize = 0;
    public Integer getOffsetSize(){
        return OffsetSize;
    }
    private Integer QueryLimit = 50;
    public Integer CountTotalRecords{get;set;}
    public Boolean showMsg{get;set;}
    
    public List<sObject> tmpResult{
        get;
        set;
    }
    public List<sObject> searchResult{
        get{
        	system.debug('OFFSET IS ' + OffsetSize);
            return (tmpResult!=null) ? Database.query(Query+' where id in :tmpResult order by name limit :QueryLimit offset :OffsetSize'): null;
            
        }
        set;
    }
    
    public Integer searchSize{
        get{
            return (searchResult!=null) ? searchResult.size():0;
        }
        set;
    }
    public void resetSearchItems(){
    /*
        tmpResult=null;
        searchResults=null;
        OffsetSize = 0;
        QueryLimit = 25;
        CountTotalRecords = 0;
    */
    }
    
    public Boolean getDisablePrevious(){
        if(OffsetSize>0){
            return false;
        }
        else return true;
    }
 
    public Boolean getDisableNext() {
        if (OffsetSize + QueryLimit < countTotalRecords){
            return false;
        }
        else return true;
    }
    public void First() {
        OffsetSize =0;
    }
    public void Last() {
        Integer tmp=(counttotalrecords/QueryLimit);
        if(Math.mod(counttotalrecords,QueryLimit)==0){
            OffsetSize = (tmp-1)*QueryLimit;
        }else{
            OffsetSize = (tmp)*QueryLimit;
        }
    }
    public void Next() {
        OffsetSize += QueryLimit;
    }
 
    public void Previous() {
        OffsetSize -= QueryLimit;
    }
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public CustomLookup(){
        gd = Schema.getGlobalDescribe();
        showMsg = false;
    }
    
    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inner Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
    public class FieldWrapper{
       public String value{
           get;
           set;
       }
       public String name{
           get;
           set;
       }
       public String label{
           get;
           set;
       }
       public String fieldType{
           get;
           set;
       }
       
    }
}