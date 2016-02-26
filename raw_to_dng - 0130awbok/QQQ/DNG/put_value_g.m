function put_value_g(offset, value, type, byte_order)

verbose = 0;
if verbose
  fprintf('put_value(offset=%d, value=%g, type=%d)',offset,value, type);
end

switch type
  case {1,2,7}
    put1g(offset, value, byte_order);
  case 3
    put2g(offset, value, byte_order);
  case 4
    put4g(offset, value, byte_order);
  case 5
    [n,d] = rat(value,1e-4);
    put4g(offset, n, byte_order);
    put4g(offset+4, d, byte_order);
  case 6
    if value < 0
      value = value+2^8;
    end
    put1g(offset, value, byte_order);
  case 8
    if x < 0
      x = x+2^16;
    end
    put2g(offset, value, byte_order);
  case 9
    if value<0
      value = value+2^32;
    end
    put4g(offset, value, byte_order);
  case 10
    [n,d] = rat(value,1e-4);
    if verbose
      sprintf(' %d/%d (%g)', n, d, n/d);
    end
    if n<0
      n = n+2^32;
    end
    if verbose
      sprintf(' %d/%d', n, d);
    end
    put4g(offset, n, byte_order);
    put4g(offset+4, d, byte_order);
  case 11
%     error('not implemented properly')
    put4gf(offset, value, byte_order);
  case 12
%     error('not implemented properly')
    put8g(offset, value, byte_order);
  otherwise
    error(['invalid type: ' num2str(type)])
end

if verbose
  fprintf('\n');
%   fflush(stdout);
end

