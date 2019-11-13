/*
 __      __  ______   ___    ______             ______
 \ \    / / |  ____| |__ \  |___  /     /\     |___  /
  \ \  / /  | |__       ) |    / /     /  \       / / 
   \ \/ /   |  __|     / /    / /     / /\ \     / /  
    \  /    | |____   / /_   / /__   / ____ \   / /__ 
     \/     |______| |____| /_____| /_/    \_\ /_____|

Si5351 Synthesizer QRSS Xsmitter 
by Bert-VE2ZAZ - ve2zaz at rac dot ca - website: ve2zaz.net
Version 0.1, December 2019
Designed to compile on Arduino IDE for an Arduino Nano or Uno board
The Jason Mildrum's Etherkit Si5351Arduino library must be installed in the Arduino IDE prior to compiling this sketch.
*/

#include "si5351.h"
#include "Wire.h"
#include <string.h>
#include <EEPROM.h>
#include <stdlib.h>

// Constantes
#define TX_LED 11                  // Transmit LED pin

Si5351 si5351;                     // Jason Mildrum's Etherkit Si5351Arduino library

// Global Variables 
unsigned char        TxStr_pos;
unsigned char        command;
unsigned char        RxChar;
unsigned char        RxStr[500];   // Receive buffer string array that stores the configuration data until it is transferred to EEPROM. 
                                     // No choice using this as an EEPROM byte write takes more than 3 ms.
unsigned int         ctr = 0;
unsigned int         commandCtr = 0;
char                 TempChar;     // This variable must be a char, not an unsigned char.
unsigned int         TempInt;
String               TempStr;
unsigned long long   param1; 
unsigned long long   param2;
unsigned long long   param3;
unsigned int         DitDuration = 5000;
unsigned int         FastDitDuration = 70;
bool                 EnableFastCWID = true;
byte                 QRSSType = 0;
bool                 SendFastCWID  = false;
unsigned int         FSKFreqShift = 10;
unsigned long long   TxFrequency;
byte                 Tx_String_Data[150];    // Pixel data for up to 30 characters sent in MFSK-text mode.
unsigned int         PixelDuration = 1000;
String               Tx_String = "NOCALL";
unsigned char        Tx_Text_String_Length = 0;
unsigned int         param1_Int;
String               param1_Str;

// Morse Code Character Library
char* MorseCode[] = 
{
  ".-",     // A
  "-...",   // B
  "-.-.",   // C
  "-..",    // D
  ".",      // E
  "..-.",   // F
  "--.",    // G
  "....",   // H
  "..",     // I
  ".---",   // J
  "-.-",    // K
  ".-..",   // L
  "--",     // M
  "-.",     // N
  "---",    // O
  ".--.",   // P
  "--.-",   // Q
  ".-.",    // R
  "...",    // S
  "-",      // T
  "..-",    // U
  "...-",   // V
  ".--",    // W
  "-..-",   // X
  "-.--",   // Y
  "--.."    // Z
};

// Morse Code Number Library
char* Numbers[] = 
{
  "-----",   // 0
  ".----",   // 1
  "..---",   // 2
  "...--",   // 3
  "....-",   // 4
  ".....",   // 5
  "-....",   // 6
  "--...",   // 7
  "---..",   // 8
  "----."    // 9
};

  // Function that checks whether a string contains non-numerical characters 
bool IsNonNumericString(String param_string)
{
char stringLength;
char i;
  stringLength = param_string.length();
  for(i = 0; i < stringLength; ++i) 
  {
    if ((!isDigit(param_string.charAt(i))) && (param_string.charAt(i) != '.')) break;    // Only '0' to '9', and '.' accepted 
  }
  if (i == stringLength) return false;
  else return true;
}

// Conversion Fonction from String to Unigend Long-Long (64 bits). Required for the Si5351 library.
unsigned long long convert_str_to_ULL(String InString)
{
unsigned long long  OutULL = 0;
  for (int i = 0; i < InString.length(); i++) 
  {
    char c = InString.charAt(i);
    if (c < '0' || c > '9') break;
    OutULL *= 10;
    OutULL += (c - '0');
  }
  return OutULL;
}

//Converts a string representing two hex digits into a number  
byte convert_hexstr_to_char(String InString)
{
  byte tens = (InString[0] <= '9') ? InString[0] - '0' : InString[0] - '7';
  byte ones = (InString[1] <= '9') ? InString[1] - '0' : InString[1] - '7';
  byte number = (16 * tens) + ones;
  return number;
}

// This function sends a complete CW message, in both the QRSS and the fast modes
void Send_CW_Mess(int ditdelay)
{
  char TxCharacter;
  TxStr_pos = 0;
  si5351.output_enable(SI5351_CLK0, 1);     // Turn on the RF output at the beginning of the message regardless of situation
  digitalWrite(TX_LED,HIGH);
  while (TxStr_pos < sizeof(Tx_String))     // Scan through the whole character string
  {
    TxCharacter = Tx_String[TxStr_pos];
    Serial.print(TxCharacter);
     // Letters
    if (TxCharacter >= 'A' && TxCharacter <= 'Z') {
      // Call the Character element then apply morse code decoder
      SendCharacter(MorseCode[TxCharacter - 'A'],ditdelay);
    }
     // Numbers
    else if (TxCharacter >= '0' && TxCharacter <= '9') {
      // Call Number's Element then apply morse code decoder
      SendCharacter(Numbers[TxCharacter - '0'],ditdelay);
    }
     // Spacial character cases
    else if (TxCharacter == '/') 
    {
      SendCharacter("-..-.",ditdelay);
      delay(ditdelay*3);
    }  
    else if (TxCharacter == ' ') 
    {
      delay(ditdelay*3);
    }  
    TxStr_pos++;    
    Serial.print(" ");
  }
  si5351.output_enable(SI5351_CLK0, 0); // Turn off output at the end of the message regardless of situation
  digitalWrite(TX_LED,LOW);
  Serial.print("\n");
}

// Sends a single Morse code character
void SendCharacter (char* Character,int ditdelay) 
{
  char i = 0;
  while (Character[i] != '\0') SendDitDah(Character[i++],ditdelay);   // Arrays have \0 at their end. 
  delay(ditdelay*3);    // Delay between every character
}

// Sends Dit or Dah Morse code element 
void SendDitDah (char DitDah_data,int ditdelay) 
{
    // Turn LED and Si5351 Output ON
  digitalWrite(TX_LED,HIGH);
  if ((QRSSType == 1) && (!SendFastCWID)) si5351.set_freq(TxFrequency, SI5351_CLK0);      // In FSK CW, set the main carrier frequency, no shift
  else si5351.output_enable(SI5351_CLK0, 1);     // In ASK CW, turn on the main carrier frequency
  Serial.print(DitDah_data);
  if (DitDah_data == '.') delay(ditdelay);    // Dit
  else if (DitDah_data == '-') delay(ditdelay*3);    // Dah
    // Turn LED and Si5351 Output off
  if ((QRSSType == 1) && (!SendFastCWID)) si5351.set_freq(TxFrequency-(FSKFreqShift*100), SI5351_CLK0);    // In FSK CW, set the shifted main carrier frequency
  else si5351.output_enable(SI5351_CLK0, 0);    // In ASK CW, turn off the main carrier frequency
  digitalWrite(TX_LED, LOW);
  delay(ditdelay);    //Delay before the following dit/dah
}

// Sends an entire text message made of pixels
void Send_Text_Mess()
{
  unsigned char i;
  unsigned char k;
  unsigned char bitmask;
  
  for (i=0; i < 5*Tx_Text_String_Length; i++)   // will scan through the pixel data, one column at a time (5 columns per character)
  {
    bitmask = 0b00000001;    // Used to isolate each bit (pixel) from a byte
    for (k=0; k < 8; k++)    // 8 pixels per column
    {
      if ((Tx_String_Data[i] & bitmask) != 0)    // If there is a pixel to send
      {
        si5351.set_freq(TxFrequency+(FSKFreqShift * k) * 100, SI5351_CLK0);    //  Apply the proper frequency shift based on pixel position
        si5351.output_enable(SI5351_CLK0, 1);    // Turn on transmitter
        digitalWrite(TX_LED, HIGH);
      }
      else     // If there is no pixel to send
      {
        si5351.output_enable(SI5351_CLK0, 0);    // Turn off transmitter
        digitalWrite(TX_LED, LOW);
      }
      bitmask = bitmask<<1;    // Shift bitmask left by one bit to isolate next pixel
      delay(PixelDuration);
    }
    if ((i+1) % 5 == 0)     // Five columns per character
    {
      si5351.output_enable(SI5351_CLK0, 0);   // Turn off transmitter for Inter-character spacing
      delay(PixelDuration*10);  
    }
  }
}

// Parameter Transfer from the RAM (received string from PC program) to EEPROM
void Write_RxString_to_EEPROM(int length)
{
  for (int i = 0; i < length ; i++) EEPROM.write(i,RxStr[i]);   
}

// Function that reads and parses parameters that follow a command that affects the Si5351. Read from EEPROM memory
void parse_params_from_EEPROM_commands()
{
  TempStr = "";
  while (1)   
  {   // First parameter
    TempChar = char(EEPROM.read(ctr++)); 
    if (TempChar != '|' && TempChar != ',') TempStr = TempStr + TempChar;  // 
    else    // Caractère de séparation de champ détecté
    {
      param1 = convert_str_to_ULL(TempStr);   // Conversion en format ULL (64 bits non signés)
      break;    // Sortie de la boucle 
    }    
  }
  TempStr = "";
  while (TempChar != '|')   
  {   // Second parameter, if necesary
    TempChar = char(EEPROM.read(ctr++)); 
    if (TempChar != '|' && TempChar != ',') TempStr = TempStr + TempChar;  // 
    else     // Caractère de séparation de champ détecté
    {
      param2 = convert_str_to_ULL(TempStr);   // Conversion en format ULL (64 bits non signés)
      break;    // Sortie de la boucle 
    }    
  }

  TempStr = "";
  while (TempChar != '|')   
  {   // Third parameter, if necesary
    TempChar = char(EEPROM.read(ctr++)); 
    if (TempChar != '|' && TempChar != ',') TempStr = TempStr + TempChar;  // 
    else     // Caractère de séparation de champ détecté
    {
      param3 = convert_str_to_ULL(TempStr);   // Conversion en format ULL (64 bits non signés)
      break;    // Sortie de la boucle 
    }    
  }
}

// Function that reads and parses parameters that follow a command that affects a variable. Read from EEPROM memory
void parse_params_from_EEPROM_vars()
{
  TempStr = "";
  while (1)   
  {   // Premier paramètre
    TempChar = EEPROM.read(ctr++); //char(EEPROM.read(ctr))
    if (TempChar != '|' && TempChar != ',') TempStr = TempStr + TempChar;    //  Concatenate the characters until the end of parameter or end of command symbols are detected.
    else    // End of parameter or end of command symbol detected. Treat the parameter
    {
      if (IsNonNumericString(TempStr)) param1_Str = TempStr;   // In the case that the parameter is a string
      else param1_Int = TempStr.toInt();   // In the case that the parameter is a numerical value
      break;    // Exit from the loop 
    }    
  }
}  
  
// Function that transfers the Si5351 configuration data from EEPROM to the Si5351 using library commands. 
// It also transfers some other configuration values to local variables. 
void Send_Commands_From_EEPROM_to_Si5351_and_Vars()
{
  unsigned int i;

  ctr = 1;    // Skip the "$" in position 0 of EEPROM. This is the "begininng of transfer" character.
  while (1)    // Uses a "break" command to leave the loop
  {
    TempChar = char(EEPROM.read(ctr));  // Read one character from EEPROM
    if (TempChar == '%') break;         // % is "End of transfer" character. Leave this loop
    ctr = ctr + 2;                      // Skip "begininng of transfer" character and the comma character that follows it
    command = TempChar;                 // Read the command
    if ((command >= '0') && (command <= '9')) parse_params_from_EEPROM_commands();       // When it is a number command. Will affect Si5351
  else if (command != 'G') parse_params_from_EEPROM_vars();                              // When it a letter command othe than the 'G' command. Will affect some of the sketch variables
    if (command == '1') si5351.init(param1, param2, param3);             // Command INIT
    else if (command == '2') si5351.set_pll_input(param1, param2);       // SET_PLL_INPUT Command
    else if (command == '3') si5351.set_ref_freq(param1, param2);        // SET_REF_FREQ Command
    else if (command == '4') si5351.set_correction(param1, param2);      // SET_CORRECTION Command
    else if (command == '5')                                             // SET_FREQ Command
    {
      si5351.set_freq(param1, param2);    
      TxFrequency = param1;
    }
    else if (command == '6') si5351.output_enable(param1, param2);       // OUTPUT_ENABLE Command
    else if (command == '7') si5351.drive_strength(param1, param2);      // DRIVE_STRENGTH Command
    else if (command == '8') si5351.set_clock_invert(param1, param2);    // SET_CLOCK_INVERT Command
    else if (command == '9') si5351.pll_reset(param1);                   // PLL_RESET Command
    else if (command == 'A') Tx_String = param1_Str;                     // Tx_String variable
    else if (command == 'B') DitDuration = param1_Int;                   // DitDuration variable 
    else if (command == 'C') FastDitDuration = param1_Int;               // FastDitDuration variable
    else if (command == 'D') EnableFastCWID = param1_Int;                // EnableFastCWID variable
    else if (command == 'E') QRSSType = param1_Int;                      // QRSSType variable
    else if (command == 'F') FSKFreqShift = param1_Int;                  // FSKFreqShift variable
    else if (command == 'G')     // The G command has special formatting, a series of hex bytes representing the series of pixels that make the QRSS text
    {
      for (i=0; i < 5*Tx_Text_String_Length; i++)    // Parse all pixel column data, 5 columns per character
      {
    TempStr = "";
        TempStr += char(EEPROM.read(ctr++));  // Read one caracter from EEPROM
        TempStr += char(EEPROM.read(ctr++));  // Read one caracter from EEPROM, concatenate to make both caracters the hex byte
        Tx_String_Data[i] = convert_hexstr_to_char(TempStr);  // must be converted to a numerical value before saving
      }
      ctr++;    // Position to next hex character
    }
    else if (command == 'H') PixelDuration = param1_Int;                 // PixelDuration variable
    else if (command == 'I') Tx_Text_String_Length  = param1_Int;        // Tx_Text_String_Length variable
  }
 }

// Arduino'd setup function, run only once at startup
void setup()
{
  Serial.begin(1200);         // Open serial port (USB) at 1200 bps.
  pinMode(TX_LED, OUTPUT);    // Transmit LED pin definition 
  Serial.print("R");          // send the "reset completed" character to PC program
  Serial.flush();             // flush out the serial port transmit buffer
  delay(1000);                // wait for parameters for 1 second. If nothing, carry on with config from EEPROM
  if (Serial.available()>0)   // Any Caracter available in the Serial port receive buffer?
  {        // Yes
    RxChar = Serial.read();     // Read one character
    if (RxChar == '$')          // Is it the $ "beginning of configuration" character?
    {      // Yes
      RxStr[0] = RxChar;      // Store that character in the receive string array
      ctr = 1;                // Set the position counter to position 1
      while (RxChar != '%')    // Loop while the % "end of configuration" character is not detected
      {
        if (Serial.available()>0)     // Any Caracter available in the Serial port receive buffer?
        {     // Oui
          RxChar = Serial.read();     // Read one character
          RxStr[ctr++] = RxChar;        // Store that character in the receive string array and then Increment the position counter
        }
      }
      Serial.print("O");      // End of transmission detected. Advise PC program that all parameters were received
      Serial.flush();
      // Sauvegarder les commands et paramtransfer the received string array to EEPROM memory to make it permanent
      Write_RxString_to_EEPROM(ctr);   //            
      Serial.print("E");    // Advise PC program that all parameters were saved to EEPROM memory
      Serial.flush();       // flush out the serial port transmit buffer
    }
  }
  if (char(EEPROM.read(0)) == '$') Send_Commands_From_EEPROM_to_Si5351_and_Vars();   // Transfer parameters from EEPROM to Si5151 to configure it if there is valid data. Also configure some variables using the EEPROM data.
  Serial.print("S");        // Advise PC program that the transfer and configuration process is completed        
  Serial.flush();           // flush out the serial port transmit buffer
  delay(500);               // Pause 500 ms before starting loop execution.
}

// Arduino's main loop. QRSS transmission is managed here 
void loop()
{
  if (Tx_String != "NOCALL")  // Checks that there is valid configuration data received, otherwise does not send anything.
  {
    if (QRSSType == 2)        // MFSK-Text mode
    {
      Send_Text_Mess();
      delay(DitDuration*10);    // Empty space after QRSS Text message is sent
    }
    else                      // CW modes
    {  
        // sending QRSS CW message
      Serial.print("QRSS: ");
      Send_CW_Mess(DitDuration);
      delay(DitDuration*6);     // Empty space after QRSS message is sent   
    }
      // sending fast CW ID
    if (EnableFastCWID == true)
    {
      Serial.print("Fast: ");
      SendFastCWID = true;      // flag used to tell the Send_CW_Mess and other called functions that it has to be a fast CW
      Send_CW_Mess(FastDitDuration);
      SendFastCWID = false;
    }
    delay(DitDuration*6);     // Added space at the end of transmission    
  }
}
