% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

function [pilot_bb, pilot_template, t] = generatePilotSignal(params)
    % Grab system parameters.
    Fs      = params.Fs;
    up      = params.upsample_factor;
    PN_len  = params.PN_len;

    % Optional flag:
    plot_spectrum = false;
    if isfield(params, "plot_spectrum")
        plot_spectrum = params.plot_spectrum;
    end

    % ---------- Generate PN Sequence ----------
    pn = 2*randi([0 1], 1, PN_len) - 1;

    % Upsample PN to sampling rate
    pn_upsampled = upsample(pn, up);

    % --- OPTIMIZATION: RRC Pulse Shaping ---
    % Define RRC parameters
    span = 6; % Filter span in symbols
    alpha = 0.05; % Roll-off factor (0 < alpha <= 1)
    rrc_filter = rcosdesign(alpha, span, up);
    % Apply RRC pulse shaping
    pn_shaped = conv(pn_upsampled, rrc_filter, 'same');
    % Trim convolution result to match original length (crucial for 'same' with custom filter)
    pn_shaped = pn_shaped(floor(span*up/2)+1 : end-floor(span*up/2)); 
    % If 'same' mode wasn't used: L_pn = length(pn_upsampled); pn_shaped = pn_shaped(ceil(length(rrc_filter)/2):ceil(length(rrc_filter)/2)+L_pn-1);
    % -----------------------------------------

    % Time vector for one PN frame
    L = length(pn_shaped);
    t = (0:L-1) / Fs;

    % ---------- Generate CW Component ----------
    cw_bb = params.A_cw * ones(1, L) .* exp(1j*0);

    % ---------- Generate BPSK DSSS Component ----------
    bpsk_bb = params.A_bpsk * pn_shaped;

    % ---------- Composite Pilot Signal ----------
    pilot_bb = cw_bb + bpsk_bb;

    % ---------- Matched Filter Template ----------
    pilot_template = conj(pilot_bb);

    % =======================================================
    % Optional: Spectrum Plot of Hybrid CW + DSSS Pilot
    % =======================================================
    if plot_spectrum
        Nfft = 4096;
        FFT_vals = fftshift( fft(pilot_bb, Nfft) );
        freq_axis = (-Nfft/2 : Nfft/2-1) * (Fs/Nfft);

        figure;
        plot(freq_axis/1e3, 20*log10(abs(FFT_vals)+1e-12), 'LineWidth', 1.4);
        grid on;
        xlabel('Frequency (kHz)');
        ylabel('Magnitude (dB)');
        title('Spectrum of Hybrid CW + DSSS Pilot Signal');
    end
end
