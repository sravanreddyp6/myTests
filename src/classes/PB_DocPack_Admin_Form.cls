public with sharing class PB_DocPack_Admin_Form {

    public List<SelectOption> getItemOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('','--None--'));
            options.add(new SelectOption('Packet','Packet'));
            options.add(new SelectOption('Document','Document'));
            return options;
    }
    public string SelectedItemOption {get; set;}
    public PB_Document__c SelectedDocument { get; set;}
    public PB_DocPacket__c SelectedDocPacket {get; set;}
    public TMN_Tree dataTree {get; set;}
    public TMN_Tree miniFormTreeForDocs {get; set;}
    public TMN_Tree packetForDocumentsTree {get; set;}
    public string miniFormTreeSelectedKeys {get; set;}

    
    //construct
    public PB_DocPack_Admin_Form(ApexPages.StandardController controller) {
        SelectedDocument = new PB_Document__c ();
        SelectedDocPacket = new PB_DocPacket__c();
        refreshDataTree();
    }
    //page methods
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
        }    
        return null;
    }     
    public PageReference SaveDoc(){
        try{
            if(SelectedDocument.External_ID__c == null){            
                SelectedDocument.External_ID__c = genID(20);
            }
            upsert SelectedDocument;
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
            refreshDataTree();
            refreshMiniForm();
            
            

        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }    
    public PageReference setSelectiblePacketsForDocumentsTree(){
        try{
            refreshMiniFormTree(null);
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }   
    public PageReference resetMiniForm(){
        try{
            refreshMiniFormTree(null);
            SelectedDocument = new PB_Document__c ();
            SelectedDocPacket = new PB_DocPacket__c(); 
            SelectedItemOption  = null;        
            
        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }   
    
    
    
       
    //refresh methods
    public void refreshMiniForm(){
        string SelectedItemOption = null;
        SelectedDocument = new PB_Document__c();
        SelectedDocPacket = new PB_DocPacket__c ();
    
    }
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
            dataTree.root.nodes.add(packetNode);
        }
        
        
        list<PB_DocPacket_Document_JO__c> allPackDocJO = [select id, name, DocPacket__c, DocPacket__r.Packet_Name__c, Document__c, Document__r.Document_Name__c from PB_DocPacket_Document_JO__c];
        
        for(PB_DocPacket_Document_JO__c PackDocJO: allPackDocJO){
            TMN_Tree.node docNode = new TMN_Tree.node(PackDocJO.id, PackDocJO.Document__r.Document_Name__c);
            docNode.pbDocPacketJO = PackDocJO;
            integer docKey = dataTree.root.getNode_Key(PackDocJO.DocPacket__c); 
            dataTree.root.nodes.get(docKey).nodes.add(docNode);
        }
        packetForDocumentsTree(new list<string>());
    
    }
    public void packetForDocumentsTree(list<string> selectedKeys){
    
    
    }
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
                SelectedDocument = [select id, name, Document_Name__c, Due_Days__c, Effective_Date__c,
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
 //helper methods
    public string GenId(integer len){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);            
        
        return h.substring(0,len);
    
    }        
 
}