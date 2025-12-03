function plotSimulationResults(params, t, pilot_bb, tx_bb, rx_matrix, phase_offsets_est, P_incoherent, P_coherent)
%   Inputs:
%       params             - System parameters structure (contains num_sats)
%       t                  - Time vector
%       pilot_bb           - Baseband BPSK PN Pilot signal
%       tx_bb              - Composite Transmit Baseband signal (CW + BPSK)
%       rx_matrix          - Matrix of received signals (num_sats x N matrix)
%       phase_offsets_est  - Estimated phase offsets (rad) for each satellite
%       P_incoherent       - Combined power without phase correction (W)
%       P_coherent         - Combined power after phase correction (W)

num_sats = params.num_sats;

%% Figure 1: Pilot & Received Signals
figure('Name','Pilot & Received Signals','NumberTitle','off','Position',[100 100 900 800]);

% Subplot 1: Baseband BPSK PN Pilot
subplot(4,1,1);
plot(t(1:2000), real(pilot_bb(1:2000)));
title('Baseband BPSK PN Pilot (first 2000 samples)');
xlabel('Time (s)'); ylabel('Amplitude');

% Subplot 2: Composite Transmit Baseband
subplot(4,1,2);
plot(t(1:2000), real(tx_bb(1:2000)));
title('Composite Transmit Baseband (CW + BPSK) (first 2000 samples)');
xlabel('Time (s)'); ylabel('Amplitude');

% Subplot 3: Received Magnitude at Satellite 1
subplot(4,1,3);
% Assumes first row of rx_matrix is satellite 1
plot(t(1:2000), abs(rx_matrix(1,1:2000)));
title('Received Magnitude at Satellite 1 (first 2000 samples)');
xlabel('Time (s)'); ylabel('Magnitude');

% Subplot 4: Estimated Phase Offsets
subplot(4,1,4);
bar(1:num_sats, phase_offsets_est);
title('Estimated Phase Offsets (rad) per Satellite');
xlabel('Satellite Index'); ylabel('Phase (rad)');
sgtitle('Pilot Signal Simulation Results');

%% Figure 2: Combination Results
figure('Name','Combination Results','NumberTitle','off');
bar([P_incoherent, P_coherent]);
set(gca, 'XTickLabel', {'Incoherent','Coherent'});
ylabel('Avg Combined Power (W)');
title('Effect of Phase Correction on Combined Power');

end