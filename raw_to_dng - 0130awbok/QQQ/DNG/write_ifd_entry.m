function [data, offset_data] = write_ifd_entry(data, entry, entry_offset, offset_data, byte_order)

%entry

typ = entry.type;
val = entry.values;
%val
%fflush(stdout);

data = put2(data, entry_offset  , entry.tag, byte_order);
data = put2(data, entry_offset+2, typ, byte_order);
data = put4(data, entry_offset+4, entry.count, byte_order);

sz = size_of_type(typ);
N=length(val);
bytes = sz*N;
if bytes <= 4
  for i=1:N
    data = put_value(data, entry_offset+8+sz*(i-1), val(i), typ, byte_order);
  end
else
  data = put_value(data, entry_offset+8, offset_data, 4, byte_order);
  for i=1:N
    data = put_value(data, offset_data, val(i), typ, byte_order);
    offset_data = round_up(offset_data + sz);
  end
end
