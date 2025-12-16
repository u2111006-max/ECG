clc; clear; close all;
records = {'102','106'};   % MIT-BIH records
Fs = 360;                  
time_limit = 10;          

for r = 1:length(records)
    record = records{r};
    fprintf('\nRecord %s \n', record); 
    [ecg, ~, tm] = rdsamp(record, [], []); 
    ecg = ecg(:,1);  % MLII lead
    N = length(ecg);

    fprintf('Loaded ECG with %d samples.\n', N);
    %Task-1
    % Plot 10-second segment
    seg10 = 1:Fs*time_limit;
    figure; plot(tm(seg10), ecg(seg10),'k'); xlabel('Time (s)'); ylabel('Amplitude'); 
    title(['Record ', record,' - 10-sec ECG']); grid on;

    % Plot 1-minute segment
    seg60 = 1:min(Fs*60,N);
    figure; plot(tm(seg60), ecg(seg60),'k'); xlabel('Time (s)'); ylabel('Amplitude'); 
    title(['Record ', record,' - 1-min ECG']); grid on;

    fprintf('Noise sources may include baseline wander, muscle artifacts, and power-line interference.\n');

   
    % High-pass filter (0.5 Hz)
    [b_hp,a_hp] = butter(2, 0.5/(Fs/2), 'high');
    ecg_hp = filtfilt(b_hp,a_hp,ecg);

    % Notch filter (60 Hz)
    wo = 60/(Fs/2); bw = wo/35;
    [b_notch,a_notch] = iirnotch(wo,bw);
    ecg_notch = filtfilt(b_notch,a_notch,ecg_hp);

    % Bandpass 5-15 Hz
    [b_bp,a_bp] = butter(2, [5 15]/(Fs/2), 'bandpass');
    ecg_filtered = filtfilt(b_bp,a_bp,ecg_notch);
    %TASK 2: Noise Removal & Filtering with Plots 
% High-pass filter (baseline wander removal)
[b_hp,a_hp] = butter(2, 0.5/(Fs/2), 'high');
ecg_hp = filtfilt(b_hp,a_hp,ecg);

% Notch filter (power-line interference)
wo = 60/(Fs/2); bw = wo/35;
[b_notch,a_notch] = iirnotch(wo,bw);
ecg_notch = filtfilt(b_notch,a_notch,ecg_hp);

% Bandpass filter (QRS enhancement 5-15 Hz)
[b_bp,a_bp] = butter(2, [5 15]/(Fs/2), 'bandpass');
ecg_filtered = filtfilt(b_bp,a_bp,ecg_notch);

figure('Name',['Record ',record,' - Filtering Steps']);
subplot(4,1,1); plot(tm(1:Fs*10), ecg(1:Fs*10),'k'); xlabel('Time (s)'); ylabel('Amp'); 
title('Raw ECG (10 sec)'); grid on;

subplot(4,1,2); plot(tm(1:Fs*10), ecg_hp(1:Fs*10),'b'); xlabel('Time (s)'); ylabel('Amp'); 
title('High-pass Filtered (0.5 Hz)'); grid on;

subplot(4,1,3); plot(tm(1:Fs*10), ecg_notch(1:Fs*10),'m'); xlabel('Time (s)'); ylabel('Amp'); 
title('High-pass + Notch Filtered (60 Hz)'); grid on;

subplot(4,1,4); plot(tm(1:Fs*10), ecg_filtered(1:Fs*10),'r'); xlabel('Time (s)'); ylabel('Amp'); 
title('High-pass + Notch + Bandpass (5-15 Hz)'); grid on;


%TASK 3: R-Peak Detection (10-sec plot) 
gqrs(record);  % WFDB detector
[qrs_locs, ~] = rdann(record,'qrs');
[ref_locs, ~] = rdann(record,'atr');

% Detection metrics
tolerance = round(0.05*Fs);
TP = 0; FP = 0; matched_ref=false(size(ref_locs));
for i = 1:length(qrs_locs)
    [min_diff, idx] = min(abs(ref_locs - qrs_locs(i)));
    if min_diff <= tolerance && ~matched_ref(idx)
        TP = TP + 1;
        matched_ref(idx) = true;
    else
        FP = FP + 1;
    end
end
FN = sum(~matched_ref);
Sensitivity = TP/(TP+FN)*100;
PPV = TP/(TP+FP)*100;

fprintf('Detected %d R-peaks.\n', length(qrs_locs));
fprintf('TP=%d | FP=%d | FN=%d\n', TP, FP, FN);
fprintf('Sensitivity=%.2f%% | PPV=%.2f%%\n', Sensitivity, PPV);

%Plot detected R-peaks on first 10 sec
seg10 = 1:Fs*10;
figure('Name',['Record ',record,' - R-Peak Detection (10 sec)']);
plot(tm(seg10), ecg_filtered(seg10),'b'); hold on;

% Only R-peaks in first 10 sec
R_10s = qrs_locs(qrs_locs <= seg10(end));
plot(tm(R_10s), ecg_filtered(R_10s),'ro','MarkerSize',6,'LineWidth',1.2');

xlabel('Time (s)'); ylabel('Amplitude'); 
title(['Record ', record,' - Detected R-peaks (10 sec)']); 
grid on;

    %TASK 4: HRV (10-sec plots) 
    % Use R-peaks within first 10 sec
    R_10s_idx = find(qrs_locs/Fs <= time_limit);
    R_10s = qrs_locs(R_10s_idx);
    RR_10s = diff(R_10s)/Fs;
    t_RR_10s = cumsum(RR_10s);

    % Time-domain HRV (full recording)
    RR_full = diff(qrs_locs)/Fs;
    MeanRR = mean(RR_full);
    SDNN = std(RR_full);
    RMSSD = sqrt(mean(diff(RR_full).^2));
    pNN50 = sum(abs(diff(RR_full))>0.05)/length(RR_full)*100;
    fprintf('Time-domain HRV (full):\nMeanRR=%.3f s | SDNN=%.3f s | RMSSD=%.3f s | pNN50=%.2f%%\n',...
        MeanRR, SDNN, RMSSD, pNN50);

    %% Frequency-domain HRV (FULL DATA)
    Fs_HRV = 4;  % resampling rate
    t_RR = cumsum(RR_full); 
    t_interp = 0:1/Fs_HRV:t_RR(end); 
    RR_interp = interp1(t_RR, RR_full, t_interp, 'pchip');

    [pxx, freq] = pwelch(RR_interp, [], [], [], Fs_HRV);
    LF = bandpower(pxx, freq, [0.04 0.15], 'psd');
    HF = bandpower(pxx, freq, [0.15 0.40], 'psd');
    LFHF = LF / HF;

    fprintf('Frequency-domain HRV (full):\n');
    fprintf('LF=%.4f | HF=%.4f | LF/HF=%.3f\n', LF, HF, LFHF);

    % ECG with annotated & detected R-peaks
    figure; plot(tm, ecg_filtered,'b'); hold on;
    plot(ref_locs/Fs, ecg_filtered(ref_locs),'go','DisplayName','Annotated R');
    plot(qrs_locs/Fs, ecg_filtered(qrs_locs),'ro','DisplayName','Detected R');
    xlabel('Time (s)'); ylabel('Amplitude'); title(['Record ', record,' - R-peaks']);
    legend; grid on;

    % RR interval series, tachogram, PSD (10-sec)
    figure; 
    subplot(3,1,1); plot(RR_10s,'-o'); ylabel('RR (s)'); title('RR Intervals (10 sec)'); grid on;
    subplot(3,1,2); plot(t_RR_10s, RR_10s,'-o'); xlabel('Time (s)'); ylabel('RR (s)'); title('RR Tachogram (10 sec)'); grid on;
    subplot(3,1,3); plot(freq,10*log10(pxx),'LineWidth',1.2); xlabel('Hz'); ylabel('Power (dB)');
    
    xlim([0 0.5]); title('RR PSD (10 sec)'); grid on;
end 
%% Frequency-domain HRV (FULL DATA)
    Fs_HRV = 4;  % resampling rate
    t_RR = cumsum(RR_full); 
    t_interp = 0:1/Fs_HRV:t_RR(end); 
    RR_interp = interp1(t_RR, RR_full, t_interp, 'pchip');

    [pxx, freq] = pwelch(RR_interp, [], [], [], Fs_HRV);
    LF = bandpower(pxx, freq, [0.04 0.15], 'psd');
    HF = bandpower(pxx, freq, [0.15 0.40], 'psd');
    LFHF = LF / HF;

    fprintf('Frequency-domain HRV (full):\n');
    fprintf('LF=%.4f | HF=%.4f | LF/HF=%.3f\n', LF, HF, LFHF);