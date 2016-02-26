function offset_data = write_ifd_g(ifd, ifd_offset, offset_data, byte_order)

global data

N = length(ifd);
put2g(ifd_offset, N, byte_order);
for i=1:N
  offset_data = write_ifd_entry_g(ifd{i}, ifd_offset+12*(i-1)+2, ...
				  offset_data, byte_order);
end
put4g(ifd_offset+12*N+2, 0, byte_order);
