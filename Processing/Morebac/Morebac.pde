// This program establishes a connection with the microcontroller.
// The function of it is telling the microcontroller when to measure as well as retrieving the measurement data and storing it on a file.

import processing.serial.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;



Serial myPort;  // Create object from Serial class
String val;    // Data variable: The data that will be received from the serial port
int countTimes=0; // Counter that increments for each measurement
int prefTimes=10;  // Number of measurements to be done
PrintWriter output;  // Printer that writes the data from light measurements 
PrintWriter dark_output; // Printer that writes the data from dark measurements (Will probably not be used in final version)
PrintWriter currentPrinter; // Changes between light and dark printers
String fileName;  
char sendChar;  // Command that processing sends to make certain measurement
int timeDelay=3000; // Set the timedelay to 2 sec more than that of Arduinos


void setup() {
  fileName="thin_bac_dilution_"; // Change name to suit current measurement
  output=createWriter(fileName+".txt"); // File for measurements with lights on
  dark_output=createWriter("dark_"+fileName+".txt"); //File for measurements in the dark
  String portName = Serial.list()[3]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
}

void draw()
{
  for(int lightOrDark=1; lightOrDark<=2; lightOrDark++) { // Measure in the dark and the light
    if (lightOrDark==1) {
      println("Measurements with LED:s on: ");
      sendChar='1'; //<>//
      currentPrinter=output;
    } else
    {
      println("\n"+"Measurements in the dark");
      sendChar='0';
      countTimes=0;
      prefTimes=1;
      currentPrinter=dark_output;
    }

    while (countTimes<prefTimes) { // Measure until preferred amount of voltages
      myPort.write(sendChar);               // Tell Arduino to measure and send data
      delay(timeDelay);                     // Wait for the duration that it takes for a measurement to be made + extratime. No handshake communication has been implemented. 
      if ( myPort.available() > 0) {               // When data is available,
        //val = myPort.readString();                 // Read it and store it in val
        byte[] byteValue = myPort.readBytes();
        if (byteValue!=null) {
          String val = "";
          int intValue = (((byteValue[0]<<8)&0xFF00)|(byteValue[1]&0xFF)); //Sorry for this
          //println(((byteValue[1] << 8) & 0xFF00) + "");
          if(intValue > 4095) val = "Invalid";
          else{
            val = (intValue/4095f)*3.3f + "";
          }
          currentPrinter.println(val);              // Store the measurement on a file
          delay(100);                               // - : Unsure if even needed : -
          currentPrinter.flush();                   // Write the remaining data to the file
          countTimes++;                             // Count the number of measurements done
          println(val);                             // Write the result in the command window for a realtime  overview of measurements
        }
      }
    }
    currentPrinter.close(); // Closes the file
  }
println("\n"+"Measurements concluded");
exit();         // Exits the program at the end of draw
}


public static String byteArrayToHex(byte[] a) {
   StringBuilder sb = new StringBuilder(a.length * 2);
   for(byte b: a)
      sb.append(String.format("%02x", b & 0xff));
   return sb.toString();
}