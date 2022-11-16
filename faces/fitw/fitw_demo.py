# Intro code for using Faces in the Wild

# Added options, conda support, iset integration, D. Cardinal, Stanford University
# Original: https://sefiks.com/2020/08/27/labeled-faces-in-the-wild-for-face-recognition/
# 
# requires matplotlib, sklearn, deepface, dlib
# NOTE: For gpu, install tensorflow-gpu first
#       the pip install deepface --no-deps
from sklearn.datasets import fetch_lfw_pairs
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import matplotlib.pyplot as plt
from deepface import DeepFace
from tqdm import tqdm
import google
import pandas as pd

# Here we are only loading the test set pairs
fetch_lfw_pairs = fetch_lfw_pairs(subset = 'test', color = True, resize = 1)

pairs = fetch_lfw_pairs.pairs
labels = fetch_lfw_pairs.target
target_names = fetch_lfw_pairs.target_names

instances = pairs.shape[0]
print("instances: ", instances)

from deepface.basemodels import VGGFace, Facenet, OpenFace, FbDeepFace
from deepface.basemodels.DlibResNet import DlibResNet

vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

"""
vgg_model = VGGFace.loadModel()
print("VGG-Face loaded")

facenet_model = Facenet.loadModel()
print("FaceNet loaded")

openface_model = OpenFace.loadModel()
print("OpenFace loaded")

deepface_model = FbDeepFace.loadModel()
print("DeepFace loaded")

"""

#dlib_model = DlibResNet()
#print("Dlib loaded")

plot = False # otherwise shows us every pair 1 by 1

# reset stats
actuals = []; predictions = []; distances = []

# get our data
pbar = tqdm(range(0, instances))

for i in pbar:
    # iterate over all the pairs of images
    pair = pairs[i]
    img1 = pair[0]; img2 = pair[1]
    img1 = img1[:,:,::-1]; img2 = img2[:,:,::-1] #opencv expects bgr instead of rgb
    
    #obj = DeepFace.verify(img1, img2, model_name = 'VGG-Face', model = vgg_model)
    #obj = DeepFace.verify(img1, img2, model_name = 'Dlib', model = dlib_model, distance_metric = 'euclidean', enforce_detection=False)
    obj = DeepFace.verify(img1, img2, model_name = 'VGG-Face', model = vgg_model, enforce_detection=False)

    # Record our prediction for each pair
    prediction = obj["verified"]
    predictions.append(prediction)
    
    distances.append(obj["distance"])

    # get the actual answer  
    label = target_names[labels[i]]
    actual = True if labels[i] == 1 else False
    actuals.append(actual)
    
    # if we want to preview each pair
    if plot:    
        print(i)
        fig = plt.figure(figsize=(5,2))

        ax1 = fig.add_subplot(1,3,1)
        plt.imshow(img1/255)
        plt.axis('off')

        ax2 = fig.add_subplot(1,3,2)
        plt.imshow(img2/255)
        plt.axis('off')

        ax3 = fig.add_subplot(1,3,3)
        plt.text(0, 0.50, label)
        plt.axis('off')

        plt.show()

# calculate some classic stats based on our performance
accuracy = 100*accuracy_score(actuals, predictions)
precision = 100*precision_score(actuals, predictions)
recall = 100*recall_score(actuals, predictions)
f1 = 100*f1_score(actuals, predictions)

print("instances: ",len(actuals))
print("accuracy: " , accuracy, "%")
print("precision: ", precision, "%")
print("recall: ", recall,"%")
print("f1: ",f1,"%")

# show our confusion matrix
cm = confusion_matrix(actuals, predictions)
cm
 
tn, fp, fn, tp = cm.ravel()
(tn, fp, fn, tp)

"""
true_negative = 472
false_positive = 28
false_negative = 45
true_positive = 455
"""