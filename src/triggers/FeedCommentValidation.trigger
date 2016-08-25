trigger FeedCommentValidation on FeedComment (after delete, after insert, before delete, before insert) {

    FeedCommentValidation handler = new FeedCommentValidation(true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
      /* Before Delete */
    else if(Trigger.isDelete && Trigger.isBefore){
         list<FeedComment> fc = new list<FeedComment>();
        fc = trigger.old;
    
        handler.OnBeforeDelete(fc);
    }
 
}