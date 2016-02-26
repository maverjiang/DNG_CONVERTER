function [ifd0, raw_data, thumb, sub_ifds, exif_ifd] = dng_parse(filename)

% function [ifd0, raw_data, thumb, sub_ifds, exif_ifd] = dng_parse(filename)

f = fopen(filename,'rb');
data = fread(f,Inf,'uint8');
fclose(f);

global TAGS
TAGS = read_tiff_tags;

if data(1) == 'M' && data(2) == 'M'
  byte_order = 'b'
elseif data(1) == 'I' && data(2) == 'I'
  byte_order = 'l'
else
  error('Invalid byte-order marker')
end

tiff42 = get2(data,2,byte_order);
if tiff42 ~= 42
  warning(['Invalid magic number: ' num2str(tiff42)])
end

ifd0_offset = get4(data,4,byte_order);

disp('IFDs')
[ifd0, next_ifd_offset] = parse_ifd(data, ifd0_offset, byte_order);

sub_ifds = find_tag(ifd0, 330);
exif_ifds = find_tag(ifd0, 34665);

found = 0;
for i=1:length(sub_ifds)
  t = find_tag(sub_ifds{i}, 254); % NewSubFileType
  if t==0 % should be raw data
    interp = find_tag(sub_ifds{i}, 262);
    assert(interp == 32803) % check it is raw
    found = 1;
    break
  end
end
assert(found > 0)

disp('Raw data')
raw_ifd = sub_ifds{i};
raw_data = get_image_data(data, raw_ifd, byte_order);
if isnumeric(raw_data)
  tiff_write(round(255*raw_data/max(raw_data(:))),[filename '_parsed_raw.tif']);
end

%%%%rgb_simple = raw_to_rgb_simple(raw_data, raw_ifd);
disp('Thumbnail')
thumb = get_image_data(data, ifd0, byte_order);

%%%%tiff_write(round(255*rgb_simple),[filename '_parsed_rgb_simple.tif']);
if isnumeric(thumb)
  tiff_write(thumb,[filename '_parsed_thumb.tif']);
end

exif_ifd = exif_ifds{1};
