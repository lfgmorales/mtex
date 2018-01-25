function value = mean(sF, varargin)
% calculates the mean value for an univariate S2Fun or calculates the mean along a specified dimension fo a multimodal S2Fun
% Syntax
%  value = mean(sF)
%  sF = mean(sF, d)
%
% Options
%   d - dimension to take the mean value over
%
% Example
%   sF is a 3x3 S2Fun
%     snum(sF) returns a 3x3 matrix with the mean values of each function
%     sum(sF, 1) returns a 1x3 S2Fun wich contains the pointwise means values along the first dimension
%

s = size(sF);
if nargin == 1
  sF = sF.subSet(':');
  value = real(sF.fhat(1, :))/sqrt(4*pi);
  value = reshape(value, s);
else
s = size(sF);
  value = sum(sF, varargin{1})./s(varargin{1});
end

end