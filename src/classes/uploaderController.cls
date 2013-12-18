/*
 * Controller for multi attachment component
 */
 
global class uploaderController 
{
  

    // the parent object it
    public Id sobjId {get; set;}
    
    // list of existing attachments - populated on demand
    public List<Attachment> attachments;
    
    // list of new attachments to add
    public List<Attachment> newAttachments {get; set;}
    
    // the number of new attachments to add to the list when the user clicks 'Add More'
    public static final Integer NUM_ATTACHMENTS_TO_ADD=5;

    public uploaderController()
    {
        // instantiate the list with a single attachment
        newAttachments=new List<Attachment>{new Attachment()};
    }   
    
    // retrieve the existing attachments
    public List<Attachment> getAttachments()
    {
        attachments=[select Id, ParentId, Name, Description from Attachment where parentId=:sobjId];
        return attachments;
    }

    // Add more attachments action method
    public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
        {
            newAttachments.add(new Attachment());
        }
    }    
    
    // Save action method
    public void save()
    {
        List<Attachment> toInsert=new List<Attachment>();
        for (Attachment newAtt : newAttachments)
        {
            if (newAtt.Body!=null)
            {
                newAtt.parentId=sobjId;
                toInsert.add(newAtt);
            }
        }
        insert toInsert;
        newAttachments.clear();
        newAttachments.add(new Attachment());
        
        // null the list of existing attachments - this will be rebuilt when the page is refreshed
        attachments=null;
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