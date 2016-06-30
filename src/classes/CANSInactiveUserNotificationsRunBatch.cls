public with sharing class CANSInactiveUserNotificationsRunBatch implements Schedulable{
	public void execute(SchedulableContext sc) {
		CANSInactiveUserNotifications.sendReport();
	}
}