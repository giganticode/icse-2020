#!/bin/bash

trap 'if [[ "$BASH_COMMAND" =~ ^codeprep* ]]; then echo -e "\nRunning:          $BASH_COMMAND"; fi' DEBUG

# PATH_TO_DATASET="$1"
PATH_TO_DATASET="$PWD/min-dataset"

CPREP_VERSION=$(codeprep --version | grep -o "[^ ]*$")
PATH_TO_VOCABS="/root/.config/codeprep/$CPREP_VERSION/vocab/"

print_latest_calculated_vocab () {
    VOCAB_DIR="$PATH_TO_VOCABS/$(ls -1t $PATH_TO_VOCABS | head -1)"

    VOCAB_SIZE=$(cat "$VOCAB_DIR/vocabsize" | head -1)
    CORPUS_SIZE=$(cat "$VOCAB_DIR/vocab" | awk '{print $2}' | paste -sd+ | bc)
    echo -e "$1\t$VOCAB_SIZE\t$CORPUS_SIZE"
}

FULL_STRING=""

format_res () {
    echo -e "$1" | awk -F'\t' '{print $1"   Vocab size: "$2"      Corpus size: "$3}'
}

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab
RES=$(print_latest_calculated_vocab "Full                              ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode
RES=$(print_latest_calculated_vocab "No unicode                        ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces
RES=$(print_latest_calculated_vocab "+  No whitespace                  ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"2

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com
RES=$(print_latest_calculated_vocab "+  +  no comments                 ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --no-str
RES=$(print_latest_calculated_vocab "+  +  +  no strings               ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "+  +  +  H&D string               ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo "====== Word Splitting  ========"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "Convention splitting              ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --no-case
RES=$(print_latest_calculated_vocab "Convension splitting + no case    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo "====== Subword plitting ======="2

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers
RES=$(print_latest_calculated_vocab "Convention splitting + numbers    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin
RES=$(print_latest_calculated_vocab "Convention splitting + + ronin    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin --stem
RES=$(print_latest_calculated_vocab "Convention splitting + + + stemming")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo "======  BPE ============"

codeprep bpe -p "$PATH_TO_DATASET" "1k" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "BPE 1K                             ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo -e "$FULL_STRING"
