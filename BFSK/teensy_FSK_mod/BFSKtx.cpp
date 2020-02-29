/*
  BFSK_TX.cpp - Open Modem Binary FSK transmission code
  Future Oceans Lab
*/
#include "Arduino.h" 
#include "BFSKtx.h"

BFSKtx::BFSKtx(uint16_t freq_one, uint16_t freq_zero) {
  _freq0 = freq_zero;
  _freq1 = freq_one;
  pinMode(pinOut1, OUTPUT);
  pinMode(pinOut2, OUTPUT);
}

void BFSKtx::INFO() {
  Serial.print("Frequency 0: ");
  Serial.println(_freq0);
  Serial.print("Frequency 1: ");
  Serial.println(_freq1);
  Serial.print("pinOut1: ");
  Serial.println(pinOut1);
  Serial.print("pinOut2: ");
  Serial.println(pinOut2);
  Serial.print("Toggle Count: ");
  Serial.println(toggle_count);
}

// sending one modulated code [8 bits]
void BFSKtx::modCode(float bitPerSec, float wait_duration, int code[], int code_bit_size){
  float bit_duration = float(1000/bitPerSec); // microseconds
  for (int i = 0; i < code_bit_size; i ++){
    modBit(bit_duration, code[i]);
    delay (bit_duration+ wait_duration);
  }
}

// sending one modulated bit 
void BFSKtx::modBit(float bit_duration, int one_bit) {
  switch (one_bit){
  case 0:
      _count = (bit_duration / 1000 * _freq0) * 2;
      _usec = (float)50000.0 / (float)_freq0;
      break;
  case 1:
      _count = (bit_duration / 1000 * _freq1) * 2;
      _usec = (float)50000.0 / (float)_freq1;
      break;
  }
  toggle_count = _count;

  // setting the clock on for PIT
  CCM_CCGR1 |= CCM_CCGR1_PIT(CCM_CCGR_ON);

  // the cycles of interrupt setting depends on the microseconds 
  uint32_t cycles = float(240000000 / 1000000) * _usec - 1;

  // set the Timer Load Value Register
  PIT_LDVAL0 = cycles;

  // enable timer and interrupt
  PIT_TCTRL0 = 3;

  // attach interrupt vector 
  attachInterruptVector(IRQ_PIT, &mod_isr);

  // set priority
  NVIC_SET_PRIORITY(IRQ_PIT, 255);
  
  // enable IRQ
  NVIC_ENABLE_IRQ(IRQ_PIT);  
}

void mod_isr() {
  // reset the TFLG 
  PIT_TFLG0 = 1;
  
  if (toggle_count) {
      digitalWriteFast(pinOut1, !digitalReadFast(pinOut1));
      digitalWriteFast(pinOut2, !digitalReadFast(pinOut1));
      toggle_count--;
  }
  else{
      digitalWriteFast(pinOut1, 0);
      digitalWriteFast(pinOut2, 0);
      
      // disalbe timer and interrupt 
      PIT_TCTRL0 = 0;

      // disable IRQ_PIT
      NVIC_DISABLE_IRQ(IRQ_PIT);
  }
  
  #if defined(__IMXRT1062__)  // Teensy 4.0
    asm("DSB");
  #endif
}
