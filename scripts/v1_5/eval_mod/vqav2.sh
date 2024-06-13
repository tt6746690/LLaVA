#!/bin/bash

set -e

gpu_list="${CUDA_VISIBLE_DEVICES:-0}"
IFS=',' read -ra GPULIST <<< "$gpu_list"

echo $gpu_list

CHUNKS=${#GPULIST[@]}

SPLIT="llava_vqav2_mscoco_test-dev2015"
CKPT=$1
EVAL_DATA_DIR=./playground/data/eval/vqav2

for IDX in $(seq 0 $((CHUNKS-1))); do
    CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
        --model-path $CKPT \
        --question-file $EVAL_DATA_DIR/$SPLIT.jsonl \
        --image-folder $EVAL_DATA_DIR/test2015 \
        --answers-file $CKPT/eval/vqav2/$SPLIT/answers/${CHUNKS}_${IDX}.jsonl \
        --num-chunks $CHUNKS \
        --chunk-idx $IDX \
        --temperature 0 \
        --conv-mode vicuna_v1 &
done

wait

output_file=$CKPT/eval/vqav2/$SPLIT/answers/merge.jsonl

echo $output_file

# Clear out the output file if it exists.
> "$output_file"

# Loop through the indices and concatenate each file.
for IDX in $(seq 0 $((CHUNKS-1))); do
    cat $CKPT/eval/vqav2/$SPLIT/answers/${CHUNKS}_${IDX}.jsonl >> "$output_file"
done

python scripts/convert_vqav2_for_submission.py --src "$output_file" --dst $CKPT/eval/vqav2/$SPLIT/answers_upload.json --test_split $EVAL_DATA_DIR/llava_vqav2_mscoco_test2015.jsonl


# submit with evalai-cli
conda activate evalai
echo -e "y\n$CKPT\n\n\n\n" | evalai challenge 830 phase 1793 submit --file $CKPT/eval/vqav2/$SPLIT/answers_upload.json  --large --private

