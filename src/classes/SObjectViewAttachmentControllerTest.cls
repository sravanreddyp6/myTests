@isTest
public class SObjectViewAttachmentControllerTest {
	
	static testmethod void simpleTests(){
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
		Attachment attach = new Attachment();
		attach.ParentId = testData.theSA.Id;
		attach.Name ='Test String';
		attach.body = blob.ValueOf('test data');
		insert attach;
		
		PageReference ref = Page.UpdateAttachment;
		test.setCurrentPage(ref);
		ref.getParameters().put('docId', attach.Id);
		ref.getParameters().put('retURL', '/testData.theSA.Id');
		SObjectViewAttachmentController controller = new SObjectViewAttachmentController();
		Attachment att = [SELECT Id, Name, Description, CreatedDate, LastModifiedBy.Name, CreatedBy.Name, IsPrivate, BodyLength,OwnerId, owner.Name FROM Attachment WHERE Id=:attach.Id];
		SObjectViewAttachmentController.AttachmentView wrap = new SObjectViewAttachmentController.AttachmentView(att);
		system.assert(wrap.name == 'Test String');
		system.assert(wrap.Description == null );
		system.assert(wrap.ID == att.Id);
		system.assert(wrap.CreatedDate == att.CreatedDate.format('MM/dd/yyyy hh:mm a'));
		system.assert(wrap.BodyLength == att.BodyLength/1024+' KB');
		system.assert(wrap.IsPrivate == false);
		system.assert(wrap.CreatedBy == att.CreatedBy.Name);
		system.assert(wrap.LastModifiedBy == att.LastModifiedBy.Name);
		system.assert(wrap.OwnerId == UserInfo.getUserId());
		system.assert(wrap.OwnerName == att.owner.Name);
		
		controller.redirectToViewAttachment();
		controller.redirectToLastView();
		controller.redirectToUpdate();
		attach.body = blob.valueOf('test');
		controller.editAttachment();
		controller.deleteFile();
	}

}