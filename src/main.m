% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

% ==========
% Parameters
% ==========
B = 1e6;        % Bandwidth in Hz
Fs = 10 * B;    % Sampling frequency
N = 100;        % Number of samples
fc = 2e9;        % Carrier frequency in Hz
pt = 1;          % Transmit power in Watts
Gt = 10;         % Gain of the transmitting antenna in dBi
Gr = 10;         % Gain of the receiving antenna in dBi
R = 1000;        % Distance in meters
upsample_factor = 4; % Upsampling factor for the pilot signal

% Generate and upsample the pilot sequence for Modulation
pilot = pilotSignal(B, Fs, N);

% Applies modulation using the carrier frequency
tx_signal = modulatePilot(pilot, fc, Fs);

% Computes received power using Friss equation??
rx_signal = applyPathLoss(tx_signal, pt, Gt, Gr, fc, R);

% RF Link analysis abstracted function ??

% Adds white gaussian noise and jamming to simulate interference
rx = addNoiseAndJamming(rx_signal, pilot, upsample_factor);

% Performs cross-correlation to extract phase offset from pilot reference
phase_offset = estimatePhase(rx_noisy, pilot, upsample_factor);

% Combines received signals coherently or incoherently depending on mode.
beam = combineBeams(rx_signals, phase_offsets, mode);

% Generates plots for visualizing pilot and phase alignment.
plotResults(t, pilot, rx_signal, rx_noisy, phase_offsets)