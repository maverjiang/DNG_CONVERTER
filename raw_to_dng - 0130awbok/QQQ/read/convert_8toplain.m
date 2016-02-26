function [ frame ] = convert_8toplain( FRAME,width,height )
%CONVERT_8TOPLAIN Summary of this function goes here
%   Detailed explanation goes here
frame=zeros(height,width*2);
frame(:,1:2:(width*2))=FRAME;
frame=uint8(frame);
end

