function put4gf(offset, value, byte_order)

% function data = put4(data, offset, value, byte_order)
fid=fopen('temp','W+');
  if byte_order == 'b'
    fwrite(fid,value,'single','b');
  else
    fwrite(fid,value,'single');
  end
fclose(fid);
fid=fopen('temp','r');
b=fread(fid,4,'uchar');
fclose(fid);
global data;
for i=1:4
    data(offset+i) = b(i); 
end