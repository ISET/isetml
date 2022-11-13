# Test FITW-trained model on local faces
# 
# D. Cardinal, Stanford University, 2022
#
# requires matplotlib, deepface, dlib, scikit-learn, opencv
# NOTE: For gpu, install tensorflow-gpu first
#       the pip install deepface --no-deps
#       (might mean you also need fire, gdown)

# scikit (sk) is a powerful ML framework for Python
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

# deepface is an impressive package that provides access to many
# leading facial recognition models and tools
from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

# Select the model we want to evaluate:
vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

# clear our result counters:
actuals = []; predictions = []; distances = []

# Set face dir & get faces (some are in the vistalab repo)
# Assume that the vistalab repo is relative to our drive:
ourPath = os.path.splitdrive(os.getcwd())
ourDrive = os.path.join(ourPath[0],'/')

# !! Vistalab repo is private since it has lots of our faces
# !! So for a project should be replaced by other faces
# They are just a bunch of selfies foldered by subject name
# Should be easy enough for those working on a project to do
# with team members and friends
vLabRepo = os.path.join(ourDrive, "iset", "vistalab")
faceDirs =  [os.path.join(vLabRepo, "faces", "annie")]
faceDirs.append(os.path.join(vLabRepo, "faces", "david"))
faceDirs.append(os.path.join(vLabRepo, "faces", "band"))
faceDirs.append(os.path.join(vLabRepo, "faces", "thomas"))

# Face models typically work at surprisingly-low resoolution
# Might be interesting to treat this as a variable and experiment
faceDim = (300, 300)

# When we're finished we provide a nice graphic showing matches
# This just allocates a large enough grid to hold our results in a single plot
# It'd be nice if we knew tht total number of face before we plot
#    faceCount = len(otherFaces)
#    faceRowCol = ceil(sqrt(faceCount))
faceRowCol = 8 # make sure it is big enough

faceFig = plt.figure()

# counter for all our faces
ii = 0

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

        # Verify tells us whether we have a face
        faceVerify = DeepFace.verify(baseFace, img, model_name = 'VGG-Face', model = vgg_model, enforce_detection=False)
        
        # and Analyze then picks it apart for characteristics
        faceAnalyze = DeepFace.analyze(img, enforce_detection=False)

        #Now start producing a graphic with our results
        plt.subplot(faceRowCol, faceRowCol, ii)
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
