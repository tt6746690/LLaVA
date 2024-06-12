#!/bin/bash


DATA_DIR=/fsx/wpq/github/metasummer2024/external/LLaVA/playground/data
mkdir -p $DATA_DIR

echo "Downloading COCO dataset..."
mkdir -p "$DATA_DIR/coco"
cd "$DATA_DIR/coco"
wget http://images.cocodataset.org/zips/train2017.zip
unzip -q train2017.zip
wget http://images.cocodataset.org/zips/val2014.zip # for POPE
unzip -q val2014.zip
rm val2014.zip train2017.zip

echo "Downloading GQA dataset..."
mkdir -p "$DATA_DIR/gqa"
cd "$DATA_DIR/gqa"
wget https://downloads.cs.stanford.edu/nlp/data/gqa/images.zip
unzip -q images.zip
rm images.zip

echo "Downloading OCR-VQA dataset..."
# 1. download folder from gdrive: https://drive.google.com/drive/folders/1_GYPY5UkUy7HIcR0zq3ZCFgeZN7BAfm_
# 2. rsync ~/Downloads/OCR-VQA-200K-* wpq@wpq.submit.c1.ai4p.metafb.cloud:/fsx/wpq/github/metasummer2024/external/LLaVA/data/gqa/. does not work instead uploaded to dropbox and use dropbox link to download instead.
mkdir -p "$DATA_DIR/ocr_vqa"
cd "$DATA_DIR/ocr_vqa"
wget https://www.dropbox.com/scl/fi/1y6eczbfk8ax3anec9ynn/OCR-VQA-200K-20240606T170617Z-001.zip?rlkey=vo47zqjp8xj7k35vi61rn2jf4&dl=1
 -O OCR-VQA-200K.zip
unzip -q OCR-VQA-200K.zip
mv OCR-VQA-200K/* .
python loadDataset.py # need to comment out `pdb.set_trace()`
rmdir OCR-VQA-200K
rm OCR-VQA-200K.zip LICENCE.txt


echo "Downloading TextVQA dataset..."
mkdir -p "$DATA_DIR/textvqa"
cd "$DATA_DIR/textvqa"
wget https://dl.fbaipublicfiles.com/textvqa/images/train_val_images.zip
unzip -q train_val_images.zip
rm train_val_images.zip


echo "Downloading VisualGenome dataset..."
mkdir -p "$DATA_DIR/vg"
cd "$DATA_DIR/vg"
wget https://cs.stanford.edu/people/rak248/VG_100K_2/images.zip
wget https://cs.stanford.edu/people/rak248/VG_100K_2/images2.zip
unzip -q images.zip
unzip -q images2.zip
rm images.zip images2.zip

tree -L 2 $DATA_DIR

echo "Setup llava eval datasets..."
mkdir -p "$DATA_DIR/eval"
cd "$DATA_DIR/eval"
wget -O eval.zip https://www.dropbox.com/s/povzrf0q14e8nn9/llava_eval.zip?dl=1
unzip -q eval.zip -d .
rm eval.zip


echo "Setup eval/vqav2 dataset..."
cd "$DATA_DIR/eval/vqav2"
# 1. images
wget http://images.cocodataset.org/zips/test2015.zip
unzip -q test2015.zip
rm test2015.zip


echo "Setup eval/gqa dataset..."
cd "$DATA_DIR/eval/gqa"
# 1. sceneGraphs (not really used): https://cs.stanford.edu/people/dorarad/gqa/download.html
wget https://downloads.cs.stanford.edu/nlp/data/gqa/sceneGraphs.zip
unzip -q sceneGraphs.zip
# 2. questions
wget questions1.2.zip https://downloads.cs.stanford.edu/nlp/data/gqa/questions1.2.zip
unzip -q questions1.2.zip
# 3. images: already downloaded the images.
ln -s ../../gqa/images/ .
# 4. script: https://cs.stanford.edu/people/dorarad/gqa/evaluate.html
wget https://nlp.stanford.edu/data/gqa/eval.zip
unzip -q eval.zip
rm sceneGraphs.zip questions1.2.zip eval.zip
# 5. replace eval.py since the GQA dataset has some missing assets in v1.2 release.
mv eval.py eval_default.py 
wget -O eval.py https://gist.githubusercontent.com/haotian-liu/db6eddc2a984b4cbcc8a7f26fd523187/raw/1ac7a1aab0c631845c645722082789977850ace0/1_eval.py


echo "Setup eval/vizwiz dataset..."
cd "$DATA_DIR/eval/vizwiz"
# download dataset
# 1. questions
wget https://vizwiz.cs.colorado.edu/VizWiz_final/vqa_data/Annotations.zip
unzip -q Annotations.zip # need `test.json` containing test question image pairs.
# 2. images
wget https://vizwiz.cs.colorado.edu/VizWiz_final/images/test.zip
rm Annotations.zip, test.zip
unzip -q test.zip # holds the test images


echo "Setup eval/scienceqa dataset..."
cd "$DATA_DIR/eval/scienceqa"
# download from github: https://github.com/lupantech/ScienceQA?tab=readme-ov-file
# 1. problems
wget https://raw.githubusercontent.com/lupantech/ScienceQA/main/data/scienceqa/problems.json
# 2. test images https://github.com/lupantech/ScienceQA/blob/main/tools/download.sh
wget https://scienceqa.s3.us-west-1.amazonaws.com/images/test.zip
unzip test.zip -d images/
rm test.zip
# 3. pid_splits.json on google drive, move to dropbox, then download
wget -O pid_splits.json https://www.dropbox.com/scl/fi/d6s4etwf6wx77juvu3d4v/pid_splits.json?rlkey=imvvvi3hxcgsyxi2m378e8lja&dl=1

 
echo "Setup eval/textvqa dataset..."
cd "$DATA_DIR/eval/textvqa"
# 1. questions
wget https://dl.fbaipublicfiles.com/textvqa/data/TextVQA_0.5.1_val.json
# 2. images
wget https://dl.fbaipublicfiles.com/textvqa/images/train_val_images.zip
unzip -q train_val_images.zip
rm train_val_images.zip


echo "Setup eval/pope dataset..."
cd "$DATA_DIR/eval/pope"
# 1. object categories
mkdir coco
wget -P coco https://raw.githubusercontent.com/AoiDragon/POPE/e3e39262c85a6a83f26cf5094022a782cb0df58d/output/coco/coco_pope_random.json
wget -P coco https://raw.githubusercontent.com/AoiDragon/POPE/e3e39262c85a6a83f26cf5094022a782cb0df58d/output/coco/coco_pope_popular.json
wget -P coco https://raw.githubusercontent.com/AoiDragon/POPE/e3e39262c85a6a83f26cf5094022a782cb0df58d/output/coco/coco_pope_adversarial.json
# 2. coco val2014: downloaded to coco directory, just need a soft link.
ln -s $DATA_DIR/coco/val2014 .


echo "Setup eval/MME dataset..."
cd "$DATA_DIR/eval/MME"
# 1. images
wget -O MME_Benchmark.zip https://www.dropbox.com/scl/fi/n8hzkfb55jeqhiicbkdl2/MME_Benchmark.zip?rlkey=phly8yt5zzo7dpmpraz77xpp6&dl=1
unzip MME_Benchmark.zip
rm MME_Benchmark.zip
# 2. evaluation tools
wget https://github.com/BradyFU/Awesome-Multimodal-Large-Language-Models/raw/Evaluation/tools/eval_tool.zip
unzip eval_tool.zip
rm eval_tool.zip


echo "Setup eval/mmbench dataset..."
cd "$DATA_DIR/eval/mmbench"
wget https://download.openmmlab.com/mmclassification/datasets/mmbench/mmbench_dev_20230712.tsv