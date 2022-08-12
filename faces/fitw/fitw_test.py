# requires matplotlib, deepface, dlib
# NOTE: For gpu, install tensorflow-gpu first
#       the pip install deepface --no-deps
from sklearn.datasets import fetch_lfw_pairs
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import ImageGrid
from deepface import DeepFace
from tqdm import tqdm
import os
import glob
import google
import pandas as pd

from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

actuals = []; predictions = []; distances = []

# Set face dir & get faces (some are in the vistalab repo)
faceDir = "c:/iset/vistalab/faces/david"

baseFace = os.path.join(faceDir, 'Baseline_Face.jpg')
# compare to all faces, including our sample
otherFaces = glob.glob(os.path.join(faceDir, '*.jpg'))

ii = 0
faceFig = plt.figure()
for img in otherFaces:
    ii += 1
    obj = DeepFace.verify(baseFace, img, model_name = 'VGG-Face', model = vgg_model, enforce_detection=False)
    #print(obj['verified'])

    plt.subplot(4,4, ii)
    plt.axis('off')
    plt.title(obj['verified'])
    plt.imshow(plt.imread(img))

plt.show()
plt.pause


    # annotate plt.annotate.__annotations__
    # show
    
"""
For other models:

vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

facenet_model = Facenet.loadModel()
print("FaceNet loaded")

openface_model = OpenFace.loadModel()
print("OpenFace loaded")

deepface_model = FbDeepFace.loadModel()
print("DeepFace loaded")

"""
