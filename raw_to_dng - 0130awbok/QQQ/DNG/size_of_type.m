function size_in_bytes = size_of_type(type)

% function s = size_of_type(type)

switch type
  case {1,2,6,7}
    size_in_bytes = 1;
  case {3,8}
    size_in_bytes = 2;
  case {4,9,11}
    size_in_bytes = 4;
  case {5,10,12}
    size_in_bytes = 8;
  otherwise
    error('invalid type')
end
