#!/bin/bash


DATA_DIR=/fsx/wpq/github/metasummer2024/external/LLaVA/data

echo "Downloading COCO dataset..."
mkdir -p "$DATA_DIR/coco"
cd "$DATA_DIR/coco"
wget -O train2017.zip http://images.cocodataset.org/zips/train2017.zip
unzip train2017.zip -d .
rm train2017.zip

echo "Downloading GQA dataset..."
mkdir -p "$DATA_DIR/gqa"
cd "$DATA_DIR/gqa"
wget -O images.zip https://downloads.cs.stanford.edu/nlp/data/gqa/images.zip
unzip images.zip -d .
rm train2017.zip

echo "Downloading OCR-VQA dataset..."
# 1. download folder from gdrive: https://drive.google.com/drive/folders/1_GYPY5UkUy7HIcR0zq3ZCFgeZN7BAfm_
# 2. rsync ~/Downloads/OCR-VQA-200K-* wpq@wpq.submit.c1.ai4p.metafb.cloud:/fsx/wpq/github/metasummer2024/external/LLaVA/data/gqa/. does not work instead uploaded to dropbox and use dropbox link to download instead.
mkdir -p "$DATA_DIR/ocr_vqa"
cd "$DATA_DIR/ocr_vqa"
wget https://www.dropbox.com/scl/fi/1y6eczbfk8ax3anec9ynn/OCR-VQA-200K-20240606T170617Z-001.zip\?rlkey\=vo47zqjp8xj7k35vi61rn2jf4\&dl\=1 -O OCR-VQA-200K.zip
unzip OCR-VQA-200K.zip -d .
mv OCR-VQA-200K/* .
python loadDataset.py # need to comment out `pdb.set_trace()`
rmdir OCR-VQA-200K
rm OCR-VQA-200K.zip LICENCE.txt


echo "Downloading TextVQA dataset..."
mkdir -p "$DATA_DIR/textvqa"
cd "$DATA_DIR/textvqa"
wget -O train_val_images.zip https://dl.fbaipublicfiles.com/textvqa/images/train_val_images.zip
unzip train_val_images.zip -d .
rm train_val_images.zip


echo "Downloading VisualGenome dataset..."
mkdir -p "$DATA_DIR/vg"
cd "$DATA_DIR/vg"
wget -O images.zip https://cs.stanford.edu/people/rak248/VG_100K_2/images.zip
wget -O images2.zip https://cs.stanford.edu/people/rak248/VG_100K_2/images2.zip
unzip images.zip -d .
unzip images2.zip -d .
rm images.zip images2.zip


tree -L 2 $DATA_DIR