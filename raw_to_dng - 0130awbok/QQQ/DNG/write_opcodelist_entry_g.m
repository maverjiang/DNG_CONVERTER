function offset_data = write_opcodelist_entry_g(entry, entry_offset, offset_data, byte_order)

global data
typ = entry.type;
val = entry.values;
sz = size_of_type(typ);
N=length(val);
  for i=1:N
%     fprintf('put_value(offset=%d, value=%g, type=%d),\n',entry_offset,val(i), typ);
    put_value_g(entry_offset, val(i), typ, byte_order);
    entry_offset = entry_offset + sz;
  end

