% clear all;
% close all;
% clc;
% 
% % 디렉토리 및 파일 설정
% dir_data = 'C:\Users\user\sean\lfp_frequency\Codes\Recording\0719\';
% dir_file = '';
% save_dir = 'C:\Users\user\sean\lfp_frequency\Codes\Recording\0719\';
% 
% % 채널 정보
% ch = 2;
% prefname = '';
% postfname = '_heatmap'; % 저장 파일 이름
% 
% % 데이터를 추출할 시간 범위
% t1 = 19.5; % 시작 시간 (0초 이상의 시간이어야 함)
% t2 = 20; % 끝나는 시간
% 
% % 파일 이름 생성
% fname = sprintf('%s%i', prefname, ch);
% 
% % 지정된 채널의 데이터 로드
% load([dir_data dir_file 'E_' fname  '.mat']);
% eeg_signal = data.y;  % EEG 데이터가 'data.y'에 저장되어 있다고 가정
% data.x = data.x - data.x(1); %시간 벡터 data.x의 시작점을 0으로 맞추기 위함
% t = data.x; % 이전 코드와 동일한 시간 벡터 사용
% 
% % 지정된 시간 범위에 해당하는 인덱스 찾기
% start_index = find(t >= t1, 1);
% end_index = find(t <= t2, 1, 'last');
% 
% % 지정된 시간 범위 내의 데이터 추출
% extracted_signal = eeg_signal(start_index:end_index);
% extracted_time = t(start_index:end_index);
% 
% extracted_signal = extracted_signal - mean(extracted_signal);
Fs_sine = 1000;          % Sampling frequency (Hz)
f_sine = 10;             % Frequency of sine wave (Hz)
T = 2;              % Duration (seconds)
A = 1;              % Amplitude of sine wave

% Time vector (discrete)
t_s = 0:1/Fs_sine:T;       % Time from 0 to T with Fs samples per second

% Sine wave
extracted_signal = A * sin(2 * pi * f_sine * t_s);
extracted_time = t_s;

% STFT 분석을 위한 파라미터 정의
alpha = [0.02, 0.03, 0.04, 0.05];
beta = [0.6, 0.7, 0.85, 0.93];

fs = 20000; % 샘플링 주파수
nfft = fs * 20; % FFT 점수 설정

% 4x4 subplot 생성
figure('Units', 'inches', 'Position', [1 1 16 12]);
plot_idx = 1;

for i = 1:length(alpha)
    for j = 1:length(beta)
        wlen = round(fs * alpha(i)); % 윈도우 길이
        hop = round(wlen * beta(j));

        % Hamming 윈도우 생성
        win = hamming(wlen, 'periodic');

        % STFT 계산
        [S, f, t_stft] = spectrogram(extracted_signal, win, hop, nfft, fs);

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

        % 진폭 스펙트럼을 dB로 변환
        S_smooth = imgaussfilt(abs(S), 1); % Apply Gaussian smoothing
        S_dB = 20 * log10(S_smooth + eps);

        % STFT 시간 벡터를 추출된 시간에 맞게 조정
        t_stft_new = linspace(extracted_time(1), extracted_time(end), size(S, 2));

        % 서브플롯에 결과 플롯
        subplot(4, 4, plot_idx);
        surf(t_stft_new, f, S_dB, 'edgecolor', 'none');
        axis tight;
        view(0, 90);
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
        xlabel('Time (s)', 'FontSize', 10);
        ylabel('Frequency (Hz)', 'FontSize', 10);
        title(sprintf('Alpha=%.2f, Beta=%.2f', alpha(i), beta(j)), 'FontSize', 10);
        colormap('jet');
        caxis([0 80]); % 진폭 범위 조정
        xlim([t1 t2]); % 시간 범위 조정
        ylim([0 150]); % 주파수 범위 조정

        % 플롯 인덱스 업데이트
        plot_idx = plot_idx + 1;
    end
end

% 컬러바 추가 (공유 컬러바)
h = colorbar('Position', [0.92 0.11 0.02 0.8]);
set(h, 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel(h, 'Magnitude (dB)', 'FontSize', 12);
