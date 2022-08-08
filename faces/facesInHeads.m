function facesInHeads()
%%
% used to be a script, but needs persistent cache
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

% for 'science' intent we can re-use generated scenes
persistent cachedScenes;
if isempty(cachedScenes)
    cachedScenes = {};
end

switch intent
    case 'art'
        baseRez = 640;
        rays = 1024;
        thumbnailSize = [];
        fontSize = 36;
        scenes = {};
    case 'science'
        baseRez = 320;
        rays = 256;
        thumbnailSize = [baseRez inf];
        fontSize = 18;
        scenes = cachedScenes;
end

ieInit;
if ~piDockerExists, piDockerConfig; end

%% Generate scenes if needed
% Load the canonical pbrt head (until we get some others!)
thisR = piRecipeDefault('scene name','head');
if isequal(intent,'art') || isempty(cachedScenes)
    scenes = generateScenes(thisR,scenes);
    cachedScenes = scenes;
end

% We can loop through our results and generate a bunch of separate figures
%%
faceImages = {};
for ii=1:numel(scenes)

    % make it easier to visualize scenes with specular highlights
    scenes{ii} = sceneSet(scenes{ii},'renderflag', 'clip'); % HDR to deal with specks

    if isequal(intent, 'science')
        faceImages{ii} = facesDetect('scene',scenes{ii}, 'interactive',false,...
            'method','MTCNN','fontSize',fontSize,'caption',scenes{ii}.name); %#ok<SAGROW>
    else
        faceImages{ii} = facesDetect('scene',scenes{ii}, 'interactive',false,...
            'method','MTCNN','fontSize',fontSize); %#ok<SAGROW>
    end

end
ieNewGraphWin([],[],'What makes a face?');
montage(faceImages,'ThumbnailSize',thumbnailSize);

%% END OF MAIN CODE. Functions follow:

    function scenes = generateScenes(thisR, scenes)
        % NB: This should get simplified once assets work better:
        headAsset = '001_head_O';

        thisR.set('rays per pixel',rays);
        % we probably don't need much resolution, given the low-rez of most
        % face feature algorithms -- set higher for higher quality "poster"
        thisR.set('film resolution',[baseRez baseRez]*2);
        thisR.set('n bounces',6);

        %% This renders the default head
        [scene, results] = piWRS(thisR);
        scenes = [scenes, scene];
        %%
        % Because it is a full 3D head, we can rotate and re-render
        thisR.set('asset',headAsset,'rotate',[5 20 0]);
        [scene, results] = piWRS(thisR);
        scene.name = 'rotate 5 20 0';
        scenes = [scenes, scene];


        %% Experiment with camera rotation
        scenes = doRotation(thisR, scenes);

        %% Change the camera position
        oFrom = thisR.get('from');
        oTo = thisR.get('to');
        oUp = thisR.get('up');

        thisR.set('object distance', 1.3);

        % relight the scene with a variety of skymaps
        scenes = doSkymaps(thisR, scenes);

        % Move closer? Ask Brian:)
        thisR.set('from',oFrom);
        thisR.set('object distance', 1.5);
        thisR.set('from',oFrom + [0 0 0.1]);
        [scene, results] = piWRS(thisR);
        scene = sceneSet(scene,'renderflag', 'clip'); % HDR to deal with specks
        scenes = [scenes, scene];

        %%  Materials
        scenes = doMaterials(thisR,scenes);
    end

%% Rotation function
    function scenes = doRotation(thisR,scenes)
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

    function scenes = doSkymaps(thisR,scenes)
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

    function scenes = doMaterials(thisR,scenes)
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
end