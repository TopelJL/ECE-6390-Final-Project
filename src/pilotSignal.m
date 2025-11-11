% =======================================================
% ECE 6390 - Satellite Communication & Navigation Systems
% Georgia Institute of Technology
% =======================================================

function pilotSignal = pilotSignal(params)
    % Grab bandwidth
    Fs = params.Fs; % Sampling frequency
    B = params.B;   % Bandwidth
    N = params.N;   % Number of samples
    
    % Generate pilot signal off sampling frequency, bandwidth, and samples
    t = (0:N-1) / Fs; % Time vector
    pilotSignal = cos(2 * pi * B * t); % Generate the pilot signal

    %  plot pilot signal
    plot(t, pilotSignal);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Pilot Signal');
end