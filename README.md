ECG Signal Processing Manual
MATLAB Manual for R-Peak Detection and HRV Analysis
1.Purpose:
This manual explains how to use the ECG MATLAB project step-by-step. It is written as a user manual, guiding the user through setup, execution, and interpretation of results.
This project processes ECG signals from the MIT-BIH Arrhythmia Database to:
•	Filter ECG signals
•	Detect R-peaks
•	Compare detected peaks with expert annotations
•	Perform Heart Rate Variability (HRV) analysis

2. Files Included in this Project:
2.1 ECG Data Files:
The following ECG records are included:
•	Record 102: 102.dat, 102.hea, 102.atr, 102.qrs
•	Record 106: 106.dat, 106.hea, 106.atr, 106.qrs
File descriptions:
•	.dat → Raw ECG signal data
•	.hea → Header file (sampling frequency, signal info)
•	.atr → Expert ECG annotations
•	.qrs → QRS detection reference output

2.2 MATLAB Script:
•	ECG102_106.m
Main MATLAB script used to load ECG data, apply filters, detect R-peaks, and perform HRV analysis.

2.3 Output Images:
PNG files in the repository contain screenshots of:
•	ECG waveforms
•	Filtered signals
•	R-peak detection results
•	HRV plots

3. System Requirements:
1. Software: MATLAB (R2020a or later )
2. MATLAB Toolboxes :Signal Processing Toolbox
3. External Library: WFDB Toolbox for MATLAB
Make sure the WFDB Toolbox is installed and added to the MATLAB path.

4. How to Set Up the Project:
Step 1: Install MATLAB
Install MATLAB and ensure the Signal Processing Toolbox is available.
Step 2: Install WFDB Toolbox
Download the WFDB Toolbox for MATLAB and add it to the MATLAB path using:
addpath(genpath('wfdb'))

Step 3: Prepare Project Folder:
•	Place all ECG files and ECG102_106.m in the same directory
•	Set this directory as the MATLAB working directory

5. How to Run the Program:
Step 1: Open MATLAB:
Launch MATLAB and navigate to the project folder.
Step 2: Run the Script:
In the MATLAB Command Window, type:
ECG102_106
Press Enter.
Step 3: Observe Output:
The program will automatically:
•	Load ECG records 102 and 106
•	Apply filtering
•	Detect R-peaks
•	Compare detected peaks with annotations
•	Compute HRV parameters

6. Signal Processing Steps:
6.1 ECG Visualization:
•	Displays a 10-second ECG segment for waveform inspection.
•	Displays a 1-minute ECG segment for rhythm analysis.
6.2 Noise Removal:
The following filters are applied in sequence:
•	High-pass filter (0.5 Hz) → Removes baseline wander
•	Notch filter (60 Hz) → Removes power-line noise
•	Band-pass filter (5–15 Hz) → Enhances QRS complexes.
6.3 R-Peak Detection:
•	R-peaks are detected using the GQRS algorithm.
•	Detected peaks are plotted on the ECG signal for verification.

6.4Evaluation:
Detected R-peaks are compared with expert annotations using a ±50 ms tolerance.
The program calculates:
•	True Positives (TP)
•	False Positives (FP)
•	False Negatives (FN)
•	Sensitivity (%)
•	Positive Predictive Value (PPV %)
Results are displayed in the MATLAB Command Window.

6.5 Heart Rate Variability (HRV) Analysis:
Time-Domain HRV:
•	Mean RR interval
•	SDNN
•	RMSSD
•	pNN50

Frequency-Domain HRV:
•	LF power (0.04–0.15 Hz)
•	HF power (0.15–0.40 Hz)
•	LF/HF ratio


7. Output:
After execution, the user will see:
•	ECG plots (raw and filtered)
•	R-peak markers on ECG
•	RR interval series
•	HRV spectral plots
These plots help evaluate ECG quality, rhythm, and autonomic activity.

8. Common Issues and Solutions:
Issue	Solution
WFDB functions not found	   -      Add WFDB Toolbox to MATLAB path
ECG files not detected	     -    Ensure files are in the working directory
No plots displayed	         -     Check script execution for errors

9. Limitations:
•	Designed for offline ECG analysis
•	HRV frequency analysis requires sufficiently long recordings
•	Results are intended for academic use

10. Conclusion:
This provides step-by-step guidance for using the ECG MATLAB project. By following the instructions, users can successfully perform ECG filtering, R-peak detection, and HRV analysis using standard biomedical datasets.

11. Author Information:
•	Mallicka Mallick, Samia Islam
•	Project: ECG Signal Processing Manual

