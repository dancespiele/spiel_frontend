class_name Utils

func shortWalletAddress(walletAddress: String):
  return "{first_part}...{second_part}".format({ "first_part": walletAddress.substr(0, 6), "second_part": walletAddress.substr(-4)})