defmodule Slack do

  def notify(temperature) when temperature <= 15 do
    if spam_check(:cold) do
      message(:cold, temperature) |> post
    end
  end

  def notify(temperature) when temperature > 15 do
    if spam_check(:warm) do
      message(:warm, temperature) |> post
    end
  end

  def post(message) do
    HTTPoison.post System.get_env("SLACK_URL"), message |> Poison.encode!, [{"Content-Type", "application/json"}]
  end


  def spam_check(key) do
    now  = DateTime.utc_now()

    case :ets.lookup(:notifications, key) do
      []-> true
      last_notified ->
        DateTime.diff(last_notified, now, :minutes) > 15
    end
  end

  defp message(:cold, temperature) do
    %{
      text: "Oh no! It's quite chilly up here (#{temperature} °C). Could someone please adjust the A/C? :snowman:"
    }
  end

  defp message(:warm, temperature) do
    %{
      text: "It's all good here again! (#{temperature} °C) :sunny:"
    }
  end
end
