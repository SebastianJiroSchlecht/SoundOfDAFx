classdef PluggyCheby < audioPlugin
% -------------------------------------------------------------------------
% Sweep-Based Circuit Modeling with Chebyshev ADAA
% -------------------------------------------------------------------------
% Author: Thomas Baker & Christopher Bennett
% Paper: Antiderivative Antialiasing for Chebyshev based Generalized Hammerstein Models
% Journal Information: J. Audio Engineering Society, vol. XX, pp. YY (2025)
% PluggyCheby: Real-time audio plugin implementing a Chebyshev-based ADAA model.
%    This plugin processes audio input using a Chebyshev-based model with
%    antiderivative antialiasing (ADAA). Users can adjust the drive level
%    and output limiter threshold via UI controls.
% License: This code is licensed under the MIT License. You are free to use,
% modify, and distribute it. See the LICENSE file for details.
% -------------------------------------------------------------------------

    properties
        DRIVE = 0;          % Drive parameter in dB
        THRESHOLD = 0;      % Limiter threshold in dB
        fs = 48000;         % Sampling frequency
    end

    properties (Constant)
        PluginInterface = audioPluginInterface(...
            'PluginName', 'PluggyCheby WaveFolder', ...
            'VendorName', 'Digital Audio Theory', ...
            'VendorVersion', '1.3.0', ...
            'UniqueId', 'WF10', ...
            'BackgroundColor', [0.4, 0.4, 0.4], ...
            audioPluginGridLayout(...
                'RowHeight', [100, 200, 25], ...
                'ColumnWidth', [200, 25, 200]), ...
            audioPluginParameter('THRESHOLD', ...
                'Label', 'dB', ...
                'DisplayName', 'Limiter', ...
                'Style', 'RotaryKnob', ...
                'Mapping', {'int', -10, 0}, ...
                'Layout', [2, 3], ...
                'DisplayNameLocation', 'above'), ...
            audioPluginParameter('DRIVE', ...
                'Label', 'dB', ...
                'DisplayName', 'Drive', ...
                'Style', 'RotaryKnob', ...
                'Mapping', {'int', -24, 12}, ...
                'Layout', [2, 1], ...
                'DisplayNameLocation', 'above'));
    end

    properties (Access = private)
        Zleft;              % Filter state for the left channel
        Zright;             % Filter state for the right channel
        hm;                 % Harmonic impulse responses (HHIRs)
        N;                  % Number of harmonics
        LM;                 % Limiter object
        xnm1left;           % Previous input values for left channel
        xnm1right;          % Previous input values for right channel
    end

    methods
        % Constructor
        function plugin = PluggyCheby()
            % Initialize parameters
            plugin.N = 10;                              % Number of harmonics
            plugin.hm = gethm10();                      % Load HHIRs
            plugin.Zleft = zeros(length(plugin.hm)-1, plugin.N);
            plugin.Zright = zeros(length(plugin.hm)-1, plugin.N);
            plugin.xnm1left = zeros(plugin.N, 1);
            plugin.xnm1right = zeros(plugin.N, 1);
            plugin.LM = limiter('Threshold', 0);        % Initialize limiter
        end

        % Main processing method
        function out = process(plugin, in)
            % Initialize output
            out = zeros(size(in));
            drive = db2mag(plugin.DRIVE); % Convert drive to linear scale

            % Process each channel independently
            for ch = 1:size(in, 2)
                if ch == 1
                    % Left channel processing
                    temp = plugin.LM(drive * in(:, 1));
                    [out(:, 1), plugin.Zleft, plugin.xnm1left] = ...
                        ChebyshevRT(temp, plugin.N, plugin.hm, plugin.Zleft, plugin.xnm1left);
                else
                    % Right channel processing
                    temp = plugin.LM(drive * in(:, 2));
                    [out(:, 2), plugin.Zright, plugin.xnm1right] = ...
                        ChebyshevRT(temp, plugin.N, plugin.hm, plugin.Zright, plugin.xnm1right);
                end
            end
        end

        % Setter for DRIVE parameter
        function set.DRIVE(plugin, val)
            plugin.DRIVE = val;
        end

        % Setter for THRESHOLD parameter
        function set.THRESHOLD(plugin, val)
            plugin.THRESHOLD = val;
            plugin.LM.Threshold = val; % Update limiter threshold
        end

        % Reset method
        function reset(plugin)
            plugin.fs = getSampleRate(plugin); % Update sampling rate
        end
    end
end
