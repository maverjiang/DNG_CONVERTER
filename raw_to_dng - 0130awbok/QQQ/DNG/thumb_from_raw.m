function [thumb,wb] = thumb_from_raw(raw,ccm)
% function [thumb,wb] = thumb_from_raw(raw,ccm)
% sRGB_to_XYZ = [ ...
%    0.412424   0.357579   0.180464
%    0.212656   0.715158   0.072186
%    0.019332   0.119193   0.950444];
% ccm = ccm * sRGB_to_XYZ;
ccm = [1 0 0; 0 1 0; 0 0 1];
raw=uint16(raw);
N=4;
raw=raw(1:floor(size(raw,1)/(2*N))*2*N,1:floor(size(raw,2)/(2*N))*2*N);
raw1=zeros(size(raw,1)/(N),size(raw,2)/(N),'uint16');
for k=1:2
  for l=1:2
    ch=raw(k:2:end,l:2:end);
    ch1=zeros(size(ch,1)/(N),size(ch,2)/(N),'uint16');
    for i=1:N
      for j=1:N
	ch1=ch1+ch(i:N:end,j:N:end,:);
      end
    end
    raw1(k:2:end,l:2:end)=ch1;
  end
end
R=raw1(1:2:end,1:2:end);
Gr=raw1(1:2:end,2:2:end);
Gb=raw1(2:2:end,1:2:end);
B=raw1(2:2:end,2:2:end);
% Gr=raw1(1:2:end,1:2:end);
% R=raw1(1:2:end,2:2:end);
% B=raw1(2:2:end,1:2:end);
% Gb=raw1(2:2:end,2:2:end);
G=.5*(Gr+Gb+1);
RGB=R;
RGB(:,:,2)=G;
RGB(:,:,3)=B;
rgb=double(RGB)/(N*N);
ok=rgb(:,:,1)<(1020-64) & rgb(:,:,2)<(1020-64) & rgb(:,:,3)<(1020-64);
h=hist(rgb(:),0:1023);
ch=cumsum(h);
idx=find(ch>.995*ch(end));
idx=idx(1);
rgb=rgb/idx;
m=zeros(1,3);
for c=1:3
  chn=rgb(:,:,c);
  m(c)=mean(mean(chn(ok)));
end
wb = max(m)./m;
for c=1:3
  rgb(:,:,c)=wb(c)*rgb(:,:,c);
end
rgb=min(1, rgb);
rgb1 = zeros(size(rgb));
for i=1:3
    for j=1:3
        rgb1(:,:,i) = rgb1(:,:,i) + ccm(i,j) * rgb(:,:,j);
    end
end
rgb1=max(0,min(1,rgb1));
thumb=round(255*rgb1.^.45);
[n,m,c]=size(thumb);
if rem(n,2)==1
  thumb=thumb(2:end,:,:);
end
if rem(m,2)==1
  thumb=thumb(:,2:end,:);
end
