Replacement weather service for FanJu FJW4 Weather Station
==========================================================

This is a replacement service to provide th weather station [FanJu FJW4](https://www.aliexpress.com/wholesale?catId=0&initiative_id=SB_20190304065325&SearchText=FanJu+FJW4)
wit more accurate forecast information.

# Motivation
The FanJu FJW4 is a good weather station: fairly cheap, nice design and one of the few with a Internet-based 4-day weather forecast.
The only problem? While the forecast for Cinese cities might be accurate, the one here in London is terrible.
I decided to reverse the station protocol and create a service that can provide a better weather forecast (from [DarkSky](https://darksky.net/)).

# Installation and first time run
The code is written in Swift so to compile and install it you need to check out the repository on a machine with Swift 4.2 installed and
type:

```
swift build
```

This will generate a binary that can be executesd. There are a few parameters to pass on the command line.
These are:

* `-i, --bind-ip`: the local IP to bind too (by default it tries to bind to all available local IPs).
* `-p, --bind-port`: local port to bind to (by default 10000 which is the one the Weather Station expects).
* `-o, --lat`: Latitide of the location to use for weather checks.
* `-a, --lon`: Longitude of the location to use for weather checks.
* `--fanju-ip`: The IP of the original fanju weather services (default is 47.52.149.125)
* `-r, --fanju-port`: The port of of the original fanju weather service (deafult is 10000)

## Connecting the Weather station
The weather station will try to connect to "connect.emaxlife.net" to get the weather details. We'd like it to connect to our server instead.
There are two ways to achieve this:

1. The weather station has a web configuration interface: just point a web browser to the IP of the station and use admin/admin as credentials.
   The select "其它设置", update the URL at the bottom, press "保存" to save; confirm with "重启". Unfortunately the configuration seems to be
   ephemeral so it will reset every time you reboot the station.
2. If you control your DNS server you can always add an entry for "connect.emaxlife.net" and point it to your local instance of this server.
   This doesn't require any changes to the weather station configuration and so it will persists reboots.

## DarkSky API key
The server requires a valid Dark Sky API key that can be obtained for free [here](https://darksky.net/dev). The first 10000 API request a day 
are free. Unless you're planning to deploy hundreds of these weather stations, it should be enough!

Once you obtain the API key, just put it inside a file named `api_key.txt` next to the binary. The service will pick it up automatically.

# License
MIT, See [LICENSE](LICENSE) file.
