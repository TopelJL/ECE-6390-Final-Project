% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

function [pilot_bb, pilot_template, t] = generatePilotSignal(params)
    % Grab system parameters.
    Fs = params.Fs;
    BW = params.B;
    up = params.upsample_factor;
    PN_len = params.PN_len;

    % generate PN (±1) of length PN_len (use maximal length LFSR-friendly lengths)
    pn = 2*randi([0 1], 1, PN_len) - 1;  % length PN_len

    % Upsample PN to sampling rate
    pn_upsampled = upsample(pn, up);

    % simple rectangular pulse shaping by convolution with ones(up)
    pn_shaped = conv(pn_upsampled, ones(1,up), 'same');

    % Time vector for one PN frame
    L = length(pn_shaped);
    t = (0:L-1)/Fs;

    % Represent CW at baseband as constant complex phasor (DC) with amplitude params.A_cw.
    % Use a phase of zero for the reference CW.
    cw_bb = params.A_cw * ones(1, L) * exp(1j*0);  % complex DC phasor

    % BPSK component (real) scaled
    bpsk_bb = params.A_bpsk * pn_shaped;   % real-valued ±1 shaped

    % Composite: sum CW phasor (complex) + BPSK (real part)
    pilot_bb = cw_bb + bpsk_bb;   % complex vector

    % Template: use full composite (conjugated) for matched filtering
    pilot_template = conj(pilot_bb);
end