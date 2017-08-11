defmodule Slack do

  def notify(temperature) do
    HTTPoison.post System.get_env("SLACK_URL"), message(temperature) |> Poison.encode!, [{"Content-Type", "application/json"}]
  end

  defp message(temperature) when temperature < 15 do
    %{
      text: "Oh no! It's quite chilly up here (#{temperature} °C). Could someone please adjust the A/C? :snowman:"
    }
  end

  defp message(temperature) when temperature > 15 do
    %{
      text: "It's all good here again! (#{temperature} °C) :sunny:"
    }
  end
end
