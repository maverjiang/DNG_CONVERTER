function A = read_plain_raw3_wh(file_name,width1,height1,type,offset,order)

% A = read_plain_raw3(file_name,width,height,type,offset,order)
%
% read raw file in plain format, i.e., either 1 or 2 bytes per pixel
%
% Default is 2 bytes per pixel, width and height are guessed automatically
%
% file_name
% width
% height
% type: 'uint8' or 'uint16' (default): 8 or 16bits / pxl
% offset: number of bytes to skip in the beginning of the file
% order: byte order, 'pc' or 'mac'


if nargin == 0 || isempty(file_name)
    [filename, pathname] = uigetfile({'*.*';'*.raw';'*.bin'}, 'Select raw file');
    file_name = fullfile(pathname,filename)
end

if nargin < 6
    order = 'pc';
end
if ~(isequal(order,'pc') || isequal(order,'mac'))
    error('Byte order must be either pc or mac');
end
if nargin < 5
    offset = 0;
end

options = struct;
max_height = inf;
max_width = inf;
if nargin == 2
    options = width;
    if isfield(options,'max_size') && ~isempty(options.max_size)
        max_height = options.max_size(1);
        max_width = options.max_size(2);
    end
end


% try to guess image dimension and is it 8 or 16bit
% works if image dimension is exactly 4:3 and there's no ancillary data
% or, if the size is one of the following, with at most Z bytes of ancillary data

sizes = [2592 1968	% stingray
    1296 984 % Stingray TSB 2x2 binned
    864 656  % Stingray TSB 3x3 binned
    656 492  % Stingray TSB 4x4 binned
    2592 1944;	% shark5
    2592-4 1944-4; % shark5 after rapu ccdc
    2048 1536;	% shark3
    1600 1200;  % 2MP
    1040 774;	% TSB EDOF TS2 preview
    2608 1962;  % Carp Sharp test raw data
    644 484; % AcmeMini TSB ES2
    max_width max_height];

Z = 5000;

if nargin < 3
    I = dir(file_name);
    if isempty(I)
        error(['File not found: ' file_name])
    end
    height = sqrt(.75*I.bytes);
    width = 4/3*height;
    type = 'uint8';
    if abs(height - round(height)) > 1e-10
        height = sqrt(.75*I.bytes/2);
        width = 4/3*height;
        type = 'uint16';
        if abs(height - round(height)) > 1e-10
            height = -1;
            for i=1:size(sizes,1)
                z = 2*prod(sizes(i,:));
                if I.bytes >= z && I.bytes < z+Z
                    height = sizes(i,2);
                    width = sizes(i,1);
                    break;
                end
            end
            if height < 0
                % Try another way of guessing the size
                h=round(sqrt(I.bytes/2/(4/3))/2)*2;
                w=round(I.bytes/2/sqrt(I.bytes/2/(4/3))/2)*2;
                [k1,k2]=meshgrid(-32:2:32);
                [i,j] = find((I.bytes - 2*(h-k1).*(w-k2) == 0) & ...
                             (w-k2 <= max_width) & (h-k1 <= max_height));
                if length(i) == 1 && length(j) == 1
                    width = w-k2(i,j);
                    height = h-k1(i,j);
                else
                    width = w;
                    height = h;
                    warning('Unknown size?');
                    texts = {'Width', 'Height'};
                    defaults = {num2str(width), num2str(height)};
                    answers = inputdlg(texts,sprintf('Approximate size %dx%d',width,height),1,defaults);
                    if isempty(answers)
                        error('Size?')
                    end
                    width = eval(answers{1});
                    height = eval(answers{2});
                    extra_bytes_left_in_file = I.bytes - width*height*2
                    if extra_bytes_left_in_file ~= 0
                        warning('Dimensions do not match file size')
                    end
                end
            end
        end
    end
end

% default number of bits
if nargin == 3
    type = 'uint16';
end

width=width1;
height=height1;

% read it
f=fopen(file_name);
fread(f,[offset 1],'uint8');
A=fread(f,[width height],type)';
if isequal(order,'mac')
    A = floor(A/256) + rem(A,256)*256;
end
fclose(f);
