public with sharing class SObjectViewAttachmentController {
	public static final String VIEW_ATTACHMENT_URL = '/apex/ViewAttachment?docId=';
	public static final String UPDATE_ATTACHMENT_URL = '/apex/UpdateAttachment?docId=';
public String parentPageName {get;set;}	
public String parentIdNum {get;set;}	
public String pbsIdNum {get;set;}
public String retURL {get;set;}	
public String servAssignIdNum {get;set;}	
public String apIdNum {get;set;}	
public String admIdNum {get;set;}	
public String asmtIdNum {get;set;}	
public String asmtTypeName {get;set;}
public String viewAttachmentUrl {get;set;}
public AttachmentView attachmentView {get;set;}
public Attachment attachment {get;set;}
public Id documentId {get;set{
	documentId = value;
	if (attachment == null) {
		attachment =[select Id, ParentId, Name, LastModifiedDate,Description,CreatedDate,Owner.Name, OwnerID ,LastModifiedById, CreatedById, BodyLength,IsPrivate,CreatedBy.name,LastModifiedBy.name  from Attachment where Id=:documentId];
		attachmentView = (new AttachmentView(attachment));
	}
}
}

public PageReference editAttachment() {
	if (this.attachment != null) {
				update this.attachment;
		}
		return redirectToViewAttachment();
}

public PageReference redirectToViewAttachment() {
	PageReference pg= null;
	System.debug('retURL123 : ' +retURL);
		if (retURL != null) {
			 pg = new PageReference(retURL);
			 pg.setRedirect(true);
		} else{
		 pg = new PageReference(VIEW_ATTACHMENT_URL +documentId + '&retURL='+retURL+'&parentPage='+parentPageName +'&parentId='+parentIdNum+'&pbsId='+pbsIdNum+'&servAssignIdNum='+servAssignIdNum+'&apIdNum='+apIdNum+'&admIdNum='+admIdNum+'&asmtTypeName='+asmtTypeName+'&asmtIdNum='+asmtIdNum);
		pg.setRedirect(true);
		}
		return pg;
	}
	
	public PageReference redirectToLastView() {
		PageReference pg = new PageReference(retURL);
		return pg;
	}
	
	public PageReference redirectToUpdate() {
		viewAttachmentUrl = VIEW_ATTACHMENT_URL +documentId + '&retURL='+retURL+'&parentPage='+parentPageName +'&parentId='+parentIdNum+'&pbsId='+pbsIdNum+'&servAssignIdNum='+servAssignIdNum+'&apIdNum='+apIdNum+'&admIdNum='+admIdNum+'&asmtTypeName='+asmtTypeName+'&asmtIdNum='+asmtIdNum;
		System.debug('viewAttachmentUrl : ' +viewAttachmentUrl);
		PageReference pg = new PageReference(UPDATE_ATTACHMENT_URL +documentId + '&retURL='+retURL +'&parentPage='+parentPageName +'&parentId='+parentIdNum+'&pbsId='+pbsIdNum+'&servAssignIdNum='+servAssignIdNum+'&apIdNum='+apIdNum+'&admIdNum='+admIdNum+'&asmtTypeName='+asmtTypeName+'&asmtIdNum='+asmtIdNum+'&viewAttachmentUrl='+viewAttachmentUrl);
		return pg;
	}

  class AttachmentView  {
        public Attachment attachment { get; set; }
        public String Name {set; get {
            return this.attachment.Name;
        }}
        public String OwnerName { get {
            return this.attachment.Owner.Name;
        }}
        public String OwnerId { get {
        	 return this.attachment.OwnerId;
        }}
        public ID ID { get {
            return attachment.Id;
        }}
        public String LastModifiedDate { get {
            return attachment.LastModifiedDate.format('M/d/yyyy h:m a');
        }}
         public String CreatedDate { get {
            return attachment.CreatedDate.format('M/d/yyyy h:m a');
        }}
        public String Description { set;get {
            return attachment.Description;
        }}
        public String LastModifiedBy { get {
            return attachment.LastModifiedBy.name;
        }}public String CreatedBy { get {
            return attachment.CreatedBy.Name;
        }}public String BodyLength { get {
            return attachment.BodyLength/1024+' KB';
        }}public Boolean  IsPrivate {set; get {
            return attachment.IsPrivate;
        }}
        public AttachmentView(Attachment attachment) {
            this.attachment = attachment;
        }
    }
}