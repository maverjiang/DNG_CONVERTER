function data = put_value(data, offset, value, type, byte_order)

verbose = 0;
if verbose
  printf('put_value(offset=%d, value=%g, type=%d)',offset,value, type);
end

switch type
  case {1,2,7}
    data = put1(data, offset, value, byte_order);
  case 3
    data = put2(data, offset, value, byte_order);
  case 4
    data = put4(data, offset, value, byte_order);
  case 5
    [n,d] = rat(value,1e-6);
    data = put4(data, offset, n, byte_order);
    data = put4(data, offset+4, d, byte_order);
  case 6
    if value < 0
      value = value+2^8;
    end
    data = put1(data, offset, value, byte_order);
  case 8
    if x < 0
      x = x+2^16;
    end
    data = put2(data, offset, value, byte_order);
  case 9
    if value<0
      value = value+2^32;
    end
    data = put4(data, offset, value, byte_order);
  case 10
    [n,d] = rat(value,1e-4);
    if verbose
      printf(' %d/%d (%g)', n, d, n/d);
    end
    if n<0
      n = n+2^32;
    end
    if verbose
      printf(' %d/%d', n, d);
    end
    data = put4(data, offset, n, byte_order);
    data = put4(data, offset+4, d, byte_order);
  case 11
    error('not implemented properly')
    data = put4(data, offset, value, byte_order);
  case 12
    error('not implemented properly')
    data = put8(data, offset, value, byte_order);
  otherwise
    error(['invalid type: ' num2str(type)])
end

if verbose
  printf('\n');
  fflush(stdout);
end

