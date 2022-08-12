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
import imageio
import google
import pandas as pd
import cv2

from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

actuals = []; predictions = []; distances = []

# Set face dir & get faces (some are in the vistalab repo)
vLabRepo = 'b:/iset/vistalab' # in matlab is: vlRootPath();

faceDirs =  [os.path.join(vLabRepo, "faces", "annie")]
faceDirs.append(os.path.join(vLabRepo, "faces", "david"))
faceDirs.append(os.path.join(vLabRepo, "faces", "band"))

faceDim = (200, 200)

ii = 0
faceFig = plt.figure()
for dir in faceDirs:

    baseFace = os.path.join(dir, 'Baseline_Face.jpg')
    # compare to all faces, including our sample
    otherFaces = glob.glob(os.path.join(dir, '*.jpg'))

    for imgFile in otherFaces:
        ii += 1
        img = cv2.imread(imgFile)
        img = cv2.resize(img, faceDim)
        rgbImg = img
        obj = DeepFace.verify(baseFace, img, model_name = 'VGG-Face', model = vgg_model, enforce_detection=False)
        #print(obj['verified'])

        plt.subplot(6,6, ii)
        plt.axis('off')
        plt.title(obj['verified'])
        plt.imshow(rgbImg)

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
