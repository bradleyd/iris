use Mix.Config

# see https://github.com/Vagabond/gen_smtp for more options
config :iris, 
  listener: [[{:sessionoptions, [{:callbackoptions, [{:relay, false},{:parse, true}]}]}]],
  server: Iris.Server,
  message_handler: Iris.MessageHandler
