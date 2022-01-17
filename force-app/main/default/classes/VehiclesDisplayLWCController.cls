public with sharing class VehiclesDisplayLWCController {
    static Integer Page_Size = 9;

    public class VehicleType {
        @AuraEnabled
        public String objectAPI {get; set;}
        @AuraEnabled
        public String recordType {get; set;}
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getVehicles(VehicleType vehicleType, Integer pageNumber){
        Integer pageSize = VehiclesDisplayLWCController.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        String recordType = vehicleType.recordType;
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM ' + vehicleType.objectAPI + ' WHERE RecordType.DeveloperName = :recordType'
        );
        result.records = Database.query(
            'SELECT Id, Name, Year__c, Maximum_Capacity__c, Odometer_Reading__c, Number_of_Wheels__c, Photo_URL__c, Resale_Value__c, Bus_Id__c FROM ' + vehicleType.objectAPI +
            ' WHERE RecordType.DeveloperName = :recordType' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );
        System.debug('result.reords: ' + result.records);
        return result;
    }
}
