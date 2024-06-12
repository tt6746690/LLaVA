#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/pope

python -m llava.eval.model_vqa_loader \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/llava_pope_test.jsonl \
    --image-folder $EVAL_DATA_DIR/val2014 \
    --answers-file $CKPT/eval/pope/answers.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python llava/eval/eval_pope.py \
    --annotation-dir $EVAL_DATA_DIR/coco \
    --question-file $EVAL_DATA_DIR/llava_pope_test.jsonl \
    --result-file $CKPT/eval/pope/answers.jsonl