class_name Auth

var siwe := JavaScriptBridge.get_interface("siwe")
var window := JavaScriptBridge.get_interface("window")
var ethereum := JavaScriptBridge.get_interface("ethereum")
var localStorage := JavaScriptBridge.get_interface("localStorage")
var jose := JavaScriptBridge.get_interface("jose")

func create_siwe_message(address: String, statement: String, nonce: String):
  window.SiweMessage = siwe.SiweMessage
  var message_obj = "window.messageData = {domain: '{domain}', address: '{address}', statement: '{statement}', uri: '{origin}', version: '1', chainId: '{chainId}', nonce: '{nonce}'}".format({
    "domain": window.location.host,
    "address": address,
    "statement": statement,
    "origin": window.location.origin,
    "chainId": ethereum.networkVersion,
    "nonce": nonce
  })
  JavaScriptBridge.eval(message_obj)
  var message = JavaScriptBridge.create_object("SiweMessage", window.messageData)

  return message.prepareMessage()

func store_token(token: String):
  localStorage.setItem("auth_token", token)

func delete_token():
  localStorage.removeItem("auth_token")

func get_token():
  return localStorage.getItem("auth_token")

func get_claims():
  var token = localStorage.getItem("auth_token")

  if !token:
    return null
  
  var claims = jose.decodeJwt(token)
  var now = JavaScriptBridge.create_object("Date");

  if now.getTime() < window.Number(claims.exp) * 1000:
    return claims
  
  return null