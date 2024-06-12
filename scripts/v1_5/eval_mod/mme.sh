#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/MME

python -m llava.eval.model_vqa_loader \
    --model-path $CKPT \
    --question-file $EVAL_DATA_DIR/llava_mme.jsonl \
    --image-folder $EVAL_DATA_DIR/MME_Benchmark_release_version \
    --answers-file $CKPT/eval/mme/answers.jsonl \
    --temperature 0 \
    --conv-mode vicuna_v1

python $EVAL_DATA_DIR/convert_answer_to_mme.py \
    --data_path $EVAL_DATA_DIR/MME_Benchmark_release_version \
    --result_dir $CKPT/eval/mme/

python $EVAL_DATA_DIR/eval_tool/calculation.py --results_dir $CKPT/eval/mme/results