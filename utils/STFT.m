clear all;
close all;
clc;


% 디렉토리 및 파일 설정
dir_data = '/Volumes/CHOO''S SSD/LINK/Multimodal-Brain-Signal-Analysis/processed_data/eeg-seizure/';
dir_file = '';
save_dir = '/Volumes/CHOO''S SSD/LINK/Multimodal-Brain-Signal-Analysis/processed_data/eeg-seizure/';

% 채널 정보
ch = 2;
prefname = '';
postfname = '_heatmap'; % 저장 파일 이름

% 데이터를 추출할 시간 범위
data_param.t1 = 20; % 시작 시간 (0초 이상의 시간이어야 함)
data_param.t2 = 40; % 끝나는 시간

% Parameter
fft_param.fs = 20000; % 샘플링 주파수
fft_param.wlen = round(fft_param.fs * 0.5); % 윈도우 길이
fft_param.olen = round(fft_param.wlen * 0.9);
fft_param.nfft = fft_param.fs * 20;
fft_param.shifter = 0;
fft_param.beta = 7;

% 파일 이름 생성
fname = sprintf('%s%i', prefname, ch);

% 지정된 채널의 데이터 로드
load([dir_data dir_file 'E_' fname  '.mat']);
eeg_signal = data.y;  % EEG 데이터가 'data.y'에 저장되어 있다고 가정
data.x = data.x - data.x(1); %시간 벡터 data.x의 시작점을 0으로 맞추기 위함
t = data.x; % 이전 코드와 동일한 시간 벡터 사용

% 지정된 시간 범위에 해당하는 인덱스 찾기
start_index = find(t >= data_param.t1, 1);
end_index = find(t <= data_param.t2, 1, 'last');

% 지정된 시간 범위 내의 데이터 추출
extracted_signal = eeg_signal(start_index:end_index);
data_param.extracted_time = t(start_index:end_index);
data_param.extracted_signal = extracted_signal - mean(extracted_signal);

STFFT(data_param, fft_param);

function STFFT(data_param, fft_param)
    fs = fft_param.fs;
    wlen = fft_param.wlen;
    olen = fft_param.olen;
    nfft = fft_param.nfft;
    shifter = fft_param.shifter;
    beta = fft_param.beta;

    t1 = data_param.t1;
    t2 = data_param.t2;
    extracted_time = data_param.extracted_time;
    extracted_signal = data_param.extracted_signal;
    
    % % Notch 필터 설계 및 적용
    % harmonic_freqs = 120:120:1000;
    % notch_bw =10;
    % for i =1:length(harmonic_freqs)
    %     Wn= [(harmonic_freqs(i) - notch_bw/2)  (harmonic_freqs(i) + notch_bw/2)] /(fs/2);
    %     [b,a] = butter(2, Wn, 'stop');
    %     extracted_signal = filtfilt(b,a,extracted_signal);
    % end
    % 
    % harmonic_freqs = 180:180:1000;
    % notch_bw =10;
    % for i =1:length(harmonic_freqs)
    %     Wn= [(harmonic_freqs(i) - notch_bw/2)  (harmonic_freqs(i) + notch_bw/2)] /(fs/2);
    %     [b,a] = butter(2, Wn, 'stop');
    %     extracted_signal = filtfilt(b,a,extracted_signal);
    % end
    % 
    
    % 필터링된 데이터에 대해 STFT 수행
    % win = hann(wlen, 'periodic');
    win = kaiser(wlen,beta);
    
    [S, f, t_stft] = spectrogram(extracted_signal, win, olen, nfft, fs);
    
    
    
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
    t_stft_new = linspace(extracted_time(1), extracted_time(end), size(S, 2));
    
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
    xlim([t1 t2]); % 필요에 따라 시간 범위 조정
    ylim([0 200]); % 주파수 범위를 0-200 Hz로 조정
    
end