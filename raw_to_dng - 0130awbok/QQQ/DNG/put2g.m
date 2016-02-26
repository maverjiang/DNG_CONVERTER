function put2g(offset, value, byte_order)

% function data = put2(data, offset, value, byte_order)

global data

high = floor(value / 256);
low = rem(value, 256);

if byte_order == 'b'
  data(offset+1) = high;
  data(offset+2) = low;
else
  data(offset+2) = high;
  data(offset+1) = low;
end
