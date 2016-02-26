function [ frame_pixels] = convert_MIPI10bitto_plain(Qframe,width,height)
%UNTITLED Summary of this function goes here
% Detailed explanation goes here
global new_width;
global byte_num;
global packet_num_L;
frame=reshape(Qframe,byte_num,height);
frame=frame';
one_byte=frame(:,1:5:byte_num);%将所有Packet的第1字节提取
two_byte=frame(:,2:5:byte_num);%将所有Packet的第2字节提取
three_byte=frame(:,3:5:byte_num);%将所有Packet的第3字节提取
four_byte=frame(:,4:5:byte_num);%将所有Packet的第4字节提取
five_byte=frame(:,4:5:byte_num);%将所有Packet的第4字节提取

one_byte=bitshift(one_byte,2)+bitand((five_byte),3);
two_byte=bitshift(two_byte,2)+bitshift(bitand((five_byte),12),-2);
three_byte=bitshift(three_byte,2)+bitshift(bitand((five_byte),48),-4);
four_byte=bitshift(four_byte,2)+bitshift(bitand((five_byte),192),-6);

one_byte_low=bitand((one_byte),255);
two_byte_low=bitand((two_byte),255);
three_byte_low=bitand((three_byte),255);
four_byte_low=bitand((four_byte),255);

one_byte_high=bitshift(one_byte,-8);
two_byte_high=bitshift(two_byte,-8);
three_byte_high=bitshift(three_byte,-8);
four_byte_high=bitshift(four_byte,-8);



frame_pixels(:,1:8:(new_width*2))=one_byte_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,2:8:(new_width*2))=one_byte_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,3:8:(new_width*2))=two_byte_low(:,1:packet_num_L);
frame_pixels(:,4:8:(new_width*2))=two_byte_high(:,1:packet_num_L);
frame_pixels(:,5:8:(new_width*2))=three_byte_low(:,1:packet_num_L);
frame_pixels(:,6:8:(new_width*2))=three_byte_high(:,1:packet_num_L);
frame_pixels(:,7:8:(new_width*2))=four_byte_low(:,1:packet_num_L);
frame_pixels(:,8:8:(new_width*2))=four_byte_high(:,1:packet_num_L);

end















