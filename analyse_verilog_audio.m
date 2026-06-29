clear;
clc;

fs_audio = 50e3;

filename = ...
    'D:\zynq-sdr-fm-bpsk\ZedModem_FM_Demod\verilog_audio_samples.txt';

audio = readmatrix(filename);
audio = audio(~isnan(audio));

% Remove initial FIR and de-emphasis startup transient
audio = audio(101:end);
audio = audio - mean(audio);

% Normalize for plotting
audio_normalized = audio / max(abs(audio));

t = (0:length(audio)-1).' / fs_audio;

% Find the strongest frequency
nfft = 2^nextpow2(length(audio));
spectrum = abs(fft(audio, nfft));
frequency = (0:nfft/2-1).' * fs_audio / nfft;
spectrum = spectrum(1:nfft/2);

[~, index] = max(spectrum(2:end));
index = index + 1;
peak_frequency = frequency(index);

fprintf('Audio samples analysed: %d\n', length(audio));
fprintf('Strongest frequency: %.2f Hz\n', peak_frequency);

figure;

subplot(2,1,1);
plot(t*1000, audio_normalized);
xlabel('Time (ms)');
ylabel('Normalized amplitude');
title('Recovered Verilog Audio');
grid on;

subplot(2,1,2);
plot(frequency, spectrum);
xlim([0 5000]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Recovered Audio Spectrum');
grid on;