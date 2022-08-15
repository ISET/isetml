# requires matplotlib, deepface, dlib, scikit-learn, opencv
# NOTE: For gpu, install tensorflow-gpu first
#       the pip install deepface --no-deps
#       (might mean you also need fire, gdown)
from sklearn.datasets import fetch_lfw_pairs
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import matplotlib.pyplot as plt
import math
from mpl_toolkits.axes_grid1 import ImageGrid
from deepface import DeepFace
from tqdm import tqdm
import os
import glob
#import imageio
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
# Assume that the vistalab repo is relative to our drive:
ourPath = os.path.splitdrive(os.getcwd())
ourDrive = os.path.join(ourPath[0],'/')
vLabRepo = os.path.join(ourDrive, "iset", "vistalab")
# If we can query matlab:
#vLabRepo = 'c:/iset/vistalab' # in matlab is: vlRootPath();

faceDirs =  [os.path.join(vLabRepo, "faces", "annie")]
faceDirs.append(os.path.join(vLabRepo, "faces", "david"))
faceDirs.append(os.path.join(vLabRepo, "faces", "band"))
faceDirs.append(os.path.join(vLabRepo, "faces", "thomas"))

faceDim = (300, 300)

ii = 0

# It'd be nice if we knew tht total number of face before we plot
#    faceCount = len(otherFaces)
#    faceRowCol = ceil(sqrt(faceCount))
faceRowCol = 9 # make sure it is big enough

faceFig = plt.figure()
for dir in faceDirs:

    # split out dirname for labeling
    pathParts = os.path.split(dir)
    baseFace = os.path.join(dir, 'Baseline_Face.jpg')
    # compare to all faces, including our sample
    otherFaces = glob.glob(os.path.join(dir, '*.jpg'))

    # Need a smaller font to fit
    titleFont = {'family':'serif','color':'blue','size':6}
    for imgFile in otherFaces:
        ii += 1
        img = plt.imread(imgFile)
        img = cv2.resize(img, faceDim)
        rgbImg = img.copy()
        faceVerify = DeepFace.verify(baseFace, img, model_name = 'VGG-Face', model = vgg_model, enforce_detection=False)
        faceAnalyze = DeepFace.analyze(img, enforce_detection=False)

        plt.subplot(7, 8, ii)
        plt.axis('off')

        # figure out most likely emotion
        eVals = faceAnalyze['emotion']
        eMostLikely = max(eVals, key=eVals.get)

        # now age
        eAge = faceAnalyze['age']
        # and race
        rVals = faceAnalyze['race']
        rMostLikely = max(rVals, key=rVals.get)
        # add + str(eAge) +, but so far the results are pretty lame
        # add + rMostLikely +, but so far the results are prett lame
        if faceVerify['verified'] == True:
            tString = pathParts[1] + ' ' +  eMostLikely
        else:
            tString = '??' + ' ' +  eMostLikely
        
        plt.title(tString, fontdict=titleFont)

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
