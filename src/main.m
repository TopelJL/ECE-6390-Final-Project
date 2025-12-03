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
params.PN_len = 4095;                           % PN length
params.fc = 5.8e9;                              % Carrier frequency (Hz)

% Transmit power: table gives 3 dBW = 2 watts
params.pt = 10^(3/10);                          % 3 dBW → watts = 1.995 = 2 W

% Antenna gains from table
params.Gt = 25;                                 % TX antenna gain (dBi)
params.Gr = 25;                                 % RX antenna gain (dBi)

% GEO range from table
params.R = 36000e3;                             % GEO range (m)

params.noiseFigure = 0;                         % NF handled by C/No instead
params.CNo_dBHz = 45;                           % directly set C/No from table

params.SNR_target = [];                         % REMOVE old SNR requirement

params.upsample_factor = params.Fs / params.B;  % should be integer
params.burst_period = 0.01;                     % Pilot burst period (s)

% PLL from table
params.PLL_BW = 10;                             % PLL bandwidth = 10 Hz
params.phase_update_rate = 20;                  % Keep same

params.num_sats = 25;                           % Number of satellites
params.A_cw = 0.7;                              % relative amplitude of CW tone
params.A_bpsk = 1.0;                            % relative amplitude of PN
params.plot_spectrum = true;

% Jammer configuration
jammer.enable = true;
jammer.rel_power_dB = -10;                      % jammer weaker than signal
jammer.freq_offset = 1e3;                       % 1 kHz away
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

%% === Processing Gain & Diagnostic Plots ===
% Assumes params and pilot_bb exist

% Basic derived values
chip_rate = params.Fs / params.upsample_factor;    % should equal params.B
PN_len = params.PN_len;
R_data = chip_rate / PN_len;                       % if 1 symbol per PN frame
PG_linear = PN_len;
PG_dB = 10*log10(PG_linear);

fprintf('--- Processing Gain ---\n');
fprintf('Chip rate = %.3g Hz\n', chip_rate);
fprintf('Effective data rate (1 frame) = %.6g Hz\n', R_data);
fprintf('Processing gain (linear) = %.3g\n', PG_linear);
fprintf('Processing gain (dB) = %.3f dB\n', PG_dB);