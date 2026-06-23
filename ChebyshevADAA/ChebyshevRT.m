function [y, Z, xnm1] = ChebyshevRT(x, N, hm, Z, xnm1)
% -------------------------------------------------------------------------
% ChebyshevRT: Real-time processing using a Chebyshev-based model.
%
% Inputs:
%   x     - Input signal (vector)
%   N     - Number of harmonics to model
%   hm    - Higher Harmonic Impulse Responses (HHIRs)
%   Z     - Filter states for each harmonic (matrix of size [filterOrder, N])
%   xnm1  - Previous input signal values for each harmonic (vector of size [N, 1])
%
% Outputs:
%   y     - Output signal after real-time processing
%   Z     - Updated filter states for each harmonic
%   xnm1  - Updated previous input values for Chebyshev polynomials
%
% Notes:
%   - This function is optimized for real-time applications by maintaining
%     filter states (Z) and previous input values (xnm1) across calls.
%   - Chebyshev polynomials are computed recursively in real-time using
%     T_r_ADAA_RT, which ensures efficient updates for each harmonic.
% -------------------------------------------------------------------------

% Initialize the output signal
y = zeros(size(x));

% Loop through each harmonic to compute and accumulate contributions
for harmonicIdx = 1:N
    % Compute the antialiased Chebyshev polynomial for the current harmonic
    [chebyshevADAA, xnm1(harmonicIdx)] = T_r_ADAA_RT(harmonicIdx, x, xnm1(harmonicIdx));

    % Apply the HHIR filter in real-time
    [convolvedADAA, Z(:, harmonicIdx)] = filter(hm(:, harmonicIdx), 1, chebyshevADAA, Z(:, harmonicIdx));

    % Accumulate the contribution of the current harmonic to the output
    y = y + convolvedADAA;
end

