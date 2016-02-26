function frame = plain_to_plain( filename,width,height)
%PLAIN_TO_PLAIN Summary of this function goes here
%   Detailed explanation goes here
f=fopen(filename);
% D=dir(filename);
frame=fread(f,'uint8');
fclose(f);
width=width*2;
frame=reshape(frame,width,height);

frame=rot90(frame,3);
frame=fliplr(frame);
end

