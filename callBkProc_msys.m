% class definition for  callBkProc_msys
% This function would take a noisy waveform, estimatie its
% stationary noise floor and then attempt to reduce the noise
% Input: fNoisy (the noisy waveform),
%        param (structure holding parameters):
%           binIncre (estimator adjustment rate)
%           gainAlpha (signal level smoother rate)
%           win (the windowing function to be applied)
% output: outClean (the cleaner waveform
%
% Copyright © 2020-2024 The MathWorks, Inc.
% Francis Tiong (ftiong@mathworks.com)
%
classdef callBkProc_msys

    % params to be passed in
    properties
        param = struct('binIncre', 0.1, 'gainAlpha', 0.1, 'hh', ...
            ones(1024,1), 'frameSize', 1, 'fftsize',1);
        outframeSize = 4410
        fftsize = 8820
    end
    % retain mem
    properties
        previnn
        previousFrameLvl
        prevOutput
        countSN
        estNoise_inst
        cmd = 0  
        
    end

    methods(Access = public)
        function obj = callBkProc_msys(param)

            obj.param = param;
            obj.fftsize = param.fftsize;
            obj.outframeSize = param.frameSize;

            
            obj.estNoise_inst = estNoiseFloor_msys(param);
            obj = reset_obj(obj);

        end
        function obj = reset_obj(obj)
            obj.previnn = 0.01*rand(obj.param.frameSize, 1);
            obj.previousFrameLvl = zeros(obj.fftsize, 1);
            obj.prevOutput = zeros(obj.param.frameSize, 1);
            obj.countSN = 0;
        end


    end
    methods
        function obj = set.cmd(obj, in)
            obj.cmd = in;
        end

        function [outClean, obj] = doingStep(obj, fNoisy)

            inx = zeros(obj.fftsize,1);

            %% obtain the amplitude of the signal frame in frequency domain

            obj.countSN = obj.countSN + 1;       % counting the number of frames elapsed, just for debugging

             inn = [ obj.previnn; fNoisy];
             obj.previnn = fNoisy;

            inx(1:obj.fftsize) = inn(1:obj.fftsize);

           fff = fft(inx);

            anglefff = atan2(imag(fff),real(fff));   % remmeber the phase angle, to be applied back after removing noise
            absfff = abs(fff);                       % the amplitude will be used to track and estimate the noise floor

            %% estimate the noise floor
            [temp,obj.estNoise_inst] = obj.estNoise_inst.step( absfff);

            %% calculate and apply an appropriate adjustment to the signal amplitude
            lvlDiff = absfff - temp;         % the temporary clean signal is used to obtain an esimtated level change measure

            % LPF gain change
            obj.previousFrameLvl =  obj.previousFrameLvl*(1-obj.param.gainAlpha) + lvlDiff*obj.param.gainAlpha; % filter the level change measure to obtain a more controlled measure
            temp = absfff -  obj.previousFrameLvl;    % obtain an estimate of a clean spectrum, temp

            %% put the phase back and obtain the time domain signal
            tempout = temp.* (cos(anglefff)+j*sin(anglefff));

            tempout(obj.param.fftsize/2+2:obj.param.fftsize) = conj(tempout(obj.param.fftsize/2:-1:2));

            outt = real( ifft( tempout));


            %% windowing and overlap the output
            outClean = zeros(obj.outframeSize,1);
            for ii=1:obj.outframeSize
                %outClean = outt(1:obj.param.frameSize) .*obj.param.hh(1:obj.param.frameSize) +   obj.prevOutput.*obj.param.hh(obj.param.frameSize+1:end);
                outClean(ii) = outt(ii)* obj.param.hh(ii) + obj.prevOutput(ii) * obj.param.hh(ii+obj.outframeSize);
            end
            obj.prevOutput = outt(obj.param.frameSize+1 : end);

           %% 
           
        end
    end
end
