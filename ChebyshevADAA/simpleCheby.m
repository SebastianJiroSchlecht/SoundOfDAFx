% -------------------------------------------------------------------------
% Sweep-Based Circuit Modeling with Chebyshev ADAA
% -------------------------------------------------------------------------
% Author: Thomas Baker & Christopher Bennett
% Paper: Antiderivative Antialiasing for Chebyshev based Generalized Hammerstein Models
% Journal Information: J. Audio Engineering Society, vol. XX, pp. YY (2025)
% Purpose: Generates a synchronized swept cosine signal, processes it
% through a circuit simulation (e.g., LTSpice), and deconvolves the
% resulting output to generate a Chebyshev-based ADAA nonlinear model.
% License: This code is licensed under the MIT License. You are free to use,
% modify, and distribute it. See the LICENSE file for details.
% -------------------------------------------------------------------------

%% Initialization and Parameters
clear all; close all; clc;

% Sampling frequency
fs = 48000; 

% Sweep parameters
startFreq = 20;         % Start frequency (Hz)
endFreq = fs / 2;       % End frequency (Hz)
approxDuration = 12;    % Approximate duration of the sweep (seconds)
numHarmonics = 15;      % Number of harmonics for the Chebyshev model

% Spectrogram properties (optional, for visualization)
nfft = 2048;            % Number of FFT points
overlap = 1600;         % Overlap for the spectrogram

%% Step 1: Create Synchronized Swept Cosine
% Generate a synchronized swept cosine signal
[sweptCosineSignal, timeVec, sweepLength, sweepDuration, k] = ...
    synchronizedSweptCosine(startFreq, endFreq, approxDuration, 4*fs);

% Save the swept cosine to CSV for use in circuit simulation
csvwrite('sweptCosine.csv', [timeVec', sweptCosineSignal']);

disp('Swept cosine generated and saved as "sweptCosine.csv".');
disp('Pass this signal through your circuit simulation (e.g., LTSpice).');
disp('Save the output of the simulation as "sweptCosine.txt".');

% --- Run LTSpice Simulation ---
% At this stage, you should process the swept cosine signal through your
% circuit in LTSpice or another simulator. Save the output and proceed
% to the next steps.

%% Step 2: Import Circuit Simulation Output
% Import the LTSpice output file (assumes "sweptCosine.txt")
[Vvout, timeVecOut] = importSweptCosine('sweptCosine.txt');
% you can use uiimport() to bring in the output of your SPICE simulation.
% the output voltage signal should be called Vvout, and the time array
% should be timeVecOut, imported as column vectors.

% Resample the output back to 48 kHz to match the original sampling rate
circuitOutput = resample(Vvout, timeVecOut, fs);

%% Step 3: Deconvolve the Circuit Response
% Deconvolve the circuit response to compute the harmonic impulse responses
harmonicImpulseResponses = deconvolveSweptCosine(circuitOutput, ...
    numHarmonics, sweepLength, startFreq, fs);

disp('Harmonic impulse responses generated.');

% at this point you might save the harmonicImpulseResponses matrix to a
% file for easy recall. look at gethm10.m for an example of the HHIRs for
% the wavefolder circuit with 10 harmoics modeled. 

%% Step 4: Example Application with Audio

% Load an example audio file (drums)
[inputAudio, inputFs] = audioread('Drums_dry.mp3');
inputAudio = resample(inputAudio(:, 1), fs, inputFs); % Ensure the sample rate matches

% Process the audio through the Chebyshev-based ADAA model
processedAudio = ChebyshevADAA(inputAudio, numHarmonics, harmonicImpulseResponses);

% Play the processed audio
soundsc(processedAudio, fs);

disp('Processed audio played using Chebyshev ADAA model.');
