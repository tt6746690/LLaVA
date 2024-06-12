#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/mmbench
SPLIT="mmbench_dev_20230712"

python -m llava.eval.model_vqa_mmbench \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/$SPLIT.tsv \
    --answers-file $CKPT/eval/mmbench/$SPLIT.jsonl \
    --single-pred-prompt \
    --temperature 0 \
    --conv-mode vicuna_v1

python scripts/convert_mmbench_for_submission.py \
    --annotation-file $EVAL_DATA_DIR/$SPLIT.tsv \
    --result-dir $CKPT/eval/mmbench \
    --upload-dir $CKPT/eval/mmbench \
    --experiment $SPLIT


python scripts/copy_predictions.py $CKPT ./playground/answers_upload