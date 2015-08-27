public with sharing class SObjectViewAttachmentController {
    public static final String VIEW_ATTACHMENT_URL = '/apex/ViewAttachment?docId=';
    public static final String UPDATE_ATTACHMENT_URL = '/apex/UpdateAttachment?docId=';
public String parentPage {get{return apexpages.currentpage().getparameters().get('parentPage');}set;}   
public String parentId {get{return apexpages.currentpage().getparameters().get('parentId');}set;}   
public String pbsId {get{return apexpages.currentpage().getparameters().get('pbsId');}set;}
public String retURL {get{return apexpages.currentpage().getparameters().get('retURL');}set;}   
public String servAssignId {get{return apexpages.currentpage().getparameters().get('servAssignId');}set;}   
public String apId {get{return apexpages.currentpage().getparameters().get('apId');}set;}   
public String admId {get{return apexpages.currentpage().getparameters().get('admId');}set;} 
public String asmtId {get{return apexpages.currentpage().getparameters().get('asmtId');}set;}   
public String asmtType {get{return apexpages.currentpage().getparameters().get('asmtType');}set;}
public String ReferralName {get{return apexpages.currentpage().getparameters().get('ReferralName');}set;}
public String viewAttachmentUrl {get;set;}
public AttachmentView attachmentView {get;set;}
public Attachment attachment {get;set;}
public boolean enableDelete {get;set;}
public String docId {get{return apexpages.currentpage().getparameters().get('docId');}set;}
public list<progress_note__C> note = [ select recordtype.developername from progress_note__c where id=:parentId limit 1];
Public list<TMN_User__c> TU = [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1];
        
SystemSettings__c pnnew = SystemSettings__c.getOrgDefaults();
public SObjectViewAttachmentController() {
    if (attachment == null) {
        attachment =[select Id, ParentId, Name, LastModifiedDate,Description,CreatedDate,Owner.Name, OwnerID ,LastModifiedById, CreatedById, BodyLength,IsPrivate,CreatedBy.name,LastModifiedBy.name  from Attachment where Id=:docId];
        attachmentView = (new AttachmentView(attachment));
    }
        if(attachment.OwnerID.equals(UserInfo.getUserId())){
        enableDelete = true;
        }else {
        enableDelete = false;
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
    // added by Amruth for EB-513
        if(note.size()>0 && TU.size()>0 && retURL != null && pnnew.AZ_OPT_Enabler__c && note[0].recordtype.DeveloperName == 'AZ_OPT' && TU[0].Operating_Group__c == 'Redwood'){
          pagereference pr = new PageReference('/'+parentId);
            return pr;
        }
        
        
        else if (retURL != null) {
            pg = new PageReference(retURL);
            pg.setRedirect(true);
        }
        
        else{
            pg = new PageReference(VIEW_ATTACHMENT_URL +docId + '&retURL='+retURL+'&parentPage='+parentPage +'&parentId='+parentId+'&pbsId='+pbsId+'&servAssignId='+servAssignId+'&apId='+apId+'&admId='+admId+'&asmtType='+asmtType+'&asmtId='+asmtId+'&ReferralName='+ReferralName);
            pg.setRedirect(true);
        }
        return pg;
    }
    
    public PageReference redirectToLastView() {
    pagereference pg ;
      // added by Amruth for EB-513
      if(note.size()>0 && TU.size()>0 && pnnew.AZ_OPT_Enabler__c && note[0].recordtype.DeveloperName == 'AZ_OPT' && TU[0].Operating_Group__c == 'Redwood'){
          pg = new PageReference('/'+parentId);
      }
      else{
          pg = new PageReference(retURL);
      }  
      return pg;
    }
    
    public PageReference redirectToUpdate() {
        PageReference pg = new PageReference(UPDATE_ATTACHMENT_URL +docId + '&retURL='+retURL +'&parentPage='+parentPage +'&parentId='+parentId+'&pbsId='+pbsId+'&servAssignId='+servAssignId+'&apId='+apId+'&admId='+admId+'&asmtType='+asmtType+'&asmtId='+asmtId+'&viewAttachmentUrl='+viewAttachmentUrl+'&ReferralName='+ReferralName);
        return pg;
    }
    
    public  PageReference deleteFile()
    {
        delete attachment;
        PageReference pg;
        // added by Amruth for EB-513
        if(note.size()>0 && TU.size()>0 && pnnew.AZ_OPT_Enabler__c && note[0].recordtype.DeveloperName == 'AZ_OPT' && TU[0].Operating_Group__c == 'Redwood'){
          pg = new PageReference('/'+parentId);
        } else{
        pg = new PageReference(retURL);
        }pg.setRedirect(true);
        return pg;
    }

 @TestVisible class AttachmentView  {
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
            return attachment.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
        }}
         public String CreatedDate { get {
            return attachment.CreatedDate.format('MM/dd/yyyy hh:mm a');
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