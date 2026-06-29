clear;
clc;
close all;

%% Sampling and IF parameters
fs  = 200e3;
Ts = 1/fs;
Tsim = 5e-3;
t = 0:Ts:Tsim-Ts;

fIF = 50e3;

%% Test message
fm = 1e3;                  % 1 kHz test audio tone
m = 0.6*cos(2*pi*1e3*t) + 0.3*cos(2*pi*3e3*t) + 0.2*cos(2*pi*6e3*t);
m = m / max(abs(m));

%% FM deviation
df  = 25e3;      

%% Instantaneous frequency of the low-IF FM signal
fi = fIF + df*m;
%% Generate sampled low-IF FM waveform
phase = 2*pi*cumsum(fi)/fs;
%% Ideal analogue low-IF FM waveform before ADC
x_if_ideal = cos(phase);
%% Add analogue IF noise before ADC
SNR_dB = 30;   % start with a clean but realistic-ish test

signal_power = mean(x_if_ideal.^2);
noise_power  = signal_power / (10^(SNR_dB/10));
rng(1);   % repeatable noise for golden-model testing
noise = sqrt(noise_power) * randn(size(x_if_ideal));

x_if_noisy = x_if_ideal + noise;

%% ADC model: level shift + quantization + digital centering
adc_bits = 12;
adc_levels = 2^adc_bits;

% Put bipolar IF waveform into a normalized unipolar ADC range [0, 1]
adc_headroom = 0.2;                 % keeps signal away from rails
x_adc_unipolar = 0.5 + adc_headroom*x_if_noisy;

% Clip just in case
x_adc_unipolar = min(max(x_adc_unipolar, 0), 1);

% Quantize to ADC integer codes
x_adc_code = round(x_adc_unipolar*(adc_levels - 1));
%% ADC diagnostics
num_clipped_low  = sum(x_adc_code == 0);
num_clipped_high = sum(x_adc_code == adc_levels - 1);

fprintf('ADC headroom  = %.2f\n', adc_headroom);
fprintf('ADC code min  = %d\n', min(x_adc_code));
fprintf('ADC code max  = %d\n', max(x_adc_code));
fprintf('Clipped low   = %d samples\n', num_clipped_low);
fprintf('Clipped high  = %d samples\n', num_clipped_high);

% Convert ADC codes back to signed normalized DSP samples
x_adc = (x_adc_code/(adc_levels - 1) - 0.5)/adc_headroom;
%% Plot a short section of the ADC waveform
Nplot = 300;

figure;
plot(t(1:Nplot)*1e6, x_adc(1:Nplot));
grid on;
xlabel('Time [\mus]');
ylabel('Amplitude');
title('Simulated ADC samples: low-IF FM signal');
%% Digital downconversion from low IF to complex baseband
lo = exp(-1*j*2*pi*fIF*t);
fprintf('max imag(lo)   = %.3f\n', max(abs(imag(lo))));
z_mixed = x_adc .* lo;
%% Low-pass filter after mixing
lpf_order = 100;
fc_lpf = 40e3;                  % DDC LPF cutoff for 200 kS/s case
b = fir1(lpf_order, fc_lpf/(fs/2));

z_bb = filter(b, 1, z_mixed);

%% Plot I and Q after downconversion
figure;
plot(t*1e3, real(z_bb));
hold on;
plot(t*1e3, imag(z_bb));
grid on;
xlabel('Time [ms]');
ylabel('Amplitude');
title('Complex baseband signal after digital downconversion');
legend('I', 'Q');

%% FM demodulation using phase difference
dphi = angle(z_bb(2:end) .* conj(z_bb(1:end-1)));

% Convert phase change per sample to recovered normalized message
m_hat = dphi * fs / (2*pi*df);
t_demod = t(2:end);
%% Audio low-pass filter after FM demodulation
audio_lpf_order = 200;
fc_audio = 15e3;

b_audio = fir1(audio_lpf_order, fc_audio/(fs/2));

m_hat_audio = filter(b_audio, 1, m_hat);

%% Ignore filter transient for cleaner view
skip = 200;

figure;
plot(t_demod(skip:end)*1e3, m(skip+1:end), 'LineWidth', 1.2);
hold on;
plot(t_demod(skip:end)*1e3, m_hat(skip:end), '--', 'LineWidth', 1.2);
grid on;
xlabel('Time [ms]');
ylabel('Amplitude');
title('Recovered message after ignoring filter transient');
legend('Original m(t)', 'Recovered m\_hat(t)');

%% Align recovered message by compensating filter delays
D_if    = lpf_order/2;
D_audio = audio_lpf_order/2;
D_total = D_if + D_audio;

m_hat_aligned = m_hat_audio(D_total+1:end);
m_ref_aligned = m(2:end-D_total);
t_aligned     = t_demod(1:end-D_total);

figure;
plot(t_aligned*1e3, m_ref_aligned, 'LineWidth', 1.2);
hold on;
plot(t_aligned*1e3, m_hat_aligned, '--', 'LineWidth', 1.2);
grid on;
xlabel('Time [ms]');
ylabel('Amplitude');
title('Original message vs delay-aligned recovered message');
legend('Original m(t)', 'Recovered m\_hat(t), delay aligned');

%% Downsample recovered audio to audio-rate samples
M_decim = 4; 
fs_audio = fs / M_decim;

m_audio_out = m_hat_aligned(1:M_decim:end);
m_audio_ref = m_ref_aligned(1:M_decim:end);
t_audio     = t_aligned(1:M_decim:end);

figure;
plot(t_audio*1e3, m_audio_ref, 'LineWidth', 1.2);
hold on;
plot(t_audio*1e3, m_audio_out, '--', 'LineWidth', 1.2);
grid on;
xlabel('Time [ms]');
ylabel('Amplitude');
title('Recovered audio after downsampling to 50 kS/s');
legend('Reference audio', 'Recovered audio');

%% Golden model error measurement
skip = 200;   % ignore startup transient

x_ref = m_ref_aligned(skip:end);
x_hat = m_hat_aligned(skip:end);

err = x_ref - x_hat;

rmse = sqrt(mean(err.^2));
max_abs_err = max(abs(err));

% Correlation without using corr()
x_ref0 = x_ref - mean(x_ref);
x_hat0 = x_hat - mean(x_hat);

corr_val = sum(x_ref0 .* x_hat0) / sqrt(sum(x_ref0.^2) * sum(x_hat0.^2));

fprintf('RMSE          = %.6f\n', rmse);
fprintf('Max abs error = %.6f\n', max_abs_err);
fprintf('Correlation   = %.6f\n', corr_val);

%% Audio-rate error measurement, ignoring initial transient
skip_audio = ceil(0.2e-3 * fs_audio);   % ignore first 0.2 ms

x_audio_ref = m_audio_ref(skip_audio+1:end);
x_audio_out = m_audio_out(skip_audio+1:end);

err_audio = x_audio_ref - x_audio_out;

rmse_audio = sqrt(mean(err_audio.^2));
max_abs_err_audio = max(abs(err_audio));

% Audio correlation without corr()
x_audio_ref0 = x_audio_ref - mean(x_audio_ref);
x_audio_out0 = x_audio_out - mean(x_audio_out);

corr_audio = sum(x_audio_ref0 .* x_audio_out0) / ...
             sqrt(sum(x_audio_ref0.^2) * sum(x_audio_out0.^2));

fprintf('Audio fs      = %.0f Hz\n', fs_audio);
fprintf('Audio RMSE    = %.6f\n', rmse_audio);
fprintf('Audio max err = %.6f\n', max_abs_err_audio);
fprintf('Audio corr    = %.6f\n', corr_audio);
fprintf('SNR test      = %.1f dB\n', SNR_dB);
%% Pass/fail check
if exist('SNR_dB', 'var')
    rmse_limit = 2e-2;      % relaxed limit for noisy IF test
    corr_limit = 0.999;
    check_name = sprintf('NOISY IF CHECK at %.1f dB SNR', SNR_dB);
else
    rmse_limit = 1e-3;      % strict clean golden-model limit
    corr_limit = 0.999;
    check_name = 'CLEAN GOLDEN MODEL CHECK';
end

if rmse < rmse_limit && corr_val > corr_limit && ...
   rmse_audio < rmse_limit && corr_audio > corr_limit && ...
   num_clipped_low == 0 && num_clipped_high == 0

    fprintf('\n%s: PASS\n', check_name);
else
    fprintf('\n%s: FAIL\n', check_name);
end

%% Export Verilog test vectors: ADC input and centred expected output
adc_mid = 2^(adc_bits-1);

adc_input_u12 = uint16(x_adc_code);
adc_expected_s13 = int16(int32(x_adc_code) - adc_mid);

writematrix(adc_input_u12(:), 'adc_input_u12.txt');
writematrix(adc_expected_s13(:), 'adc_expected_s13.txt');

fprintf('\nExported Verilog test vectors:\n');
fprintf('adc_input_u12.txt\n');
fprintf('adc_expected_s13.txt\n');