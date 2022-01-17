import { LightningElement, wire } from 'lwc';

// Lightning Message Service and a message channel
import { NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import VEHICLE_SELECTED_MESSAGE from '@salesforce/messageChannel/VehicleSelected__c';
import REFRESH_VEHICLES_MESSAGE from '@salesforce/messageChannel/RefreshVehicles__c';

// Utils to extract field values
import { getFieldValue } from 'lightning/uiRecordApi';

/* 
 * If/when other vehicle objects are added, would need to add logic to choose the correct field names
 * maybe can pass in a list of field names from a meta data table
*/
import BUS_NAME_FIELD from '@salesforce/schema/Bus__c.Name';
import BUS_YEAR_FIELD from '@salesforce/schema/Bus__c.Year__c';
import BUS_MAXIMUM_CAPACITY_FIELD from '@salesforce/schema/Bus__c.Maximum_Capacity__c';
import BUS_ODOMETER_FIELD from '@salesforce/schema/Bus__c.Odometer_Reading__c';
import BUS_RESALE_VALUE_FIELD from '@salesforce/schema/Bus__c.Resale_Value__c';
import BUS_ID_FIELD from '@salesforce/schema/Bus__c.Bus_ID__c';
import BUS_STATUS_FIELD from '@salesforce/schema/Bus__c.Current_Status__c';

export default class VehicleCard extends NavigationMixin(LightningElement) {
    yearField = BUS_YEAR_FIELD;
    maxCapacityField = BUS_MAXIMUM_CAPACITY_FIELD;
    odometerField = BUS_ODOMETER_FIELD;
    vehicleIdField = BUS_ID_FIELD;
    statusField = BUS_STATUS_FIELD;
    
    recordId;
    objectAPI;
    recordType;
    resaleValue;
    vehicleName;
    vehicleIdString;
    vehicleType = 'Bus';

     /** Load context for Lightning Messaging Service */
     @wire(MessageContext) messageContext;

    /** Subscription for ProductSelected Lightning message */
    vehicleSelectionSubscription;

    connectedCallback() {
        // Subscribe to ProductSelected message
        this.vehicleSelectionSubscription = subscribe(
            this.messageContext,
            VEHICLE_SELECTED_MESSAGE,
            (message) => this.handleVehicleSelected(message)
        );
    }

    handleRecordLoaded(event) {
        const { records } = event.detail;
        const recordData = records[this.recordId];
        this.resaleValue = getFieldValue(recordData, BUS_RESALE_VALUE_FIELD);
        this.vehicleName = getFieldValue(recordData, BUS_NAME_FIELD);
        this.vehicleIdString = getFieldValue(recordData, BUS_ID_FIELD);
    }

    /**
     * Handler for when a product is selected. When `this.recordId` changes, the
     * lightning-record-view-form component will detect the change and provision new data.
     */
     handleVehicleSelected(message) {
        this.recordId = message.vehicleId;
        this.objectAPI = message.objectAPI;
        this.recordType = message.recordType;
    }

    handleNavigateToRecord() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectAPI,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleSuccess(){
        // Publish vehicle updated message
        window.console.log('handleSuccess');
        publish(this.messageContext, REFRESH_VEHICLES_MESSAGE, { });
    }
}