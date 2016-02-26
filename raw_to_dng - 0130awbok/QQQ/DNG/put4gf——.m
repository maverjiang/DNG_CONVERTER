function put4gf(offset, value, byte_order)

% function data = put4(data, offset, value, byte_order)
value = typecast(value, 'uint32'); 
value = value(2);
divisor = uint32(256);
global data
for i=1:4
  low = double(rem(value, 256));
  if byte_order == 'b'
    data(offset+(5-i)) = low;
  else
    data(offset+i) = low;
  end

value = idivide(value, divisor, 'floor');
end
