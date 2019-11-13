unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, LazSerial, StrUtils, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    CALLSIGN: TEdit;
    Dit_Duration_Label3: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Output_Power: TRadioGroup;
    Shape4: TShape;
    Text_String: TEdit;
    Dit_Duration_Label1: TLabel;
    Dit_Duration: TFloatSpinEdit;
    Dit_Duration_Label2: TLabel;
    Fast_Dit_Duration: TFloatSpinEdit;
    About_Button: TButton;
    Pixel_Duration: TFloatSpinEdit;
    Ref_Frequency: TFloatSpinEdit;
    QRSS_Type: TRadioGroup;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    SubTitle_Label: TLabel;
    TxFreq_Label1: TLabel;
    TX_Frequency: TFloatSpinEdit;
    Frequency_Offset: TLabel;
    Frequency_Offset1: TLabel;
    Insert_CWID: TCheckBox;
    TxFreq_Label: TLabel;
    CWMsg_Panel: TPanel;
    Freq_panel: TPanel;
    TxCallsign_Label: TLabel;
    Ref_Select: TRadioGroup;
    Dit_Duration_Label: TLabel;
    Title_Label: TLabel;
    LazSerial1: TLazSerial;
    Message_Memo: TMemo;
    Transfer_Button: TButton;
    Quit_Button: TButton;
    SerialPort_Edit: TEdit;
    Freq_Offset: TFloatSpinEdit;
    Freq_Shift: TFloatSpinEdit;
    procedure About_ButtonClick(Sender: TObject);
    procedure Form1_Destroy(Sender: TObject);
    procedure Form1_Created(Sender: TObject);
    procedure Insert_CWIDChange(Sender: TObject);
    procedure QRSSTypeClick(Sender: TObject);
    procedure Transfer_ButtonClick(Sender: TObject);
//    procedure successMsg(mess:ANSIString);
  private

  public

  end;

const
  // This table lists the Morse Code characters available in Arduino. Allows to check the callsign before sending it to Arduino.
MORSECODE_TABLE : array[0..37] of Char = (
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '/',
    ' '
);

  // This table lists the Text message characters available for sending as pixels. Each character position in this table maps
  // to its pixel data in the CHAR_DATA_TABLE table.
CHAR_TABLE : array[0..48] of Char = (
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    '?',
    '!',
    '@',
    '#',
    '&',
    '(',
    ')',
    '+',
    '-',
    '=',
    '/',
    ' ',
    '.'
);

  // Character pixel data for each character listed in the CHAR_TABLE table. Each byte of a line corresponds to the vertical pixel positions,
  // 1 is a dot, 0 is no dot. 5 bytes code 5 vertical lines for each character
CHAR_DATA_TABLE : array[0..244] of Byte = (
    $7F, $88, $88, $88, $7F,           // Corresponds to CHAR_TABLE character  'A',
    $FF, $91, $91, $91, $6E,           // Corresponds to CHAR_TABLE character  'B',
    $7E, $81, $81, $81, $42,           // Corresponds to CHAR_TABLE character  'C',
    $FF, $81, $81, $42, $3C,           // Corresponds to CHAR_TABLE character  'D',
    $FF, $91, $91, $91, $81,           // Corresponds to CHAR_TABLE character  'E',
    $FF, $90, $90, $90, $80,           // Corresponds to CHAR_TABLE character  'F',
    $7E, $81, $89, $89, $4E,           // Corresponds to CHAR_TABLE character  'G',
    $FF, $10, $10, $10, $FF,           // Corresponds to CHAR_TABLE character  'H',
    $81, $81, $FF, $81, $81,           // Corresponds to CHAR_TABLE character  'I',
    $06, $01, $01, $01, $FE,           // Corresponds to CHAR_TABLE character  'J',
    $FF, $18, $24, $42, $81,           // Corresponds to CHAR_TABLE character  'K',
    $FF, $01, $01, $01, $01,           // Corresponds to CHAR_TABLE character  'L',
    $FF, $40, $30, $40, $FF,           // Corresponds to CHAR_TABLE character  'M',
    $FF, $40, $30, $08, $FF,           // Corresponds to CHAR_TABLE character  'N',
    $7E, $81, $81, $81, $7E,           // Corresponds to CHAR_TABLE character  'O',
    $FF, $88, $88, $88, $70,           // Corresponds to CHAR_TABLE character  'P',
    $7E, $81, $85, $82, $7D,           // Corresponds to CHAR_TABLE character  'Q',
    $FF, $88, $8C, $8A, $71,           // Corresponds to CHAR_TABLE character  'R',
    $61, $91, $91, $91, $8E,           // Corresponds to CHAR_TABLE character  'S',
    $80, $80, $FF, $80, $80,           // Corresponds to CHAR_TABLE character  'T',
    $FE, $01, $01, $01, $FE,           // Corresponds to CHAR_TABLE character  'U',
    $F0, $0C, $03, $0C, $F0,           // Corresponds to CHAR_TABLE character  'V',
    $FF, $02, $0C, $02, $FF,           // Corresponds to CHAR_TABLE character  'W',
    $C3, $24, $18, $24, $C3,           // Corresponds to CHAR_TABLE character  'X',
    $E0, $10, $0F, $10, $E0,           // Corresponds to CHAR_TABLE character  'Y',
    $83, $85, $99, $A1, $C1,           // Corresponds to CHAR_TABLE character  'Z',
    $00, $41, $FF, $01, $00,           // Corresponds to CHAR_TABLE character  '1',
    $43, $85, $89, $91, $61,           // Corresponds to CHAR_TABLE character  '2',
    $42, $81, $91, $91, $6E,           // Corresponds to CHAR_TABLE character  '3',
    $18, $28, $48, $FF, $08,           // Corresponds to CHAR_TABLE character  '4',
    $F2, $91, $91, $91, $8E,           // Corresponds to CHAR_TABLE character  '5',
    $1E, $29, $49, $89, $86,           // Corresponds to CHAR_TABLE character  '6',
    $80, $8F, $90, $A0, $C0,           // Corresponds to CHAR_TABLE character  '7',
    $6E, $91, $91, $91, $6E,           // Corresponds to CHAR_TABLE character  '8',
    $70, $89, $89, $8A, $7C,           // Corresponds to CHAR_TABLE character  '9',
    $7E, $89, $91, $A1, $7E,           // Corresponds to CHAR_TABLE character  '0',
    $60, $80, $8D, $90, $60,           // Corresponds to CHAR_TABLE character  '?',
    $00, $00, $FD, $00, $00,           // Corresponds to CHAR_TABLE character  '!',
    $66, $89, $8F, $81, $7E,           // Corresponds to CHAR_TABLE character  '@',
    $24, $FF, $24, $FF, $24,           // Corresponds to CHAR_TABLE character  '#',
    $76, $89, $95, $62, $05,           // Corresponds to CHAR_TABLE character  '&',
    $00, $3C, $42, $81, $00,           // Corresponds to CHAR_TABLE character  '(',
    $00, $81, $42, $3C, $00,           // Corresponds to CHAR_TABLE character  ')',
    $08, $08, $3E, $08, $08,           // Corresponds to CHAR_TABLE character  '+',
    $08, $08, $08, $08, $08,           // Corresponds to CHAR_TABLE character  '-',
    $14, $14, $14, $14, $14,           // Corresponds to CHAR_TABLE character  '=',
    $04, $08, $10, $20, $40,           // Corresponds to CHAR_TABLE character  '/',
    $00, $00, $00, $00, $00,           // Corresponds to CHAR_TABLE character  ' ',
    $00, $03, $03, $00, $00            // Corresponds to CHAR_TABLE character  '.',
    );


var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

  // Displays a success or information message in the status box.
procedure successMsg(mess:ANSIString);
begin
     Form1.Message_Memo.Font.Color := TColor($023700);   // Green text
     Form1.Message_Memo.Lines.Add(mess);
     Application.ProcessMessages;          // Refreshes the screen
end;

  // Displays an error message in the status box and re-enables the various components that were disabled during the config transfer.
procedure errorMsg(mess:ANSIString);
begin
     Form1.Message_Memo.Font.Color := clRed;     // Red text;
     Form1.Message_Memo.Lines.Add(mess);
     Application.ProcessMessages;          // Refreshes the screen
     Form1.Transfer_Button.Enabled := True;
     Form1.SerialPort_Edit.Enabled := True;
     Form1.Quit_Button.Enabled := True;
     Form1.About_Button.Enabled := True;
     Form1.Freq_panel.Enabled := True;
     Form1.CWMsg_Panel.Enabled := True;
end;

  // Program launch
procedure TForm1.Form1_Created(Sender: TObject);
var
   tempString: string;
   settings_File: TextFile ;

begin    // Display the welcome message
    successMsg('Welcome to the Si5351A/C QRSS Transmitter (Beacon) Configuration Software, Version 0.1, December 2019. Author: Bert, VE2ZAZ, (ve2zaz at rac dot ca)');
    successMsg('Please note that the settings shown are retrieved from the last session, not from the ATmega processor EEPROM.');

      // Retrieving the previously-saved parameters from the text file
    AssignFile(settings_File,'saved_settings.cfg');
    Try
       Reset(settings_File);
       Readln(settings_File,tempString);
       Ref_Select.ItemIndex := StrToInt(tempString);
       Readln(settings_File,tempString);
       TX_Frequency.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Freq_Offset.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Ref_Frequency.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Insert_CWID.Checked := StrToBool(tempString);
       Readln(settings_File,tempString);
       CALLSIGN.Text := tempString;
       Readln(settings_File,tempString);
       Dit_Duration.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Fast_Dit_Duration.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       SerialPort_Edit.Text := tempString;
       Readln(settings_File,tempString);
       Form1.top := StrToInt(tempString);
       Readln(settings_File,tempString);
       Form1.left := StrToInt(tempString);
       Readln(settings_File,tempString);
       QRSS_Type.ItemIndex := StrToInt(tempString);
       Readln(settings_File,tempString);
       Freq_Shift.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Text_String.Text :=  tempString;
       Readln(settings_File,tempString);
       Pixel_Duration.Value := StrToFloat(tempString);
       Readln(settings_File,tempString);
       Output_Power.ItemIndex := StrToInt(tempString);
       CloseFile(settings_File);
    Except
          on E: EInOutError do      // missing or inaccessible settings file
          ErrorMsg('Error! Software cannot retrieve its window settings. Reverting to default parameter values.');
    end;

end;

  // Invoked when the Fast CW ID check mark is changed. Changes accessibility of the CW duration field.
procedure TForm1.Insert_CWIDChange(Sender: TObject);
begin
    case Insert_CWID.Checked of
    True:    Fast_Dit_Duration.Enabled := True;
    False:   Fast_Dit_Duration.Enabled := False;
    end;
end;

  // Invoked when the QRSS mode is changed. Changes accessibility of the various components based on the QRSS mode selected.
procedure TForm1.QRSSTypeClick(Sender: TObject);
begin
     case QRSS_Type.ItemIndex of
     0:  begin     // ASK CW
              Freq_Shift.Enabled := False;
              Text_String.Enabled := False;
              Pixel_Duration.Enabled := False;
              Dit_Duration.Enabled := True;
         end;
     1:  begin     // FSK CW
              Freq_Shift.Enabled := True;
              Text_String.Enabled := False;
              Pixel_Duration.Enabled := False;
               Dit_Duration.Enabled := True
         end;
     2:  begin     // MFSK Text
              Freq_Shift.Enabled := True;
              Text_String.Enabled := True;
              Pixel_Duration.Enabled := True;
              Dit_Duration.Enabled := False
         end;
     end;
end;

  // When the Transfer button is clicked. This is the configuration transfer to the Arduino, the main task of this program!
procedure TForm1.Transfer_ButtonClick(Sender: TObject);
var       RXchar : string;
          TxStr: AnsiString;
          message_length : Integer;
          string_data : array[0..149] of Byte;
          failed_lookup : Boolean;
          i : integer;
          j : integer;
          k : integer;
          h : integer;

const
// Constant definitions related to the Si5351 library
          SI5351_CLK_SRC_XTAL	=	'0';
          SI5351_CLK_SRC_CLKIN	=	'1';
          SI5351_PLL_INPUT_XO	=	'0';
          SI5351_PLL_INPUT_CLKIN	=	'1';
          SI5351_CRYSTAL_LOAD_0PF = '0';
          SI5351_PLLA	=	'0';
          SI5351_CLK0	=	'0';
//Constant definitions that identify the Si5351 library commands and other commands sent to Arduino.
          INIT = '1';
          SET_PLL_INPUT = '2';
          SET_REF_FREQ = '3';
          SET_CORRECTION = '4';
          SET_FREQ = '5';
          OUTPUT_ENABLE = '6';
          DRIVE_STRENGTH = '7';
          SET_CLOCK_INVERT = '8';
          PLL_RESET = '9';
          Call_Sign = 'A';
          DitDuration = 'B';
          FastDitDuration = 'C';
          EnableFastCWID = 'D';
          QRSSType = 'E';
          FSKFreqShift = 'F';
          TextPixelData = 'G';
          TextPixelDuration = 'H';
          TextStringLength = 'I';

begin
       // Disable the various components during configuration transfer to Arduino.
     Form1.Transfer_Button.Enabled := False;
     Form1.SerialPort_Edit.Enabled := False;
     Form1.Quit_Button.Enabled := False;
     Form1.About_Button.Enabled := False;
     Form1.Freq_panel.Enabled := False;
     Form1.CWMsg_Panel.Enabled := False;
     Form1.Message_Memo.Lines.text := '';
     LazSerial1.Device := SerialPort_Edit.Text;

     // Convert callsign and Text message to uppercase
     CALLSIGN.Text := AnsiUpperCase(CALLSIGN.Text);
     Text_String.Text := AnsiUpperCase(Text_String.Text);
     Application.ProcessMessages;       // Update the form

     // Check contents of the CW message against valid characters from the Morse code character table.
     for i := 1 to (Length(Form1.CALLSIGN.Text)) do         // Must skip character [0]
     begin
           for j := 0 to (sizeof(MORSECODE_TABLE)-1) do
               if Form1.CALLSIGN.Text[i] = MORSECODE_TABLE[j] then
               begin
                    failed_lookup := False;
                    Break;
               end
               else  failed_lookup := True;
           if (failed_lookup = True) then
           begin
                ErrorMsg('Error! The QRSS/CW ID Callsign field contains non-useable characters. Verify the syntax.');
                exit;
           end;
     end;

          // Check contents of the text message against valid characters from the text message character table.
     for i := 1 to (Length(Form1.Text_String.Text)) do         // Must skip character [0]
     begin
           for j := 0 to (sizeof(CHAR_TABLE)-1) do
               if Form1.Text_String.Text[i] = CHAR_TABLE[j] then
               begin
                    failed_lookup := False;
                    Break;
               end
               else  failed_lookup := True;
           if (failed_lookup = True) then
           begin
                ErrorMsg('Error! The QRSS Text field contains non-useable characters. Verify the syntax.');
                exit;
           end;
     end;

     // Produce the character data (bitmap) when that mode is selected
     if  QRSS_Type.ItemIndex = 2 then
     begin
          message_length := Length(Form1.Text_String.Text);
          h := 0;
          for  i := 1 to (message_length) do               // position 0 has an empty character. Must skip.
          begin
               j := 0;
                while (CHAR_TABLE[j] <> Form1.Text_String.Text[i]) and (j < sizeof(CHAR_TABLE)) do Inc(j);
                for  k := 0 to 4 do          //Index of the data in the data table
                begin
                     string_data[h] :=  CHAR_DATA_TABLE[j*5 + k];
                     Inc(h);
                end;
          end;
     end;

     // Check if serial port is available
     try
        LazSerial1.open;
     except
           On E :Exception do
           begin
                ErrorMsg('Error! Serial port is unavailable or not present. Verify port naming.');
                exit;
           end;
     end;
     successMsg('-----------------------------------------'#10'Configuration Transfer Initiated...');
     while (LazSerial1.DataAvailable) do RXchar := LazSerial1.ReadData;               //   Empty the Rx buffer
     try
//       Sleep(1000);
       repeat
             RXchar := LazSerial1.ReadData; //
             if RXchar = 'R' then successMsg('Processor reset completed'); //Message_Memo.Lines.Add('Processor reset completed');
       until RXchar = 'R';
       successMsg('Transferring Configuration Data...');
       LazSerial1.WriteData('$');
       TxStr := INIT + ',' + SI5351_CRYSTAL_LOAD_0PF + ',' + FloatToStr(Ref_Frequency.Value) + ',' + FloatToStr(Freq_Offset.Value*1000) + '|';
       LazSerial1.WriteData(TxStr);
       Sleep(500);			             //  This Pause is required for the Arduino to swallow all the characters before its Rx buffer gets full
       if Ref_Select.ItemIndex = 0 then	             //  Configuration when the crystal is the timing source
       begin
            TxStr := SET_PLL_INPUT + ',' + SI5351_PLLA + ',' + SI5351_PLL_INPUT_XO + '|';
            LazSerial1.WriteData(TxStr);
       end
       else if Ref_Select.ItemIndex = 1 then               // Configuration when the external reference is the timing source
       begin
            TxStr := SET_REF_FREQ + ',' + FloatToStr(Ref_Frequency.Value) + ',' + SI5351_PLL_INPUT_CLKIN + '|';
            LazSerial1.WriteData(TxStr);
            TxStr := SET_PLL_INPUT + ',' + SI5351_PLLA + ',' + SI5351_PLL_INPUT_CLKIN + '|';
            LazSerial1.WriteData(TxStr);
       end;
       Sleep(500);			// This Pause is required for the Arduino to swallow all the characters before its Rx buffer gets full
       // Output 0 configuration
       TxStr := SET_FREQ + ',' + FloatToStr(TX_Frequency.Value*100)  + ',' + SI5351_CLK0 + '|';
       LazSerial1.WriteData(TxStr);
       TxStr := DRIVE_STRENGTH + ',' + SI5351_CLK0  + ',' + IntToStr(Output_Power.ItemIndex) + '|';
       LazSerial1.WriteData(TxStr);
       // Other parameters, callsign and Dit durations transfer
       TxStr := Call_Sign + ',' + CALLSIGN.Text + '|';
       LazSerial1.WriteData(TxStr);
       TxStr := DitDuration + ',' + Dit_Duration.Text + '|';
       LazSerial1.WriteData(TxStr);
       Sleep(500);			// This Pause is required for the Arduino to swallow all the characters before its Rx buffer gets full
       TxStr := FastDitDuration + ',' + Fast_Dit_Duration.Text + '|';
       LazSerial1.WriteData(TxStr);
       TxStr := EnableFastCWID + ',' + IfThen(Insert_CWID.Checked,'1','0') + '|';
       LazSerial1.WriteData(TxStr);
       TxStr := QRSSType + ',' + IntToStr(QRSS_Type.ItemIndex) + '|';
       LazSerial1.WriteData(TxStr);
       TxStr := FSKFreqShift + ',' + FloatToStr(Freq_Shift.Value) + '|';
       LazSerial1.WriteData(TxStr);
       if QRSS_Type.ItemIndex = 2 then          // Send Text data only when QRSS Text mode is selected.
       begin
            TxStr := TextPixelDuration + ',' + Pixel_Duration.Text + '|';
            LazSerial1.WriteData(TxStr);
            TxStr := TextStringLength + ',' + IntToStr(Length(Text_String.Text)) + '|';
            LazSerial1.WriteData(TxStr);
            Sleep(500);			// This Pause is required for the Arduino to swallow all the characters before its Rx buffer gets full
            TxStr :=  TextPixelData + ',';
            LazSerial1.WriteData(TxStr);
            k := 0;        // k will count the position of the pixel columns
            TxStr := '';
            for k := 0 to (5*Length(Text_String.Text)-1) do       // position 0 has an empty character. Must skip.
            begin
                     TxStr := HexStr(string_data[k],2);    // Add pixel column data to the transmitted string
                     LazSerial1.WriteData(TxStr);
                     Sleep(20);             // This Pause is required for the Arduino to swallow all the characters before its Rx buffer gets full
            end;
            TxStr := '|';
            LazSerial1.WriteData(TxStr);
       end;
         // Add the termination character
       LazSerial1.WriteData('%');
         // Validate the reception of the "Configuration data received" flag
       while not(LazSerial1.DataAvailable) do;         // Wait for a character
       RXchar := LazSerial1.ReadData; //
       if RXchar = 'O' then successMsg('Configuration data received by processor') //Message_Memo.Lines.Add('Processor reset completed');
       else begin
           ErrorMsg('Error! Software did not receive confirmation that the ATmega processor received the configuration data. Try again...');
           LazSerial1.close;
           exit;
       end;
       with Message_Memo do SelStart:=GetTextLen-1;     // move cursor to the end of memo
         // Validate the reception of the "Configuration saved to flash" flag
       while not(LazSerial1.DataAvailable) do;          // Wait for a character
       RXchar := LazSerial1.ReadData; //
       if RXchar = 'E' then successMsg('Configuration saved to the ATmega processor EEPROM') //Message_Memo.Lines.Add('Processor reset completed');
       else begin
              ErrorMsg('Error! Software did not receive confirmation that the configuration data was saved to the ATmega processor EEPROM. Try again...');
              LazSerial1.close;
	      exit;
       end;
       with Message_Memo do SelStart:=GetTextLen-1;     // move cursor at the end of memo
         // Validate the reception of the "Configuration data transferred to the Si5351" flag.
       while not(LazSerial1.DataAvailable) do;
       RXchar := LazSerial1.ReadData; //
       if RXchar = 'S' then successMsg('Configuration data transferred from the ATmega processor to the Si5351') //Message_Memo.Lines.Add('Processor reset completed');
       else begin
              ErrorMsg('Error! Software did not receive confirmation that the configuration data transferred from the ATmega processor to the Si5351. Try again...');
              LazSerial1.close;
	      exit;
       end;
       with Message_Memo do SelStart:=GetTextLen-1;     // move cursor at the end of memo
       successMsg('Configuration Success!');
       with Message_Memo do SelStart:=GetTextLen-1;     // move cursor at the end of memo
     finally;
     end;
     LazSerial1.close;
     // Re-enable the various components after configuration transfer to Arduino.
     Form1.Transfer_Button.Enabled := True;
     Form1.SerialPort_Edit.Enabled := True;
     Form1.Quit_Button.Enabled := True;
     Form1.About_Button.Enabled := True;
     Form1.Freq_panel.Enabled := True;
     Form1.CWMsg_Panel.Enabled := True;
end;

  // This is invoked when the program ends.
procedure TForm1.Form1_Destroy(Sender: TObject);

var
   settings_File: TextFile ;
begin
      // Saving the variious configuration values and window position for the next program launch.
    AssignFile(settings_File,'saved_settings.cfg');
     Try
        Rewrite(settings_File);
        Writeln(settings_File,IntToStr(Ref_Select.ItemIndex));
        Writeln(settings_File,FloatToStr(TX_Frequency.Value));
        Writeln(settings_File,FloatToStr(Freq_Offset.Value));
        Writeln(settings_File,FloatToStr(Ref_Frequency.Value));
        Writeln(settings_File,BoolToStr(Insert_CWID.Checked));
        Writeln(settings_File,CALLSIGN.Text);
        Writeln(settings_File,FloatToStr(Dit_Duration.Value));
        Writeln(settings_File,FloatToStr(Fast_Dit_Duration.Value));
        Writeln(settings_File,SerialPort_Edit.Text);
        Writeln(settings_File,IntToStr(Form1.top));
        Writeln(settings_File,IntToStr(Form1.left));
        Writeln(settings_File,IntToStr(QRSS_Type.ItemIndex));
        Writeln(settings_File,FloatToStr(Freq_Shift.Value));
        Writeln(settings_File,Text_String.Text);
        Writeln(settings_File,FloatToStr(Pixel_Duration.Value));
        Writeln(settings_File,IntToStr(Output_Power.ItemIndex));
        CloseFile(settings_File);
     Except
           on E: EInOutError do
           begin
                ErrorMsg('Error! Software cannot save its window settings. Will revert to default values at next launch. Exiting...');
                Sleep(2000);
           end;
     end;
     Application.terminate;
end;

 // When the Help button is clicked, makes the OS open the help file using the default web browser.
procedure TForm1.About_ButtonClick(Sender: TObject);
begin
    OpenDocument('Help.html');
end;

end.

