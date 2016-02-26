function offset_data = write_opcodelist_g(opcodelist, offset_opcodelist, offset_data, byte_order)


global data
ifd = opcodelist;
ifd_offset = offset_opcodelist;
N = length(ifd);
for i=1:N
    typ = opcodelist{i}.type;
    val = opcodelist{i}.values;
    sz = size_of_type(typ);
    M = length(val);
    sz = M*sz;
  offset_data = write_opcodelist_entry_g(ifd{i}, ifd_offset, ...
				  offset_data, byte_order);
   ifd_offset = ifd_offset + sz;
end
offset_data = offset_data +4+4*(16+76+4*32*32);

 