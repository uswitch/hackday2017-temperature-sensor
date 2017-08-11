defmodule TemperatureSensor do
  alias ElixirALE.GPIO

  @a_pin 18
  @b_pin 23

  @c 0.33
  @r0 1000.0
  @r1 1000
  @b 3800

  @z_C 0.38
  @z_R1 1000
  @z_B 3800.0
  @z_R0 1000.0

  def z_discharge do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :input)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :output)
    GPIO.write(b_pid, false)
    GPIO.release(b_pid)
    GPIO.release(a_pid)
    :timer.sleep(10)
  end

  def z_charge_time do
    {:ok, b_pid} = GPIO.start_link(@b_pin, :input)
    {:ok, a_pid} = GPIO.start_link(@a_pin, :output)

    t1 = Time.utc_now
    t2 = Time.utc_now

    z_read_gpio(b_pid)

    return Time.diff(t2, t1, :microsecond)
    GPIO.release(b_pid)
    GPIO.release(a_pid)
  end

  def z_read_gpio(pid) do
    z_read_gpio(b_pid, GPIO.read(b_pid))
  end

  def z_read_gpio(_, 1) do
    1
  end

  def z_read_gpio(pid, _) do
    z_read_gpio(b_pid, GPIO.read(b_pid))
  end

  def z_analog_read do
    z_discharge
    t = z_charge_time
    z_discharge

    t
  end

  def z_read_resistance
    n = 10
    total = 0

    for x <- 1..n, do total = total + analog_read()

    t = total / n
    tt = t * 0.632 * 3.3
    r = (tt / @z_C ) -  @z_R1
    return r
  end

  def z_read_temp_c
    r = z_read_resistance
    t0 = 273.15
    t25 = t0 + 25.0

    inv_T = 1/t25 + 1 / @z_B * :math.log(r / @z_R0)
    final_t = (1/inv_T - t0)

    final_t
  end

  def z_try
    z_read_temp_c() * 9.0 / 5.0 + 32
  end

  def discharge do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :input)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :output)

    GPIO.write(b_pid, 0)

    GPIO.release(b_pid)
    GPIO.release(a_pid)

    :timer.sleep(10)
  end

  def charge_time() do
    {:ok, a_pid} = GPIO.start_link(@a_pin, :output)
    {:ok, b_pid} = GPIO.start_link(@b_pin, :input)

    current_time = :os.system_time(:microsecond)

    GPIO.write(a_pid, 1)

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

    (1/inv_t - t0)  * 9.0 / 5.0 + 32
  end

  def start do
    :ets.new(:notifications, [:named_table])
  end
end
