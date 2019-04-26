// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  console.log("cable.js: App.cable before: " + App.cable);

  App.cable = ActionCable.createConsumer();

  console.log("cable.js: App.cable after: " + App.cable);

}).call(this);
