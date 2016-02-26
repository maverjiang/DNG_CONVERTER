function [ frame ] = read_MIPI_10bit( filename,width,height)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
global new_width;
new_width=floor((width+3)/4)*4;
global packet_num_L;
packet_num_L=new_width/4;%每行packet数
global byte_num;
byte_num=packet_num_L*5;%每行字节数
byte_num=floor((byte_num+7)/8)*8;
fid=fopen(filename);
frame=fread(fid,byte_num*height,'uint8');%读入有效文件
fclose(fid);
end


