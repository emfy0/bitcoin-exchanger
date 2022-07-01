import consumer from "./consumer"

consumer.subscriptions.create("ExchangeRateChannel", {
  connected() {
    console.log('Connected to Channel')
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log(data)
  }
});
