defmodule Slack do

  def notify(temperature) when temperature <= 15, do: action(:cold, temperature)
  def notify(temperature) when temperature > 15, do: action(:warm, temperature)

  defp action(key, temperature) do
    with time_now <- DateTime.utc_now(),
         true <- should_notify?(key, time_now),
         {:ok, _} <- message(key, temperature) |> post,
      do: log(key, time_now)
  end

  defp post(message) do
    HTTPoison.post Config.get(:temperature_sensor, :slack_url), message |> Poison.encode!, [{"Content-Type", "application/json"}]
  end

  defp should_notify?(key, time_now) do
    case :ets.lookup(:notifications, key) do
      [] -> true
      {:cold, last_notified} ->
        DateTime.diff(last_notified, time_now, :minutes) > 15
      _ -> false
    end
  end

  defp log(key, time) do
    :ets.insert(:notifications, {key, time})
  end

  defp message(:cold, temperature), do: "Oh no! It's quite chilly up here (#{temperature} °C). Could someone please adjust the A/C? :snowman:"
  defp message(:warm, temperature), do: "It's all good here again! (#{temperature} °C) :sunny:"
end
