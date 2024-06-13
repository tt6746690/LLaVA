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
# 1. questions
wget https://raw.githubusercontent.com/lupantech/ScienceQA/main/data/scienceqa/problems.json
# 2. images https://github.com/lupantech/ScienceQA/blob/main/tools/download.sh
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
mv MME_Benchmark_release_version/eval_tool .
mv convert_answer_to_mme.py convert_answer_to_mme_default.py
wget -O convert_answer_to_mme.py https://www.dropbox.com/scl/fi/jdfz36yyak6um4esoe7od/convert_answer_to_mme_wpq.py?rlkey=xn3n1pt19n0xumzcaza1n6bv9&dl=1 # some modification due to different file structure used to store results.
# 3. some images need to be downloaded manually.
cd MME_Benchmark_release_version
# 3.1 landmark
cd landmark/images
wget -O download_landmark_fixed.py https://www.dropbox.com/scl/fi/oafadikxadkkhsw9j0pqh/download_landmark.py?rlkey=1ms3b8z68cb7era4taudwz323&dl=1
python download_landmark_fixed.py
wget -O 03d5e3bfc958be38.jpg https://upload.wikimedia.org/wikipedia/commons/2/2a/Museo_nazionale_ferroviario_di_Pietrarsa_-_locomotiva_899.006.jpg
cd ../../
# 3.2 artwork. 
# download Toy artwork dataset from https://deepart.hkust.edu.hk/ART500K/art500k.html. and use the following to pick the 200 subset. upload to dropbox
# mkdir artwork200
# rsync -av mrs:/fsx/wpq/github/metasummer2024/external/LLaVA/playground/data/eval/MME/MME_Benchmark_release_version/artwork/images/image_list.txt ~/Downloads/image_list.txt
# while read -r filename; do
#     cp "toy_dataset/$filename" "artwork200/"
# done < image_list.txt
wget -O artwork200.zip https://www.dropbox.com/scl/fi/ggs1novmyoj9dhfqmrprw/artwork200.zip?rlkey=2j5n6r8mclhqbzqhfzjf50ekp&dl=1
unzip artwork200.zip
mv artwork200/*.jpg .
rmdir artwork200
rm  artwork200.zip
rm -r __MACOSX



echo "Setup eval/mmbench dataset..."
cd "$DATA_DIR/eval/mmbench"
wget https://download.openmmlab.com/mmclassification/datasets/mmbench/mmbench_dev_20230712.tsv


echo "Setup eval/seed_bench dataset..."
cd "$DATA_DIR/eval/seed_bench"
# https://github.com/AILab-CVC/SEED-Bench/blob/main/DATASET.md
# 1. CC3M (1-9) is part of huggingface's repo
git lfs install
git clone https://huggingface.co/datasets/AILab-CVC/SEED-Bench
cd Seed-Bench
unzip SEED-Bench-image.zip
rm SEED-Bench-image.zip
cat v1_video.zip.??? > v1_video.zip
unzip v1_video.zip
rm v1_video.zip v1_video.zip.*
cp SEED-Bench.json SEED-Bench.py ..
mv SEED-Bench-image ..
cd ..
# 3 tasks contain videos which are not in the huggingface repo.
# more details on how to download videosfor the 3 tasks: https://github.com/AILab-CVC/SEED-Bench/blob/main/DATASET.md 
mkdir videos # contains raw videos
mkdir SEED-Bench-video-image # extract video frame from middle from raw videos
# 3.1 Something-Something v2 (10-action recognition) 1740 videos: https://developer.qualcomm.com/software/ai-datasets/something-something
# info: file:///Users/wpq/Downloads/20bn-something-something_download_instructions_-_091622.pdf
# download page: https://developer.qualcomm.com/software/ai-datasets/something-something
# once downloaded 20 shards of the tar file, combine and decompress, pick the 1509 video subset, zip, upload to dropbox.
# for z in *.zip; do unzip "$z"; done
# cat 20bn-something-something-v2-?? > 20bn-something-something-v2
# cat 20bn-something-something-v2 | tar -xvzf -
# curl https://huggingface.co/datasets/AILab-CVC/SEED-Bench/raw/main/SEED-Bench.json
# python -c "import json; data = json.load(open('SEED-Bench.json', 'r')); l = [x['data_id'] for x in data['questions'] if x['question_type_id'] == 10]; open('subset.txt', 'w').write('\n'.join(l))"
# mkdir -p something-something-v2-seed-subset
# cat subset.txt | xargs -I {} cp 20bn-something-something-v2/{} something-something-v2-seed-subset/
wget -O 20bn-something-something-v2.zip https://www.dropbox.com/scl/fi/gfpwsx3o0n3no9nn3qe3r/something-something-v2-seed-subset.zip?rlkey=my1u6ota48j67zgigh5am2k89&dl=1
unzip 20bn-something-something-v2.zip
rm 20bn-something-something-v2.zip
rm -r __MACOSX/
mv 20bn-something-something-v2/ videos/
# 3.2 Epic-kitchen 100 (11-action prediction) 138 long videos
# the scripts are too slow: https://github.com/epic-kitchens/epic-kitchens-download-scripts.git
# use Transmission on academic torrents instead. the 138 long videos took 200gb!
# EPIC-KITCHENS 2018 (instead of 100!) https://academictorrents.com/details/d08f4591d1865bbe3436d1eb25ed55aae8b8f043/tech&filelist=1 


echo "Setup eval/mm-vet dataset..."
cd "$DATA_DIR/eval/mm-vet"
# 1. data
wget https://github.com/yuweihao/MM-Vet/releases/download/v1/mm-vet.zip
unzip mm-vet.zip
rm mm-vet.zip
mv mm-vet/* .
rm .DS_Store
rmdir mm-vet
# 2. evaluation code (gpt-4 based)
wget https://raw.githubusercontent.com/yuweihao/MM-Vet/main/mm-vet_evaluator.py



echo "Setup eval/llava-bench-in-the-wild dataset..."
cd "$DATA_DIR/eval/llava-bench-in-the-wild"
# 1. image / questions
git clone https://huggingface.co/datasets/liuhaotian/llava-bench-in-the-wild
mv llava-bench-in-the-wild/* .
rm -r llava-bench-in-the-wild