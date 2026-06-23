adc = readmatrix("D:\zynq-sdr-fm-bpsk\adc_input_u12.txt");
x = int32(adc) - 2048;

N = length(x);
I = zeros(N,1,'int32');
Q = zeros(N,1,'int32');

for n = 1:N
    switch mod(n-1,4)
        case 0
            I(n) =  x(n);
        case 1
            Q(n) = -x(n);
        case 2
            I(n) = -x(n);
        case 3
            Q(n) =  x(n);
    end
end

% Match the 2-tap Verilog filter.
If = floor(double(I(2:end) + I(1:end-1))/2);
Qf = floor(double(Q(2:end) + Q(1:end-1))/2);

% Match the 16-bit CORDIC phase representation.
cordic_phase = round(atan2(Qf,If)/pi * 8192);
phase_code = 4 * cordic_phase;
phase_code = mod(phase_code + 32768,65536) - 32768;

% Wrapped phase difference.
demod_expected = diff(phase_code);
demod_expected = mod(demod_expected + 32768,65536) - 32768;

writematrix(demod_expected, 'D:\zynq-sdr-fm-bpsk\demod_expected_s16.txt');