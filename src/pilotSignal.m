% function named pilotSignal
function pilotSignal = pilotSignal(B, Fs, N)
    % Generate pilot signal off sampling frequency, bandwidth, and samples
    t = (0:N-1) / Fs; % Time vector
    pilotSignal = cos(2 * pi * B * t); % Generate the pilot signal

    %  plot pilot signal
    plot(t, pilotSignal);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Pilot Signal');
end