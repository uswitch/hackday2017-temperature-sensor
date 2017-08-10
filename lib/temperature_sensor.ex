defmodule TemperatureSensor do
  alias ElixirALE.GPIO

  @a_pin 18
  @b_pin 23

  def discharge(a_pid, b_pid) do
    GPIO.write(b_pid, 0)
  end

  def charge_time(a_pid, b_pid) do
    GPIO.write(a_pid, 1)

    current_time = :os.system_time(:microsecond)

    read_gpio(GPIO.read(b_pid), b_pid)

    end_time = :os.system_time(:microsecond)

    end_time - current_time
  end

  def read_gpio(1,_) do
    1
  end

  def read_gpio(_,b_pid) do
    read_gpio(GPIO.read(b_pid), b_pid)
  end

  def analog_read({a_in, a_out, b_in, b_out}) do
    discharge(a_in, b_out)
    t = charge_time(a_out, b_in)
    discharge(a_in, b_out)

    t
  end

  def setup do
    {:ok, a_in} = GPIO.start_link(@a_pin, :input)
    {:ok, b_out} = GPIO.start_link(@b_pin, :output)
    {:ok, a_out} = GPIO.start_link(@a_pin, :output)
    {:ok, b_in} = GPIO.start_link(@b_pin, :input)

    {a_in, a_out, b_in, b_out}
  end
end
