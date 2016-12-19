#include <TimerThree.h>

#define NUMBER_OF_CHANNELS 8
#define CONVST 5 
#define RD 13
#define BUSY 7
/*
 * Digital Output In Order:
 * SCK --> ICSP 3
 * MOSI --> ICSP 4
 * MISO --> ICSP 1
 * D8
 * D9
 * D10
 * D11
 * D3
 * D2
 * D0
 * D1
 * D4
 * D12
 * D6
 */

char DB[NUMBER_OF_CHANNELS*2];
uint8_t DATA0;
int8_t DATA1;
//int time_elapsed = 0;
int i = 0;
volatile byte new_data = 0;
unsigned int sample_rate = 3125;
unsigned int long period = 1000000 / sample_rate;

void setup() {
  pinMode(CONVST,OUTPUT);
  pinMode(RD,OUTPUT);
  digitalWrite(RD,HIGH);
  Serial.begin(115200);
  Timer3.initialize(period);
  attachInterrupt(digitalPinToInterrupt(BUSY),INT,FALLING);
  Timer3.pwm(CONVST, (50.0 / 100) * 1023);
}

void loop() {
  if(new_data){
    //time_elapsed = micros();
    new_data=0;
    for(i=0;i<NUMBER_OF_CHANNELS;i++){
      digitalWrite(RD,LOW); 
      digitalWrite(RD,HIGH);
      DATA0 = PINB; //unsigned
      DATA1 = PIND; //signed
      DATA0 = DATA0 >> 1;
      DATA0 |= (DATA1 << 7);
      DATA1 = DATA1 >> 1;
      DATA1 = ((DATA1 >> 1) & 0B11110000) | (DATA1 & 0B00001111);
      DB[0 + 2*i] = DATA0;
      DB[1 + 2*i] = DATA1;
    }
    Serial.write(DB, NUMBER_OF_CHANNELS*2);
    //time_elapsed = micros() - time_elapsed;
    //Serial.println(time_elapsed);
    //delay(100);
  }
}

void INT(){
  new_data=1;
}
