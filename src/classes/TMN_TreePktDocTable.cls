public with sharing class TMN_TreePktDocTable {
    public node root{get; set;}        
    public boolean autoExpand{ get; set;}
    

    public string GetSelectedNodeStr {
        get{ string str=''; 
            str = BuildSelectedNodeStr(root.children);
            if (str.length()>0) {
                str = str.substring(0, (str.length()-1));
            }
            return str;} 
    }
    
    public TMN_TreePktDocTable(){
        root = new node('root','root');
        autoExpand = true; 
    }

//Node Class
    public class node {
        public list<node> children {get; set;}
        public string key {get; set;}
        public string title {get; set;}
        public string refID {get; set;}
        public string status {get; set;}
        public string helpText {get; set;}
        public boolean isNew {get; set;}
        public boolean isInserted {get; set;}
        public boolean DeleteRecord {get; set;}
            
        //fancy tree settings            
        public boolean selected {get; set;}
        public boolean unselectable {get; set;} 
        public boolean folder {get; set;}
        public boolean expanded {get; set;}
        public boolean isActivate {get; set;}
        public boolean hideCheckbox {get; set;}
        //end fancy tree settings
        
        //Additional data for the table view of fancyTree
        public integer dueDays {get; set;}
        public Date effectiveDate {get; set;}
        public Date filedDate {get; set;}
        public string recurr {get; set;}
        public string recurrFreq {get; set;}
        public string assocStatus {get; set;}
        public Date statusDate {get; set;}
        //end Additional data for the table view of fancyTree

        //construct
        public node(string k, string t){
            children = new list<node>();   
            key = k;
            title = t;
            status = 'Active';
            Unselectable = false;
            Folder = false;
            Expanded = true;
            isActivate = true;
            Selected = false;
            hideCheckbox = false;
            isNew = true;
            DeleteRecord = false; }
        //end construct
        
        //custom getters
        public map<string, integer> getnode_keys (){
            map<string, integer> keys = new map<string, integer>();
            keys.clear();
            for(Integer i = 0; i < children.size(); i++){                                
                    keys.put(children.get(i).key, i);
            }
            return null;
        }
        
        public integer getNode_Key(string key){
            integer myint = -1;
            for(Integer i = 0; i < children.size(); i++){                                
                    if(children.get(i).key == key){myint = i;}
            }        
            return myint;
        } 
        //end custom getters
    }
//End Node Class
    
    private static map<string, node> nodeKeyMap;
    private static void buildNodeKeyMap(list<TMN_TreePktDocTable.node> theNodes){
        //if (nodeKeyMap == null && nodeKeyMap.isEmpty()) nodeKeyMap = new map<string, node>();
        for(node n: theNodes){
        	nodeKeyMap.put(n.key, n);
        	buildNodeKeyMap(n.children);
        }
    }
    public static map<string, node> buildNodeKeyMapFor(list<TMN_TreePktDocTable.node> theNodes){
    	nodeKeyMap = new map<string, node>();
    	buildNodeKeyMap(theNodes);
    	return nodeKeyMap;
    }
    
//Custom Methods    
    //use in the controller of the page using the custom compentent
    //pass it selected keys to have them applied to the class
    public void inputSelectedKeys(list<string> keys, boolean ForceDeSelect){
        checkSelectedKeys(keys, root.children, ForceDeSelect);
    }
    
    private void checkSelectedKeys(list<string> keys, list<TMN_TreePktDocTable.node> theNodes, boolean ForceDeSelect){
        for(node n: theNodes){
                //if appendond only is set to false
                if(ForceDeSelect){
                    n.Selected = false;
                }         
            for(string k: keys){
           
                if (n.key == k){
                    n.Selected = true;
                } 
            }
            if(n.children.size() >0){
                checkSelectedKeys(keys, n.children, ForceDeSelect);
            }  
        }
    }    
    

   //get the comma separated list of selected items 
    public string BuildSelectedNodeStr(list<TMN_TreePktDocTable.node> theNodes){
        string str = '';
        for(node n: theNodes){
            if (n.Selected){  
                str += n.key + ',';
                // str += ',';
            }
            //get children
            if(n.children.size() >0){
                str += BuildSelectedNodeStr(n.children);
            }            
        }
        return str;
    }
}