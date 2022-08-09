% Interface to DeepFace library for ISETml
%   David Cardinal, Stanford University, August, 2022
%
% requires installing deepface via pip or similar
%

DF = py.importlib.import_module('deepface');
%from deepface import DeepFace

img1_path = "c:/iset/isetml/data/test_faces/Pe_Lanes_0002.jpg";
img2_path = "c:/iset/isetml/data/test_faces/Pe_Lanes_0007.jpg";
verification = py.deepface.DeepFace.verify(img1_path = img1_path, img2_path = img2_path);
%verification = py.deepface.DeepFace.verify(img1_path = img1_path, img2_path = img2_path);
