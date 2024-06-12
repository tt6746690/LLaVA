#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/scienceqa

python -m llava.eval.model_vqa_science \
    --model-path liuhaotian/llava-v1.5-13b \
    --question-file $EVAL_DATA_DIR/llava_test_CQM-A.json \
    --image-folder $EVAL_DATA_DIR/images/test \
    --answers-file $CKPT/eval/scienceqa/answers.jsonl \
    --single-pred-prompt \
    --temperature 0 \
    --conv-mode vicuna_v1

python llava/eval/eval_science_qa.py \
    --base-dir $EVAL_DATA_DIR \
    --result-file $CKPT/eval/scienceqa/answers.jsonl \
    --output-file $CKPT/eval/scienceqa/outputs.jsonl \
    --output-result $CKPT/eval/scienceqa/results.jsonl
