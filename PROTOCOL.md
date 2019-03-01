Fanju Weather Station UDP Protocol
==================================
The protocol is based on UDP over IPv4 and the server listens on port 10000.
The exchange is in the form of Request/Response, driven by the client.

There are a few Requests/Response that I still don't understand. They seem to be fixed request/responses and they're not influencing the data displayed
on the screen as far as I can tell.
I won't describe these here but keep in mind that this proxy will just forward them to the server transparently. Without the weather station won't be
able to boot.

All the data is sent over the wire in little endian format.

# Anatomy of a packet
The packet format is variable in size. But it resembles the following structure:
```
 0                 1                   2                   3
 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                             Header                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           MACAddress                          |
+                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               |              Type             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               |              Size             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
|                   Payload data (length = size)                |
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|              CheckSum         |             Footer            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

Where:

* **Header:** (32bits) is a constant that starts every message - always `aa:3c:57:01`.
* **MACAddress:** (48bits) is the MAC address of the weather station. It can be found on the Weather station web interface (see README for more details)
* **Type:** (32bits) describes the type of message. I strongly think this is a 16bit value followed by another 16bit value where the first defines the kind of message
            and the second one identifies if it's a request or a response. Since I couldn't pin point this with precision I'm treating the whole 32bit as
            a single value.
* **Size:** (16bits) is the size of the payload that follows, up to the checksum excluded. Some messages (like some requests) have no payload and so this is `00:00`.
* **Payload:** is the payload specific to the message type. See below for details.
* **Checksum:** (16bits) is the checksum of all the packet, Checksum and Footer excluded. The checksum is calculated by summing up all the bytes and taking a mod 2^16 of the final result.
* **Footer:** (16bits) is a constant that closes every message - always `cc:3e`.

# Request packets
Request packets usually don't have much payload. Not all of them are understood but here's the list:

## Hello Request (`01:01 01:00`)
Payload is empty. This message is sent first when the Weather station starts up

## Hello Response (`01:01 01:01`)
Payload is empty. This is sent back to the Weather station to aknowledge the conversation.

## Current Weather Request (`52:30 01:00`)
Payload is empty. This message is sent periodically (every hour or so) together with the Weather Forecast Request to update the current weather
conditions (on the top half of the weather station).

## Current Weather Response (`52:30 00:00`)
The payload looks like this:
```
 0                 1                   2                   3
 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       Id      |            Country            |               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+               +
|                              Date                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                Unknown                |       Feels like      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       |            Pressure           |       Wind speed      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       |    Unknown    | Wind direction|1 1 1 1 1 1 1 1 1 1 1 1|
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                       +
|1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1|
+1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1|
|1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1|
+                       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|1 1 1 1 1 1 1 1 1 1 1 1|            Unknown            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

Where: 
* **ID:** (8bits) is... not too sure about this one. It's always set to 0x01 so I expected it to be some kind of ID in case multiple weather station share the same MAC? It's safe to assume this to be a costant 0x01
* **Country:** (16bits)  is the code identifying the country where the Weather station resides. See below for values.
* **Date:** (40bits) is the current date displayed in the top left corner. See below for the format.
* **Feels like:** (16bits) is the "feels like" temperature displayed in the top right corner of the weather station. See "temperature format" for more info.
* **Pressure:** (16bits) is the pressure in hpa. See floating point format.
* **Wind speed:** (16bits)  is the wind speed in km/h. See floating point format.
* **Wind direction:** (8bits) is the direction of the wind displayed in the clock like wind gauge on the left on the display.


#### Country List
| Value   | Description  |
|---------|--------------|
| 0x130c  | UK           |
| 0x1413  | China        |

### Date format
The date is encoded over 40bits in the following format:
```
 0                 1                   2                   3                   4
 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|     Month     |     Day       |      Hour     |    Minutes    |     Seconds   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```
There is no concept of year because it's not displayed anyway.

*NOTE:* The date/time is sent twice: once on the current weather and once on the forecast request. It's not clear to me which one is picked up but I
        expect to be the first one

### Floating point format (wind speed, pressure, etc)
Floating point nunmber are limited to 1 digit of precision and stored in an UInt16 using the following formula: 

`10 * value`

I assume because this
way the number is representable with an integer.
There's no precision on the weather station display so all number are rounded down/up to the closest integer.

### Wind direction format
The wind is represented by an integer from 0 to 11 where each number represent one position on the wind clock on the display. Starting from 0 at the top
and following clock-wise.

## Weather Forecast Request (`52:31 01:00`)
Payload is empty. This message is sent periodically (every hour or so) to update the forecast displayed (at the bottom of the weather station).

## Weather Forecast Response (`52:31 00:00`)
The payload looks like this:
```
 0                 1                   2                   3
 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|       Id      |            Country            |               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+               +
|                              Date                             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Today's weather                        |
+                                               +-+-+-+-+-+-+-+-+
|                                               |               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+               +
|                       Tomorrow's weather                      |
+                               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                               |                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
|                       Weather in 2 days                       |
+               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               |                                               |
+-+-+-+-+-+-+-+-+                                               +
|                        Weather in 3 days                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Weather in 4 days                       |
+                                               +-+-+-+-+-+-+-+-+
|                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```
Where:
* **ID:** see "Current Weather Response"
* **Country**: see "Current Weather Response"
* **Date:** see "Current Weather Response"
* **Weather nibbles**: these 5 blocks contain the current weather conditions and the forecast for the next 4 days. [See below](###Weather-Forecast-nibble-format) for the format.


### Weather Forecast nibble format
The format of the weather in the Weather packet looks like this:
```
 0                 1                   2                   3
 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|      Icon     |1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1|    TempMax    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|               |            TempMin            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

#### Icon values
These are the possible icon values:

| Value |Description       |
|-------|------------------|
| 0x00  | Sunny            |
| 0x06  | Mostly Sunny     |
| 0x08  | Mostly Cloudy    |
| 0x??  | Cloudy           |
| 0x??  | Patchy Rain      |
| 0x??  | Mostly Rain      |
| 0x??  | Showers          |
| 0x0D  | Heavy Rain       |
| 0x10  | Thunder Rain     |
| 0x??  | Rain & Hail      |
| 0x??  | Hail             |
| 0x??  | Snow & hail      |
| 0x??  | Patchy snow      |
| 0x??  | Mostly snow      |
| 0x??  | Snow shower      |
| 0x??  | Heavy snow       |
| 0x??  | Rain & snow      |
| 0x??  | Foggy            |
| 0x??  | Windy            |

#### Temperature format
Temperature is sent in Fahrenheit but the format is not straightforward. The data is stored as a UInt16 following the formula:

`(90 + temperature) * 10`

This allow for 1 digit precision that is discarded by the weather station that seems to round up/down to the closest integer.

**Example**: A sunny day with a min temperature of 25 (-4C) and a max of 42 (+6C) would be sent as:
`00:ff:ff:28:05:74:04:`
Note how the temperature values are stored as little endian.

### Local Weather Upload Request (`53:30 01:00`)
This is sent by the weather station every minute or so and the payload contains the data of the internal and external sensor. I haven't spent any time
understanding this for now but it shouldn't be too hard to reverse it.

### Local Weather Upload Response (`53:30 00:00`)
Payload is empty. This seems to be a generic "OK" response that the server sends to signify that the data of the previous request has been accepted


# Sample exchange
This is a sample exchange between the weather station and the server when booting up. Please note that the request `57:00 01:00` is repeated multiple
times but the server returns different responses. This is the only request that has not a 1:1 match to the response.

```
[Station boot]
2019-01-24 18:00:16,674
2019-01-24 18:00:16,675 REQUEST: 0101 0100 0000 0004
2019-01-24 18:00:16,973 RESPONSE: Received from server: 0101 0101 0000 0104
2019-01-24 18:00:17,158
2019-01-24 18:00:17,158 REQUEST: 0202 0100 0000 0204
2019-01-24 18:00:17,463 RESPONSE: Received from server: 0202 0001 0000 0204
2019-01-24 18:00:17,648
2019-01-24 18:00:17,648 REQUEST: 5700 0100 0000 5504
2019-01-24 18:00:17,953 RESPONSE: Received from server: 5032 0001 0400 9407c404 e705
2019-01-24 18:00:18,164
2019-01-24 18:00:18,165 REQUEST: 5700 0100 0000 5504
2019-01-24 18:00:18,463 RESPONSE: Received from server: 4332 0001 0100 03 7704
2019-01-24 18:00:18,650
2019-01-24 18:00:18,650 REQUEST: 5700 0100 0000 5504
2019-01-24 18:00:18,948 RESPONSE: Received from server: 5033 0001 0200 5f14 f604
2019-01-24 18:00:19,144
2019-01-24 18:00:19,145 REQUEST: 5132 0100 0100 02 8404
2019-01-24 18:00:19,446 RESPONSE: Received from server: 5132 0000 0200 4f4b 1c05
2019-01-24 18:00:24,146
2019-01-24 18:00:24,147 REQUEST: 5230 0100 0000 8004
2019-01-24 18:00:24,443 RESPONSE: Received from server: 5230 0000 2200 01 0c13011812001828055c0a051e05c2273c00b80bffffffffffffffffffffffa000
2019-01-24 18:00:29,147
2019-01-24 18:00:29,149 REQUEST: 5231 0100 0000 8104
2019-01-24 18:00:29,446 RESPONSE: Received from server: 5231 0000 2b00 01 0c13011812001d0dffff2805e2040dffff5005c4040dffff64050a050dffff32050a0500ffff1e05ba04
2019-01-24 18:00:29,802
2019-01-24 18:00:29,803 REQUEST: 5330 0100 3200 01 0c13 011812001d 00320631320631320631ffffffffffffffffffffffffffffffffffffffffffffffffffffff00ffffffff3725
2019-01-24 18:00:30,128 RESPONSE: Received from server: 5330 0000 0200 4f4b 1c05
```
