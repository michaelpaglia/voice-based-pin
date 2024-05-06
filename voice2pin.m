%% ICSI 471/571 Final Project: Spring 2024
%% Michael J. Paglia, Michael A. Smith, Joseph Regan, Proshanto Dabnath

warning('off', 'all');

% Stores user input spectrograms
user_input_spectrograms = cell(1, 5);

% Compute the spectrogram
[audio, Fs] = audioread("AudioPin-Sequence.wav");
audio = audio(:, 1);
[S, F, T, P] = spectrogram(audio, 256, 250, 256, Fs);

% Determine the number of segments to split the spectrogram into
num_segments = 5;

% Calculate the segment length
segment_length = floor(size(P, 2) / num_segments + 1);

% ----------------------------------------
% USER INPUT SPECTROGRAM SLICING & STORAGE
% ----------------------------------------

% Split the spectrogram into segments
for i = 1:num_segments
    startIdx = (i - 1) * segment_length + 1;
    endIdx = i * segment_length;
    
    % Handle the case when the last segment is shorter
    if i == num_segments
        endIdx = size(P, 2);
    end
    
    % Extract the spectrogram segment
    segmentSpectrogram = P(:, startIdx:endIdx);

    Z = 10*log10(segmentSpectrogram + 1e-6); % Convert to dB scale
    Z = (Z - min(Z(:))) / (max(Z(:)) - min(Z(:))); % Normalize to [0, 1]
    
    % Store in stored_spectrograms at respective index
    user_input_spectrograms{i} = im2uint8(Z); % Store as uint8 image

end


% -----------------------------------
% SPECTROGRAM COMPARISON & BEST GUESS
% -----------------------------------

% Initialize cell array of size 10 to store the base spectrograms
stored_spectrograms = cell(1, 10);

for num = 0:9
    % Read the audio file corresponding to num := num-1
    % Create spectrogram and convert to image
    % Store in storedSpectrograms at respective index
    filename = sprintf('%d.wav', num);
    [y, Fs] = audioread(filename);
    y = y(:, 1); % Extract the first channel
    
    % Create spectrogram and convert to image
    [S, F, T, P] = spectrogram(y, 256, 250, 256, Fs);
    P = 10*log10(P + 1e-6); % Convert to dB scale
    P = (P - min(P(:))) / (max(P(:)) - min(P(:))); % Normalize to [0, 1]
    
    % Store in stored_spectrograms at respective index
    stored_spectrograms{num+1} = im2uint8(P); % Store as uint8 image
end

% Initialize an array of sequential guesses. This will be read at the end
% for the GUI.
guess_pin = cell(1, 5);

% Iterate through the array and compare each cell in user input to each
% spectrogram image in the storedSpectrograms. 
% Keep track of the best metric along the way for each (inner) iteration. At the
% end of each (outer) iteration, store the guess number in the
% corresponding entry cell in guess_pin.
for i = 1:length(user_input_spectrograms)
    % Some initially very low metric.
    best_metric = -inf;
    best_guess = 0;
    
    % Iterate through each entry in stored_spectrograms.
    for j = 1:length(stored_spectrograms)
        [~, metric] = imregcorr(user_input_spectrograms{i}, stored_spectrograms{j}, 'translation');
        
        % Keep track of best metric.
        if metric > best_metric
            best_metric = metric;
            best_guess = j - 1; % Subtract 1 to get the actual digit (0-9) to account for zero-based indexing
        end
    end
    
    % Store best guess.
    guess_pin{i} = best_guess;

    fprintf('The number is: %d\n', best_guess);

end

% guess_pin now contains the final answer. GUI will handle visualization.
% Example output:
% [4 5 7 1 9]
