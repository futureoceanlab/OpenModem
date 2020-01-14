% ----------- FSK Modulation ---------------
clear
bitMap = [1 0 1 0 1 0 0 1]
f0 = 25000;
f1 = 30000;
targetFreq = [f0 f1];

sigAmp = 1;
noiseAmp = 0;

sampleRateTx = 100000*100; %Transmission Sample Rate should be faster
sampleRateRx = 100000; %Receive ADC sample rate
samplePeriodTx = 1/sampleRateTx; %Sample Period transmitter
samplePeriodRx = 1/sampleRateRx; %Sample period receiver

bitRate = 1000; %For now, but it should be 200
bitPeriod = 1/bitRate;
bitTimeVec = 0:bitPeriod:length(bitMap); %Time Vector for digital Bits
mesDur = length(bitMap)*bitPeriod; %Total time of message

spb = bitPeriod/samplePeriodTx; %number of sample in a bit
sampleTimeVec = (0:spb-1)*samplePeriodTx; %Time Vector for sample
totalSampleTime = (0:length(bitMap)*spb-1)*samplePeriodTx; %Time Vector for total Samples

spbRx = bitPeriod/samplePeriodRx;


% Digital Binary FSK Signal
dsig = [];
for i = 1:1:length(bitMap)
    if bitMap(i) == 0;
        de = zeros(1, spb);
    else bitMap(i) == 1;
        de = ones(1, spb);
    end
    dsig = [dsig de];
end

subplot (4, 2, 1);
plot(totalSampleTime, dsig)
title('Digital Signal')

% Modulated Binary FSK Signal
sig = [];
for i=1:1:length(bitMap)
    if bitMap(i) == 0;
        se = sigAmp * sin(2*pi*f0*sampleTimeVec);
    else bitMap(i) == 1;
        se = sigAmp * sin(2*pi*f1*sampleTimeVec);
    end
    sig = [sig se];
end
        
subplot(4, 2, 3);
plot(totalSampleTime, sig)
title('FSK Modulated Signal')

% Multipath Effect
mpCoeff = [1 zeros(1, 1000) 0.8 0.3*exp(i*0.3*pi) zeros(1, 1000) 0.5];
mpSig = filter(mpCoeff, 1, sig);
%impz(mpCoeff, 1)

subplot(4, 2, 5);
plot(mpSig + sig);
title('FSK Modulated Signal with Multipath')

% White Noise Effect
noise = noiseAmp*randn(1, numel(mpSig));

% Doppler Effect

% Power spectrum of signal 
subplot(4, 2, 7);
n = 2^nextpow2(length(sig));
Y = fft(sig, n);
f = sampleRateTx*(0:(n/2))/n;
P = abs(Y/n);
plot(f, P(1:n/2+1))
title('Power Spectrum of FSK channeled Signal')

% ----------- FSK Demodulation ---------------
% Receiver sample data
rxSig = resample(mpSig, sampleRateRx, sampleRateTx);
%sampleTimeRxVec = 0:length
subplot(4, 2, 2);
plot(rxSig)
title('Received FSK signal')

% Goertzel Init 
mag = [];
binSize = 15;
for i = (1:length(targetFreq))
    single = [];
    k = round(0.5 + binSize*targetFreq(i)/sampleRateRx);
    w = 2.0*pi*k/binSize;
    cosCoeff = cos(w);
    sinCoeff = sin(w);
    coeff = 2.0*cosCoeff;
    for j=(0:binSize:length(rxSig)-binSize)
        q1 = 0.0;
        q2 = 0.0;
        for n=(1:binSize)+j
            q0 = rxSig(n) + coeff.*q1 - q2;
            q2 = q1;
            q1 = q0;
        end
    single = [single q1.*q1 + q2.*q2 - q1.*q2.*coeff];
    end
    mag  = [mag; single];
end

subplot(4,2,4)
plot(mag(1,:))
hold on
plot(mag(2,:))



    


