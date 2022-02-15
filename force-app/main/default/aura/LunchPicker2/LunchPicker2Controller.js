({
  init: function (component) {
    var columns = [
      { label: "Restaurant Name", fieldName: "Name" },
      { label: "Wait Time", fieldName: "Wait_Time__c", type: "url" },
      { label: "Price", fieldName: "Price__c" }
    ];
    var action = component.get("c.queryRestaurants");
    action.setCallback(this, function (a) {
      component.set("v.restaurant", a.getReturnValue());
    });
    $A.enqueueAction(action);
  }
});
