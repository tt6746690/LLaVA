#!/bin/bash

set -e


CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/textvqa


python -m llava.eval.model_vqa_loader \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/llava_textvqa_val_v051_ocr.jsonl \
    --image-folder $EVAL_DATA_DIR/train_images \
    --answers-file $CKPT/eval/textvqa/answers.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python -m llava.eval.eval_textvqa \
    --annotation-file $EVAL_DATA_DIR/TextVQA_0.5.1_val.json \
    --result-file $CKPT/eval/textvqa/answers.jsonl