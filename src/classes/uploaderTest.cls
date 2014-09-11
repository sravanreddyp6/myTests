@istest
public class uploaderTest{
    public static final Integer NUM_ATTACHMENTS_TO_ADD=5;

    private static testMethod void testController()
    {
        Account acc=new Account(Name='Unit Test');
        insert acc;
        uploaderController controller=new uploaderController();
        controller.sobjId=acc.id;

        System.assertEquals(0, controller.getAttachments().size());

        System.assertEquals(1, controller.newAttachments.size());

        controller.addMore();

        System.assertEquals(NUM_ATTACHMENTS_TO_ADD, controller.newAttachments.size());

        // populate the first and third new attachments
        //List<uploaderController.ProxyAttachment> newAtts=controller.newAttachments;
        controller.newAttachments[0].Name='Unit Test 1';
        controller.newAttachments[0].Description='Unit Test 1';
        controller.newAttachments[0].Body=Blob.valueOf('Unit Test 1');

        controller.newAttachments[2].Name='Unit Test 2';
        controller.newAttachments[2].Description='Unit Test 2';
        controller.newAttachments[2].Body=Blob.valueOf('Unit Test 2');

        controller.newAttachments[3].Name='Unit Test 3';
        controller.newAttachments[3].Description='Unit Test 3';
        controller.newAttachments[3].Body=Blob.valueOf('Unit Test 3');
        controller.newAttachments[3].isHeadShot = 'true';

        controller.save();

        System.assertEquals(3, controller.getAttachments().size());
        System.assertNotEquals(null, controller.done());
    }
}