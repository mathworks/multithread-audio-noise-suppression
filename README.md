# Multithreaded Audio Apps

## Overview
This application showcases the utilization of multiple threads for processing an audio stream. Users have the option to choose their audio input source, which can be a microphone or an audio file. As the app plays the audio, it actively suppresses static noise in real-time. It operates using a background thread that doesn't rely on the Parallel Computing Toolbox. However, this background thread is restricted from any external I/O interactions, including accessing the audio driver. As a result, it can only carry out signal processing tasks on each data frame. The specific signal processing technique applied in this context is the frame-by-frame suppression of static noise.

## How to get started
Run the below line in MATLAB:
multiThreadAudioApp

## Multithreaded implementation 
To ensure that the user interface remains responsive, it is preferable to make all processing functions in the app non-blocking. This means that only minimal processing should be done when a button(UI) is pressed, and all heavy processing should be done outside of the servicing function. This way, the main thread can focus on monitoring the buttons(UI) as much as possible. After the PLAY button is pressed, the procedure of processing as follows:
1, read a frame of data from the file
2, setup a timer interrupt to process one frame of data
3, send one frame of data to be processed in the background thread
4, when the backgroud work is finished, set the buffer to be send to the audio writer
5, when the timer interrupt expires, send a buffer to the audio writer
6, if the STOP button is not pressed, goto 3.

The audio writer function is a blocking function, which means that the thread will wait at that instruction until the buffer is consumed. To minimize the hold time, it is preferable to call the audio writer when the audio driver is almost starved. This can be achieved by using the tic/toc functions to monitor the time taken to call the audio write function, followed by a pause to adjust the delay time for sending the data. The idea is to set the time interrupt for one time frame and have the audio writer consume one time frame of data. However, the starting time for the frame time for the audio driver and the processing timer interrupt is not synchronized. Therefore, by inserting a delay in the time interrupt, we can adjust to have the two closer to being synchronized, thus reducing the hold time. 

## The audio interfaces and the file reader
In the implemented code, I've utilized audioDeviceWriter and audioDeviceReader for transmitting data to and receiving data from the sound card, respectively. These functions default to using the DirectSound driver on Windows. The design choice to separate the read and write functionalities enables the potential use of two distinct sound cards by adjusting the Device property for each object. If there's a requirement for the sound playback and recording to operate under a unified clock source, opting for the audioPlayerRecorder function is advisable over the separate read and write options. It's important to note that audioPlayerRecorder primarily uses the ASIO driver, in contrast to the DirectSound driver. The ASIO driver facilitates a direct pathway for data to be sent to and received from the sound card, bypassing Windows' control mechanism, which typically results in reduced latency. While it's possible to configure both audioDeviceWriter and audioDeviceReader to utilize the ASIO driver, mixing devices across DirectSound and ASIO drivers is not recommended.  

The AudioFileReader function is designed to extract samples from an audio file, operating on the foreground thread. It is not suitable for use within a background thread. However, if there is a need to read data from a file in a background thread, the audioread function can be utilized as an alternative

## Noise suppression function
The idea is to take the FFT on one frame of data and then use a single-pole tracker on estimate the noise floor of each bin.  The estimated floor is subtracted from each bin and followed by an IFFT using the new magnitude but with the original phase.


## File List
=========  
multiThreadAudioApp.mlapp  	-- this is the code for the application where the GUI is designed and the functions are assigned to the buttons and the signal processing tasks are called. 

estNoiseFloor_msys.m 		-- this function tracks the noise floor of the FFT bins

callBkProc_msys.m		-- this is call back function that is being called per timer expires.  This function does the signal processing on the data. This includes doing the FFT, call estNoiseFloor_msys and IFFT. 

multiThreadAudioApp.pptx	-- A few slides that helps explain what the code is doing.


## Relevant Industries

audio streaming, audio equipments design, audio systems design, web applications, audio applications 

## Relevant Products
 *  MATLAB®
 *  Signal Processing Toolbox™
 *  DSP System Toolbox™ 
 *  Audio Toolbox™


Copyright 2024 The MathWorks, Inc.

