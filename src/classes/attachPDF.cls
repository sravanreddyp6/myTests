public class attachPDF {

    public String myId {get; set;}
    public String strImg {get; set;}
    public Blob img { get; set;}
    public String attachID { get; set;}
    
    public Attachment attachment {
      get {
      if (attachment == null) {
          attachment = new Attachment();
          }
      return attachment;
    	}
      set;
      }
  
  
  String LongDate = ' ';

	// Init LongDate with the current Datetime in long date format 
	public String getLongDate() {
	    Datetime cDT = System.now();
	    LongDate = cDT.format('MM-dd-yyyy hh:mm:ss a z');
	    return LongDate;
	}
  
  public PageReference upload() {
  
    myId = ApexPages.currentPage().getParameters().get('id'); //  this will be the id of the progress note passed up from ajax post
    strImg = ApexPages.currentPage().getParameters().get('img'); // the canvas img output, base-64 encoded string
    
    // decode the img string back to binary data
    img = EncodingUtil.base64Decode(strImg);
    
    attachment.OwnerId = Userinfo.getUserId();
    attachment.ParentId = myId; // the record the file is attached to
    
    // get the progress note for this id
    Progress_Note__c pn = new Progress_Note__c();
    pn = [select id, name, number_of_required_signatures__c from Progress_Note__c where id = :myId limit 1];
 	
 	// create name for attachment based on note name + date posted
    attachment.Name = pn.Name  + ' ' + getLongDate() + ' Esigned.jpg';
    
    // attachment body is the actual canvas jpg image
    attachment.Body =  img; 
    
    try {
      
	    insert attachment;
	    attachID = attachment.Id;
		
		// if signature was required, update the "signature on file" field on the progress note 
		if ( pn.Number_of_Required_Signatures__c > 0 ) {
			pn.Signature_on_File__c = 'Y';
			update pn;
		}
			
    } catch (DMLException e) {
	      return null;
    } finally {
	      attachment = new Attachment();
	      return null;
    }
    
    return null;
  }
 
}