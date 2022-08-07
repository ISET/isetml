%% cpFacesHeads
%
%
% Use Brian's Heads with Face Detector
% D.Cardinal, Stanford, 2022
%
%%

% intent determines whether we add captions stating the material
% (e.g. 'science' or 'art')
intent = 'science';
%intent = 'art';

ieInit;
if ~piDockerExists, piDockerConfig; end

%%
% Load the canonical pbrt head (until we get some others!)
thisR = piRecipeDefault('scene name','head');

thisR.set('rays per pixel',64); 
% we probably don't need much resolution, given the low-rez of most
% face feature algorithms
thisR.set('film resolution',[320 320]);
thisR.set('n bounces',5);

% Set up a list of scenes that we render for later evaluation
scenes = {};

%% This renders
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];
%%
% Because it is a full 3D head, we can rotate and re-render
thisR.set('asset','001_head_O','rotate',[5 20 0]);
[scene, results] = piWRS(thisR);
scene.name = 'rotate 5 20 0';
scenes = [scenes, scene];

camStart = thisR.get('from');
%% Experiment with camera rotation
direction = thisR.get('fromto');
% not sure whether we want this?...
%direction = direction/norm(direction);
nsamples = 11;
degrees = 8;
frompts = piRotateFrom(thisR,direction,'nsamples',nsamples,'degrees',degrees,'method','circle');

%% Do it.
for ii=1:size(frompts,2)
    thisR.set('from',frompts(:,ii));
    [scene, results] = piWRS(thisR, 'render flag','hdr');
    scene.name = ['rotate ' sprintf('%2.2f %2.2f %2.2f',...
        frompts(1,ii), frompts(2,ii), frompts(3,ii))];
    scenes = [scenes, scene];
end

% put the camera back
thisR.set('from',camStart);

%% Change the camera position
oFrom = thisR.get('from');
oTo = thisR.get('to');
oUp = thisR.get('up');

thisR.set('object distance', 1.3);

% relight the scene with a variety of skymaps
thisR.set('lights','all','delete');

skymaps = {'sky-brightfences', ...
    'glacier_latlong.exr', ...
    'sky-sun-clouds.exr', ...
    'sky-rainbow.exr', ...
    'ext_LateAfternoon_Mountains_CSP.exr', ...
    'sky-cathedral_interior'
    };

for ii = 1:numel(skymaps)
    thisR.set('skymap',skymaps{ii});
    [scene, results] = piWRS(thisR);
    scene.name = skymaps{ii};
    scenes = [scenes, scene];
end

%{
% This adds a small xyz coordinate legend if we want it
coord = piAssetLoad('coordinate');
thisR = piRecipeMerge(thisR,coord.thisR,'node name',coord.mergeNode,'object instance', false);
thisR.set('asset','mergeNode_B','world position',thisR.get('from') + -0.5*thisR.get('fromto'));
thisR.set('asset','mergeNode_B','scale',0.2);

piWRS(thisR);
%}

% Move closer? Ask Brian:)
thisR.set('from',oFrom);
thisR.set('object distance', 1.5);
thisR.set('from',oFrom + [0 0 0.1]);
[scene, results] = piWRS(thisR);
scene = sceneSet(scene,'renderflag', 'clip'); % HDR to deal with specks
scenes = [scenes, scene];

%%  Materials

% Use a nice skylight
thisR.set('lights','all','delete');
thisR.set('skymap','sky-brightfences.exr');

% Add our list of materials, or pick and choose
allMaterials = piMaterialPresets('list');

% If debugging, pick a couple for starters:1: checkerboard 
%{
allMaterials = {... %'marble-beige', 'tiles-marble-sagegreen-brick',...
    'mirror', 'metal-ag','chrome','rough-metal','metal-au',... 
    'metal-cu','metal-cuzn','metal-mgo','metal-tio2', ... 
    'ringrays','slantededge','dots','checkerboard','wood-mahogany','macbethchart'};
%}

% look to see which objects we have, to assign materials
%thisR.show('objects')

% Loop through our material list
for ii = 1:numel(allMaterials)
    try
        piMaterialsInsert(thisR, 'names',allMaterials{ii});
    catch
        warning('Material: %s insert failed. \n',allMaterials{ii});
    end

end

ourMaterialsMap = thisR.get('materials');
ourMaterials = values(ourMaterialsMap);
for ii = 1:numel(ourMaterials)
    try
        thisR.set('asset','001_head_O','material name',ourMaterials{ii}.name);
        [scene, results] = piWRS(thisR);
        scene = sceneSet(scene,'renderflag', 'clip'); % to deal with specks
        scene = sceneSet(scene,'name',ourMaterials{ii}.name);
        scenes = [scenes, scene];
    catch EX
        warning('Material: %s failed with %s. \n',allMaterials{ii}, EX.message);
    end
end

%% Now Textures
textures = {'macbethchart', 'DupontPaintChip_Vhrel', ...
    'Hair_Vhrel', 'Clothes_Vhrel'};

%{
BROKEN:
for ii = 1:numel(textures)
    thisR.get('texture',textures{ii});
    thisR.set('texture',textures{ii},'scale',0.3);
    [scene, results] = piWRS(thisR);
    scenes = [scenes, scene];
end
%}

%{
needs help:

thisR.set('asset','001_head_O','material name','macbethchart');
piWRS(thisR); % save it out with modified asset
thisR.get('texture','macbethchart');
thisR.set('texture','macbethchart','uscale',0.3);
thisR.set('texture','macbethchart','vscale',0.3);
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];

thisR.set('texture','macbethchart','vscale',10);
thisR.set('texture','macbethchart','uscale',10);

thisR.set('asset','head_O','material name','head');

[scene, results] = piWRS(thisR);
scenes = [scenes, scene];
%}
% We can loop through and generate a bunch of separate figures
%% 
faceImages = {};
for ii=1:numel(scenes)
    
    if isequal(intent, 'science')
        faceImages{ii} = facesDetect('scene',scenes{ii}, ...
            'interactive',true,'method','MTCNN','caption',scenes{ii}.name); %#ok<SAGROW> 
    else
        faceImages{ii} = facesDetect('scene',scenes{ii}, ...
            'interactive',true,'method','MTCNN'); %#ok<SAGROW> 
    end

    % trying to get rid of specular noise / maybe an nr call?
    %faceImages{ii}(faceImages{ii}(:)>220) = 0;
    %faceImages{ii} = imadjust(faceImages{ii},[.1 .1 .1 ; .95 .95 .95]);
end
ieNewGraphWin();
montage(faceImages);

% Now we have an array of images


%%
% The depth map is crazy, though.
% scenePlot(scene,'depth map');

%%

% depthRange = thisR.get('depth range');
% depthRange = [1 1];

%{
    we don't handle oi's yet
% Need to un-comment one lens to have the script run
thisR.set('lens file','fisheye.87deg.100.0mm.json');
% lensFiles = lensList;
lensfile = 'fisheye.87deg.100.0mm.json';
% lensfile  = 'dgauss.22deg.50.0mm.json';    % 30 38 18 10

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('focal distance',5);
thisR.set('film diagonal',33);

oi = piWRS(thisR);
%}
