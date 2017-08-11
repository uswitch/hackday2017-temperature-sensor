defmodule TemperatureSensor do
  alias ElixirALE.GPIO

  @a_pin 18
  @b_pin 23

  @c 0.38
  @r1 1000
  @b 3800

  def discharge do
    {:ok, b_pid} = GPIO.start_link(@b_pin, :output)

    GPIO.write(b_pid, 0)

    GPIO.release(b_pid)
  end

  def charge_time() do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :output)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :input)

    GPIO.write(a_pid, 1)

    current_time = :os.system_time(:microsecond)

    read_gpio(GPIO.read(b_pid), b_pid)

    end_time = :os.system_time(:microsecond)

    GPIO.release(a_pid)
    GPIO.release(b_pid)
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

  def r(0, total) do
    total
  end

  def r(count, total) do
    r(count - 1, total + analog_read())
  end

  def read_resistance do
    num_of_readings = 10
    total = r(num_of_readings, 0)
    t = total / num_of_readings
    tt = t * 0.632 * 3.3

    (tt / @c) - @r1
  end

  def read_temp_c do
    resistance = read_resistance()

    t0 = 273.15
    t25 = t0 + 25

    inv_t = 1 / t25 + 1/@b * :math.log(resistance / @r0)

    1/inv_t - t0
  end

  def start do
    :ets.new(:notifications, [:named_table])
  end
end
