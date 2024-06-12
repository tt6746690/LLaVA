#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/vizwiz


python -m llava.eval.model_vqa_loader \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/llava_test.jsonl \
    --image-folder $EVAL_DATA_DIR/test \
    --answers-file $CKPT/eval/vizwiz/answers.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python scripts/convert_vizwiz_for_submission.py \
    --annotation-file $EVAL_DATA_DIR/llava_test.jsonl \
    --result-file $CKPT/eval/vizwiz/answers.jsonl \
    --result-upload-file $CKPT/eval/vizwiz/answers_upload.json


# submit with evalai-cli
conda activate evalai
echo -e "y\n$CKPT\n\n\n\n" | evalai challenge 2185 phase 4336 submit --file $CKPT/eval/vizwiz/answers_upload.json  --large --private

