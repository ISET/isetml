function rootPath=mlRootPath()
% Return the path to the root isetml directory
%
% This function must reside in the directory at the base of the running
% version of ISETml's directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(mlRootPath,'data')

rootPath=which('mlRootPath');
% try
%     ls('-la','/opt/toolboxes')
% catch
%     error('Error on ls of /opt/toolboxes');
% end
% tbLocateToolbox('iset3d')

[rootPath,fName,ext]=fileparts(rootPath);

return