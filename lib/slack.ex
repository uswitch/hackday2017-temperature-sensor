defmodule Slack do

  @endpoint "https://hooks.slack.com/services/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"

  def notify(temperature) do
    HTTPoison.post @endpoint, "payload={\"text\": \"test\"}", [{"Content-Type", "application/json"}]
  end

  defp message(temperature) do
    "Hello world"
#    "Oh no! It's quite chilly up here. Could someone please adjust the A/C?"
  end

end
