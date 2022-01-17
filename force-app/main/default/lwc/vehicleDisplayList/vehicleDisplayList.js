import { LightningElement, api, wire } from 'lwc';

import { refreshApex } from '@salesforce/apex';

// Lightning Message Service and message channels
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import VEHICLE_SELECTED_MESSAGE from '@salesforce/messageChannel/VehicleSelected__c';
import REFRESH_VEHICLES_MESSAGE from '@salesforce/messageChannel/RefreshVehicles__c';

// getProducts() method in ProductController Apex class
import getVehicles from '@salesforce/apex/VehiclesDisplayLWCController.getVehicles';

export default class VehicleDisplayList extends LightningElement {
    /** Current page in the product list. */
    pageNumber = 1;

    /** The number of items on a page. */
    pageSize;

    /** The total number of items matching the selection. */
    totalItemCount = 0;

    //these are the default values until/if additional vehicle types are added
    vehicleType = {objectAPI: 'Bus__c', recordType: 'Gas_Powered'};

    /** Load context for Lightning Messaging Service - maybe change this to listen for an update to refresh the list of records */
    @wire(MessageContext) messageContext;

    /**
     * Load the list of available products.
     */
    vehicles;
    wireResponse;

    @wire(getVehicles, { vehicleType: '$vehicleType', pageNumber: '$pageNumber' })
    response(result){
        this.wireResponse = result;
        this.vehicles = result;
        // this.vehicleList = result.data;
    }

    /** Subscription for refreshVehicles Lightning message */
    vehicleSelectionSubscription;

    connectedCallback() {
        // Subscribe to refresh vehicles message
        this.vehicleSelectionSubscription = subscribe(
            this.messageContext,
            REFRESH_VEHICLES_MESSAGE,
            (message) => this.handleRefreshVehicles()
        );
    }

    handlevehicleselected(event) {
        // Publish VehicleSelected message
        publish(this.messageContext, VEHICLE_SELECTED_MESSAGE, {
            vehicleId: event.detail.id,
            objectAPI: event.detail.objectAPI,
            recordType: event.detail.recordType
        });
    }

    handleRefreshVehicles(){
        window.console.log('refresh vehicles: ');
        refreshApex(this.wireResponse);
    }

    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
    }
}