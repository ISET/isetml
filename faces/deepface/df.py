# Interface to DeepFace library for ISETml
#   David Cardinal, Stanford University, August, 2022
#
# requires installing deepface via pip or similar
#
from deepface import DeepFace

verification = DeepFace.verify(img1_path = "img1.jpg", img2_path = "img2.jpg")
