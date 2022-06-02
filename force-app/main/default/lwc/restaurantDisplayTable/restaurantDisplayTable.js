import { LightningElement, wire } from "lwc";
import { publish, messageContext } from "lightning/messageService";
// TODO: Add lightning message service channel

// TODO: Replace these with data from an API
import NAME from "@salesforce/schema/Restaurant__c.Name";
import PRICE from "@salesforce/schema/Restaurant__c.Price__c";
import LAST_VISITED_DATE from "@salesforce/schema/Restaurant__c.Last_Visited_Date__c";
import WAIT_TIME from "@salesforce/schema/Restaurant__c.Wait_Time__c";
import queryAllRestaurants from "@salesforce/apex/LunchPickerQueryService.queryAllRestaurants";

export default class RestaurantDisplayTable extends LightningElement {
  columns = [
    { label: "Name", type: "button", typeAttributes: { label: { fieldName: NAME.fieldApiName, value: "Id" }, variant: "base" } },
    { label: "Wait Time", fieldName: WAIT_TIME.fieldApiName },
    { label: "Price", fieldName: PRICE.fieldApiName },
    { label: "Last Visited", fieldName: LAST_VISITED_DATE.fieldApiName, type: "date" },
  ];

  data = [];
  currentRecordId;

  // TODO: Figure out how to get @wire to work?
  async connectedCallback() {
    this.data = await queryAllRestaurants()
  }

  selectRecord(event) {
    this.currentRecordId = event.detail.row.Id;
    console.log(this.currentRecordId);
  }
}
