public with sharing class ChatterRetentionRunBatch implements schedulable {
    public void execute(SchedulableContext sc){
        String query = 'Select f.Type, f.CommentCount, f.Body, f.Title, f.Id, f.CreatedById, f.ParentId, f.LastModifiedDate, f.CreatedDate From FeedItem f';
        ID batchprocessid = Database.executeBatch(new ChatterRetention(query), 200);
    }
}