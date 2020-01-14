% FSK Demodulation with Goertzel Algorithm
% Based on https://www.embedded.com/the-goertzel-algorithm/
% http://www.mstarlabs.com/dsp/goertzel/goertzel.html

% ------------- FSK Modulation ----------------
% Parameters
bitmap = [1 0];
baudrate = 2000;
sampleRateTx = 100000*5;
sampleRateRx = 100000;
f1 = 25000;
1
f2 = 28000;
0
AC = 5;
AN = 1;

% Rate breakdown
ppb = 1/baudrate; %period per bits
pps = 1/sampleRateTx; %period per sample
spb = ppb/pps; %samples/bits

t_bit=ppb/spb:ppb/spb:ppb;                          % time matrix for bit                
t_message=ppb/spb:ppb/spb:length(bitmap)*ppb;       % time matrix for message
mesdur = max(t_message);

% Binary to digital signals 
bit = [];
for n = 1:1:length(bitmap)
    if bitmap(n) == 1;
        se=ones(1, int16(spb)); %create a list of ones
    else bitmap(n) == 0;
        se=zeros(1, int16(spb)); %create a list of zeros
    end
    bit = [bit se]; %add to bit list
    
end
subplot(3,2,1);
plot(t_message,bit,'lineWidth',2.5);grid on;
axis([ 0 ppb*length(bitmap) -.5 1.5]);
ylabel('logic level');
xlabel(' time(sec)');
title('Digital source');

% Modulated Signal
mSig = [];
for (i=1:1:length(bitmap))
    if (bitmap(i)==1)
        y=AC*cos(2*pi*f1*t_bit); %create a list at frequency1
    else
        y=AC*cos(2*pi*f2*t_bit); 
    end
    mSig=[mSig y];
end
subplot(3,2,2);
plot(t_message,mSig);
axis ([0 max(t_message) (AC+1)*-1 (AC+1)]);
xlabel('time(sec)');
ylabel('SS(V)');
title('FSK modulated signal for TX');
disp(sprintf('Signal sent\n'));

% White Noise
noise = AN*randn(1, numel(mSig));
%mSig = mSig + noise;

% Path Loss Models

% Multipath interference
mpCoeff = [1 0.3*exp(j*0.2*pi)];
mpSig = filter(mpCoeff, 1, mSig);
z = abs(mpSig);
subplot(3,2,3);
fvtool(mpCoeff, 1)
%plot(t_message,z);
xlabel('time(sec)');
ylabel('SS(V)');
title('M');
disp(sprintf('Signal sent\n'));

% FFT Calculation
ffSig = fft(z);
L = 2^nextpow2(length(z));
f = sampleRateTx*(0:(L/2))/L;
P = abs(ffSig/L);

subplot(3,2,4);
plot(f,P(1:L/2+1)) 
title('Gaussian Pulse in Frequency Domain')
xlabel('Frequency (f)')
ylabel('|P(f)|')


% ------------- FSK Demodulation ----------------
% sampler frequency and carrier frequency 
rSig = mSig;


