
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");                   
});

Parse.Cloud.beforeSave("Item", function(request, response) {

                       var Item = Parse.Object.extend("Item");
                       if (!request.object.isNew()) {
                       // Let existing object updates go through
                       response.success();
                       }
                       var query = new Parse.Query(Item);
                       query.equalTo("itemUUID", request.object.get("itemUUID"));

                       query.first().then(function(existingObject) {
                                          if (existingObject) {
                                          // Update existing object
                                          existingObject.set("status", request.object.get("status"));
                                          existingObject.set("text", request.object.get("text"));
                                          existingObject.set("status_changed_at", request.object.get("status_changed_at"));
                                          return existingObject.save();
                                          } else {
                                          // Pass a flag that this is not an existing object
                                          return Parse.Promise.as(false);
                                          }
                                          }).then(function(existingObject) {
                                                  if (existingObject) {
                                                  // Existing object, stop initial save
                                                  response.error("Existing object");
                                                  } else {
                                                  // New object, let the save go through
                                                  response.success();
                                                  }
                                                  }, function (error) {
                                                  response.error("Error performing checks or saves.");
                                                  });
                       });