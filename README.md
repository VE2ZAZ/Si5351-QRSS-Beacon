# Si5351-QRSS-Beacon Software

Please see the [Help.html]( http://htmlpreview.github.com/?https://github.com/VE2ZAZ/Si5351-QRSS-Beacon/blob/master/Help.html) file for all the details.

This software allows to configure Silicon Laboratories Si5351A/C Synthesizer chips for QRSS beacon transmission, when supervised by an Arduino Uno or Nano board. After the Arduino has received a configuration from the software, it will re-load the Si5351 chip with that same configuration at every power up or reset. The Arduino (properly configured by this software) is required, as the Si5351 chip does not retain its configuration when power is removed; it must be re-configured at power up.

This software was written in FreePascal programming language within the Lazarus IDE. Being a cross-platform compiler, the executable can be made to run in any Linux, Windows or Mac OS environment when compiled in that environment. See the "Prerequisites and Installation" section below for more details specific to the operating system you are running.

This software was developed on the VE2ZAZ synthesizer board hosting an Arduino-nano and an Si5351C Clock Synthesizer chip. The board can alternately be equipped with the Chinese-made Si5351A board. The main difference between the A and C versions of the Si5351 is that the C version can lock to an external frequency reference between 10 and 40 Mhz (useable down to 5 MHz). All produced output frequencies are then PLL-locked to that reference. The A version relies solely on the accompanying on-board 25 or 27 MHz crystal for its reference. Another advantage of the VE2ZAZ board is that it includes an external reference scaling/shaping circuit, which provides the proper amplitude to the Si5351C, regardless of the shape or amplitude of the input signal.

Note that this software is not designed to run exclusively on the VE2ZAZ Synthesizer board. As a minimum, one can build this beacon on a solderless prototype board using an Arduino Nano, an off-the-shelf Si5351A board, and and I2C line conversion circuit, also available off-the-shelf. External +5V and +3.3V supplies are required. See the VE2ZAZ's Si5351A/C Synthesizer board Circuit Schematic.

The software offers three QRSS transmit modes:
* ASK-CW, which is more or less regular CW, but stretched in time.
* FSK-CW, which is an always-on mode using frequency shifting to differientate between dits/dahs and silences.
* MFSK-Text, which uses multiple tone frequencies to encode a text message's pixels. 

Among available settings, the Morse code 'dit' duration, the FSK frequency shift and the external reference frequency can be set. An optional fast CW identification can be inserted after each transmission cycle, so that anyone can decode who is sending the tones, without the need of waterfall display capabilities. 

This software, along with all accompanying files and scripts, is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>. When modifying the software, a mention of the original author, namely Bert-VE2ZAZ, would be a gracious consideration.
