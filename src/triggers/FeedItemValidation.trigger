trigger FeedItemValidation on FeedItem (after delete, after insert, before delete, before insert ) {

    FeedItemValidation handler = new FeedItemValidation(true);

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
         list<Feeditem> fi = new list<Feeditem>();
        fi = trigger.old;
        
        handler.OnBeforeDelete(fi);
    }
    /* After Delete */
   // else if(Trigger.isDelete && Trigger.isAfter){
   //    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
   // }
 }