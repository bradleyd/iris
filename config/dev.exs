use Mix.Config

# see https://github.com/Vagabond/gen_smtp for more options
config :iris, 
  listener: [[{:sessionoptions, [{:callbackoptions, [{:relay, false}]}]}]],
  message_handler: Iris.MessageHandler
