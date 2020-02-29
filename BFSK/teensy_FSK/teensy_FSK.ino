#include "BFSKrx.h"

// TODO add calculation from frequency to coeff
// TODO add programmer pre amp

void setup() {
  Serial.begin(9600);
  // BFSKrxSetup takes in coeff 
  BFSKrxSetup(float(0.13), float(-0.37)); // 24khz, 28khz 
  BFSKrxADCSetup();
  BFSKrxStart();
}

void loop() {
}
