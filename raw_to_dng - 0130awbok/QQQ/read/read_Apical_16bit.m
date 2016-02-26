function [ frame ] = read_Apical_16bit( filename,width,height)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
f=fopen(filename);
disp(char(fread(f, 30)'));%disp header
frame =  fread(f,[width*2 height],'ubit16=>uint16');
frame = single(frame(1:width,:)');
fclose(f);
frame=round(frame/(2^6));
imageselect=frame;
raw_name_tab='test.raw';

fid=fopen('test.raw','wb');
fwrite(fid,imageselect','ubit16');
fclose(fid);
%
%frame = single(frame(1:width,:))/(2^16-1);
end


%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
% f=fopen(filename);
% disp(char(fread(f, 30)'));%disp header
% frame =  fread(f,[width*2 height],'ubit16=>uint16');
% fclose(f);
% 
% frame = single(frame(1:width,:)')/(2^16-1);
% %frame = single(frame(1:width,:))*(2^10-1)/(2^16-1);
% end


