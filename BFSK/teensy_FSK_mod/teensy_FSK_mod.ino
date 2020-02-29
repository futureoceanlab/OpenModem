#include "BFSKtx.h"

BFSKtx test((uint16_t) 24000, (uint16_t) 28000);

const int buttonPin = 2;

void setup(){
  Serial.begin(9600);
  pinMode(buttonPin, INPUT_PULLUP);
}

int buttonState = 0;
int preState = 0;
int code[8] = {1, 0, 0, 1, 0, 1, 0, 1};

void loop(){  

  buttonState = digitalRead(buttonPin);

  if (buttonState != preState){
    if (buttonState == HIGH){
      // modCode(bit frequency, wait time (ms), code array, code bit length)
      test.modCode(200, 1, code, 8);
    }
  }
  
  preState = buttonState;
}  
