# Interface to DeepFace library for ISETml
#   David Cardinal, Stanford University, August, 2022
#
# requires installing deepface via pip or similar
#
from deepface import DeepFace

verification = DeepFace.verify(img1_path = "b:/iset/isetml/data/test_faces/Pe_Lanes_0002.jpg", img2_path = "b:/iset/isetml/data/test_faces/Pe_Lanes_0007.jpg");
