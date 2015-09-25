defmodule LoggerEmailBackend do
  use GenEvent

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_event({level, _gl, {Logger, msg, _ts, _md}}, %{level: min_level, from: from, to: to, title: title} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      email = Mailer.compose_email(from, to, title, "plain", [message: msg])
      Mailer.send(email)

      {:ok, state}
    else
      {:ok, state}
    end
  end

  # helper

  defp configure(name, opts) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    from = Keyword.get(opts, :from)
    to = Keyword.get(opts, :to)
    title = Keyword.get(opts, :title)

    %{level: level, from: from, to: to, title: title}
  end
end
