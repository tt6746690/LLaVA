#!/bin/bash

set -e

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/llava-bench-in-the-wild


# python -m llava.eval.model_vqa \
#     --model-path $CKPT \
#     --question-file $EVAL_DATA_DIR/questions.jsonl \
#     --image-folder $EVAL_DATA_DIR/images \
#     --answers-file $CKPT/eval/llavabench/answers.jsonl \
#     --temperature 0 \
#     --conv-mode vicuna_v1

# mkdir -p $EVAL_DATA_DIR/reviews

python llava/eval/eval_gpt_review_bench.py \
    --question $EVAL_DATA_DIR/questions.jsonl \
    --context $EVAL_DATA_DIR/context.jsonl \
    --rule llava/eval/table/rule.json \
    --answer-list \
        $EVAL_DATA_DIR/answers_gpt4.jsonl \
        $CKPT/eval/llavabench/answers.jsonl \
    --output \
        $CKPT/eval/llavabench/reviews.jsonl

python llava/eval/summarize_gpt_review.py -f $CKPT/eval/llavabench/reviews.jsonl