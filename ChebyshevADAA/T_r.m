function T = T_r(k, x)
% -------------------------------------------------------------------------
% T_r: Computes the Chebyshev polynomial of the first kind, T_k(x).
%
% Inputs:
%   k - Order of the Chebyshev polynomial (non-negative integer)
%   x - Input signal (vector or matrix)
%
% Output:
%   T - Chebyshev polynomial of order 'k' applied to the input 'x'
%
% Notes:
%   - Uses the recursive relation:
%       T_k(x) = 2 * x * T_{k-1}(x) - T_{k-2}(x)
%     with base cases:
%       T_0(x) = 1
%       T_1(x) = x
% -------------------------------------------------------------------------

    % Initialize output to all ones for base case k = 0
    T = ones(size(x));

    % Handle the base case for k = 1
    if k == 1
        T = x;
    elseif k > 1
        % Initialize the first two terms in the recurrence relation
        prevT = ones(size(x));   % T_0(x)
        currT = x;               % T_1(x)

        % Compute the Chebyshev polynomial recursively for k >= 2
        for i = 2:k
            T = 2 .* x .* currT - prevT;  % Recursive step: T_k(x)
            prevT = currT;               % Update T_{k-2}(x)
            currT = T;                   % Update T_{k-1}(x)
        end
    end
end
