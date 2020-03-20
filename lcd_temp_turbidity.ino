#include <Servo.h>
Servo myservo;  // create servo object to control a servo
int pos = 0;    // variable to store the servo position
long FISHFEEDER = 3600; // 12 hours between feeding
long endtime; 
long now;

//Include LCD library
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
   float temp;
int tempPin = 0;
void setup()
{
  myservo.attach(7);
  myservo.write(0);
  Serial.begin(9600);
  // set up the LCD's number of columns and rows: 
  lcd.begin(16, 2);
  // Print a message to the LCD.
  lcd.print("Temp="); 
  delay(15);
  
}

void loop() {
  // set the cursor to column 0, line 1
  // (note: line 1 is the second row, since counting begins with 0):
 
  int sensorValue = analogRead(A0);// read the input on analog pin 0:
  float voltage = sensorValue * (5.0 / 1024.0); // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
  Serial.print("Turbidity = ");
  Serial.println(voltage); // print out the value you read:
  delay(500);
  temp = analogRead(tempPin);
  temp = temp * (0.2628125)+4 `;
  Serial.print("TEMPERATURE = ");
  Serial.print(temp);

  Serial.println();
  delay(1000);
 lcd.setCursor(8,0);
  //Print a message to second line of LCD
  lcd.print(temp);
   lcd.setCursor(14,0);
  lcd.print("C");
  lcd.setCursor(0,1);
  lcd.print("Turbidity=");
  lcd.setCursor(11,1);
  lcd.print(voltage);
  now = millis();
  endtime = now + FISHFEEDER;
  
  while(now < endtime) {
   myservo.write(0);
   delay(20000);
   now = millis();   
  }
  

  for(pos = 0; pos < 180; pos += 1)  // goes from 0 degrees to 180 degrees 
  {                                  // in steps of 1 degree 
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  } 
  for(pos = 180; pos>=1; pos-=1)     // goes from 180 degrees to 0 degrees 
  {                                
    myservo.write(pos);              // tell servo to go to position in variable 'pos' 
    delay(15);                       // waits 15ms for the servo to reach the position 
  } 
}
