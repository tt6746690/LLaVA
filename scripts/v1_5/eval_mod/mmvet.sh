#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/mm-vet

python -m llava.eval.model_vqa \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/llava-mm-vet.jsonl \
    --image-folder $EVAL_DATA_DIR/images \
    --answers-file $CKPT/eval/mmvet/answers.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python scripts/convert_mmvet_for_eval.py \
    --src $CKPT/eval/mmvet/answers.jsonl \
    --dst $CKPT/eval/mmvet/results.json

python $EVAL_DATA_DIR/mm-vet_evaluator.py \
    --mmvet_path $EVAL_DATA_DIR \
    --result_file $CKPT/eval/mmvet/results.json \
    --result_path $CKPT/eval/mmvet \
    --gpt_model gpt-4-0613
    # --use_sub_set to debug