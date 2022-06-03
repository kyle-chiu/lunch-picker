import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, MessageContext, APPLICATION_SCOPE } from "lightning/messageService";
import RESTAURANT_SELECTION_CHANNEL from "@salesforce/messageChannel/RestaurantSelectionChannel__c";
import { getRecord, getFieldValue, getRecordNotifyChange } from "lightning/uiRecordApi";
import NAME from "@salesforce/schema/Restaurant__c.Name";
import PRICE from "@salesforce/schema/Restaurant__c.Price__c";
import LAST_VISITED_DATE from "@salesforce/schema/Restaurant__c.Last_Visited_Date__c";
import WAIT_TIME from "@salesforce/schema/Restaurant__c.Wait_Time__c";

const FIELDS = [NAME, PRICE, LAST_VISITED_DATE, WAIT_TIME];

export default class SelectedRestaurantDisplay extends LightningElement {
  subscription = null;
  recordId;
  @wire(MessageContext)
  messageContext;
  fields = FIELDS;

  connectedCallback() {
      this.subscribeToMessageChannel();
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  record({ error, data }) {
    if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading restaurant.",
          message: error.message,
          variat: "error"
        })
      );
    } else if (data) {
      fields.forEach(
        (item) => (this[item.fieldApiName] = getFieldValue(data, item))
      );
      getRecordNotifyChange([{ recordId: this.recordId }]);
    }
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      subscribe(this.messageContext, RESTAURANT_SELECTION_CHANNEL, (message) =>
        this.handleMessage(message), { scope: APPLICATION_SCOPE }
      );
    }
  }

  handleMessage(message) {
    this.recordId = message.recordId;
    console.log('handleMessage');
    console.log(this.recordId);
  }
}
