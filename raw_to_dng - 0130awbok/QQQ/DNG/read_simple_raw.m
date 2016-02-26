if 0
f = fopen('raw/Image40014.raw','rb');
A = fread(f,Inf,'uint8');
fclose(f);
end
raw_offset = get2(A,6+16+8+8,'l')
width = get2(A,6+16+8+8+4,'l')
height = get2(A,6+16+8+8+6,'l')
raw0 = A(raw_offset+1:raw_offset+width*height*5/4);
raw0 = reshape(raw0,width*5/4,height)';
cols = 1:width*5/4;
cols(5:5:end)=[];
raw = 4*raw0(:,cols);
bits = raw0(:,5:5:end);
for i=1:4
  raw(:,(5-i) : 4 : end) =   raw(:,(5-i) : 4 : end) + rem(bits, 3);
  bits = floor(bits/4);
end

R = raw(1:2:end,2:2:end);
G = .5*(raw(1:2:end,1:2:end) + raw(2:2:end,2:2:end));
B = raw(2:2:end,1:2:end);
rgb = R;
rgb(:,:,2)=G;
rgb(:,:,3)=B;
rgb1=(rgb/1023).^.45;
thumb=zeros(size(rgb,1)/4,size(rgb,2)/4,3);
for i=1:4
  for j=1:4
    thumb = thumb + rgb(i:4:end,j:4:end,:);
  end
end
m=[mean(R(:)) mean(G(:)) mean(B(:))];
g=max(m)./m
for i=1:3
  thumb(:,:,i) = g(i)*thumb(:,:,i);
end

thumb = max(0, min(255, round(255*(thumb/1023/16).^.45)));

    