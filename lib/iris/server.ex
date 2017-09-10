defmodule Iris.Server do
  require Logger
  alias Iris.Relay

  @message_handler Application.get_env(:iris, :message_handler)

  defmodule State do
    defstruct options: []
  end

  def init(hostname, session_count, _address, options) do
    Logger.info("options: #{inspect(options)}")
    case session_count > 20 do
      false ->
        banner  = [hostname, " ESMTP Bungadog"]
        options = Keyword.merge(%State{}.options, options)
        Logger.debug("new options: #{inspect(options)}")
        state   = %State{ %State{} | options: options}
        Logger.debug("State from init: #{inspect(state)}")
        {:ok, banner, state}
      true ->
        Logger.error("Connection limit exceeded")
        {:stop, :normal, ["421 ", hostname, " is too busy to accept mail right now"]}
    end
  end
  def handle_HELO(<<"invalid">>, state) do
    {:error, "554 invalid hostname", state}
  end
  def handle_HELO(<<"trusted_host">>, state) do
    {:ok, state}
  end
  def handle_HELO(hostname, state) do
    Logger.warn("HELO from #{hostname}")
    {:ok, 655360, state} # If {ok, State} was returned here, we'd use the default 10mb limit
  end
  def handle_EHLO(<<"invalid">>, _extensions, state) do
    {:error, "554 invalid hostname", state}
  end
  def handle_EHLO(hostname, extensions, state) do
    Logger.warn("EHELO from #{hostname}")
    my_extensions = 
      case :proplists.get_value(:auth, state.options, false) do
        true ->
          # auth is enabled, so advertise it
          extensions ++ [{"AUTH", "PLAIN LOGIN CRAM-MD5"}, {"STARTTLS", true}];
        false ->
          extensions
      end
    {:ok, my_extensions, state}
  end

  def handle_MAIL(<<"badguy@blacklist.com">>, state) do
    {:error, "552 go away", state}
  end
  def handle_MAIL(from, state) do
    Logger.warn("Mail from #{inspect(from)}")
    # you can accept or reject the FROM address here
    {:ok, state}
  end
  def handle_MAIL_extension(<<"X-SomeExtension">> = extension, state) do
    :io.format("Mail from extension ~s~n", [extension])
    # any MAIL extensions can be handled here
    {:ok, state}
  end
  def handle_MAIL_extension(extension, _state) do
    :io.format("Unknown MAIL FROM extension ~s~n", [extension])
    :error
  end

  def handle_RCPT(<<"nobody@example.com">>, state) do
    {:error, "550 No such recipient", state}
  end
  def handle_RCPT(to, state) do
    Logger.warn("Mail to #{inspect(to)} with state: #{inspect(state)}")
    # you can accept or reject RCPT TO addesses here, one per call
    {:ok, state}
  end

  def handle_RCPT_extension(<<"X-SomeExtension">> = extension, state) do
    # % any RCPT TO extensions can be handled here
    :io.format("Mail to extension ~s~n", [extension])
    {:ok, state}
  end

  def handle_RCPT_extension(extension, _state) do
    :io.format("Unknown RCPT TO extension ~s~n", [extension])
    :error
  end

  def handle_DATA(_from, _to, <<>>, state) do
    {:error, "552 Message too small", state}
  end
  def handle_DATA(from, to, data, state) do
    # some kind of unique id
    #reference = :lists.flatten([:io_lib.format("~2.16.0b", [x]) || <<x>> <= :erlang.md5(:erlang.term_to_binary(unique_id()))])
    reference = [ :erlang.md5(:erlang.term_to_binary(unique_id())) ]
    # if RELAY is true, then relay email to email address, else send email data to console
    Logger.debug("proplist data: #{:proplists.get_value(:relay, state.options, false)}")
    Logger.debug("proplist data: #{inspect(reference)}")
    case :proplists.get_value(:relay, state.options, false) do
      true -> @message_handler.handle(from, to, data)
      false ->
      Logger.info("message from #{from} -> #{to} queued as #{inspect(reference)}, body length #{byte_size(data)}")
        case :proplists.get_value(:parse, state.options, false) do
          false -> :ok
          true ->
            try do
              results = :mimemail.decode(data)
              Logger.info("Message decoded successfully!, #{inspect(results)}")
            catch 
              what ->
                Logger.warn("Message decode FAILED with #{inspect(what)}")
                case :proplists.get_value(:dump, state.options, false) do
                  false -> :ok
                  true ->
                    # optionally dump the failed email somewhere for analysis
                    file = "dump/"++ reference
                    case :filelib.ensure_dir(file) do
                      :ok -> :file.write_file(file, data)
                      _ ->
                        :ok
                    end
                end
            end
        end
    end
    # At this point, if we return ok, we've accepted responsibility for the email
    {:ok, reference, state}
  end

  def handle_AUTH(type, <<"username">>, <<"PaSSw0rd">>, state) when type == :login and type == :plain do
    {:ok, state}
  end
  def handle_AUTH('cram-md5', <<"username">>, {digest, seed}, state) do
    case :smtp_util.compute_cram_digest(<<"PaSSw0rd">>, seed) do
      ^digest ->
        {:ok, state}
      _ ->
        :error
    end
  end
  def handle_AUTH(_type, _username, _password, _state) do
    :error
  end

  #  this callback is OPTIONAL
  #  it only gets called if you add STARTTLS to your ESMTP extensions
  def handle_STARTTLS(state) do
    IO.write("TLS Started")
    state
  end

  def terminate(reason, state) do
    {:ok, reason, state}
  end
  def handle_RSET(state) do
    # reset any relevant internal state
    state
  end

  def handle_VRFY(<<"someuser">>, state) do
    {:ok, "someuser@" <> :smtp_util.guess_FQDN(), state}
  end
  def handle_VRFY(_address, state) do
    {:error, "252 VRFY disabled by policy, just send some mail", state}
  end

  def handle_other(verb, _args, state) do
    # You can implement other SMTP verbs here, if you need to
    {["500 Error: command not recognized : '", verb, "'"], state}
  end


  defp unique_id do
    System.unique_integer
  end
end
