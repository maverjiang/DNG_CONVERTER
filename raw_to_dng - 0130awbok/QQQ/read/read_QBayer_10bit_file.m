function [ frame ] = read_QBayer_10bit_file( filename,width,height)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
global new_width;
new_width=floor((width+11)/12)*12;
global packet_num_L;
packet_num_L=new_width/6;%每行packet数
global byte_num;
byte_num=packet_num_L*8;%每行字节数
fid=fopen(filename);
frame=fread(fid,byte_num*height,'uint8');%读入有效文件
fclose(fid);
end

