function put8g(offset, value, byte_order)

% function data = put4(data, offset, value, byte_order)
fid=fopen('temp','W+');
  if byte_order == 'b'
    fwrite(fid,value,'double','b');
  else
    fwrite(fid,value,'double');
  end
fclose(fid);
fid=fopen('temp','r');
b=fread(fid,8,'uchar');
fclose(fid);
global data;
for i=1:8
    data(offset+i) = b(i); 
end