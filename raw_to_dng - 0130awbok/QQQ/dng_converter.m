function varargout = dng_converter(varargin)
% DNG_CONVERTER MATLAB code for dng_converter.fig
%      DNG_CONVERTER, by itself, creates a new DNG_CONVERTER or raises the existing
%      singleton*.
%
%      H = DNG_CONVERTER returns the handle to a new DNG_CONVERTER or the handle to
%      the existing singleton*.
%
%      DNG_CONVERTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DNG_CONVERTER.M with the given input arguments.
%
%      DNG_CONVERTER('Property','Value',...) creates a new DNG_CONVERTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dng_converter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dng_converter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dng_converter

% Last Modified by GUIDE v2.5 19-Jan-2016 10:18:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dng_converter_OpeningFcn, ...
                   'gui_OutputFcn',  @dng_converter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dng_converter is made visible.
function dng_converter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dng_converter (see VARARGIN)

% Choose default command line output for dng_converter
handles.output = hObject;
set(handles.raw_type,'String',{'Apical_16bit';'Plain_10bit'});
set(handles.raw_type,'Value',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dng_converter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dng_converter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_file.
function select_file_Callback(hObject, eventdata, handles)
% hObject    handle to select_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath(fullfile(pwd,'DNG'));
addpath(fullfile(pwd,'read'));
[raw_name, pathname] = uigetfile('*.raw', 'raw file'); 
fullname = [pathname raw_name];

width = get(handles.width, 'string');
width = str2num(width);
height = get(handles.height, 'string');
height = str2num(height);
raw_type = get(handles.raw_type, 'value');
format=raw_type;
if (numel(width)<=0) || (numel(height)<=0)
    warndlg('please fill width & height firstly','warning');
    return;
end

if(format==1)
    FRAME=read_Apical_16bit(fullname,width,height);
    raw_name_tab='test.raw';

end
if(format==2)
    raw_name_tab=fullname;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dng_name = strrep(raw_name,'.RAW','.dng');
varargin={'camera','acmelite_tsb'};
compression = 1;
lensshading = 1;
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


        header.Phone_manufacturer = 'dummy1';
        header.Phone_model = 'dummy2';
        header.Camera_SW_version = 'dummy3';
        header.Phone_SW_version = 'dummy4';
        header.Phone_IMEI_number = 'dummy5';
        header.Flash_Status = 0;
try
            raw = read_plain_raw3_wh(raw_name_tab,width,height);
            %!!! TO DO:
            % Get pedestal value from DCC, and do this below
            raw = max(0, raw-64);
            header.Exposure_Time_in_microseconds = 10;
            header.Global_Analog_Gain = 1;
            header.Global_Analog_Gain_Divider = 1;

   
catch
  disp(['Cannot open raw file ' raw_name])
  return
end
raw = double(raw);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load DCC
% ...
lut = [];
% matrix3000=[256, 0, 0, 0, 256, 0, 0, 0,256]./256; 
% matrix6500=[256, 0, 0, 0, 256, 0, 0, 0,256]./256;  
matrix3000=[2.905063291 -0.9821428571 -0.3025210084 0.2752293578 0.9190751445 0.4150943396 0.3553719008 -0.3391304348 0.9259259259]; 
matrix6500=[2.905063291 -0.9821428571 -0.3025210084 0.2752293578 0.9190751445 0.4150943396 0.3553719008 -0.3391304348 0.9259259259];

% 2.905063291 -0.9821428571 -0.3025210084 0.2752293578 0.9190751445 0.4150943396 0.3553719008 -0.3391304348 0.9259259259
matrix3000 = reshape(matrix3000,3,3)';
matrix6500 = reshape(matrix6500,3,3)';
%lut
lut =[300,41,280,62,240,81,220,98,200,113,186,127,175,139,167,149,160,159,155,166,151,173,147,179,144,184,141,189,139,192,137,195,136,198,134,200,133,202,132,203,131,204,130,206,129,207,127,209,125,212,123,214,122,215,120,216,120,217] ;
lut = reshape(lut,2,length(lut)/2)';
ref_sensitivity=[256,256,256];

this_sensitivity = getappdata(0,'this_sensitivity');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DNG data
matrix3000 = getappdata(0,'matrix3000');
matrix6500 = getappdata(0,'matrix6500');
%matrix3000 = reshape(matrix3000,3,3)';
%matrix6500 = reshape(matrix6500,3,3)';
matrix3000 = reshape(matrix3000,3,3);
matrix6500 = reshape(matrix6500,3,3);

%matrix3000 = matrix3000';
%matrix6500 = matrix6500';

[thumb,wb]=thumb_from_raw(raw,matrix6500);
thumb = double(thumb);

meta_data.ccm1 = matrix3000;
meta_data.ccm2 = matrix6500;
%meta_data.ccm1 = [1 , 0,  0; 0,  1 , 0; 0, 0 ,1];
%meta_data.ccm2 = [1 , 0 , 0; 0  ,1 , 0; 0 ,0 ,1];

%meta_data.ccm1 = [1.7578 , -0.5781,  -0.1794; -0.4297,  1.3789 , 0.0508; 0.0742, -1.6836 ,2.6094];
%meta_data.ccm2 = [1.5469 , -0.4414 , -0.1055; -0.2578  ,1.5352 , 0.2773; 0.1328 ,-0.7539 ,1.6211];
%sens_idx1 = find(T==3000);
%sens_idx2 = find(T==6500);
%meta_data.white1 = sens2_to_3(lut(sens_idx1,:)) .* white_correction;
%meta_data.white2 = sens2_to_3(lut(sens_idx2,:)) .* white_correction;
%white_correction = ones(1,3);
meta_data.white1 = getappdata(0,'white1') .* white_correction;
meta_data.white2 = getappdata(0,'white2') .* white_correction;


meta_data.make = header.Phone_manufacturer;
meta_data.model = header.Phone_model;
meta_data.version = [header.Camera_SW_version ' ' header.Phone_SW_version ' ' header.Phone_IMEI_number];
meta_data.exposure_time = header.Exposure_Time_in_microseconds * 1e-6;
meta_data.iso = round(header.Global_Analog_Gain / header.Global_Analog_Gain_Divider)*100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WB
%wb = ones(1,3);
%meta_data.white1 = ones(1,3);
%meta_data.white2 = ones(1,3);

wb(1) = getappdata(0,'WB_GainR');
wb(2) = getappdata(0,'WB_GainG');
wb(3) = getappdata(0,'WB_GainB');

wb(1) = wb(1)/wb(2);
wb(3) = wb(3)/wb(2);
wb(2) = 1;


meta_data.white = 1./wb;
meta_data.flash = header.Flash_Status;

if compression
    [compr, decompr] = compression_luts;%这个是直接照搬原来的compression_luts.m
    meta_data.compression_table = compr;
    meta_data.decompression_table = decompr;
end
if lensshading
    meta_data.lensshading_r = getappdata(0,'shading_d65_r_linear');
    %[LSC_R,LSC_G,LSC_B] = lenscorrection_luts;
    meta_data.lensshading_g = getappdata(0,'shading_d65_g_linear');
    meta_data.lensshading_b = getappdata(0,'shading_d65_b_linear');
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

dng_write_g(raw,thumb,meta_data,dng_name);
disp(['Wrote DNG file ' dng_name])

i=0;













function width_Callback(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width as text
%        str2double(get(hObject,'String')) returns contents of width as a double


% --- Executes during object creation, after setting all properties.
function width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function height_Callback(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of height as text
%        str2double(get(hObject,'String')) returns contents of height as a double


% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in raw_type.
function raw_type_Callback(hObject, eventdata, handles)
% hObject    handle to raw_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns raw_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from raw_type


% --- Executes during object creation, after setting all properties.
function raw_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raw_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadmeta.
function loadmeta_Callback(hObject, eventdata, handles)
% hObject    handle to loadmeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[raw_name, pathname] = uigetfile('*.TXT', 'meta file'); 
fullname = [pathname raw_name];
fid = fopen(fullname, 'r');
while ~feof(fid)
    
   s = strtrim(fgetl(fid));
   k = strfind(s, 'Gain 00');
   if ~isempty(k)
    m = s(10:12);
    WB_GainR = str2num(m);
     s = strtrim(fgetl(fid));
     m = s(10:12);
    WB_GainG = str2num(m);
     s = strtrim(fgetl(fid));
     m = s(10:12);
    WB_GainG = str2num(m);
    s = strtrim(fgetl(fid));
     m = s(10:12);
    WB_GainB = str2num(m);
      setappdata(0,'WB_GainR',WB_GainR);      
      setappdata(0,'WB_GainG',WB_GainG);      
      setappdata(0,'WB_GainB',WB_GainB); 
    break;
   end  
end
% --- Executes on button press in loadstatic.
function loadstatic_Callback(hObject, eventdata, handles)
% hObject    handle to loadstatic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[raw_name, pathname] = uigetfile('*.c', 'calibration file'); 
fullname = [pathname raw_name];
fid = fopen(fullname, 'r');
while ~feof(fid)
    
    s = strtrim(fgetl(fid));
   k = strfind(s, 'calibration_ct_rg_pos_calc');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     k = strfind(s, '256');
     m = s(k-5:k-3);
     n = s(k+10:k+12);
     a = str2num(m);
     RG_D65 = a;
     a = str2num(n);
     RG_D30 = a;     
   end  
      k = strfind(s, 'calibration_ct_bg_pos_calc');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     k = strfind(s, '256');
     m = s(k-5:k-3);
     n = s(k+10:k+12);
     a = str2num(m);
     BG_D65 = a;
     a = str2num(n);
     BG_D30 = a;     
     
    white1 = [RG_D65/256,1,BG_D65/256];
    white2 = [RG_D30/256,1,BG_D30/256];
      setappdata(0,'white1',white1);      
      setappdata(0,'white2',white2);      
   end  

   k = strfind(s, 'calibration_color_temp');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);
     T = 1e6./a;
     setappdata(0,'T',T);   
   end  
   
   k = strfind(s, '_calibration_static_wb');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     a(3) =''; 
     this_sensitivity = a;
     disp(s);
   
     setappdata(0,'this_sensitivity',this_sensitivity);   
   end  
   
    k = strfind(s, 'calibration_mt_absolute_ls_a_ccm_linear');
    if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);
     for i=1:9
      if a(i)>32768
     a(i) = (a(i)-32768)*(-1);
      end
     end
     matrix3000 = a./256;
     setappdata(0,'matrix3000',matrix3000);
   end
   k = strfind(s, '_calibration_mt_absolute_ls_d50_ccm_linear');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);
     for i=1:9
      if a(i)>32768
         a(i) = (a(i)-32768)*(-1);
      end
     end
     matrix6500 = a./256;
     setappdata(0,'matrix6500',matrix6500);
    % break;
   end
k = strfind(s, '_calibration_shading_ls_d65_r');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);
     
     shading_d65_r_linear = a;
     
%    shading_d65_r_linear = reshape(shading_d65_r_linear,32,32)';
     setappdata(0,'shading_d65_r_linear',shading_d65_r_linear);
   end      
 k = strfind(s, '_calibration_shading_ls_d65_g');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);

     shading_d65_g_linear = a;
%    shading_d65_g_linear = reshape(shading_d65_g_linear,32,32)'
     setappdata(0,'shading_d65_g_linear',shading_d65_g_linear);
   end   
   
  k = strfind(s, '_calibration_shading_ls_d65_b');
   if ~isempty(k)
     s = strtrim(fgetl(fid));
     k = strfind(s, '{');
     j = strfind(s, '}');
     s = s(k+2:j-2);
     a = str2num(s);
     disp(s);

     shading_d65_b_linear = a;
%    shading_d65_b_linear = reshape(shading_d65_b_linear,32,32)'
     setappdata(0,'shading_d65_b_linear',shading_d65_b_linear);
     break;
   end

end
