function frame = read_MIPI_8bit( filename,width,height)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

f=fopen(filename);
% D=dir(filename);
frame=fread(f,'uint8');
fclose(f);
frame=reshape(frame,width,height);

frame=rot90(frame,3);
frame=fliplr(frame);




