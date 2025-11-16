function [rx_amp_linear, Pr_dBm, EIRP_dBm, FSPL_dB] = computeFriisScaling(params)
    % Computes FSPL and received power given params
    c = 3e8;
    lambda = c / params.fc;
    R = params.R;
    FSPL = (4*pi*R/lambda)^2; % linear
    FSPL_dB = 20*log10(4*pi*R/lambda);

    Pt = params.pt; % Watts
    Gt_lin = 10^(params.Gt/10);
    Gr_lin = 10^(params.Gr/10);

    % Received power (Watts)
    Pr = Pt * Gt_lin * Gr_lin / FSPL;
    Pr_dBm = 10*log10(Pr) + 30;

    % EIRP (dBm)
    EIRP_dBm = 10*log10(Pt*Gt_lin) + 30;

    rx_amp_linear = sqrt(Pr); % RMS amplitude scaling for unit-power baseband

    % return
    rx_amp_linear = rx_amp_linear;
    FSPL_dB = FSPL_dB;
end