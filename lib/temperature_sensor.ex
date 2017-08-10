defmodule TemperatureSensor do
  alias ElixirALE.GPIO

  @a_pin 18
  @b_pin 23

  def discharge do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :input)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :output)

    GPIO.write(b_pid, 0)
  end

  def charge_time() do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :output)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :input)

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

  def analog_read do
    discharge
    t = charge_time
    discharge

    t
  end
end
