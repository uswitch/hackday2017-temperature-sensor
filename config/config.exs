# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

# config :nerves, :firmware,
#   rootfs_additions: "config/rootfs_additions",
#   fwup_conf: "config/fwup.conf"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

import_config "#{Mix.Project.config[:target]}.exs"

config :bootloader,
  init: [:nerves_runtime],
  app: :temperature_sensor

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay"

config :nerves_leds, names: [ green: "led0" ]

config :nerves_network,
  regulatory_domain: "UK"

  config :nerves_network, :default,
  wlan0: [
    ssid: "temperature",
    key_mgmt: :NONE
  ],
  eth0: [
    ipv4_address_method: :dhcp
  ]

# ntpd binary to use
config :nerves_ntp, :ntpd, "/usr/sbin/ntpd"
 
# servers to sync time from
config :nerves_ntp, :servers, [
    "0.pool.ntp.org",
    "1.pool.ntp.org",
    "2.pool.ntp.org",
    "3.pool.ntp.org"
  ]
