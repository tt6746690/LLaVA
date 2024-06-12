#!/bin/bash

set -e

gpu_list="${CUDA_VISIBLE_DEVICES:-0}"
IFS=',' read -ra GPULIST <<< "$gpu_list"

CHUNKS=${#GPULIST[@]}

SPLIT="llava_gqa_testdev_balanced"
CKPT=$1
GQADIR="./playground/data/eval/gqa"

for IDX in $(seq 0 $((CHUNKS-1))); do
    CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
        --model-path $CKPT \
        --question-file $GQADIR/$SPLIT.jsonl \
        --image-folder $GQADIR/images \
        --answers-file $CKPT/eval/gqa/$SPLIT/answers/${CHUNKS}_${IDX}.jsonl \
        --num-chunks $CHUNKS \
        --chunk-idx $IDX \
        --temperature 0 \
        --conv-mode vicuna_v1 &
done

wait

output_file=$CKPT/eval/gqa/$SPLIT/answers/merge.jsonl

# Clear out the output file if it exists.
> "$output_file"
 
# Loop through the indices and concatenate each file.
for IDX in $(seq 0 $((CHUNKS-1))); do
    cat $CKPT/eval/gqa/$SPLIT/answers/${CHUNKS}_${IDX}.jsonl >> "$output_file"
done

python scripts/convert_gqa_for_eval.py --src $output_file --dst $CKPT/eval/gqa/$SPLIT/testdev_balanced_predictions.json

python $GQADIR/eval.py --tier $GQADIR/testdev_balanced --predictions $CKPT/eval/gqa/$SPLIT/testdev_balanced_predictions.json
