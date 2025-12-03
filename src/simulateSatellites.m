function [phase_offsets_est, phase_true, rx_matrix, P_coherent, P_incoherent] = simulateSatellites(params, jammer, rx_bb_no_channel, pilot_template, t)
%   Inputs:
%       params             - System parameters structure (contains num_sats, B, noiseFigure, etc.)
%       jammer             - Jammer parameters structure (contains enable, rel_power_dB, etc.)
%       rx_bb_no_channel   - Received baseband signal without channel phase (1 x N vector)
%       pilot_template     - Known pilot sequence template (1 x N vector)
%       t                  - Time vector (1 x N vector)
%
%   Outputs:
%       phase_offsets_est  - Estimated phase offsets (rad) for each satellite (1 x num_sats vector)
%       phase_true         - True phase offsets (rad) for each satellite (1 x num_sats vector)
%       rx_matrix          - Matrix of received signals (num_sats x N matrix)
%       P_coherent         - Combined power after phase correction (W)
%       P_incoherent       - Combined power without phase correction (W)

num_sats = params.num_sats;
phase_offsets_est = zeros(1,num_sats);
phase_true = zeros(1,num_sats);
rx_matrix = zeros(num_sats, length(rx_bb_no_channel));

%% 1. Noise and Template Setup
% Compute noise variance from noise floor
k = -174; % dBm/Hz (Boltzmann's constant equivalent at room temperature)
N0_dBm = k + 10*log10(params.B) + params.noiseFigure;
N0_linear = 10^((N0_dBm-30)/10); % Noise power spectral density (W) in the bandwidth
noise_sigma = sqrt(N0_linear/2); % per complex dimension (Watts)

% Normalize matched filter template energy
template = pilot_template / sqrt(sum(abs(pilot_template).^2));  % unit-energy template

%% 2. Satellite Simulation Loop
% For each satellite, add independent oscillator drift and noise/jammer, then estimate phase
for ksat = 1:num_sats
    % small random oscillator drift (radians)
    true_phase = 0.05 * randn; % radians (tunable)
    phase_true(ksat) = true_phase;

    % Apply true phase to received baseband
    rx_k = rx_bb_no_channel .* exp(1j*true_phase);

    % Add AWGN with power equal to noise floor
    noise = noise_sigma * (randn(size(rx_k)) + 1j*randn(size(rx_k)));

    % Add jammer if enabled: narrowband complex tone at freq offset
    j = zeros(size(rx_k));
    if jammer.enable
        % Determine jammer amplitude relative to signal power at receiver
        signal_power_W = mean(abs(rx_k).^2);
        jammer_power_W = signal_power_W * 10^(jammer.rel_power_dB/10);
        
        f_offset = jammer.freq_offset; % Hz
        j = sqrt(jammer_power_W) * exp(1j*(2*pi*f_offset.*t + jammer.phase));
    end

    % Total received signal for satellite k
    rx_total = rx_k + noise + j;

    % Store
    rx_matrix(ksat, :) = rx_total;

    % === Phase Estimation ===
    % Use matched filter (correlate with full composite pilot template)
    corr_val = sum(rx_total .* conj(template));   % complex correlation scalar
    phase_offsets_est(ksat) = angle(corr_val);
end

%% 3. Display Results
disp(' ');
disp('--- Satellite Simulation Results ---');
disp('True phases (rad):');
disp(phase_true);
disp('Estimated phases (rad):');
disp(phase_offsets_est);

%% 4. Correct Phase and Combine
% Coherent combination after phase correction
corrected = zeros(1, length(rx_bb_no_channel));
for ksat = 1:num_sats
    % Remove estimated phase
    corrected = corrected + rx_matrix(ksat,:) .* exp(-1j*phase_offsets_est(ksat));
end

% Incoherent combination (no phase correction)
incoherent = sum(rx_matrix, 1);

% Compute combined power
P_coherent = mean(abs(corrected).^2);
P_incoherent = mean(abs(incoherent).^2);

fprintf('Combined power (coherent): %.4e W\n', P_coherent);
fprintf('Combined power (incoherent): %.4e W\n', P_incoherent);
fprintf('Coherent gain vs incoherent (dB): %.2f dB\n', 10*log10(P_coherent/P_incoherent));

end