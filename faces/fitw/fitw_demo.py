# Intro code for using Faces in the Wild
# Original: https://sefiks.com/2020/08/27/labeled-faces-in-the-wild-for-face-recognition/

# requires matplotlib, sklearn, deepface, dlib

import matplotlib.pyplot as plt
from deepface import DeepFace
from sklearn.datasets import fetch_lfw_pairs
fetch_lfw_pairs = fetch_lfw_pairs(subset = 'test', color = True, resize = 1)

pairs = fetch_lfw_pairs.pairs
labels = fetch_lfw_pairs.target
target_names = fetch_lfw_pairs.target_names

actuals = []; predictions = []; numPredicts = []
for i in range(0, pairs.shape[0]):
   pair = pairs[i]
   img1 = pair[0]
   img2 = pair[1]
 
   # this shows us every result if we want
   if False:
      fig = plt.figure()
 
      ax1 = fig.add_subplot(1,3,1)
      plt.imshow(img1)
 
      ax2 = fig.add_subplot(1,3,2)
      plt.imshow(img2)
 
      ax3 = fig.add_subplot(1,3,3)
      plt.text(0, 0.50, target_names[labels[i]])
 
      plt.show()
 
   #deepface expects bgr instead of rgb
   img1 = img1[:,:,::-1]; img2 = img2[:,:,::-1]

   #Models include: 'Dlib', 'OpenFace'
   obj = DeepFace.verify(img1, img2
      , enforce_detection = False, model_name = 'OpenFace', distance_metric = 'euclidean')
   prediction = obj["verified"]
   predictions.append(prediction)
   if prediction == True:
      numPredicts.append(1)
   else:
      numPredicts.append(0)
   print(numPredicts)
 
   actual = True if labels[i] == 1 else False
   actuals.append(actual)

from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
accuracy = 100*accuracy_score(actuals, predictions)
precision = 100*precision_score(actuals, predictions)
recall = 100*recall_score(actuals, predictions)
f1 = 100*f1_score(actuals, predictions)

print("Accuracy: ", accuracy, ", Precision: ", precision, ", Recall: ", recall, ", F1: ", f1)
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(actuals, predictions)
print(cm)
 
tn, fp, fn, tp = cm.ravel()
print(tn, fp, fn, tp)
