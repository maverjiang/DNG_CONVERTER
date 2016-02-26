function put4g(offset, value, byte_order)

% function data = put4(data, offset, value, byte_order)

global data
for i=1:4
  low = rem(value, 256);
  if byte_order == 'b'
    data(offset+(5-i)) = low;
  else
    data(offset+i) = low;
  end
  value = floor(value / 256);
end
