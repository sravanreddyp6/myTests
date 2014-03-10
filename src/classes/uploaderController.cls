/*
 * Controller for multi attachment component
 */
 
global class uploaderController 
{
    /**
     * This proxy class is used to add the Head Shot choosing ability, because
     * we can't actually add custom fields to Attachment.
     */
    private class ProxyAttachment {
        private Attachment attachment;
        public ID Id { get { return attachment.ID; } set { attachment.ID = value; } }
        public ID ParentId { get { return attachment.ParentId; } set { attachment.ParentId = value; } }
        public String Name { get { return attachment.Name; } set { attachment.Name = value; } }
        public Blob Body { get { return attachment.Body; } set { attachment.Body = value; } }
        public String Description { get { return attachment.Description; } set { attachment.Description = value; } }
        public String isHeadShot { get; set; }
        public ProxyAttachment(Attachment attachment) {
            this.attachment = attachment;
            isHeadShot = 'false';
        }
        public Attachment getSObject() {
            return attachment;
        }
    }

    public Boolean showPersonalRecord{ get; set; } 


    // the parent object it
    public Id sobjId {get; set{
        sobjId = value;
        if (sobjId.getSObjectType().getDescribe().getLocalName()=='Contact') {
            showHeadShotSelection = true;
            showPersonalRecord = true;
        } else {
            showHeadShotSelection = false;
            showPersonalRecord = false;
        }
    }}

    public Boolean showHeadShotSelection { get; set; }
    public String headShotPhotoIndex { get; set; }
    
    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    
    // list of new attachments to add
    public List<ProxyAttachment> newAttachments {get; set;}
    
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=5;

    public uploaderController()
    {
        // instantiate the list with a single attachment
        newAttachments=new List<ProxyAttachment>{new ProxyAttachment(new Attachment())};
    }   
    
    // retrieve the existing attachments
    public List<Attachment> getAttachments()
    {
        attachments=[select Id, ParentId, Name, Description from Attachment where parentId=:sobjId];
        return attachments;
    }

    // Add more attachments action method
    public PageReference addMore()
    {
        // Clear out the current newAttachments first, otherwise we'll run into
        // View State maximum limit
        newAttachments.clear();
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
        {
            newAttachments.add(new ProxyAttachment(new Attachment()));
        }
        return null;
    }    
    
    // Save action method
    public PageReference save()
    {
        System.debug('Save called!');
        List<Attachment> toInsert=new List<Attachment>();
        Integer index = 0;
        Boolean headShotFound = false; // only use 1 photo as the headshot
        for (ProxyAttachment newProxyAtt : newAttachments)
        {
            Attachment newAtt = newProxyAtt.getSObject();
            if (newAtt.Body!=null)
            {
                System.debug('Body not null');
                if (newProxyAtt.isHeadShot=='true' && !headShotFound) {
                    System.debug('This is the headshot');
                    newAtt = manageHeadShotName(newAtt);
                    headShotFound = true;
                }
                newAtt.parentId=sobjId;
                toInsert.add(newAtt);
            }
            index ++;
        }
        insert toInsert;
        newAttachments.clear();
        newAttachments.add(new ProxyAttachment(new Attachment()));
        
        // null the list of existing attachments - this will be rebuilt when the page is refreshed
        attachments=null;
        return null;
    }

    public PageReference chooseHeadshot() {
        String attachmentId = Apexpages.currentPage().getParameters().get('aId');
        String attachmentName = Apexpages.currentPage().getParameters().get('aName');
        Attachment a = new Attachment(id=attachmentId, Name=attachmentName);
        a = manageHeadShotName(a);
        upsert a;
        return null;
    }

    public Attachment manageHeadShotName(Attachment a) {
        for (Attachment current: attachments) {
            if (current.Name.indexOf('HeadShot-Current')!=-1) {
                current.Name = 'HeadShot-' + Date.today().format() + findExtension(current.Name);
            }
        }
        upsert attachments;
        a.Name = 'HeadShot-Current' + findExtension(a.Name);
        return a;
    }

    private String findExtension(String fileName) {
        List<String> nameParts = fileName.split('\\.');
        if (nameParts.size()<=1) {
            return '';
        }
        return '.' + nameParts[nameParts.size()-1];
    }
    
    // Action method when the user is done
    public PageReference done()
    {
        // send the user to the detail page for the sobject
        return new PageReference('/' + sobjId);
    }
    

   public  PageReference deleteFile()
    {
        string attachmentId = Apexpages.currentPage().getParameters().get('aId');
        Attachment thisAttachment = new Attachment(id=attachmentId);
        delete thisAttachment;
        Attachments = null;     
        Attachments = getAttachments();
        return null;
    }
    
}