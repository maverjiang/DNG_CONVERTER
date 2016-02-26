function dngx(raw_name,dcc_name,varargin)

% function dngx(raw_name,dcc_name,varargin)

%!!! TO DO:
% - Allow selecting input raw file format
% - LSC never done, assuming raw data is already LSC'd
% - Pedestal subtraction not fully implemented



% Stupid matlab random number generator always starts from same value,
% unless specially initialized:
%!!! TO DO: use MD5 hash instead of random numbers
rand('twister',sum(100*clock));


if nargin < 2
  dcc_name = '';
end

%dng_name = [raw_name '_' strrep(strrep(datestr(clock,31),':','-'),' ','_') '.dng'];
dng_name = strrep(raw_name, '.raw', '.dng');
if isequal(dng_name, raw_name)
  dng_name = [raw_name '.dng'];
end

compression = 1;

i=1;
while i<=length(varargin)
    switch varargin{i}
        case 'output_directory'
            output_dire = varargin{i+1};
            dng_name = fullfile(output_dire, [basename(dng_name) '.dng']);
        case 'camera'
            camera_name = varargin{i+1};
        case 'compress'
            compression = varargin{i+1};
        otherwise
            warning(['Unknown option ' varargin{i} ', value ' varargin{i+1}])
    end
    i = i+2;
end

%dng_name
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load raw
disp(['Opening raw file ' raw_name])
% Try different formats one after another
try
    try
        [raw,header]=read_rapu_raw(raw_name);
        %!!! TO DO: 
        % check header for flag if pedestal and LSC has already been done
    catch
        header.Phone_manufacturer = 'dummy1';
        header.Phone_model = 'dummy2';
        header.Camera_SW_version = 'dummy3';
        header.Phone_SW_version = 'dummy4';
        header.Phone_IMEI_number = 'dummy5';
        header.Flash_Status = 0;
        try
            [raw,header1]=read_smia_raw(raw_name,10,13);
            raw = max(0, raw-64);
            header.Exposure_Time_in_microseconds = header1.integration_time_us;
            header.Global_Analog_Gain = header1.analogue_gain_multiplier;
            header.Global_Analog_Gain_Divider = 1;
            header.Flash_Status = 0;
        catch
            raw = read_plain_raw3(raw_name);
            %!!! TO DO:
            % Get pedestal value from DCC, and do this below
            raw = max(0, raw-64);
            header.Exposure_Time_in_microseconds = 10;
            header.Global_Analog_Gain = 1;
            header.Global_Analog_Gain_Divider = 1;
        end
    end
catch
  disp(['Cannot open raw file ' raw_name])
  return
end
raw = double(raw);
%toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load nvm
% ...
try
    nvm_filename = strrep(raw_name, '.raw', '.jpg_IspRnDdata.bin');
    nvm = read_nvm_from_mkn(nvm_filename);
    nvmp = parse_nvm(nvm, camera_name);
    this_sensitivity = nvmp.grid((size(nvmp.grid,1)+1)/2, (size(nvmp.grid,2)+1)/2, :);
    this_sensitivity = this_sensitivity(:)';
    disp('. NVM data loaded from makernote')
catch
    this_sensitivity = [];
    disp('. No NVM data')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load DCC
% ...
lut = [];

if nargin >= 2 && ~isempty(dcc_name)

    try
        DCC = dcc_decode(dcc_name);
        B = DCC.blocks;
        for i=1:length(B)
            b=B{i};
            switch b.id
                case 7
                    matrix3000 = b.iRGB2RGB_matrix_3000K / 256;
                    matrix6500 = b.iRGB2RGB_matrix_5500K / 256;
                    matrix3000 = reshape(matrix3000,3,3)';
                    matrix6500 = reshape(matrix6500,3,3)';
                case 8
                    lut = b.KColTempRefLut;
                    lut = reshape(lut,2,length(lut)/2)';
                    ref_sensitivity = [b.SensitivityR b.SensitivityG b.SensitivityB];
            end
        end
        disp('. DCC loaded')

    catch
    end

end

if isempty(lut)
  [lut, matrix3000, matrix6500] = default_dcc;
  ref_sensitivity = [];
  disp('. No DCC - using defaults')
end


if isempty(this_sensitivity) || isempty(ref_sensitivity)
    white_correction = ones(1,3);
else
    white_correction = this_sensitivity./ref_sensitivity;
    disp('. NVM based correction for color sensitivity')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
T = [ ...
    1500
    2000
    2500
    3000
    3500
    4000
    4500
    5000
    5500
    6000
    6500
    7000
    7500
    8000
    8500
    9000
    9500
    10000
    10500
    11000
    11500
    12000
    12500
    13500
    15000
    17500
    20000
    22500
    25000];
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thumbnail
%tic
try
  thumb=imread(strrep(raw_name,'.raw','.jpg'));
  thumb=imresize(imresize(thumb,1/2,'nearest'),1/4);
  [n,m,c]=size(thumb);
  if rem(n,2)==1
      thumb=thumb(2:end,:,:);
  end
  if rem(m,2)==1
      thumb=thumb(:,2:end,:);
  end
  disp('. Creating thumbnail from jpeg')
  wb = [];
catch
  [thumb,wb]=thumb_from_raw(raw,matrix6500);
  disp('. Creating thumbnail from raw')
end
thumb = double(thumb);
%toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DNG data
meta_data.ccm1 = matrix3000;
meta_data.ccm2 = matrix6500;
sens_idx1 = find(T==3000);
sens_idx2 = find(T==6500);
meta_data.white1 = sens2_to_3(lut(sens_idx1,:)) .* white_correction;
meta_data.white2 = sens2_to_3(lut(sens_idx2,:)) .* white_correction;

meta_data.make = header.Phone_manufacturer;
meta_data.model = header.Phone_model;
meta_data.version = [header.Camera_SW_version ' ' header.Phone_SW_version ' ' header.Phone_IMEI_number];
meta_data.exposure_time = header.Exposure_Time_in_microseconds * 1e-6;
meta_data.iso = round(header.Global_Analog_Gain / header.Global_Analog_Gain_Divider)*100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WB
%tic
try
  mkn=mknote_read_data([strrep(raw_name,'.raw','.jpg') '.txt']);
  wb=[mkn.Gain_R .5*(mkn.Gain_GR+mkn.Gain_GB) mkn.Gain_B];
  disp('. Using white point from makernote')
  wb = wb/256;
  meta_data.white = 1./wb;
catch
  disp('. Using white point from simple awb')
  if isempty(wb)
      [junk,wb]=thumb_from_raw(raw,matrix6500);
  end
  %wb
  meta_data.white = 1./wb;
end
%toc

meta_data.flash = header.Flash_Status;

if compression
    [compr, decompr] = compression_luts;
    meta_data.compression_table = compr;
    meta_data.decompression_table = decompr;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%!!! TO DO: get date of raw file like this:
dir_info=dir(raw_name);
if ~isempty(dir_info)
  meta_data.date_time = strrep(datestr(datenum(dir_info(1).date), 31),  '-', ':');
else
  meta_data.date_time = strrep(datestr(clock,31), '-', ':');
end


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%tic
  
dng_write_g(raw,thumb,meta_data,dng_name);
disp(['Wrote DNG file ' dng_name])
%toc
