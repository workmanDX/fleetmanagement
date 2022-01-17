public with sharing class MaintenanceSchedulerHandler {
    public static String prepQueryString(){
        String query = null;
        QueryInfo info = getQueryInfo();
        if(info.lowestInterval != 0){
            query = 'SELECT Id, Location__c, Miles_Since_Last_Maintenance__c, Maximum_Capacity__c, Garage__c, ' +
            '(SELECT Id, Schedule_Time__c, Recorded_Odometer__c FROM Maintenance__r ORDER BY Schedule_Time__c LIMIT 1) ' +
            'FROM Bus__c WHERE Current_Status__c = \'Ready for Use\' AND (Miles_Since_Last_Maintenance__c > ' + info.lowestInterval +  
            ' OR Miles_Since_Last_Maintenance__c < 0)';
        }
        return query;
    }

    public static QueryInfo getQueryInfo() {
        QueryInfo info = new QueryInfo();
        // info.countList = new String[0];
        info.lowestInterval = 0;
        for(Bus_Maintenance_Configuration__mdt config : [
            SELECT Passenger_Capacity__c, Maintenance_Interval__c 
            FROM  Bus_Maintenance_Configuration__mdt
            WHERE Active__c = TRUE
        ]){
            // info.countList.add('\'' + config.Passenger_Capacity__c + '\'');

            if(info.lowestInterval == 0 || config.Maintenance_Interval__c < info.lowestInterval){
                info.lowestInterval = config.Maintenance_Interval__c;
            }
        }

        return info;
    }

    public static void scheduleAppointments(Bus__c[] busList){
        BusMaintenanceInfo[] bussesForMaintenance = checkBussesForInterval(busList);
        if(!bussesForMaintenance.isEmpty()){
            createMaintenanceRecords(bussesForMaintenance);
        }
    }

    private static void createMaintenanceRecords(BusMaintenanceInfo[] busList){
        Maintenance__c[] maintenanceRecordsToInsert = new Maintenance__c[0];
        Garage__c[] garageList = getGarages();
        Bus__c[] bussesToUpdate = new Bus__c[0];
        for(BusMaintenanceInfo info : busList){
            Double dist;
            Id garageId = null;
            if(info.bus.Location__c == null){
                if(info.bus.Garage__c != null){
                    garageId = info.bus.Garage__c;
                } else {
                    //add an email/chatter post for when there is an issue
                    continue;
                }
            } else {
                for(Garage__c garage : garageList){
                    Double tempDist = Location.getDistance(info.bus.Location__c, garage.Location__c, 'mi');
                    if(garageId == null || tempDist < dist){
                        dist = tempDist;
                        garageId = garage.Id;
                    }
                }
            }
            
            System.debug('garageId: ' + garageId);

            Maintenance__c maint = new Maintenance__c(
                Bus__c = info.bus.Id,
                Garage__c = garageId,
                Schedule_Time__c = DateTime.now(),
                Schedule_Reason__c = info.config.Maintenance_Type__c
            );
            maintenanceRecordsToInsert.add(maint);
            info.bus.Current_Status__c = 'Scheduled for Maintenance';
            bussesToUpdate.add(info.bus);
        }

        System.debug('maintenanceRecordsToInsert: ' + maintenanceRecordsToInsert);
        if(!maintenanceRecordsToInsert.isEmpty()){
            insert maintenanceRecordsToInsert;
        }
        if(!bussesToUpdate.isEmpty()){
            update bussesToUpdate;
        }
    }

    private static Garage__c[] getGarages(){
        return [SELECT Id, Location__c FROM Garage__c WHERE Active__c = true];
    }

    private static BusMaintenanceInfo[] checkBussesForInterval(Bus__c[] busList){
        Map<String, Bus_Maintenance_Configuration__mdt> configMap = getConfigMap();
        Bus_Maintenance_Configuration__mdt defaultConfig = configMap.containsKey('Default') ? configMap.get('Default') : null;
        BusMaintenanceInfo[] bussesForMaintenance = new BusMaintenanceInfo[0];
        for(Bus__c bus : busList){
            Bus_Maintenance_Configuration__mdt matchingConfig = new Bus_Maintenance_Configuration__mdt();
            if(bus.Maximum_Capacity__c != null && configMap.containsKey(bus.Maximum_Capacity__c)){
                matchingConfig = configMap.get(bus.Maximum_Capacity__c);
            }
            else if(defaultConfig != null){
                matchingConfig = defaultConfig;
            }
            else {
                //skip this bus if there isn't a matching config
                continue;
            }
            BusMaintenanceInfo info = new BusMaintenanceInfo();
            if(bus.Miles_Since_Last_Maintenance__c > matchingConfig.Maintenance_Interval__c || bus.Miles_Since_Last_Maintenance__c < 0){
                info.bus = bus;
                info.config = matchingConfig;
                bussesForMaintenance.add(info);
            }
        }

        return bussesForMaintenance;
    }

    private static Map<String, Bus_Maintenance_Configuration__mdt> getConfigMap(){
        Map<String, Bus_Maintenance_Configuration__mdt> configMap = new Map<String, Bus_Maintenance_Configuration__mdt>();
        for(Bus_Maintenance_Configuration__mdt config : [
            SELECT Passenger_Capacity__c,  Maintenance_Interval__c, Maintenance_Type__c
            FROM Bus_Maintenance_Configuration__mdt 
            WHERE Active__c = true
        ]){
            configMap.put(config.Passenger_Capacity__c, config);
        }

        return configMap;
    }

    public class BusMaintenanceInfo{
        Bus__c bus;
        Bus_Maintenance_Configuration__mdt config;
    }

    public class QueryInfo{
        String[] countList;
        Decimal lowestInterval;
    }
}
