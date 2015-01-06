public with sharing class PB_DocPack_Admin_Form {

    public string SelectedItemOption {get; set;}
    public PB_Document__c SelectedDocument { get; set;}
    public PB_DocPacket__c SelectedDocPacket {get; set;}
    public TMN_Tree dataTree {get; set;}
    public TMN_Tree miniFormTreeForDocs {get; set;}
    public string miniFormTreeSelectedKeys {get; set;}
    final string xClasses = 'treeRow';

    //////////////////
    //constructs
    /////////////////

    public PB_DocPack_Admin_Form(ApexPages.StandardController controller) {
        IntializeClass();
    }
    public PB_DocPack_Admin_Form(){
        IntializeClass();
    }
    public void IntializeClass(){
        SelectedDocument = new PB_Document__c ();
        SelectedDocPacket = new PB_DocPacket__c();
        refreshDataTree();        
    }

    /////////////////////
    //page methods
    ////////////////////

    // save a packet
    public PageReference SavePack(){
        try{
            if(SelectedDocPacket.External_ID__c == null){
                SelectedDocPacket.External_ID__c = genID(20);
            }
            upsert SelectedDocPacket;
            refreshDataTree();
            refreshMiniForm();

        }
        catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('Error line' + e.getLineNumber());
            system.debug('Error msg' + e.getMessage());
            system.debug('Error cause' + e.getCause());            
        }    
        return null;
    } 

    // Save a Document    
    public PageReference SaveDoc(){
        try{
            if(SelectedDocument.External_ID__c == null){            
                SelectedDocument.External_ID__c = genID(20);
            }

            boolean AddJos = (miniFormTreeSelectedKeys != null && miniFormTreeSelectedKeys.length() != 0);
            if(SelectedDocument.id == null && !AddJos){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,   
                                'You must Select at least one Packet')); 


                                return null;
            }
            upsert SelectedDocument;
            if(addJos){
                set<string> selectedPackets = new set<string>();
                for(string item : miniFormTreeSelectedKeys.split(',')){
                    selectedPackets.add(item);
                }
                
                for(PB_DocPacket_Document_JO__c JO : [select id, name, document__c, DocPacket__c from PB_DocPacket_Document_JO__c where DocPacket__c IN :selectedPackets  and document__c = :SelectedDocument.id]){
                    selectedPackets.remove(JO.DocPacket__c);
                }
            
            
                list<PB_DocPacket_Document_JO__c> newJOsToInsert = new list<PB_DocPacket_Document_JO__c>();

                for(string packetID: selectedPackets){
                    PB_DocPacket_Document_JO__c newJO = new PB_DocPacket_Document_JO__c();
                    newJO.Document__c = SelectedDocument.id;
                    newJo.DocPacket__c = packetID;  
                    newJosToInsert.add(newJO);          
                }
                insert newJosToInsert;
            }
            refreshDataTree();
            refreshMiniForm();
            
            

        }
        catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('Error line' + e.getLineNumber());
            system.debug('Error msg' + e.getMessage());
            system.debug('Error cause' + e.getCause());

        }    
        return null;
    }   

    // reset the mini Form 
    public PageReference resetMiniForm(){
        try{
            refreshMiniFormTree(null);
            SelectedDocument = new PB_Document__c ();
            SelectedDocPacket = new PB_DocPacket__c(); 
            SelectedItemOption  = ApexPages.CurrentPage().getParameters().get('selection');        
            
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }  

    // When the Fancy tree is clicked this happens
     public PageReference editItem(){
        try{
            //this is passed from the JS method we'll need the prefix from that ID to figure out the object in question
            // so we know what element to display in the miniForm
            string itemID = ApexPages.CurrentPage().getParameters().get('itemID');
            string itemPrefix = itemID.left(3);
            
            Schema.DescribeSObjectResult packObj = PB_DocPacket__c.sObjectType.getDescribe();
            String packetPrefix= packObj.getKeyPrefix();
            Schema.DescribeSObjectResult joObj = PB_DocPacket_Document_JO__c.sObjectType.getDescribe();
            String joPrefix= joObj.getKeyPrefix();    
            
            if(itemPrefix == packetPrefix){
                SelectedItemOption = 'Packet';
                SelectedDocPacket = [select id, name, External_ID__c,  Packet_Name__c, Status__c from PB_DocPacket__c where id =:itemID];            
            }
            else if(itemPrefix == joPrefix){
                //the JS passes us the ID of the junction object, what we need is the ID of the acutal document 
                //
                SelectedItemOption = 'Document';
                SelectedDocument = [select id, name, Document_Name__c, Due_Days__c, Due__c,
                                        Effective_Date__c, Due_Date__c, Recurring_Interval__c,
                                        Expiration_Date__c, External_ID__c, Recurring__c, Recurring_Frequency__c, 
                                        Status__c, Type__c, Version__c 
                                            From PB_Document__c
                                            Where id IN (select document__c from PB_DocPacket_Document_JO__c where id = :itemID)];
                                            
                // now we need to find the packets that this document is a part of 
                refreshMiniFormTree(SelectedDocument.id);    
            } 
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }     
    
    
    ///////////////////////   
    //refresh methods
    //////////////////////

    //reset all items used on the mini form
    public void refreshMiniForm(){
        SelectedItemOption = null;
        SelectedDocument = new PB_Document__c();
        SelectedDocPacket = new PB_DocPacket__c ();
    
    }
    //refresh the the document records packet tree selector 
    public void refreshMiniFormTree(string DocID){
        miniFormTreeForDocs = new TMN_Tree();
        
        for(PB_DocPacket__c packet: [select id, name, External_ID__c, Packet_Name__c, Status__c from PB_DocPacket__c]){
            TMN_Tree.Node packetNode = new TMN_Tree.Node(packet.id, packet.Packet_Name__c);
            packetNode.pbDocPacket = packet;
            miniFormTreeForDocs.root.nodes.add(packetnode);        
        }
        
        for(PB_DocPacket_Document_JO__c JO: [select id, name, DocPacket__c, Document__c from PB_DocPacket_Document_JO__c Where Document__c = :DocID]){
            integer packetKey = miniFormTreeForDocs.root.getNode_Key(JO.DocPacket__c);
            miniFormTreeForDocs.root.nodes.get(packetKey).isSelected = true;       
            miniFormTreeForDocs.root.nodes.get(packetKey).isUnselectable = true;   

        }
    
    }
    public void refreshDataTree(){
    
        dataTree = new TMN_Tree();
        list<PB_DocPacket__c > allPackets = [select id, name, External_ID__c, Packet_Name__c, Status__c from PB_DocPacket__c];
        
        for(PB_DocPacket__c packet: allPackets){
            TMN_Tree.Node packetNode = new TMN_Tree.Node(packet.id, packet.Packet_Name__c);
            packetNode.pbDocPacket = packet;
            packetNode.isFolder = true;
            packetNode.isActivate = packet.Status__c == 'Active';
            packetNode.addFancyTreeInfo = JSON.serialize(new ExtraInfo(packet));
            packetNode.extraClasses = xClasses;
            dataTree.root.nodes.add(packetNode);
        }
        
        
        list<PB_DocPacket_Document_JO__c> allPackDocJO = [select id, name, DocPacket__c, Document__r.Recurring_Frequency__c, DocPacket__r.Packet_Name__c, Document__r.Status__c, Document__r.Effective_Date__c, Document__r.Due_Days__c, Document__r.Recurring__c, Document__r.Expiration_Date__c, Document__c, Document__r.Document_Name__c from PB_DocPacket_Document_JO__c];
        
        for(PB_DocPacket_Document_JO__c PackDocJO: allPackDocJO){
            TMN_Tree.node docNode = new TMN_Tree.node(PackDocJO.id, PackDocJO.Document__r.Document_Name__c);
            docNode.pbDocPacketJO = PackDocJO;
            docNode.isActivate = PackDocJO.Document__r.Status__c == 'Active';
            docNode.addFancyTreeInfo = JSON.serialize(new ExtraInfo(PackDocJO));
            docNode.extraClasses = xClasses;
            integer docKey = dataTree.root.getNode_Key(PackDocJO.DocPacket__c); 
            dataTree.root.nodes.get(docKey).nodes.add(docNode);
        }
    
    }

 //helper methods and classes
    public string GenId(integer len){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);            
        
        return h.substring(0,len);
    
    }   
    public class ExtraInfo{
        public date EffectiveDate {get; set;}
        public date ExpirationDate {get; set;}
        public Decimal dueDays{get; set;}
        public string Recurring{get; set;}
        public string RecurringFreq{get; set;}

        public ExtraInfo(PB_DocPacket__c pack){

        }
        public ExtraInfo(PB_DocPacket_Document_JO__c doc){
            EffectiveDate = doc.Document__r.Effective_Date__c;
            ExpirationDate =  doc.Document__r.Expiration_Date__c;
            dueDays =  doc.Document__r.Due_Days__c;
            Recurring =  doc.Document__r.Recurring__c;
            RecurringFreq = doc.Document__r.Recurring_Frequency__c;
        }        


    }     
 
}