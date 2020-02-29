% TODO: Add low pass filter (50khz) anti alising before Goertzel, add low pass filter ~600hz
% after and decision slicer
clear; clf;
% ----------- Load CSV Data --------------
fulldata = readmatrix('receiver_021720_1', 'Range', 13);
ch1_scale = 10.0; %update if needed
ch1_offset = 0; %update if needed
time = fulldata(:, 1)-fulldata(1, 1);
receiver = fulldata(:, 2).*ch1_scale-ch1_offset;
transmit = fulldata(:, 3) - fulldata(:, 4);

% plot(time, receiver);
% title('Transmission signal at 50Mhz')
% ylabel('Amplitude')
% xlabel('Frequency (Hz)')

% ------------ Demodulation --------------
f0 = 24000;
f1 = 28000;
targetFreq = [f0 f1];

totalDur = time(end, 1);
sampleRateTx = round(1/(time(2)-time(1)));
sampleRateRx = 100000; %Receive ADC sample rate
samplePeriodTx = 1/sampleRateTx; %Sample Period transmitter
samplePeriodRx = 1/sampleRateRx; %Sample period receiver

subplot(3, 2, 1);
plot(time, transmit);
title(['Transmission signal at ' num2str(sampleRateTx/1000) ' khz'])
ylabel('Amplitude')
xlabel('Time(seconds)')

% Receiver transmit data with ADC sample rate, scale
% TODO: Add 8-bit quantization and noise 
adc_scale = (2^8-1)/3.3;
rxSig = resample(receiver, sampleRateRx, sampleRateTx) * adc_scale; % resample at adc sample rate
rxSampleTimeVec = (0:length(rxSig)-1)*totalDur/length(rxSig);

subplot(3, 2, 3);
plot(rxSampleTimeVec, rxSig);
title(['Receiver signal at ' num2str(sampleRateRx/1000) ' khz'])
ylabel('Amplitude')
xlabel('Time(seconds)')

% Power spectrum of signal 
subplot(3, 2, 5);
n = 2^nextpow2(length(rxSig));
Y = fft(rxSig, n);
f = sampleRateRx*(0:(n/2))/n;
P = abs(Y/n);
plot(f, P(1:n/2+1))
title('Receiver Signal Power Spectrum')
ylabel('Amplitude')
xlabel('Frequency (Hz)')

% Goertzel Receiver Calculation
mag = [];
binSize = 100;
for i = (1:length(targetFreq))
    single = []; 
    k = round(binSize*targetFreq(i)/sampleRateRx);
    w = 2.0*pi*k/binSize;
    cosCoeff = cos(w);
    sinCoeff = sin(w);
    coeff = round(2.0*cosCoeff, 2)
    % change update frequency, right at at every 102 sample
    % for j=(0:10:length(rxSig)-10-binSize) at every 10 sample
    for j=(0:binSize:length(rxSig)-binSize) 
        q1 = 0.0;
        q2 = 0.0;
        for n=(1:binSize)+j
            q0 = round(rxSig(n) + coeff.*q1 - q2, 2);
            q2 = q1;
            q1 = q0;
        end
    % Normalize the value by binSize, result is magnitude^2
    % real value -> single = [single (q1-q2.*cosCoeff)/binSize];
    % imag value -> single = [single (q2.*sinCoeff)/binSize];
    single = [single (q1.*q1 + q2.*q2 - q1.*q2.*coeff)]; 
    end
    mag  = [mag; single];
end

% Demodulated Digital Signal time
deTimeVec = (0:length(mag)-1)*totalDur/length(mag);

subplot(3, 2, 2);
plot(deTimeVec, mag(1,:), deTimeVec, mag(2,:))
title(['Goertzel Result - ' num2str(binSize) ' bin size'])
ylabel('Amplitude')
xlabel('Time (seconds)')

% Demodulated FSK Signal with threshold
threshold = 5e6;
demodSig = [];
for (i=1:length(mag))
    if (mag(1, i) > threshold && mag(2, i) < threshold)
        demodSig = [demodSig -1];
    elseif (mag(2, i) > threshold && mag(1, i) < threshold)
        demodSig = [demodSig 1];   
    else 
       demodSig = [demodSig 0]; 
    end
    %[M, I] = max(mag(:,i));
    %demodSig = [demodSig I];
end

subplot(3, 2, 6);
plot(deTimeVec, demodSig, 'm', 'LineWidth', 2)
title(['Demodulated FSK Signal - ' num2str(threshold) ' threshold'])
ylabel('Amplitude')
xlabel('Time (seconds)')

