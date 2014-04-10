public with sharing class CareMeridianEvaluationAttachFile {
    public String myId {get; set;}
    public String strImg {get; set;}
    public Blob img { get; set;}
    public String attachID { get; set;}

    public Attachment attachment { set;
        get {
           if (attachment == null) {
               attachment = new Attachment();
           }
           return attachment;
        }
    }
    String LongDate = ' ';

    // Init LongDate with the current Datetime in long date format
    public String getLongDate() {
        Datetime cDT = System.now();
        LongDate = cDT.format('MM-dd-yyyy hh:mm:ss a z');
        return LongDate;
    }

    public PageReference upload() {
        System.debug('Inside upload');
        myId = ApexPages.currentPage().getParameters().get('id'); //  this will be the id of the evaluation passed up from ajax post
        strImg = ApexPages.currentPage().getParameters().get('img'); // the canvas img output, base-64 encoded string

        // decode the img string back to binary data
        img = EncodingUtil.base64Decode(strImg);

        attachment.OwnerId = Userinfo.getUserId();

        // get the progress note for this id
        Evaluation__c evaluation = [
            SELECT ID, Name, Referral__c FROM Evaluation__c WHERE Id=:myId LIMIT 1
        ];

        // create name for attachment based on note name + date posted
        attachment.Name = evaluation.Name  + ' ' + getLongDate() + ' Esigned.jpg';
        attachment.ParentId = evaluation.Referral__c;

        // attachment body is the actual canvas jpg image
        attachment.Body = img;

        try {
            System.debug('Attachment to insert: ' + attachment);
            insert attachment;
            evaluation.Is_Being_Signed__c = true;
            update evaluation;
            attachID = attachment.Id;
        } catch (DMLException e) {
            System.debug('Error: ' + e);
            return null;
        } finally {
            attachment = new Attachment();
        }
        return null;
    }
}