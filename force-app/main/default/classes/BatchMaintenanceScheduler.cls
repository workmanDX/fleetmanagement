global class BatchMaintenanceScheduler implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = MaintenanceSchedulerHandler.prepQueryString();
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, Bus__c[] busList) {
        try {
            MaintenanceSchedulerHandler.scheduleAppointments(busList);
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}
