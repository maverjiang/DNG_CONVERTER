function dngx_folder(dire,dcc_name,varargin)
% function dngx_folder(dire,dcc_name,varargin)
if nargin < 1
  dire = '.';
end
if nargin < 2
  dcc_name = '';
end
F=dir(fullfile(dire,'*.raw'));
for i=1:length(F)
  n=fullfile(dire,F(i).name);
  dngx(n,dcc_name,varargin{:});
  if exist('stdout','builtin')
    fflush(stdout);
  end
end
