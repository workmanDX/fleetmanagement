global class SchedulableBusReview implements Schedulable {
   global void execute(SchedulableContext sc) {
    BatchMaintenanceScheduler b = new BatchMaintenanceScheduler(); 
    database.executebatch(b);
   }
}
