% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

clc; clear; close all;
% ==========
% Parameters
% ==========
params.B = 1e6;        % Bandwidth in Hz
params.Fs = 10 * params.B;    % Sampling frequency
params.N = 100;        % Number of samples
params.fc = 2e9;        % Carrier frequency in Hz
params.pt = 1;          % Transmit power in Watts
params.Gt = 10;         % Gain of the transmitting antenna in dBi
params.Gr = 10;         % Gain of the receiving antenna in dBi
params.R = 1000;        % Distance in meters
params.upsample_factor = 4; % Upsampling factor for the pilot signal

% =======================================================
%                   PILOT SIGNAL DESIGN

% Generate and upsample the pilot sequence for Modulation
pilot = pilotSignal(params);

% Applies modulation using the carrier frequency
tx_signal = modulatePilot(pilot, params);
% =======================================================

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