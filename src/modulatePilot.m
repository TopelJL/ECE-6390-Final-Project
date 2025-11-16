% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

function tx = modulatePilot(pilot, params)
    % Sampling frequency
    Fs = params.Fs;

    % Carrier Frequency
    fc = params.fc;
    
    % Time vector
    t = (0:length(pilot)-1)/Fs;

    % BPSK modulation (baseband pilot * carrier)
    carrier = cos(2*pi*fc*t);
    tx = pilot .* carrier;
    
    figure; 
    plot(tx);
    title("Transmitted RF Pilot Signal");
end
