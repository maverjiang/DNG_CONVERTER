function [image_data, header_data] = read_rapu_raw(filename, header_only, overrides)

if nargin < 2
    header_only = 0;
end
if nargin < 3
    overrides = @no_overrides;
end

if ~isempty(overrides)
    header = feval(overrides);
else
    header = struct;
end

if ~isfield(header, 'byte_order')
    header.byte_order = 'little';
end

little_endian = isequal(header.byte_order,'little');


if nargin < 1 | isempty(filename)
    [filename, pathname] = uigetfile('*.*', 'Select raw file');
    filename = fullfile(pathname,filename)
end

f = fopen(filename,'rb');
if header_only
    A = uint8(fread(f,4096,'uint8'));
else
    A = uint8(fread(f,'uint8'));
end
fclose(f);

file_formats = {...
    {2, 'read_rapu_raw_conf_v2.txt'}, ...
    {3, 'read_rapu_raw_conf_v3.txt'}};
header_done = 0;
format_to_try = 1;

while ~header_done
    
    [offset,field_length,format,name]=textread(file_formats{format_to_try}{2},'%d%d%s%s');
    
    header = struct;
    
    for i=1:length(offset)
        data = double(A(offset(i)+1:offset(i)+field_length(i))');
        if isequal(format{i}, 'a')
            data = char(data(data ~= 0));
        elseif isequal(format{i}, 'i')
            if little_endian
                data = sum(data .* 256.^(0:length(data)-1)); %%%% Rapu
            else
                data = sum(data(end:-1:1) .* 256.^(0:length(data)-1)); %%%% IVE
            end
        else
            error('Invalid format')
        end
    header = setfield(header,name{i},data);
    end
    
    if header.Meta_data_version_number == file_formats{format_to_try}{1}
        header_done = 1;
    else
        format_to_try = format_to_try + 1;
        if format_to_try > length(file_formats)
            error('Header metadata version number not supported')
        end
    end
end


header.raw_data_is_preprocessed = header.Data_format >= 128;
header.original_Data_format = header.Data_format;
header.Data_format = bitand(header.Data_format, 127);

switch header.Data_format
    case {1,3,4}
        bytes_per_pixel = 1;
    case 0
        bytes_per_pixel = 1.25;
    case 2
        bytes_per_pixel = 2;
end


if nargin >= 2
    header = feval(overrides, header);
end


if ~header_only
    width = header.Image_width;
    height = header.Image_height;
    offset = header.Meta_data_length_in_bytes; %!!!!! was like this?
    offset = header.Image_Header_length; %!!!! changed to this
    if bytes_per_pixel == 1
        image_data = A(offset+1 : offset+width*height*bytes_per_pixel);
        image_data = reshape(image_data,[width height])';
        if header.Data_format == 4
            image_data = read_smia_raw_dpcm_decode(image_data);
        end
    elseif bytes_per_pixel == 1.25
        image_data = unpack10(A(offset+1 : offset+width*height*bytes_per_pixel), ...
            width*bytes_per_pixel, width, height);
    else
        image_data = A(offset+1 : offset+width*height*bytes_per_pixel);
        image_data=uint16(image_data(1:2:end))+256*uint16(image_data(2:2:end));
        image_data=reshape(image_data,width,height)';
    end
    
    
    image_data = image_data(header.Non_image_data_rows_at_top+1 : ...
        end-header.Non_image_data_rows_at_bottom, ...
        header.Non_image_data_columns_at_left + 1 : ...
        end - header.Non_image_data_columns_at_right);

    switch header.Bayer_order
        case 1
            image_data = image_data(:,end:-1:1);
        case 2
            image_data = image_data(end:-1:1,:);
        case 3
            image_data = image_data(end:-1:1,end:-1:1);
    end
    header.original_Bayer_order = header.Bayer_order;
    header.Bayer_order = 0;

else
    image_data = [];
end

if nargin >= 2
    [header, image_data] = feval(overrides, header, image_data);
end

header_data = header;



% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

function A = unpack10(b, line_bytes, width, height)
header_rows = 0;

% Reshape the vector b into a matrix
b = reshape(uint16(b),line_bytes,length(b)/line_bytes)';

% Extract image data, i.e., leave out header and footer, and extra bytes 
% at the end of lines
b = b(header_rows+1:header_rows+height, 1:width*5/4);

% Extract the group of four bytes with most significant bits
i = floor((0:width-1)*5/4)+1;
A = 4*b(1:end,i);

% Extract least significant bits
L = b(1:end,5:5:end);

% Add to most significant bits
for k=1:4
    A(1:end,k:4:end) = A(1:end,k:4:end) + bitand(L, 3);
    L = bitshift(L,-2);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [header, image_data] = no_overrides(header, image_data)
if nargin < 1
    header.byte_order = 'little';
end
