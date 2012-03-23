
#include <TimerOne.h>

const byte ledData = 6;
const byte ledShift = 7;

const byte latchPin = 11;
const byte clockPin = 9;
const byte dataIn = 10;
const int baseTime = 1500;
const byte numBoard = 7;

byte currentBoard = 0;
byte cycleNum = 0;

void setup() {
    
  pinMode(ledData, OUTPUT);
  pinMode(ledShift, OUTPUT);
  
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataIn, INPUT);
  
  Serial.begin(115200);
  Serial.println(currentBoard, DEC);
  
}

void loop() {
  if(currentBoard == 0){
    digitalWrite(ledData, HIGH);
  }
  else {
    digitalWrite(ledData, LOW);
  }
  
  digitalWrite(ledShift, HIGH);
  delay(1);
  digitalWrite(ledShift, LOW);
  digitalWrite(ledData, LOW);
  delay(30);
  digitalWrite(latchPin, LOW);
  digitalWrite(latchPin, HIGH);
  byte buffer[numBoard];
  for(byte i = 0; i < numBoard; i++){
    //buffer[i] = shiftIn(dataIn, clockPin, LSBFIRST);
    buffer[i] = shift4of8(dataIn, clockPin);
  }
  sendBuffer(buffer);
  currentBoard++;
  if(currentBoard == numBoard) currentBoard = 0;
  delay(1);
}

void sendBuffer(byte buffer[]) {
  Serial.write(currentBoard);
  for(int i = numBoard-1; i >= 2 ; i-=2){
    Serial.write((buffer[i]<<4)|buffer[i-1]);
  }
  if(numBoard%2 != 0){
    Serial.write(buffer[0]<<4); 
  }
  else{
    Serial.write((buffer[1]<<4)|buffer[0]);
  }
  Serial.print('\n');
}

uint8_t shift4of8(uint8_t dataPin, uint8_t clockP) {
	uint8_t value = 0;
	uint8_t i;

        for (i = 0; i < 4; ++i) {
          digitalWrite(clockPin, LOW);
	  digitalWrite(clockPin, HIGH);
	}
        
	for (i = 0; i < 4; ++i) {
          digitalWrite(clockPin, LOW);
	  value |= digitalRead(dataPin) << i;
	  digitalWrite(clockPin, HIGH);
	}
        digitalWrite(clockP, HIGH);
        delayMicroseconds(5);
        digitalWrite(clockP, LOW);
	return value;
}
