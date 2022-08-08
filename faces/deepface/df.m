% Interface to DeepFace library for ISETml
%   David Cardinal, Stanford University, August, 2022
%
% requires installing deepface via pip or similar
%

DF = py.importlib.import_module('deepface');

verification = DF.verify(img1_path = "img1.jpg", img2_path = "img2.jpg");