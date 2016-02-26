function [data, offset_data] = write_ifd(data, ifd, ifd_offset, offset_data, byte_order)

N = length(ifd);
data = put2(data, ifd_offset, N, byte_order);
for i=1:N
  [data, offset_data] = write_ifd_entry(data, ...
    ifd{i}, ifd_offset+12*(i-1)+2, offset_data, byte_order);
end
data = put4(data, ifd_offset+12*N+2, 0, byte_order);
