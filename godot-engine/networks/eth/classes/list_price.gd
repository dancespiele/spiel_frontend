class_name ListPrice extends EthConfig

var get_list_prices_callback_ref := JavaScriptBridge.create_callback((Callable(self, "get_list_prices_callback")))

var prices := {
	"link": "",
	"aave": "",
	"btc": "",
	"eth": "",
	"matic": "",
	"ape": "",
}

func get_price_list():
	var price_list_contract = window.price_list_contract
	price_list_contract.getPriceList().then(get_list_prices_callback_ref)

func get_list_prices_callback(args):
	prices.link = window.Number(ethers.formatUnits(args[0][0], 8))
	prices.aave = window.Number(ethers.formatUnits(args[0][1], 8))
	prices.btc = window.Number(ethers.formatUnits(args[0][2], 8))
	prices.eth = window.Number(ethers.formatUnits(args[0][3], 8))
	prices.matic = window.Number(ethers.formatUnits(args[0][4], 8))
	prices.ape = window.Number(ethers.formatUnits(args[0][5], 8))
