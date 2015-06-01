public with sharing class SObjectNotesAndAttachmentsController {
    public List<NoteAttachment> entries { get; set; }
    public String retURL {get;set;}	
    public ID toDelete { get; set; }
    public ID parent { get; set {
        parent = value;
        entries = new List<NoteAttachment>();
        for (Note note: [SELECT ID, Title, LastModifiedDate,CreatedDate,Owner.Name, OwnerID FROM Note WHERE ParentId=:parent]) {
             entries.add(new NoteAttachment(note));
        }
        for (Attachment attachment: [SELECT ID, Name, LastModifiedDate,CreatedDate, Description,Owner.Name, OwnerID FROM Attachment WHERE ParentId=:parent order by createddate desc limit 10]) {
            entries.add(new NoteAttachment(attachment));
        }
        entries.sort();
    }}
    
    public List<NoteAttachment> getAllAttachments {set; get  {
     List<NoteAttachment> attList = new List<NoteAttachment>();
        for (Attachment attachment: [SELECT ID, Name, LastModifiedDate,CreatedDate, Description,Owner.Name, OwnerID FROM Attachment WHERE ParentId=:parent order by createddate desc ]) {
            attList.add(new NoteAttachment(attachment));
        }
        attList.sort();
        return attList;
    }
    }
    public void del() {
        System.debug('Delete called');
        if (toDelete==null) return;
        System.debug('About to delete');
        String query ='SELECT ID FROM ' + toDelete.getSObjectType().getDescribe().getName() + ' WHERE ID=\'' + String.escapeSingleQuotes(toDelete) + '\'';
        delete Database.query(query);
        toDelete = null;
    }

    class NoteAttachment implements Comparable {
        public Boolean isNote { get; set; }
        public Note note { get; set; }
        public Attachment attachment { get; set; }
        public String Title { get {
            if (note!=null) {
                return this.note.Title;
            }
            return this.attachment.Name;
        }}
        public String OwnerName { get {
            if (note!=null) {
                return this.note.Owner.Name;
            }
            return this.attachment.Owner.Name;
        }}
        public String OwnerId { get {
            if (note!=null) {
                return this.note.OwnerId;
            }
            return this.attachment.OwnerId;
        }}
        public ID ID { get {
            if (note!=null) {
                return note.Id;
            }
            return attachment.Id;
        }}
        public String LastModifiedDate { get {
            if (note!=null) {
                return note.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
            }
            return attachment.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
        }}
       public String CreatedDate { get {
            if (note!=null) {
                return note.CreatedDate.format('MM/dd/yyyy hh:mm a');
            }
            return attachment.CreatedDate.format('MM/dd/yyyy hh:mm a');
        }}
        public String Description { get {
            if (note!=null) {
                return null;
            }
            return attachment.Description;
        }}
        public NoteAttachment(Note note) {
            this.note = note;
            this.isNote = true;
        }
        public NoteAttachment(Attachment attachment) {
            this.attachment = attachment;
            this.isNote = false;
        }
        public Integer compareTo(Object objToCompare) {
            NoteAttachment obj = (NoteAttachment) objToCompare;
            if (this.CreatedDate == obj.CreatedDate) return 0;
            if (this.CreatedDate > obj.CreatedDate) return -1;
            return 1;
        }
    }
}