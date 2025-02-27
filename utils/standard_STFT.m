clear all;
close all;
clc;

% Generate example signal with oscillating frequency
Fs = 20000; % Sampling frequency
T = 10; % Duration in seconds
f1 = 50; % Frequency 1 in Hz
f2 = 100; % Frequency 2 in Hz
duration = 10; % Duration for each frequency

% Spectrogram parameters
% wlen = round(Fs * 0.09); % Window length
% hop = round(wlen * 0.7); % Hop size

% Original
wlen = Fs*0.2; % 윈도우 길이
hop = wlen*0.9; % hop size (hop size를 늘리면 주파수 해상도 증가)
nfft = 8192*16; % FFT 포인트 수 (주파수 해상도를 높이려면 증가시킴)

% Get artificial Signal
signal = signal_generation(Fs, T, f1, f2, duration);

% Plot FFT
plotFFT(signal, Fs, f1, f2);

% Plot Spectrogram
Original(signal, Fs, T, wlen, hop, nfft);
STFT(signal, T);

function [signal] = signal_generation(Fs, T, f1, f2, dur)
    t = 0:1/Fs:T;
    signal = zeros(size(t));
    samples_per_segment = round(dur * Fs);
    num_segments = floor(length(t) / samples_per_segment);
    for k = 0:num_segments-1
        start_idx = k * samples_per_segment + 1;
        end_idx = min((k+1) * samples_per_segment, length(t));
        if mod(k, 2) == 0
            freq = f1; % Use frequency f1
        else
            freq = f2; % Use frequency f2
        end
    signal(start_idx:end_idx) = 30 * sin(2 * pi * freq * t(start_idx:end_idx));
    end
end

function plotFFT(signal, fs, f1, f2)
    % Inputs:
    % - signal: Input time-domain signal
    % - fs: Sampling frequency (Hz)

    % FFT Parameters
    f_max = max(f1, f2);
    nfft = fs * 20; % Zero-padding factor
    Y = fft(signal, nfft); % Compute FFT
    f = (0:nfft-1) * (fs / nfft); % Frequency vector

    % Normalize the FFT result
    Y_magnitude = abs(Y) / length(signal); % Normalize magnitude
    Y_magnitude(2:end-1) = 2 * Y_magnitude(2:end-1); % Adjust for single-sided spectrum

    % Limit to Nyquist frequency
    nyquist_limit = fs / 2;
    freq_indices = f <= nyquist_limit; % Indices of valid frequencies
    f = f(freq_indices); % Truncated frequency vector
    Y_magnitude = Y_magnitude(freq_indices); % Truncated FFT result

    % Plot FFT
    figure;
    plot(f, Y_magnitude, 'LineWidth', 1.5);
    grid on;
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
    xlabel('Frequency (Hz)', 'FontSize', 12);
    ylabel('Amplitude', 'FontSize', 12);
    title('Single-Window FFT of Signal', 'FontSize', 12);
    xlim([0 f_max*2]); % Display up to Nyquist frequency
end

function Original(signal, fs, T, wlen, hop, nfft)
    % Inputs:
    % - signal: Input time-domain signal

    % 필터링된 데이터에 대해 STFT 수행
    win = hann(wlen, 'periodic');
    [S, f, ~] = spectrogram(signal, win, hop, nfft, fs);

    % 윈도우의 코히어런트 증폭 계산
    C = sum(win) / wlen;

    % STFT의 진폭 계산 및 스케일링
    S = abs(S) / wlen / C;

    % DC 및 나이퀴스트 성분의 보정
    if rem(nfft, 2) % nfft가 홀수인 경우, 나이퀴스트 포인트를 제외함
        S(2:end, :) = S(2:end, :) * 2;
    else % nfft가 짝수인 경우, 나이퀴스트 포인트를 포함함
        S(2:end-1, :) = S(2:end-1, :) * 2;
    end

    % 진폭 스펙트럼을 dB로 변환 (최소 = -120 dB)
    S_dB = 20 * log10(S + eps);
    clim_max = max(S_dB(:));
    clim_min = min(S_dB(:));

    % STFT 시간 벡터를 추출된 시간에 맞게 조정
    t_stft_new = linspace(0, T, size(S, 2));

    % 지정된 시간 범위 내에서 고해상도의 스펙트로그램 플롯
    figure('Units', 'inches', 'Position', [1 1 12 6]);
    surf(t_stft_new, f, S_dB, 'edgecolor', 'none');
    axis tight;
    view(0, 90);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Frequency (Hz)', 'FontSize', 12);
    title('Amplitude Spectrogram of the Signal', 'FontSize', 12);
    colormap('jet');
    h = colorbar('FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.5);
    ylabel(h, 'Magnitude (dB)', 'FontName', 'Times New Roman', 'FontSize', 12); % 여기에 텍스트 추가
    caxis([clim_min clim_max]); % 필요에 따라 진폭 범위 조정
    xlim([0 T]); % 필요에 따라 시간 범위 조정
    ylim([0 200]); % 주파수 범위를 0-200 Hz로 조정
end

function STFT(signal, T)
    extracted_signal = signal;
    fs = 20000; % 샘플링 주파수
    wlen = round(fs * 0.9); % 윈도우 길이
    noverlap = round(wlen * 0.90);
    nfft = fs * 20; 
    
    % 필터링된 데이터에 대해 STFT 수행
    % win = hann(wlen, 'periodic');
    beta = 9;
    win = kaiser(wlen,beta);
    
    [S, f, t_stft] = spectrogram(extracted_signal, win, noverlap, nfft, fs);
    
    
    
    % 윈도우의 코히어런트 증폭 계산
    % C = sum(win) / wlen;
    
    % STFT의 진폭 계산 및 스케일링
    S = abs(S);
    
    % DC 및 나이퀴스트 성분의 보정
    if rem(nfft, 2) % nfft가 홀수인 경우, 나이퀴스트 포인트를 제외함
        S(2:end, :) = S(2:end, :) * 2;
    else % nfft가 짝수인 경우, 나이퀴스트 포인트를 포함함
        S(2:end-1, :) = S(2:end-1, :) * 2;
    end
    
    % 진폭 스펙트럼을 dB로 변환 (최소 = -120 dB)
    S_smooth = imgaussfilt(abs(S), 1); % Apply Gaussian smoothing
    S_dB = 20 * log10(S_smooth + eps);
    % S_dB = 20 * log10(S + eps);
    
    % STFT 시간 벡터를 추출된 시간에 맞게 조정
    t_stft_new = linspace(0, T, size(S, 2));
    
    shifter = 20;
    clim_max = max(S_dB(:)) + shifter;
    clim_min = min(S_dB(:)) + shifter;
    
    % 지정된 시간 범위 내에서 고해상도의 스펙트로그램 플롯
    figure('Units', 'inches', 'Position', [1 1 12 6]);
    surf(t_stft_new, f, S_dB, 'edgecolor', 'none');
    axis tight;
    view(0, 90);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
    xlabel('Time (s)', 'FontSize', 12);
    ylabel('Frequency (Hz)', 'FontSize', 12);
    title('Amplitude Spectrogram of the Signal', 'FontSize', 12);
    colormap('jet');
    h = colorbar('FontName', 'Times New Roman', 'FontSize', 12, 'LineWidth', 1.5);
    ylabel(h, 'Magnitude (dB)', 'FontName', 'Times New Roman', 'FontSize', 12); % 여기에 텍스트 추가
    caxis([clim_min clim_max]); % 필요에 따라 진폭 범위 조정
    xlim([0 T]); % 필요에 따라 시간 범위 조정
    ylim([0 200]); % 주파수 범위를 0-200 Hz로 조정
    
end