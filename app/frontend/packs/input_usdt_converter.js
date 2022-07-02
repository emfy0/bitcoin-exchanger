import consumer from "../channels/consumer"

function strIsFloat(str) {
  return str.match(/^-?\d*(\.\d+)?$/);
}

document.addEventListener('turbolinks:load', () => {
  const divWithData = document.querySelector('[data-market-fee]')
  const marketFee = +(divWithData.getAttribute("data-market-fee").replace('%', '')) / 100
  const minerFee = +divWithData.getAttribute("data-miner-fee")
  const input = document.getElementById("transaction_you_send")
  const output = document.getElementById("transaction_get")

  input.addEventListener('change', () => {
    let convertation_rate = +divWithData.getAttribute("data-ust-to-btc")
    let inputValue = input.value

    if (!strIsFloat(inputValue))
      return

    let btc = parseFloat(inputValue) * (1 - marketFee) * convertation_rate - minerFee
    output.value = Math.abs(btc.toFixed(8))
  })

  output.addEventListener('change', () => {
    let convertation_rate = +divWithData.getAttribute("data-ust-to-btc")
    let outputValue = output.value

    if (!strIsFloat(outputValue))
      return

    let ust = (parseFloat(outputValue) + minerFee) / ((1 - marketFee) * convertation_rate)
    input.value = Math.abs(ust.toFixed(8))
  })

  consumer.subscriptions.create("ExchangeRateChannel", {
    connected() {
      console.log('Connected to Channel')
    },
  
    disconnected() {
    },
  
    received(data) {
      divWithData.setAttribute('data-ust-to-btc', data['UST'])
      let changeEvent = new Event('change')
      input.dispatchEvent(changeEvent)
      console.log('received')
    }
  })
})
