function [ frame_pixels] = convert_QBaye10rto_plain(Qframe,width,height)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
global new_width;
global byte_num;
global packet_num_L;
frame=reshape(Qframe,byte_num,height);
frame=frame';
one_byte=frame(:,1:8:byte_num);%将所有Packet的第1字节提取
two_byte=frame(:,2:8:byte_num);%将所有Packet的第2字节提取
three_byte=frame(:,3:8:byte_num);%将所有Packet的第3字节提取
four_byte=frame(:,4:8:byte_num);%将所有Packet的第4字节提取
five_byte=frame(:,5:8:byte_num);%将所有Packet的第5字节提取
six_byte=frame(:,6:8:byte_num);%将所有Packet的第6字节提取
seven_byte=frame(:,7:8:byte_num);%将所有Packet的第7字节提取
eight_byte=frame(:,8:8:byte_num);%将所有Packet的第8字节提取


pixels1=one_byte+bitshift(bitand(two_byte,3),8);%字节移位
pixels2=bitshift(two_byte,-2)+bitshift(bitand(three_byte,15),6);
pixels3=bitshift(three_byte,-4)+bitshift(bitand(four_byte,63),4);
pixels4=bitshift(four_byte,-6)+bitshift(five_byte,2);
pixels5=six_byte+bitshift(bitand(seven_byte,3),8);
pixels6=bitshift(seven_byte,-2)+bitshift(bitand(eight_byte,15),6);

pixels1_low=bitand((pixels1),255);
pixels2_low=bitand((pixels2),255);
pixels3_low=bitand((pixels3),255);
pixels4_low=bitand((pixels4),255);
pixels5_low=bitand((pixels5),255);
pixels6_low=bitand((pixels6),255);

pixels1_high=bitshift(pixels1,-8);
pixels2_high=bitshift(pixels2,-8);
pixels3_high=bitshift(pixels3,-8);
pixels4_high=bitshift(pixels4,-8);
pixels5_high=bitshift(pixels5,-8);
pixels6_high=bitshift(pixels6,-8);



frame_pixels(:,1:12:(new_width*2))=pixels1_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,2:12:(new_width*2))=pixels1_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,3:12:(new_width*2))=pixels2_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,4:12:(new_width*2))=pixels2_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,5:12:(new_width*2))=pixels3_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,6:12:(new_width*2))=pixels3_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,7:12:(new_width*2))=pixels4_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,8:12:(new_width*2))=pixels4_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,9:12:(new_width*2))=pixels5_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,10:12:(new_width*2))=pixels5_high(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,11:12:(new_width*2))=pixels6_low(:,1:packet_num_L);%将像素重新整理
frame_pixels(:,12:12:(new_width*2))=pixels6_high(:,1:packet_num_L);%将像素重新整理


end














