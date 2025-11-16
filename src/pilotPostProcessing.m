%% =======================================================
% MATLAB Function: pilotPostProcessing
% =======================================================
function [phase_rmse_deg, SNR_dB_vec] = pilotPostProcessing(rx_bb_no_channel, pilot_template)
%PILOTPOSTPROCESSING Performs Monte-Carlo simulation for pilot-based phase estimation.
%   Calculates the Root Mean Square Error (RMSE) of the phase estimate
%   in degrees across a range of Signal-to-Noise Ratio (SNR) values.

%% --- Setup Parameters ---
SNR_dB_vec = 0:2:30;               % Sweep SNR values (dB)
num_trials = 200;                  % Monte-Carlo trials per SNR
phase_rmse = zeros(size(SNR_dB_vec)); % Initialize RMSE storage (radians)

% Normalize the pilot template to unit-energy
template = pilot_template / sqrt(sum(abs(pilot_template).^2));

% Pre-calculate signal power based on the noise-free received signal
signal_power = mean(abs(rx_bb_no_channel).^2);

% Find the MATLAB version of wrapToPi if not present in older versions (for compatibility)
if exist('wrapToPi','builtin') == 0
    wrapToPi = @(angle_rad) mod(angle_rad + pi, 2*pi) - pi;
end

%% --- Monte-Carlo Simulation Loop ---
disp(' ');
disp('Starting Phase RMSE Monte-Carlo simulation...');
for ii = 1:length(SNR_dB_vec)
    thisSNR = SNR_dB_vec(ii);
    
    % Compute noise power and standard deviation for this SNR
    % NOTE: Assumes noise is calculated relative to signal power (Eb/No)
    noise_power = signal_power / (10^(thisSNR/10));
    noise_sigma = sqrt(noise_power/2); % Sigma for I and Q components
    
    est_err = zeros(1, num_trials); % Initialize error storage for this SNR
    
    for tr = 1:num_trials
        % Random true phase (small variation around 0 rad)
        true_phase = 0.05 * randn; % radians
        
        % Apply the random true phase to the signal
        rx_sig = rx_bb_no_channel .* exp(1j*true_phase);
        
        % Add AWGN for this SNR
        noise = noise_sigma * (randn(size(rx_sig)) + 1j*randn(size(rx_sig)));
        rx_total = rx_sig + noise;
        
        % Matched filter phase estimate
        corr_val = sum(rx_total .* conj(template));
        phi_hat = angle(corr_val);
        
        % Calculate phase estimation error and wrap it to [-pi, pi]
        est_err(tr) = wrapToPi(phi_hat - true_phase);
    end
    
    % Compute Root Mean Square Error (RMSE) for this SNR (radians)
    phase_rmse(ii) = sqrt(mean(est_err.^2));
    
    % Optional: Display progress
    % fprintf('  Completed SNR: %d dB\n', thisSNR);
end
disp('Phase RMSE simulation complete.');

%% --- Convert Results and Plot RMSE vs SNR ---

% Convert RMSE from radians to degrees
phase_rmse_deg = phase_rmse * 180 / pi;

figure('Name','Phase RMSE vs SNR','NumberTitle','off');
plot(SNR_dB_vec, phase_rmse_deg,'-o','LineWidth',1.5);
grid on;
xlabel('SNR (dB)');
ylabel('Phase RMSE (degrees)');
title('Phase Estimation Accuracy vs SNR');

end