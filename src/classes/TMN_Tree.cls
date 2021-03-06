public virtual class TMN_Tree{
//Declarations

    String TEMPLATE_STR = '{0}title:"{1}", tooltip:"{2}", expanded:{3}, hideCheckbox:{4}, folder:{5}, activate:{6}, selected:{7}, unselectable:{8}, key:"{9}", status:"{10}", {12}, extraClasses:"{13}", {11}'; 
                             // {'{', n.Title, n.isExpand, n.hideCheckbox, n.isFolder, n.isActivate, n.isSelected, n.isUnselectable, n.key, n.CatTreeNode.status, 'children: ['};

    public node root{get; set;}
    public string Fancy_Tree_JSon_String {get{return BuildJSonString(root.nodes, true);} set;}
    public string Fancy_Tree_JSon_String_LongText {
    	get{ string str=''; 
    		 str = BuildJSonString(root.nodes, false);
             if (str.length()>0) {
                str = str.substring(0, (str.length()-1));
              }
            return str;}    		
    		set;}

    public string GetSelectedNodeStr {
        get{ string str=''; 
            str = BuildSelectedNodeStr(root.nodes);
            if (str.length()>0) {
                str = str.substring(0, (str.length()-1));
            }
            return str;}
            set;}
        
    public boolean autoExpand{ get; set;}
//construct    
    public TMN_Tree(){
        root = new node('root','root');
        autoExpand = true; 
    }
//Node Class
        public virtual class node{
        //Declarations            
            public list<node> nodes {get; set;}
            public string key {get; set;}
            public string title {get; set;}
            public string refID {get; set;}
            public string getLongTextTitle(){
            	if (String.isEmpty(title)) return ''; 
                String newTitle = title.replace('\r\n','<br/>');
                newTitle = newTitle.replace('\n','<br/>');
                newTitle = newTitle.replace('"','\\"');
                return newtitle;}
            public string status {get; set;}
            public string helpText {get; set;}
            public boolean isNew {get; set;}
            public boolean isInserted {get; set;}
            public boolean DeleteRecord {get; set;}
            
            
            
            //fancy tree settings            
            public boolean isSelected {get; set;}
            public boolean isUnselectable {get; set;} 
            public boolean isFolder {get; set;}
            public boolean isExpand {get; set;}
            public boolean isActivate {get; set;}
            public boolean hideCheckbox {get; set;}
            public string addFancyTreeInfo {get; set;}
            public string extraClasses {get; set;}
            //end fancy tree settings
            //this is a placeholder for any record in force, using it requires field name to be looked up via maps.
            //<apex:inputField value="{!r.myrecord['Catalog_Element__c']}" />
            public sobject myrecord { get; set;}
            //custom supported Objects - used for increased code readibility 
            public Clinical_Catalog_Tree_Node__c CatTreeNode {get; set;}
            public Clinical_Catalog_Element__c CatTreeEley {get; set;}
            public Project__c Proj {get; set;}
            public Project_Task__c ProjTask {get; set;}
            public Task theTask {get; set;}
            public Project_Task_Activity__c ProjTaskAct {get; set;}
            public PB_Document__c pbDoc { get; set;}
            public PB_DocPacket__c pbDocPacket {get; set;}
            public PB_DocPacket_Document_JO__c pbDocPacketJO{get; set;}
            
            public list<Attachment> Attaches { get; set;}
            //end Custom objects
        //construct
            public node(string k, string t){
                 
                nodes = new list<node>();   
                key = k;
                title = t;
                status = 'Active';
                isunselectable = false;
                isfolder = false;
                isexpand = true;
                isactivate = true;
                isselected = false;
                hideCheckbox = false;
                isNew = true;
                DeleteRecord = false;
                CatTreeNode = new Clinical_Catalog_Tree_Node__c ();
                CatTreeNode.Status__c = 'Active'; 
                CatTreeEley = new Clinical_Catalog_Element__c ();
                            
            }
        //end construct
        //custom getters
            public map<string, integer> getnode_keys (){
                map<string, integer> keys = new map<string, integer>();
                keys.clear();
                for(Integer i = 0; i < nodes.size(); i++){                                
                    keys.put(nodes.get(i).key, i);
                }
                
                return null;
            }
            public integer getNode_Key(string key){
                integer myint = -1;
                for(Integer i = 0; i < nodes.size(); i++){                                
                    if(nodes.get(i).key == key){myint = i;}
                }        
                return myint;
            } 
            //end custom getters   
        
        } 
//End Node Class    
//Custom Methods    
    //use in the controller of the page using the custom compentent
    //pass it selected keys to have them applied to the class
    public void inputSelectedKeys(list<string> keys, boolean ForceDeSelect){
        checkSelectedKeys(keys, root.Nodes, ForceDeSelect);
    }
    
    private void checkSelectedKeys(list<string> keys, list<tmn_tree.node> theNodes, boolean ForceDeSelect){
        for(node n: theNodes){
                //if appendond only is set to false
                if(ForceDeSelect){
                    n.isSelected = false;
                }         
            for(string k: keys){
           
                if (n.key == k){
                    n.isSelected = true;
                } 
          
            
            }
            if(n.nodes.size() >0){
                checkSelectedKeys(keys, n.nodes, ForceDeSelect);
            }  
        }
    
    
    }    
    
    public String ToString(Boolean Value){
     /* string representation of a Boolean value */
     if (Value)
       return 'true';
     else
       return 'false';
    }
  
       
   //the JSon string used to send to the a component for rendering 
    public string BuildJSonString(list<tmn_tree.node> theNodes, boolean isHTML){
        string str = '';
        String[] arguments;
        string myTitle ='error no title found';

                
        for(node n: theNodes){  
            if(isHTML){
                myTitle = n.Title;        
            }
            else{
                myTitle = n.getLongTextTitle();
            }        
            string addInfo = 'fakedata:"test"';
            if (n.addFancyTreeInfo != null){addInfo = 'custom:' +  n.addFancyTreeInfo;}
            string status = 'Inactive';
            if (n.isActivate){status = 'Active';}
            //if(n.CatTreeNode.Status__c != null){status = n.CatTreeNode.Status__c;}
            arguments = new String[] {'{', myTitle, n.helpText, ToString(n.isExpand), ToString(n.hideCheckbox), 
                                                                ToString(n.isFolder), ToString(n.isActivate), 
                                                                ToString(n.isSelected), ToString(n.isUnselectable), 
                                                                n.key, status, 
                                                                'children: [', addInfo, 
                                                                n.extraClasses};
            str += String.format(TEMPLATE_STR, arguments);
            //get children 
            if(n.nodes.size() >0){
                str += BuildJSonString(n.nodes, isHTML);
            }
            //end 
            str += ']},';
        
        }  
        return str;
    }
//End Custom Methods

   //get the comma separated list of selected items 
    public string BuildSelectedNodeStr(list<tmn_tree.node> theNodes){
        string str = '';
        for(node n: theNodes){
            if (n.isSelected){  
                str += n.key + ',';
                // str += ',';
            }
            //get children
            if(n.nodes.size() >0){
                str += BuildSelectedNodeStr(n.nodes);
            }            
        }
        return str;
    }

}