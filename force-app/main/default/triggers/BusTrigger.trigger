trigger BusTrigger on Bus__c (before insert, before update) {
    if (trigger.isInsert && trigger.isBefore){
        BusTriggerHandler.beforeInsert(Trigger.new); 
    }

    if (trigger.isUpdate && trigger.isBefore){
		BusTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }
}