function [sweepSignal, timeVector, sweepLength, sweepDuration, k] = synchronizedSweptCosine(f1, f2, approxDuration, fs)
% -------------------------------------------------------------------------
% synchronizedSweptCosine: Generates a synchronized swept cosine signal.
% 
% Inputs:
%   f1             - Start frequency of the sweep (Hz)
%   f2             - End frequency of the sweep (Hz)
%   approxDuration - Approximate desired duration of the sweep (seconds)
%   fs             - Sampling frequency (Hz)
%
% Outputs:
%   sweepSignal    - Generated swept cosine signal
%   timeVector     - Time vector for the sweep signal
%   sweepLength    - Characteristic time constant (L) of the sweep (seconds)
%   sweepDuration  - Actual duration of the sweep (seconds)
%   k              - Integer number of cycles in the lowest frequency
%
% -------------------------------------------------------------------------

% Calculate the integer number of cycles for the lowest frequency
k = round(f1 * approxDuration / log(f2 / f1));

% Calculate the precise sweep duration (T) based on k
sweepDuration = k * log(f2 / f1) / f1;

% Calculate the characteristic time constant (L)
sweepLength = k / f1;

% Generate the time vector
timeVector = (0:1/fs:sweepDuration-1/fs).';

% Generate the synchronized swept cosine signal
sweepSignal = cos(2 * pi * f1 * sweepLength * (exp(timeVector / sweepLength)));

% -------------------------------------------------------------------------
% Notes:
% - This implementation ensures that the sweep aligns perfectly at its
%   endpoints (synchronized) due to the relationship between f1, f2, and T.
% - The actual sweep duration (sweepDuration) may differ slightly from the
%   desired approximate duration (approxDuration).