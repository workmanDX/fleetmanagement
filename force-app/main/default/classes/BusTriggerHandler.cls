public with sharing class BusTriggerHandler {
    public static void beforeInsert(Bus__c[] busList) {
        calculateBusValues(busList);
    }

    public static void beforeUpdate(Bus__c[] busList, Map<Id, Bus__c> oldBusMap){
        calculateBusValues(busList);
    }

    private static void calculateBusValues(Bus__c[] busList){
        Bus__c[] bussesToCalculateValue = new Bus__c[0];
        for(Bus__c bus : busList){
            if(bus.Current_Status__c == 'Ready for Use'){
                bussesToCalculateValue.add(bus);
            }
            else {
                bus.Resale_Value__c = 0;
            }
        }

        Bus__c[] bussesToUpdate = new Bus__c[0];

        Map<String, Bus_Value_Configuration__mdt> busValueMap = getConfigurations();
        if(busValueMap.isEmpty()) return;

        //get the defaultconfig
        Bus_Value_Configuration__mdt defaultConfig = busValueMap.containsKey('Default') ? busValueMap.get('Default') : null;

        for(Bus__c bus : bussesToCalculateValue){
            Bus_Value_Configuration__mdt matchingConfig = new Bus_Value_Configuration__mdt();
            if(bus.Maximum_Capacity__c != null && busValueMap.containsKey(bus.Maximum_Capacity__c)) {
                matchingConfig = busValueMap.get(bus.Maximum_Capacity__c);
            }
            else if(defaultConfig != null){
                matchingConfig = defaultConfig;
            } 
            
            if(matchingConfig != null){
                calculateBusValue(bus, matchingConfig);
            }
        }
    }

    private static void calculateBusValue(Bus__c bus, Bus_Value_Configuration__mdt config){
        Decimal value = config.Starting_Value__c;

        if(bus.Has_AC__c && config.AC_Bonus__c != null){
            value = value * (1 + (config.AC_Bonus__c / 100));
        }

        if(bus.Year__c != null && config.Historic_Year__c != null && config.Historic_Bonus__c != null && bus.Year__c <= config.Historic_Year__c){
            value = value * (1 + (config.Historic_Bonus__c / 100));
        }

        if(bus.Odometer_Reading__c != null && config.Milage_Floor__c != null && config.Value_Reduction__c != null && bus.Odometer_Reading__c > config.Milage_Floor__c){
            value -= ((bus.Odometer_Reading__c - config.Milage_Floor__c) * config.Value_Reduction__c);
        }

        bus.Resale_Value__c = value;
    }

    private static Map<String, Bus_Value_Configuration__mdt> getConfigurations(){
        Map<String, Bus_Value_Configuration__mdt> configMap = new Map<String, Bus_Value_Configuration__mdt>();
        for(Bus_Value_Configuration__mdt config : [
            SELECT AC_Bonus__c, Historic_Bonus__c, Historic_Year__c, Milage_Floor__c, Passenger_Capacity__c, Starting_Value__c, Value_Reduction__c
            FROM Bus_Value_Configuration__mdt
            WHERE Active__c = true
        ]){
            configMap.put(config.Passenger_Capacity__c, config);
        }

        return configMap;
    }
}
