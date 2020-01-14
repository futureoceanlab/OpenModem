% ----------- FSK Modulation ---------------
bitMap = [1 0 1];
f0 = 25000; 
f1 = 5000;

sampleRateTx = 100000*100; %Transmission Sample Rate should be faster
sampleRateRx = 100000; %Receive ADC sample rate
samplePeriodTx = 1/sampleRateTx; %Sample Period

bitRate = 2000; %For now, but it should be 200
bitPeriod = 1/bitRate;
bitTimeVec = 0:bitPeriod:length(bitMap); %Time Vector for digital Bits

spb = bitPeriod/samplePeriodTx; %number of sample in a bit
sampleTimeVec = (0:spb-1)*samplePeriodTx; %Time Vector for sample
totalSampleTime = (0:length(bitMap)*spb-1)*samplePeriodTx; %Time Vector for total Samples

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

% Modulated Binary FSK Signal
sig = [];
for i=1:1:length(bitMap)
    if bitMap(i) == 0;
        se = sin(2*pi*f0*sampleTimeVec);
    else bitMap(i) == 1;
        se = sin(2*pi*f1*sampleTimeVec);
    end
    sig = [sig se];
end
        
subplot(4, 2, 3);
plot(totalSampleTime, sig)

% Multipath Effect
mpCoeff = [1 zeros(1, 1000) 0.8 0.3*exp(i*0.3*pi) zeros(1, 1000) 0.5];
mpSig = filter(mpCoeff, 1, sig);
impz(mpCoeff, 1)
subplot(4, 2, 5);
plot(mpSig + sig);

% White Noise Effect
noise = AN*randn(1, numel(mSig));

% Doppler Effect

% Power spectrum of signal
subplot(4, 2, 7);
n = 2^nextpow2(length(sig));
Y = fft(sig, n);
f = sampleRateTx*(0:(n/2))/n;
P = abs(Y/n);
plot(f, P(1:n/2+1))

% ----------- FSK Demodulation ---------------


