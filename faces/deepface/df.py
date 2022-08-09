# Interface to DeepFace library for ISETml
#   David Cardinal, Stanford University, August, 2022
#
# requires installing deepface via pip or similar
#
#from deepface import DeepFace
import deepface

verification = '';
root = 'c:/'
verification = deepface.DeepFace.verify(img1_path = "c:/iset/isetml/data/test_faces/Pe_Lanes_0002.jpg", img2_path = "c:/iset/isetml/data/test_faces/Pe_Lanes_0007.jpg")
print(verification['verified'])
