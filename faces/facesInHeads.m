%% cpFacesHeads
%
%
% Use PBRT head and materials with Face Detector
% D.Cardinal, Stanford, 2022
%
%%

% intent determines whether we add captions stating the material
% and how high-fidelity we make the output
% (e.g. 'science' or 'art')
intent = 'science';
%intent = 'art';

switch intent
    case 'art'
        baseRez = 640;
        rays = 1024;
        thumbnailSize = [];
    case 'science'
        baseRez = 320;
        rays = 256;
        thumbnailSize = [baseRez inf];
end

ieInit;
if ~piDockerExists, piDockerConfig; end

%%
% Load the canonical pbrt head (until we get some others!)
thisR = piRecipeDefault('scene name','head');
headAsset = '001_Head_O';

thisR.set('rays per pixel',rays);
% we probably don't need much resolution, given the low-rez of most
% face feature algorithms -- set higher for higher quality "poster"
thisR.set('film resolution',[baseRez baseRez]*2);
thisR.set('n bounces',6);

% Set up a list of scenes that we render for later evaluation
scenes = {};

%% This renders
[scene, results] = piWRS(thisR);
scenes = [scenes, scene];
%%
% Because it is a full 3D head, we can rotate and re-render
thisR.set('asset',headAsset,'rotate',[5 20 0]);
[scene, results] = piWRS(thisR);
scene.name = 'rotate 5 20 0';
scenes = [scenes, scene];


%% Experiment with camera rotation
doRotation(thisR);

%% Change the camera position
oFrom = thisR.get('from');
oTo = thisR.get('to');
oUp = thisR.get('up');

thisR.set('object distance', 1.3);

% relight the scene with a variety of skymaps
doSkymaps(thisR);

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
doMaterials(thisR);

% We can loop through our results and generate a bunch of separate figures
%%
faceImages = {};
for ii=1:numel(scenes)

    if isequal(intent, 'science')
        faceImages{ii} = facesDetect('scene',scenes{ii}, 'interactive',false,...
            'interactive',true,'method','MTCNN','caption',scenes{ii}.name); %#ok<SAGROW>
    else
        faceImages{ii} = facesDetect('scene',scenes{ii}, 'interactive',false,...
            'interactive',true,'method','MTCNN'); %#ok<SAGROW>
    end

    % trying to get rid of specular noise / maybe an nr call?
    %faceImages{ii}(faceImages{ii}(:)>220) = 0;
    %faceImages{ii} = imadjust(faceImages{ii},[.1 .1 .1 ; .95 .95 .95]);
end
ieNewGraphWin([],[],'What makes a face?');
montage(faceImages,'ThumbnailSize',[]);

function doRotation(thisR)
camStart = thisR.get('from');
direction = thisR.get('fromto');
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
end

function doSkymaps(thisR)
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
end

function doMaterials(thisR)
% Use a nice skylight
thisR.set('lights','all','delete');
thisR.set('skymap','sky-brightfences.exr');

% Add our list of materials, or pick and choose
allMaterials = piMaterialPresets('list');

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
end