function ifd = dng_sub_ifd0_template(M)

% function ifd = dng_sub_ifd0_template(M)
%
% M.x:
% width
% height
% raw_data_offset
% cfa_pattern
% white
% bayer_green_split'
% !!! LinearizationTable 50712 shorts

ifd = {...
  struct('tag',254,'description','NewSubfileType','type',4,'count',1,'values',[0]),...
  struct('tag',256,'description','ImageWidth','type',4,'count',1,'values',M.width),...
  struct('tag',257,'description','ImageLength','type',4,'count',1,'values',M.height),...
  struct('tag',258,'description','BitsPerSample','type',3,'count',1,'values',[8*M.bytes_per_pixel]),...
  struct('tag',259,'description','Compression','type',3,'count',1,'values',[1]),...
  struct('tag',262,'description','PhotometricInterpretation','type',3,'count',1,'values',[32803]),...
  struct('tag',273,'description','StripOffsets','type',4,'count',1,'values',M.raw_data_offset),...
  struct('tag',277,'description','SamplesPerPixel','type',3,'count',1,'values',[1]),...
  struct('tag',278,'description','RowsPerStrip','type',4,'count',1,'values',M.height),...
  struct('tag',279,'description','StripByteCounts','type',4,'count',1,'values',M.bytes_per_pixel*M.width*M.height),...
  struct('tag',284,'description','PlanarConfiguration','type',3,'count',1,'values',[1]),...
  struct('tag',33421,'description','CFARepeatPatternDim','type',3,'count',2,'values',[2   2]),...
  struct('tag',33422,'description','CFAPattern','type',1,'count',4,'values',M.cfa_pattern),...
  struct('tag',50710,'description','CFAPlaneColor','type',1,'count',3,'values',[0   1   2]),...
  struct('tag',50711,'description','CFALayout','type',3,'count',1,'values',[1]),...
  struct('tag',50712,'description','LinearizationTable','type',3,'count',length(M.decompression_table),'values',[M.decompression_table]),...
  struct('tag',50713,'description','BlackLevelRepeatDim','type',3,'count',2,'values',[1   1]),...
  struct('tag',50714,'description','BlackLevel','type',5,'count',1,'values',[0]),...
  struct('tag',50717,'description','WhiteLevel','type',3,'count',1,'values',[M.white]),...
  struct('tag',50718,'description','DefaultScale','type',5,'count',2,'values',[1   1]),...
  struct('tag',50719,'description','DefaultCropOrigin','type',5,'count',2,'values',[2   2]),...
  struct('tag',50720,'description','DefaultCropSize','type',5,'count',2,'values',[M.width-4   M.height-4]),...
  struct('tag',50733,'description','BayerGreenSplit','type',4,'count',1,'values',[M.bayer_green_split]),...
  struct('tag',50738,'description','AntiAliasStrength','type',5,'count',1,'values',[M.anti_alias_strength]),...
  struct('tag',50780,'description','BestQualityScale','type',5,'count',1,'values',[1]),...
  struct('tag',51009,'description','Opcodelist2','type',7,'count',4+4*(16+76+4*32*32),'values',M.offset_Opcodelist)};

end
    