function y = doFilter(x)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 23.2 and DSP System Toolbox 23.2.
% Generated on: 08-Dec-2023 11:37:01

persistent Hd;

if isempty(Hd)
    
    N  = 6;    % Order
    F0 = 0.5;  % Center frequency
    Q  = 2.5;  % Q-factor
    
    h = fdesign.notch('N,F0,Q', N, F0, Q);
    
    Hd = design(h, 'butter', ...
        'SOSScaleNorm', 'Linf');
    
    
    
    set(Hd,'PersistentMemory',true);
    
end

y = filter(Hd,x);

