function W = T_r_ADAA(k, x)
% -------------------------------------------------------------------------
% T_r_ADAA: Computes the antialiased Chebyshev polynomial of order 'k'
%
% Inputs:
%   k - Order of the Chebyshev polynomial
%   x - Input signal
%
% Output:
%   W - Antialiased Chebyshev polynomial of order 'k' applied to the signal
%
% -------------------------------------------------------------------------

    % Tolerance for handling near-zero denominators
    TOL = 0.01;

    % Shifted version of the input signal for finite differencing
    xD = [0; x(1:end-1)]; % Delay the signal by one sample

    % Compute the denominator for finite differencing
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

        % Handle cases where the denominator is too small (to avoid instability)
        near_zero_idx = abs(denom) <= TOL;
        W(near_zero_idx) = T_r(k, (x(near_zero_idx) + xD(near_zero_idx)) / 2);
    end
end
