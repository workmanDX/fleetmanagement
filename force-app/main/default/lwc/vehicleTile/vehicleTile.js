import SystemModstamp from '@salesforce/schema/AcceptedEventRelation.SystemModstamp';
import { LightningElement, api } from 'lwc';

export default class VehicleTile extends LightningElement {
    /** Whether the tile is draggable. */
    @api draggable;

    _vehicle;
    /** Product__c to display. */
    @api
    get vehicle() {
        return this._vehicle;
    }
    set vehicle(value) {
        this._vehicle = value;
        this.pictureUrl = value.Photo_URL__c;
        this.name = value.Name;
        this.vehicleIdString = value.Bus_ID__c;
    }

    @api vehicleType;

    /** Vehicle field values to display. */
    pictureUrl;
    name;
    vehicleIdString;

    handleClick() {
        window.console.log('handleclick');
        const selectedEvent = new CustomEvent('selected', {
            detail: {
                id: this.vehicle.Id,
                objectAPI: this.vehicleType.objectAPI,
                recordType: this.vehicleType.recordType
            }

        });
        this.dispatchEvent(selectedEvent);
    }

    handleDragStart(event) {
        event.dataTransfer.setData('vehicle', JSON.stringify(this.vehicle));
    }
}