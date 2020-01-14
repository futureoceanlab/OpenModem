dft_data = goertzel(sig, k);
subplot(4, 2, 6);
stem(targetFreq, abs(dft_data))

fs = 10000*100;
t = (0:1/fs:1/2000);
a = sin(2*pi*25000*t);
subplot (3, 1, 1);
plot(t, a)

b = [zeros(1, 86) 1];
y = filter(b, 1, a);

hold on
plot(t, y)

b1 = [zeros(1, 180) 1];
y1 = filter(b, 1, a);

hold on 
plot(t, y1)

hold on
plot(t, a + y + y1)

bTotal = [ 1 zeros(1, 85) 1 zeros(1, 93) 1];
yTotal = filter(bTotal, 1, a);

subplot(3, 1, 2)
plot(t, yTotal)