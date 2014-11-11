public with sharing class PB_DocPack_Admin_Form {
    public boolean hasError {get; set;}
    public map<PB_Document__c, boolean> allDocs {get; set;}
    public list<PB_Document__c> AllDocsInPacket {get; set;}
    public PB_Document__c PopUpDocument { get;set;}
    public string documentIdForEdit { get; set;}
    public PB_DocPacket__c DocPacket { get; set;}
    public map<string, list<PB_DocSignature__c>> allDocumentSignatures { get; set;}
    public list<PB_DocSignature__c> PopUpDocumentSignatures { get; set;}
    
    public PB_DocPack_Admin_Form(ApexPages.StandardController controller) {
        DocPacket = getDocPacket(controller.getId()); 
        PopUpDocument = new PB_Document__c();
        allDocumentSignatures = new map<string, list<PB_DocSignature__c>> ();
        clearDocSignatures();
       // refreshDocMap();
        refreshDocsInPacket();
    }
    
    
    //refresh methods
    public PB_DocPacket__c getDocPacket(id docID){
        PB_DocPacket__c doc  = new PB_DocPacket__c ();
        if(docID != null){
            doc = [select id, name, External_ID__c, Packet_Name__c, Status__c  from PB_DocPacket__c where id = :docID];
        }
        else{
            doc.External_ID__c = genID(20);
        }
        return doc;
        
    }
    public void refreshDocsInPacket(){
        AllDocsInPacket = new list<PB_Document__c>();
        list<PB_DocPacket_Document_JO__c > Joins = [select id, name, DocPacket__c, Document__c from PB_DocPacket_Document_JO__c where DocPacket__c =:DocPacket.id];
        set<id> theDocIds = new set<id>();
        for(PB_DocPacket_Document_JO__c item : Joins){
            theDocIds.add(item.Document__c);
        }
        
        AllDocsInPacket = [select id, name, Document_Name__c, 
                                        Due_Days__c, Effective_Date__c, Expiration_Date__c, Recurring__c, Recurring_Frequency__c,
                                        Status__c,  Type__c, Version__c
                                            from PB_Document__c where id IN :theDocIds]; 
    
        //reset the map
        allDocumentSignatures = new map<string, list<PB_DocSignature__c>> ();
        // add each doc and a blank list to the map
        for (string item: theDocIds){
            allDocumentSignatures.put(item, new List<PB_DocSignature__c>());
        }
        list<PB_DocSignature__c> docSigns = [select id, name, DocSigner__c, Document__c, ReSign_Interval__c, ReSign_Required__c From PB_DocSignature__c where Document__c IN :theDocIds];
        for(PB_DocSignature__c item: docSigns ){
            allDocumentSignatures.get(item.Document__c).add(item);
        }
        
    
    }  
    public void refreshDocSignatures(id docID){
    
        PopUpDocumentSignatures = [select id, name, DocSigner__c, Document__c, ReSign_Interval__c, ReSign_Required__c from PB_DocSignature__c where Document__c = :docID Order By CreatedDate];
    
    } 
    public void clearDocSignatures(){
        PopUpDocumentSignatures = new list<PB_DocSignature__c>();
    
    }
    /* 
    public void refreshDocMap(){

        allDocs = new map<PB_Document__c, boolean>();

        for(PB_Document__c item : [select id, name, Document_Name__c, 
                                        Due_Days__c, Effective_Date__c, Expiration_Date__c, Recurring__c, Recurring_Frequency__c,
                                        Status__c,  Type__c, Version__c
                                            from PB_Document__c]){
            allDocs.put(item, false);
            TMN_Tree.node node = new TMN_Tree.node(item.id, item.id);
            node.pbDoc = item;
            
            DocTree.root.nodes.add(node);

        }
    }
    */

    public PageReference SavePacket(){
        try{
            upsert DocPacket;
            DocPacket = getDocPacket(DocPacket.id);

        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }

    return  null;


    }

    //Document Methods
    public PageReference SaveDocument(){
        try{
            hasError = true;
            boolean addJO = false;
            if(PopUpDocument.id == null){
                addJO = true;
            }
            upsert PopUpDocument ;
            upsert PopUpDocumentSignatures ;
            if(addJO){
                PB_DocPacket_Document_JO__c PackDocJoin = new PB_DocPacket_Document_JO__c();
                PackDocJoin.DocPacket__c = DocPacket.id;
                PackDocJoin.Document__c = PopUpDocument.id;
                insert PackDocJoin ;
            }
            refreshDocsInPacket();
            
            //hasError = false;

        }
        catch(Exception e){
            hasError = true;
            PopUpDocument = new PB_Document__c ();
            ApexPages.addMessages(e);
        }

    return  null;


    }
    public PageReference EditDocument(){
        try{
            PopUpDocument = [select id, name, Document_Name__c, Due_Days__c, 
                                Effective_Date__c, Expiration_Date__c, External_ID__c, 
                                Recurring__c, Recurring_Frequency__c, Status__c, Type__c, Version__c
                                From PB_Document__c where id = :documentIdForEdit ];
            refreshDocSignatures(PopUpDocument.id);

        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }
    public PageReference NewDocument(){
        try{
            PopUpDocument = new PB_Document__c ();
            PopUpDocument.External_ID__c = genID(20);
            clearDocSignatures();

        }
        catch(Exception e){
            ApexPages.addMessages(e);
        }    
        return null;
    }    
    public PageReference NewDocumentSignature(){
        try{
            PB_DocSignature__c signature = new PB_DocSignature__c();
            
            PB_Document__c refDoc = new PB_Document__c();
            refDoc.External_ID__c = PopUpDocument.External_ID__c;
            signature.Document__r = refDoc;
            PopUpDocumentSignatures.add(signature);
            

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
    public Boolean getErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }   


}