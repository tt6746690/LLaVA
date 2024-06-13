#!/bin/bash

set -e

gpu_list="${CUDA_VISIBLE_DEVICES:-0}"
IFS=',' read -ra GPULIST <<< "$gpu_list"

CHUNKS=${#GPULIST[@]}

CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/seed_bench


for IDX in $(seq 0 $((CHUNKS-1))); do
    CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
        --model-path $CKPT \
        --question-file $EVAL_DATA_DIR/llava-seed-bench.jsonl \
        --image-folder $EVAL_DATA_DIR \
        --answers-file $CKPT/eval/seed/answers/${CHUNKS}_${IDX}.jsonl \
        --num-chunks $CHUNKS \
        --chunk-idx $IDX \
        --temperature 0 \
        --conv-mode vicuna_v1 &
done

wait

output_file=$CKPT/eval/seed/answers/merge.jsonl

# Clear out the output file if it exists.
> "$output_file"

# Loop through the indices and concatenate each file.
for IDX in $(seq 0 $((CHUNKS-1))); do
    cat $CKPT/eval/seed/answers/${CHUNKS}_${IDX}.json >> "$output_file"
done
 
# Evaluate
python scripts/convert_seed_for_submission.py \
    --annotation-file $EVAL_DATA_DIR/SEED-Bench.json \
    --result-file $output_file \
    --result-upload-file $CKPT/eval/seed/answers_upload.jsonl