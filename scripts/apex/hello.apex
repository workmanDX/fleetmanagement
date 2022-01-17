// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

String queryString = MaintenanceSchedulerHandler.prepQueryString();
System.debug('queryString: ' + queryString);
Bus__c[] busses = Database.query(queryString);
System.debug('busses = ' + busses);

String jobId = BatchMaintenanceScheduler.start();

BatchMaintenanceScheduler obj = new BatchMaintenanceScheduler();
DataBase.executeBatch(obj);