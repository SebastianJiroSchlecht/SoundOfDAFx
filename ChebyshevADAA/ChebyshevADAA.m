function [y, time_ADAA] = ChebyshevADAA(input_signal, num_harmonics, hhirs)
% -------------------------------------------------------------------------
% ChebyshevADAA: Process an input signal using a Chebyshev-based ADAA model.
%
% Inputs:
%   input_signal   - Input signal to be processed
%   num_harmonics  - Number of harmonics to model
%   hhirs           - Higher Harmonic Impulse Responses (HHIRs)
%
% Outputs:
%   y              - Output signal after ADAA processing
%   time_ADAA      - Computation time for processing
% -------------------------------------------------------------------------

% Get the filter order (based on HHIR length)
filter_order = length(hhirs);

% Add (near)zero-padding to account for filter delay
padded_input = [input_signal; 0.0001 * rand(filter_order / 2, size(input_signal, 2))];

% Initialize arrays for Chebyshev polynomials and convolution results
chebyshev_polynomials = zeros(length(padded_input), num_harmonics);
convolved_polynomials = zeros(length(padded_input), num_harmonics);

% Initialize output signal
processed_signal = zeros(size(padded_input));

% Start measuring processing time
tic;

% Loop through each harmonic and compute the ADAA output
for harmonic_idx = 1:num_harmonics
    % Generate the antialiased Chebyshev polynomial for the current harmonic
    chebyshev_polynomials(:, harmonic_idx) = T_r_ADAA(harmonic_idx, padded_input);

    % Convolve the HHIR with the antialiased Chebyshev polynomial
    convolved_polynomials(:, harmonic_idx) = filter(hhirs(:, harmonic_idx), 1, chebyshev_polynomials(:, harmonic_idx));
    
    % Sum the contributions of the current harmonic to the total output
    processed_signal = processed_signal + convolved_polynomials(:, harmonic_idx);
end

% Measure elapsed time for ADAA processing
time_ADAA = toc;

% Remove the filter delay caused by zero-padding
y = processed_signal(filter_order / 2 + 1:end);

% -------------------------------------------------------------------------
% Notes:
% - T_r_ADAA(harmonic_idx, padded_input) should generate the antialiased 
%   Chebyshev polynomial for the current harmonic.
% - HHIRs (Higher Harmonic Impulse Responses) are pre-computed and provided
%   as input for convolution with Chebyshev polynomials.
% - Ensure the HHIRs and input signal are sampled at the same rate.
% -------------------------------------------------------------------------
end
