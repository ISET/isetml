function  [faceOut, foundFaces] = facesDetect(options)
%FACESDETECT Summary of this function goes here
%   Detect Faces in images using Viola-Jones algorithm
%    or MTCNN algorithm
%   Requires Vision toolbox
%
% D. Cardinal, Stanford University, 2022
%
%{
facesDetect('file','b:/iset/isetml/data/test_faces/PU_Band.jpg',...
    'writeFaces', true);
%}

% Find what we are looking for
arguments
    options.file = ''; % name of an image file to open & check
    options.image = []; % image object that's already read in
    options.scene = ''; % get a flat image from a scene and evaluate it
    options.interactive = true; % whether to show results
    options.method = 'MTCNN'; %'Viola-Jones' % Viola-Jones Cascade is the default
    options.caption = '';
    options.fontSize = 18;
    options.writeFaces = false;
end

% Read an image or a video frame or an ISET scene
if isfile(which(options.file))
    ourImg = imread(which(options.file));
elseif ~isempty(options.image)
    ourImg = options.image;
elseif ~isempty(options.scene)
    % get temp png file
    imgFile = [tempname() '.png'];
    sceneSaveImage(options.scene, imgFile);
    ourImg = imread(imgFile);
    delete(imgFile);
else
    error('Face Detection called with invalid input');
end

switch options.method
    case 'Viola-Jones'
        % Default detector is set for front faces
        % But we can also use profiles
        faceDetect = vision.CascadeObjectDetector('FrontalFaceCART');
        %faceDetect = vision.CascadeObjectDetector('ProfileFace');

        % merge threshhold impacts accuracy (1 finds tons of things, 4 is default, 8 max?)
        % from some simple experiments, 3 seems like a good compromise
        faceDetect.MergeThreshold = 3;
        % step asks our detector to look at an image
        foundFaces = step(faceDetect, ourImg);
    case 'MTCNN'
        % A newer, CNN-based, approach
        [foundFaces, scores, landmarks] = mtcnn.detectFaces(ourImg);
    case 'Oxford'
        % Not working yet!!
        % External library from Oxford Robotics
        % Not sure "manager" is a great object class name:)
        % NEEDED:
        %   take image instead of path?
        %   sort out other params for use by us
        manager.detection.detect_faces_frame(framesPath, ...
            framesPattern, modelPath, facedetPath);

end

font = 'Palatino Linotype Bold';

% add a caption if we are asked to
if ~isempty(options.caption)
    iSize = size(ourImg);
    iHeight = iSize(1);
    ourImg = insertObjectAnnotation(ourImg,"rectangle",[0 iHeight 200 50], ...
        options.caption, 'FontSize', options.fontSize, 'Font',font);
end

% add a rectangle showing any found faces as a box with text
if ~isempty(foundFaces)
    faceOut = insertObjectAnnotation(ourImg,"rectangle",foundFaces,'Face', ...
        'Font',font,'FontSize',options.fontSize);
else
    faceOut = ourImg;
end

% user wants us to write out the found faces for further analysis
cropDir = 'b:/iset/isetml/local/faces/crops';
if ~isempty(foundFaces) && options.writeFaces
    for ii = 1:size(foundFaces,1)
        % find each face crop and write it outS
        cFace = imcrop(ourImg, foundFaces(ii,:));
        imwrite(cFace,fullfile(cropDir,sprintf('Crop_%s.jpg', string(ii))));
        
    end
end

% show result directly to the user if asked
if options.interactive
    figure, imshow(faceOut), title('Found faces:');
end

end


