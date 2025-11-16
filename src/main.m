% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

clc; clear; close all;

% ==========
% Parameters
% ==========
params.B = 1e6;                                 % Pilot bandwidth (Hz)
params.Fs = 10 * params.B;                      % Sampling frequency (Hz)
params.PN_len = 4095;                           % PN length (use 1023 or 4095)
params.fc = 2.45e9;                             % Carrier freq (Hz)
params.pt = 50;                                 % Transmit power (W)
params.noiseFigure = 3;                         % Rx noise figure (dB)
params.SNR_target = 15;                         % Desired SNR (dB) at satellite
params.Gt = 50;                                 % Ground antenna gain (dBi)
params.Gr = 30;                                 % Satellite antenna gain (dBi)
params.R = 3.6e7;                               % GEO distance (m)
params.upsample_factor = params.Fs / params.B;  % should be integer
params.burst_period = 0.01;                     % Pilot burst period (s)
params.PLL_BW = 0.5;                            % PLL bandwidth (Hz)
params.phase_update_rate = 20;                  % Phase update rate (Hz)
params.num_sats = 5;                            % Number of satellites simulated
params.A_cw = 0.7;                              % relative amplitude of CW tone (complex phasor)
params.A_bpsk = 1.0;                            % relative amplitude of BPSK PN component

% Jammer parameters
jammer.enable = true;
jammer.rel_power_dB = -10;   % Jammer power relative to signal power (dB)
jammer.freq_offset = 1e3;    % narrowband tone offset from carrier (Hz)
jammer.phase = 0;

% Basic checks
if mod(params.upsample_factor,1) ~= 0
    error('Fs must be an integer multiple of BW. Adjust Fs or BW.');
end

% Pilot Signal Design
[pilot_bb, pilot_template, t] = generatePilotSignal(params);

% Transmit Power
[rx_amp_linear, Pr_dBm, EIRP_dBm, FSPL_dB] = computeFriisScaling(params);

fprintf('Free Space Path Loss (dB): %.2f\n', FSPL_dB);
fprintf('Effective Isotropic Radiated Power (dBm): %.2f\n', EIRP_dBm);
fprintf('Pr = Received Power at Satellite (dBm): %.2f\n', Pr_dBm);

% Convert Pr_dBm -> Pr_W -> amplitude scaling
Pr_W = 10^((Pr_dBm - 30)/10);      % Received power in Watts
rx_amp_linear = sqrt(Pr_W);        % RMS amplitude for unit-power baseband

% Scale the pilot baseband to produce received complex baseband amplitude
tx_bb = pilot_bb;                            % baseband transmitted composite (unit amplitude)
rx_bb_no_channel = tx_bb * rx_amp_linear;   % scale so average power ~ Pr_W

% Simulate multiple satellites
[phase_offsets_est, phase_true, rx_matrix, P_coherent, P_incoherent] = simulateSatellites(params, jammer, rx_bb_no_channel, pilot_template, t);

% Call Plotting function
plotSimulationResults(params, t, pilot_bb, tx_bb, rx_matrix, phase_offsets_est, P_incoherent, P_coherent);

% Pilot Signal post processing
[phase_rmse_deg, SNR_dB_vec] = pilotPostProcessing(rx_bb_no_channel, pilot_template);

fprintf('\n--- Pilot Post-Processing Complete ---\n');
fprintf('Min Phase RMSE: %.2f degrees at max SNR (%.0f dB)\n', min(phase_rmse_deg), max(SNR_dB_vec));

