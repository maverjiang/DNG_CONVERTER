function nvm = read_nvm_from_mkn(filename)
f=fopen(filename,'rb');
mkn=fread(f,'uint8');
fclose(f);
mkn=char(mkn(:)');
begin=strfind(mkn,['EEPROM:' 0])+8;
mkn=mkn(begin:end);
%ending=regexp(mkn(begin:end),['[A-Z][a-z][a-z][a-z][a-z][a-z][a-z][a-z]*:' 0]);
%ending=regexp(mkn,['Binning']);
%ending=ending(1);
%nvm=double(mkn(1:ending));
nvm=double(mkn);

