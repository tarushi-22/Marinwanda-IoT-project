#include <Servo.h>
Servo myservo;  // create servo object to control a servo
Servo myservo2;
int pos = 0;    // variable to store the servo position

long FISHFEEDER = 3600; // 12 hours between feeding
long endtime; 
long now;
#define SensorPin A0            //pH meter Analog output to Arduino Analog Input 0
#define Offset 0.00            //deviation compensate
#define LED 13
#define samplingInterval 20
#define printInterval 800
#define ArrayLenth  40    //times of collection
int pHArray[ArrayLenth];   //Store the average value of the sensor feedback
int pHArrayIndex=0;

//LED
int b_l=2;
int a_l=3;
int n_l=4;


void setup(void)
{
  pinMode(b_l,OUTPUT);
  pinMode(a_l,OUTPUT);
  pinMode(n_l,OUTPUT);
  
  myservo.attach(9); 
  myservo2.attach(8);
  Serial.begin(9600);
  myservo.write(0);
  myservo2.write(0);
  delay(15);
  //Serial.println("pH meter experiment!");    //Test the serial monitor
}


void loop(void)
{
  static unsigned long samplingTime = millis();
  static unsigned long printTime = millis();
  static float pHValue,voltage;
  
  
  if(millis()-samplingTime > samplingInterval)
  {
      pHArray[pHArrayIndex++]=analogRead(SensorPin);
      if(pHArrayIndex==ArrayLenth)pHArrayIndex=0;
      voltage = avergearray(pHArray, ArrayLenth)*5.0/1024;
      
      pHValue = 3.5*voltage+Offset;
      //pHValue=13; for testing
 
      samplingTime=millis();
  }
  
  
  if(millis() - printTime > printInterval)   //Every 800 milliseconds, print a numerical, convert the state of the LED indicator
  {
    //Serial.print("Voltage:");
    //Serial.print(voltage,2);
    //Serial.print("    pH value: ");
    //Serial.println(pHValue,2);
    //digitalWrite(LED,digitalRead(LED)^1);

    
    if(pHValue>=4 && pHValue<=8)
    {
      Serial.println("Ph of water is fine");
      digitalWrite(n_l, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(1000);               // wait for a second
    }
    else if(pHValue>9)
    {
     Serial.println("Basic");
     digitalWrite(b_l, HIGH);   // turn the LED on (HIGH is the voltage level)
     delay(1000);               // wait for a second
     
    }
    else if(pHValue<3)
    {
      Serial.println("Acidic");
      digitalWrite(a_l, HIGH);   // turn the LED on (HIGH is the voltage level)
      delay(1000);               // wait for a second
    }
    
    
    
    if(pHValue<3)
    {
      
      now = millis();
      endtime = now + FISHFEEDER;
       
            while(now < endtime) {
                  myservo.write(0);
                  delay(15);
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
  
        else if(pHValue>9){
          
          now = millis();
          endtime = now + FISHFEEDER;
          while(now < endtime) {
                myservo2.write(0);
                delay(15);
                now = millis();   
            }
  

          for(pos = 0; pos < 180; pos += 1)  // goes from 0 degrees to 180 degrees 
              {                                  // in steps of 1 degree 
                  myservo2.write(pos);              // tell servo to go to position in variable 'pos' 
                  delay(15);                       // waits 15ms for the servo to reach the position 
              } 
         for(pos = 180; pos>=1; pos-=1)     // goes from 180 degrees to 0 degrees 
              {                                
                  myservo2.write(pos);              // tell servo to go to position in variable 'pos' 
                  delay(15); 
              }
         
      
     }
      digitalWrite(b_l, LOW);    // turn the LED off by making the voltage LOW
      digitalWrite(a_l, LOW);    // turn the LED off by making the voltage LOW
      digitalWrite(n_l, LOW);    // turn the LED off by making the voltage LOW
      delay(10);               // wait for a second
   }
 }



double avergearray(int* arr, int number)
{
 
  int i;
  int max,min;
  double avg;
  long amount=0;
  if(number<=0){
    Serial.println("Error number for the array to avraging!/n");
    return 0;
  }
  if(number<5){   //less than 5, calculated directly statistics
    for(i=0;i<number;i++){
      amount+=arr[i];
    }
    avg = amount/number;
    return avg;
  }else{
    if(arr[0]<arr[1]){
      min = arr[0];max=arr[1];
    }
    else{
      min=arr[1];max=arr[0];
    }
    for(i=2;i<number;i++){
      if(arr[i]<min){
        amount+=min;        //arr<min
        min=arr[i];
      }else {
        if(arr[i]>max){
          amount+=max;    //arr>max
          max=arr[i];
        }else{
          amount+=arr[i]; //min<=arr<=max
        }
      }//if
    }//for
    avg = (double)amount/(number-2);
  }//if
  avg=avg/1.5;
 
  return avg;
  
}

  
