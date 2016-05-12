public without sharing class DSPAttachmentViewer {


	public String attachmentId {get;set;}
	
    public AttachmentWrapper wrappedAttachment { get; set;} 
    public ATtachment a2 { get; set; }
	
	public class attachmentWrapper  {
		
		public ID id { get; set; }
		public Blob body {get; set;}
		public Integer bodyLength{ get; set; }
		public String description{ get; set; }
		public string name{ get; set; }
		public string owner{ get; set; }
		public ID parentId{ get; set; }
		public string contentType{ get; set; }
		public string createdby{ get; set; }
		public datetime createddate{ get; set; }
		public String bodyAsString { get; set; }
		
		public attachmentWrapper( Attachment a ) {
			
			id = a.id;
			body = a.body;
			bodyLength = a.bodyLength;
			description = a.description;
			name = a.name;
			parentId = a.parentId;
			owner = a.owner.name;
			contentType = a.contentType;
			createdby = a.createdby.name;
			createddate = a.createddate;
			bodyasstring = EncodingUtil.base64Encode(a.body);
		} 
		
	}
		
		
	public DSPAttachmentViewer ( ID attachId ){

		wrappedAttachment = null;
		for (Attachment a : [ select id, body, bodyLength, description, name, parentId, owner.name, contentType, createdby.name, createddate from Attachment where id= :attachId]) {
			wrappedAttachment = new AttachmentWrapper(a);

			a2 = a.clone( true);
			//a2.parentid = null;
						
		}
	}

    
}