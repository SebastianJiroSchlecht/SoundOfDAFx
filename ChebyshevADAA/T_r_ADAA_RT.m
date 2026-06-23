function [W, xnm1] = T_r_ADAA_RT(k, x, xnm1)
% -------------------------------------------------------------------------
% T_r_ADAA_RT: Real-time computation of antialiased Chebyshev polynomials.
%
% Inputs:
%   k     - Order of the Chebyshev polynomial
%   x     - Current input signal (vector)
%   xnm1  - Previous input sample value (scalar)
%
% Outputs:
%   W     - Computed antialiased Chebyshev polynomial of order k 
%   xnm1  - Updated previous input sample value
%
% Notes:
%   - This function operates in a real-time context by using xnm1 to
%     maintain the previous input sample value across calls.
%   - Antialiasing is achieved using finite differences based on the
%     recursive Chebyshev polynomial definition.
%   - Numerical stability is ensured by handling cases where the denominator
%     approaches zero (defined by TOL).
% -------------------------------------------------------------------------

    % Tolerance for near-zero denominator handling
    TOL = 0.001;

    % Create delayed version of the input signal
    xD = [xnm1; x(1:end-1)]; % Append previous sample to current signal

    % Compute the denominator for finite differences
    denom = x - xD;

    % Handle base cases for k = 0 and k = 1
    if k == 0
        W = ones(size(x)); % T_0(x) = 1
    elseif k == 1
        W = (x + xD) ./ 2; % T_1(x) = (x[n] + x[n-1]) / 2
    else
        % Compute the antialiased Chebyshev polynomial recursively
        W = ((T_r(k + 1, x) - T_r(k + 1, xD)) ./ (2 * (k + 1)) ...
           - (T_r(k - 1, x) - T_r(k - 1, xD)) ./ (2 * (k - 1))) ...
           ./ denom;

        % Handle cases where the denominator is too small (numerical stability)
        near_zero_idx = abs(denom) <= TOL;
        W(near_zero_idx) = T_r(k, (x(near_zero_idx) + xD(near_zero_idx)) / 2);
    end

    % Update the previous input sample for the next call
    xnm1 = x(end);
