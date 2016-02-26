function dng_write_g(raw, thumb, meta_data, dng_name)

% function dng_write_g(raw, thumb, meta_data)
% 
% meta_data.white1
% meta_data.white2
% meta_data.ccm1
% meta_data.ccm2
% meta_data.wb

% compute size of header:
% - byte order: 2
% - 42: 2
% - ifd0 offset: 4
% - size of ifd0 and record ifd0 offset as here
% - size of sub ifd0 and record sub ifd0 offset as here
% - (size of sub ifd1) and record sub ifd1 offset as here
% - size of exif ifd and record exif ifd offset as here
% 
% - size of ifd = 2 + 12N + 4, N = number of entries
% 
% set 'offset' to the total
% 
% write each ifd to its location
% data is written 'offset', and 'offset' incremented by the size


% ifd0
M.thumb_width = size(thumb,2);
M.thumb_height = size(thumb,1);
M.thumbnail_data_offset = nan;
M.sub_ifd_offsets = nan;
M.exif_ifd_offset = nan;
sRGB_to_XYZ = [ ...
   0.412424   0.357579   0.180464
   0.212656   0.715158   0.072186
   0.019332   0.119193   0.950444];

wb1 = diag(1./meta_data.white1);
wb2 = diag(1./meta_data.white2);

% CCM1 = inv(sRGB_to_XYZ*meta_data.ccm1*wb1);
% CCM2 = inv(sRGB_to_XYZ*meta_data.ccm2*wb2);

CCM1 = inv(sRGB_to_XYZ*meta_data.ccm1);
CCM2 = inv(sRGB_to_XYZ*meta_data.ccm2);

M.CCM1 = CCM1;%[   0.831400  -0.289300  -0.043300  -0.661100   1.446700   0.231200      -0.130700   0.196800   0.890100];
M.CCM2 = CCM2;%[0.755900  -0.213000  -0.096500  -0.761100   1.571300   0.197200      -0.247800   0.304200   0.829000];
M.balance = [1 1 1];%[2.3594   1.0000   1.1484];
M.shot_neutral = meta_data.white;%[0.681 1 0.3985];%%[1 1 1];[2.3594   1.0000   1.1484];

%M.CCM1 = [1  0  0 0  1  0 0 0 1];
%M.CCM2 = [1  0  0 0  1  0 0 0 1];

M.orig_name = strrep(dng_name,'.dng','.raw');
M.date_time = meta_data.date_time;
M.version = meta_data.version;
M.version(M.version < ' ') = ' ';
M.make = meta_data.make;
M.model = meta_data.model;
M.copy = 'Copyright...';
M.umodel = [meta_data.make ' ' meta_data.model];
M.iso_speed = meta_data.iso;
M.exposure_time = meta_data.exposure_time;
M.aperture = 2.8;
M.focal_length = 4.628;
% sub_ifd0
M.width = size(raw,2);
M.height = size(raw,1);
M.raw_data_offset = nan;
%M.cfa_pattern = [2   1   1   0];%r0g1b2
%M.white = 4095;
%M.cfa_pattern = [1   0   2   1];
M.cfa_pattern = [0   1   1   2];%rggb
%M.cfa_pattern  = [1   2   0   1];

M.white = 1023;
M.flash = meta_data.flash;

if 1
  % new!!!
  M.bayer_green_split = 1;
  M.anti_alias_strength = 1;
  M.baseline_exposure = -2/3;
  M.baseline_noise = 2;
  M.baseline_sharpness = 1/2;
  M.linear_response_limit = 1;%(1020-64)/1023;
else
  % dng defaults
  M.bayer_green_split = 0;
  M.anti_alias_strength = 1;
  M.baseline_exposure = 0;
  M.baseline_noise = 1;
  M.baseline_sharpness = 1;
  M.linear_response_limit = 1;
end

if isfield(meta_data, 'compression_table')
    compress = 1;
    M.bytes_per_pixel = 1;
    M.compression_table = meta_data.compression_table;
    M.decompression_table = meta_data.decompression_table;
else
    compress = 0;
    M.bytes_per_pixel = 2;
    M.decompression_table = 0:1023;
end

 M.compress = compress;
% M.lensshading = 1;

   M.lensshading_r = meta_data.lensshading_r./64;
   M.lensshading_g = meta_data.lensshading_g./64;
   M.lensshading_b = meta_data.lensshading_b./64;
 

M.numberofopcodegainmaps = 4;    
M.numOfPlanes = 4;       

M.opcodelist_length = 4+4*(16+76+4*32*32);%16756 Sizeofnumberofopcodegainmaps +M.numOfPlanes*(Gainheader_size + M.opcodelist.gainheader_r.OpcodeIDGainMapSize/4);
M.offset_Opcodelist = nan;


ifd0 = dng_ifd0_template(M);
sub_ifd0 = dng_sub_ifd0_template(M);
exif_ifd = dng_exif_ifd_template(M);
M.opcodelist = dng_opcodelist_template(M);

N_ifd0 = length(ifd0);
N_sub_ifd0 = length(sub_ifd0);

N_exif_ifd = length(exif_ifd);

offset_ifd0 = 8;
offset_sub_ifd0 = offset_ifd0 + (2 + 12*N_ifd0 + 4);
offset_exif_ifd =  offset_sub_ifd0 + (2 + 12*N_sub_ifd0 + 4);


offset_data = offset_exif_ifd + (2 + 12*N_exif_ifd + 4);


offset_thumb = offset_data;
sz_thumb = prod(size(thumb));
offset_data = round_up(offset_data + sz_thumb);

offset_raw = offset_data;
sz_raw = M.bytes_per_pixel*prod(size(raw));
offset_data = round_up(offset_data + sz_raw);

M.thumbnail_data_offset = offset_thumb;
M.sub_ifd_offsets = offset_sub_ifd0;
M.exif_ifd_offset = offset_exif_ifd;
M.raw_data_offset = offset_raw;


ifd0 = dng_ifd0_template(M);
sub_ifd0 = dng_sub_ifd0_template(M);
exif_ifd = dng_exif_ifd_template(M);

global data
data = zeros(1,offset_data+20*1024);

byte_order = 'b';
if byte_order == 'b'
  data(1:2) = abs('MM');
else
  data(1:2) = abs('II');
end
data = put2(data, 2, 42, byte_order);
data = put4(data, 4, 8, byte_order);

offset_data = write_ifd_g(ifd0, offset_ifd0, offset_data, byte_order);

offset_data = write_ifd_g(sub_ifd0, offset_sub_ifd0, offset_data, byte_order);

offset_data = write_ifd_g(exif_ifd, offset_exif_ifd, offset_data, byte_order);

offset_opcodelist = offset_data;
M.offset_Opcodelist = offset_opcodelist;
M.opcodelist = dng_opcodelist_template(M);
offset_data = write_opcodelist_g(M.opcodelist, offset_opcodelist, offset_data, byte_order);

for i=1:3
  ch= thumb(:,:,i)';
  ch = ch(:);
  data(offset_thumb+i:3:offset_thumb+sz_thumb) = ch;
end

if 1
    r = uint16(raw'); r=r(:);
    lo = bitand(r,255); %lo = rem(r,256);
    hi = bitshift(r,-8); %hi = floor(r/256);
else
    r = raw'; r=r(:);
    lo = rem(r,256);
    hi = floor(r/256);
end
if ~compress
    if byte_order == 'b'
        data(offset_raw+1:2:offset_raw+sz_raw) = hi;
        data(offset_raw+2:2:offset_raw+sz_raw) = lo;
    else
        data(offset_raw+1:2:offset_raw+sz_raw) = lo;
        data(offset_raw+2:2:offset_raw+sz_raw) = hi;
    end
else
    lo = M.compression_table(r+1);
    data(offset_raw+1:offset_raw+sz_raw) = lo;
end

data = data(1:offset_data);
f=fopen(dng_name,'wb');
fwrite(f,data,'uint8');
fclose(f);
