function hm = deconvolveSweptCosine(y, N, L, f1, fs)
% -------------------------------------------------------------------------
% deconvolveSweptCosine: Deconvolve a synchronized swept-cosine signal to
% extract higher harmonic impulse responses (HHIRs).
%
% Inputs:
%   y   - Output signal from the system under test (SUT)
%   N   - Number of harmonics to extract
%   L   - Characteristic time constant of the sweep
%   f1  - Start frequency of the swept cosine (Hz)
%   fs  - Sampling frequency (Hz)
%
% Output:
%   hm  - Matrix of higher harmonic impulse responses (HHIRs) 
%         Each column corresponds to a harmonic
% -------------------------------------------------------------------------

% FFT of the output signal
Y = fft(y) ./ fs; % Normalize FFT by sampling rate
len = length(y);

% Frequency axis
f_ax = linspace(0, fs, len + 1).'; 
f_ax(end) = []; % Remove redundant endpoint

% Analytical expression of the spectrum of the synchronized swept cosine
% Ref: Novak et al. (2015), JAES 63(10), Eq. (42)
X = (1/2) * sqrt(L ./ f_ax) .* ...
    exp(1i * 2 * pi * f_ax * L .* (1 - log(f_ax / f1)) + 1i * pi / 4);

% Deconvolution
H = Y ./ X; 
H(1) = 0; % Avoid Inf at DC
h = ifft(H, 'symmetric'); % Compute the impulse response in time domain

% Apply correction factor (empirical +1 dB adjustment)
h = h * 1.122;

% Define higher harmonic impulse response (HHIR) separation parameters
dt = L .* log(1:N) .* fs;  % Time positions of harmonic IRs (samples)
dt_rounded = round(dt);    % Rounded positions (integer samples)
dt_fractional = dt - dt_rounded; % Non-integer remainder of sample positions

% Circular periodization for impulse responses
len_IR = 2^7;       % Length of each separated IR
pre_IR = len_IR / 2; % Pre-padding for alignment
h_padded = [h; h(1:len_IR)]; % Extend h for circular periodization

% Frequency axis for fractional delay correction
freq_axis = linspace(0, 2 * pi, len_IR + 1).'; 
freq_axis(end) = [];

% Initialize HHIR matrix
hm = zeros(len_IR, N);

% Extract HHIRs
st_end = length(h_padded); % Last available sample for IR extraction
for n = 1:N
    % Determine start and end positions for the n-th IR
    start_idx = length(h) - dt_rounded(n) - pre_IR;
    end_idx = min(start_idx + len_IR, st_end);
    
    % Extract the n-th IR
    hm(1:end_idx - start_idx, n) = h_padded(start_idx + 1:end_idx);
    
    % Apply fractional delay correction
    H_fft = fft(hm(:, n)) .* exp(-1i * dt_fractional(n) * freq_axis);
    hm(:, n) = ifft(H_fft, 'symmetric');
    
    % Update endpoint for the next harmonic
    st_end = start_idx - 1;
end

% -------------------------------------------------------------------------
% Notes:
% - This implementation follows the methodology described in Novak et al.
% - The extracted HHIRs are stored as columns in the output matrix 'hm'.
% -------------------------------------------------------------------------
end
