clear;
clc;

% Current provisional receiver settings
fs = 200e3;
f_if = 50e3;
fm_deviation = 25e3;

% Generate 20 ms of a 1 kHz audio tone
duration = 20e-3;
t = (0:1/fs:duration-1/fs).';

message = 0.6*cos(2*pi*1e3*t);

% Generate the low-IF FM signal
instantaneous_frequency = f_if + fm_deviation*message;
phase = 2*pi*cumsum(instantaneous_frequency)/fs;
if_signal = cos(phase);

% Convert to unsigned 12-bit ADC codes
adc_amplitude = 1500;
adc_codes = round(2048 + adc_amplitude*if_signal);
adc_codes = max(0, min(4095, adc_codes));

% Write one decimal ADC code per line
output_file = ...
    'D:\zynq-sdr-fm-bpsk\ZedModem_FM_Demod\adc_samples.txt';

file_id = fopen(output_file, 'w');

if file_id == -1
    error('Could not create adc_samples.txt');
end

fprintf(file_id, '%d\n', adc_codes);
fclose(file_id);

fprintf('Created %d ADC samples.\n', length(adc_codes));
fprintf('ADC minimum: %d\n', min(adc_codes));
fprintf('ADC maximum: %d\n', max(adc_codes));
fprintf('Saved to: %s\n', output_file);

figure;

subplot(2,1,1);
plot(t*1000, message);
xlabel('Time (ms)');
ylabel('Amplitude');
title('Original 1 kHz Audio');
grid on;

subplot(2,1,2);
plot(t(1:100)*1e6, adc_codes(1:100));
xlabel('Time (\mus)');
ylabel('ADC code');
title('First 100 FM ADC Samples');
grid on;