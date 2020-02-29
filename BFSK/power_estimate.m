clear; clf;
% ----------- Load CSV Data --------------
fulldata = readmatrix('power_021820_1', 'Range', 13); %update if needed
time = fulldata(:, 1)-fulldata(1, 1); %update if needed
ch1_scale = 10.0; %update if needed
ch1_offset = -1.73; %update if needed
ch3_scale = 20; %update if needed
ch4_scale = 20; %update if needed
current_sense_amp = fulldata(:, 2).*ch1_scale + ch1_offset; %update if needed
transmit_voltage = fulldata(:, 3).*ch3_scale - fulldata(:, 4).*ch4_scale; %update if needed

% ------------ Estimated Current --------------
resistor = 0.1; %sense resistor value 0.1ohm, update if needed
amp_gain = 200; %gain of the amplifier, update if needed
current_est = current_sense_amp./(resistor*amp_gain); % V/gain = I*R 

totalDur = time(end, 1);
sampleRateTx = round(1/(time(2)-time(1)));
samplePeriodTx = 1/sampleRateTx; %Sample Period transmitter

subplot(3, 2, 1);  
plot(time, transmit_voltage);
title(['Transmission siganl at ' num2str(sampleRateTx/1000) ' khz'])
ylabel('voltage')
xlabel('Time(seconds)')

subplot(3, 2, 3);
plot(time, current_est);
title('Current Estimated')
ylabel('amp')
xlabel('Time(seconds)')

% ------------ Power Calculation -------------
power_est = abs(transmit_voltage.*current_est);
subplot(3, 2, 5);
plot(time, power_est);
title('Power Estimation')
ylabel('watt')
xlabel('Time(seconds)')

% ------------- Energy Calculation ------------
energy_est = sum(power_est.*samplePeriodTx)
max_power = max(power_est)
average_power = mean(power_est)

% ------------- Battery Calculation -----------
% 18650 battery is 10 watt hours, if we have four batteries
% in our set up that 40 watt hours, let's say that we transmit
% 8 bits at 200hz and 8 bits for 1 code, 64 code, every 1 hour
code_time = 1/200 * 8 * 64 % unit seconds, update if needed
battery_hour = 40/average_power % unit hour, update if needed
max_num_transmit = battery_hour*60*60/code_time % hr*(60 min/hr)*(60sec/hr)/sec
