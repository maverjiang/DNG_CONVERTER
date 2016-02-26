function frame = read_MIPI_plain10bitresult( filename,width,height)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f=fopen(filename);
% D=dir(filename);
frame=fread(f,'uint8');
fclose(f);
width=width*2;
frame=reshape(frame,width,height);

frame=rot90(frame,3);
frame=fliplr(frame);
Low=frame(1:1:end,1:2:end);
High=frame(1:1:end,2:2:end);
frame=Low+High*256;
frame=round(frame);
