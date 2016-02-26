function put8g(offset, value, byte_order)

% function data = put4(data, offset, value, byte_order)
value = typecast(value, 'uint64');
divisor = uint64(256);
global data
for i=1:8
  low = uint8(rem(value, 256));
  if byte_order == 'b'
    data(offset+(9-i)) = low;
  else
    data(offset+i) = low;
  end
%   value = floor(value / 256);


value = idivide(value, divisor, 'floor');
% value = idivide(value, 256, 'floor');
end
