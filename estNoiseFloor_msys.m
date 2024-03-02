% class definition for  estNoiseFloor_msys
% This function estimatie the noise floor for each of the FFT bins
% Input: absfff (absolute valued FFT vector),
%        param (structure holding parameters):
%           binIncre (estimator adjustment rate)
%           fftsize (number of FFT bins)
% output: temp (temporal value indicating the noise floor of each bin)
%
% Copyright © 2020-2024 The MathWorks, Inc.
% Francis Tiong (ftiong@mathworks.com)
%

   %% estimate the noise floor
classdef estNoiseFloor_msys 
      
   % param
   properties   
       binIncre
       fftsize
   end
   % retain mem
   properties   
       binMem          
       count 
   end
   
  methods(Access = public)
      function obj = estNoiseFloor_msys(param)
        obj.fftsize = param.fftsize;
        obj.binIncre = param.binIncre;        
        obj.binMem = ones(obj.fftsize, 1); 
        obj.count = 0;
        obj = reset_obj(obj);
      end
      
    function obj = reset_obj(obj)
        obj.binMem = ones(obj.fftsize, 1);
    end
    
    function [temp, obj] = step(obj, absfff)
       obj.count = obj.count + 1;

       idx = absfff > obj.binMem;           % binMem is the estimate of the noise floor
       obj.binMem(idx) = obj.binMem(idx) + obj.binIncre;
       obj.binMem(~idx) = obj.binMem(~idx) - obj.binIncre;

       temp = absfff - obj.binMem;          % remove the noise floor estimated from the signal
       idxx = temp < 0;                 
       temp(idxx) = obj.binIncre;   % set to a minimal value    
    end
    
  end
end
      