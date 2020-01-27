#!/bin/bash

trap 'if [[ "$BASH_COMMAND" =~ ^codeprep* ]]; then echo -e "\nRunning:          $BASH_COMMAND"; fi' DEBUG

if [ -z "$1" ]
then
  PATH_TO_TRAIN_AND_TEST="$PWD/min-dataset"
else
  PATH_TO_TRAIN_AND_TEST="$1"
fi

PATH_TO_DATASET="$PATH_TO_TRAIN_AND_TEST/train"
PATH_TO_TEST_DATASET="$PATH_TO_TRAIN_AND_TEST/test"

CPREP_VERSION=$(codeprep --version | grep -o "[^ ]*$")
PATH_TO_VOCABS="/root/.config/codeprep/$CPREP_VERSION/vocab/"

rel_freq() {
  local _vocab_file="$1"
  local _regex="$2"
  local _total_vocab="$3"

  Q=$(cat "$_vocab_file" | awk '{print $2}' | grep "$_regex" | wc -l)
  echo $(( 100 * Q / _total_vocab ))
}

rel_oov() {
  local _vocab_file="$1"
  local _vocab_file_test="$2"
  local _limit="$3"
  local _total_vocab="$4"

  oov_abs=$(echo "$(comm -13 <(cat "$_vocab_file" | head -$_limit | awk '{print $2}' | sort) <(cat "$_vocab_file_test" | awk '{print $2}' | sort)))" | wc -l)
  echo $(( 100 * oov_abs / _total_vocab ))
}

print_latest_calculated_vocab () {
    VOCAB_DIR_TEST="$PATH_TO_VOCABS/$(ls -1t $PATH_TO_VOCABS | head -1)"
    VOCAB_FILE_TEST="$VOCAB_DIR_TEST/vocab"

    VOCAB_DIR="$PATH_TO_VOCABS/$(ls -1t $PATH_TO_VOCABS | head -2 | tail -1)"
    VOCAB_FILE="$VOCAB_DIR/vocab"

    VOCAB_SIZE=$(cat "$VOCAB_DIR/vocabsize" | head -1)
    CORPUS_SIZE=$(cat "$VOCAB_FILE" | awk '{print $2}' | paste -sd+ | bc)

    F1=$(rel_freq "$VOCAB_FILE" "^\(100[1-9]\|10[1-9][0-9]\|1[1-9][0-9][0-9]\|[2-9][0-9][0-9][0-9]\)$" "$VOCAB_SIZE")
    F2=$(rel_freq "$VOCAB_FILE" "^\(10[1-9]\|1[1-9][0-9]\|[2-9][0-9][0-9]\|1000\)$" "$VOCAB_SIZE")
    F3=$(rel_freq "$VOCAB_FILE" "^\(1[1-9]\|[2-9][0-9]\|100\)$" "$VOCAB_SIZE")
    F4=$(rel_freq "$VOCAB_FILE" "^\([2-9]\|10\)$" "$VOCAB_SIZE")
    F5=$(rel_freq "$VOCAB_FILE" "^1$" "$VOCAB_SIZE")

    OOV1=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 1000000000 "$VOCAB_SIZE")
    OOV2=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 200000 "$VOCAB_SIZE")
    OOV3=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 100000 "$VOCAB_SIZE")
    OOV4=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 75000 "$VOCAB_SIZE")
    OOV5=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 50000 "$VOCAB_SIZE")
    OOV6=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 25000 "$VOCAB_SIZE")

    OOVs="$OOV1/$OOV2/$OOV3/$OOV4/$OOV5/$OOV6"

    FREQS="$F1/$F2/$F3/$F4/$F5"

    echo -e "$1\t$VOCAB_SIZE\t$CORPUS_SIZE\t$OOVs\t$FREQS"
}

FULL_STRING=""

format_res () {
    echo -e "$1" | awk -F'\t' '{print "\n"$1"   Vocab size: "$2"              Corpus size: "$3"           OOV: "$4"     Freqs: "$5}'
}

echo "Vocabulary study: evaluating different vocabulary choices"

echo ""
echo "=====  No splitting  ====="
echo ""

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab
RES=$(print_latest_calculated_vocab "Full                              ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode
RES=$(print_latest_calculated_vocab "No unicode                        ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces
RES=$(print_latest_calculated_vocab "+  No whitespace                  ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"2

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com
RES=$(print_latest_calculated_vocab "+  +  no comments                 ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --no-str
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --no-str
RES=$(print_latest_calculated_vocab "+  +  +  no strings               ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep nosplit -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
codeprep nosplit -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "+  +  +  H&D string               ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo ""
echo "====== Word Splitting  ========"
echo ""

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
codeprep basic -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "Convention splitting              ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --no-case
codeprep basic -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --no-case
RES=$(print_latest_calculated_vocab "Convension splitting + no case    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo ""
echo "====== Subword plitting ======="
echo ""

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers
codeprep basic -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers
RES=$(print_latest_calculated_vocab "Convention splitting + numbers    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin
codeprep basic -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin
RES=$(print_latest_calculated_vocab "Convention splitting + + ronin    ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

codeprep basic -p "$PATH_TO_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin --stem
codeprep basic -p "$PATH_TO_TEST_DATASET" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14 --split-numbers --ronin --stem
RES=$(print_latest_calculated_vocab "Convention splitting + + + stemming")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo ""
echo "======  BPE ============"
echo ""

codeprep bpe -p "$PATH_TO_DATASET" "1k" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
codeprep bpe -p "$PATH_TO_TEST_DATASET" "1k" --calc-vocab --no-unicode --no-spaces --no-com --max-str-length=14
RES=$(print_latest_calculated_vocab "BPE 1K                             ")
FULL_STRING="$FULL_STRING\n$RES"
format_res "$RES"

echo ""
echo ""
echo ""
echo "Pre-processing option:            Vocab size:     Corpus size        OOV:          Freq:    "
echo -e "$FULL_STRING"
