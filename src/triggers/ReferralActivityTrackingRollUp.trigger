trigger ReferralActivityTrackingRollUp on Task (after delete, after insert, after update) {
    String separator = '.';  // can't have white space at the end
    if (Trigger.isUpdate || Trigger.isInsert) {
        for (Task task: Trigger.new) {
            System.debug('Parent SObject Type: ' + task.WhatId.getSObjectType().getDescribe().getName());
            if (task.WhatId == null || task.WhatId.getSObjectType().getDescribe().getName() != 'Referral__c') {
                continue;
            }
            
            System.debug('Start Rolling Up');
            Referral__c referral = [
                SELECT ID, (SELECT ID, Description FROM Tasks) FROM Referral__c
                WHERE ID=:task.WhatId LIMIT 1
            ];
            System.debug('Referral: ' + referral);
            String rollUpComments = '';
            for (Task referralTask: referral.Tasks) {
                System.debug('Comment: ' + referralTask.Description);
                if (referralTask.Description!=null && referralTask.Description!='') {
                    rollUpComments += referralTask.Description + separator;
                }
            }
//            rollUpComments = rollUpComments.subString(0, rollUpComments.length()-2);  // takes out the last semi-colon
            System.debug('Full comments: ' + rollUpComments);
            referral.Referral_Activity_Tracking_Comments__c = rollUpComments;
            update referral;
        }
    } else if (Trigger.isDelete) {
        for (Task task: Trigger.old) {
            if (task.WhatId == null || task.WhatId.getSObjectType().getDescribe().getName() != 'Referral__c') {
                continue;
            }
            System.debug('Start Rolling Up Deleted Comments');
            Referral__c referral = [
                SELECT ID, Referral_Activity_Tracking_Comments__c FROM Referral__c
                WHERE ID=:task.WhatId LIMIT 1
            ];
            System.debug('Referral: ' + referral);
            System.debug('Task Description: ' + task.Description);
            if (task.Description!=null && task.Description!='') {
            	String stringToFind = task.Description + separator;
            	System.debug('String to find: ' + stringToFind);
                Integer indexOfComment = referral.Referral_Activity_Tracking_Comments__c.indexOf(stringToFind);
                System.debug('Index of comment: ' + indexOfComment);
                if (indexOfComment!=-1) {
                    referral.Referral_Activity_Tracking_Comments__c = referral.Referral_Activity_Tracking_Comments__c.substring(0, indexOfComment) +
                        referral.Referral_Activity_Tracking_Comments__c.substring(indexOfComment + stringToFind.length(), referral.Referral_Activity_Tracking_Comments__c.length());
                }
                update referral;
            }
        }
    }
}