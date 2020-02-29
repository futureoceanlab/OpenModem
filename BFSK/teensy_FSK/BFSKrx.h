///*
//  BFSK_rx.h - Open Modem Binary FSK receiver code
//  Future Oceans Lab
//  TODO: add ring buffer, threshold detection, windowing
//  ADD calculation for coefficients
//*/

#ifndef BFSKRX_H
#define BFSKRX_H

//TODO: #include "CircularBuffer.h"
#include "arduino.h"
#include "ADC.h"
#include "ADC_util.h"

// hardware pin setup
#define digitalOutPin1 7
#define digitalOutPin2 8

// ADC hardwae setup 
#define analogInPin A0 // pin 14 
#define samplingFreq 100000
#define USE_ADC_0
ADC *adc = new ADC();

// FSK Receiver setting 
#define N_FSK 2

// Goertzel Filter variable 
// TODO: CircularBuffer<uint16_t, BUFFER_SIZE> BUFFER;
#define BUFFER_SIZE 100
#define THRESHOLD_VALUE 10000000

volatile uint16_t buffer_adc_0_count = 0;
float coeff[N_FSK];
float mag[N_FSK];
float q1[N_FSK], q2[N_FSK], q0[N_FSK];

// function
void BFSKrxSetup(uint16_t, uint16_t);
void BFSKrxADCSetup();
void BFSKrxStart();
void BFSKrxStop();
void adc_isr();
 
#endif

void BFSKrxSetup(float freqCoeff0, float freqCoeff1){
    pinMode(analogInPin, INPUT);
    pinMode(digitalOutPin1, OUTPUT);
    pinMode(digitalOutPin2, OUTPUT);

    coeff[0] = freqCoeff0; 
    coeff[1] = freqCoeff1;
}

void BFSKrxADCSetup(){
    // setup ADC0 configuration
    adc->adc0->setAveraging(1);
    adc->adc0->setResolution(8);
    adc->adc0->setConversionSpeed(ADC_CONVERSION_SPEED::VERY_HIGH_SPEED);
    adc->adc0->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED);
}

void BFSKrxStart(){
    // Setup ADC0 interrupt start sampling
    adc->adc0->stopQuadTimer();
    adc->adc0->startSingleRead(analogInPin);
    adc->adc0->enableInterrupts(adc_isr);
    adc->adc0->startQuadTimer(samplingFreq);
}

void BFSKrxStop(){
  // Stop ADC0 stop interrupt sampling
  adc->adc0->stopTimer();
  adc->adc0->disableInterrupts();
}

void adc_isr(){
    // read a new value
    uint16_t adc_val = adc->adc0->readSingle();
    
    // saving the ADC value to the Buffer
    for (int i = 0; i < N_FSK; i++){
        if (buffer_adc_0_count < BUFFER_SIZE*N_FSK){
            q0[i] = float(adc_val) + coeff[i] * q1[i] - q2[i];
            q2[i] = q1[i];
            q1[i] = q0[i];
            buffer_adc_0_count++;
        } else {
            // reset buffer count
            buffer_adc_0_count = 0;

            // calculate goertzel magnitude, normalized by dividing via Buffer size
            mag[i] = q1[i] * q1[i] + q2[i] * q2[i] - q1[i]*q2[i]*coeff[i];
            // reset goertzel variable
            q1[i] = 0;
            q2[i] = 0;    
        }
    }
 
    // Threshold Value        
    if (mag[0] > THRESHOLD_VALUE && mag[1] < THRESHOLD_VALUE){ 
        digitalWriteFast(digitalOutPin1, 0);
        digitalWriteFast(digitalOutPin2, 1);
        //Serial.println(2);
    } else if (mag[1] > THRESHOLD_VALUE && mag[0] < THRESHOLD_VALUE){
        digitalWriteFast(digitalOutPin1, 1);
        digitalWriteFast(digitalOutPin2, 0);
        //Serial.println(0);
    } else {
        digitalWriteFast(digitalOutPin1, 0);
        digitalWriteFast(digitalOutPin2, 0);
        //Serial.println(1);
    }

    // Add low pass filter?
    // Add decision slicer?
    
    #if defined(__IMXRT1062__)  // Teensy 4.0
        asm("DSB");
    #endif
}
