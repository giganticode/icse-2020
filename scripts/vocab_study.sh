#!/bin/bash

set -e

############# Defining constants and paths

SCRIPTPATH="$( cd "$(dirname "$0")" || exit ; pwd -P )"
RESULT_FILE="$SCRIPTPATH/vocab_stats.csv"

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
EXAMPLE_FILE="$SCRIPTPATH/example.txt"

VOCAB_DESC="Vocab size"
CORPUS_SIZE_DESC="Corpus size"
OOV_DESC="% OOV in test set (no/200k/100k/75k/50k/25k)"
OOV_SHORT_DESC="% OOV (no/200k/100k/75k/50k/25k)"
FREQS_DESC="% Frequencies (>1000/101-1000/11-100/2-10/1)"

DESC_PREFIX="--->"

##############  Calculations

rel_freq() {
  local _vocab_file="$1"
  local _regex="$2"
  local _total_vocab="$3"

  Q=$(cat "$_vocab_file" | awk '{print $2}' | grep "$_regex" | wc -l)
  echo "scale=1; 100 * $Q / $_total_vocab" | bc
}

rel_oov() {
  local _vocab_file="$1"
  local _vocab_file_test="$2"
  local _limit="$3"
  local _total_test_vocab="$4"

  oov_abs=$(echo "$(comm -13 <(cat "$_vocab_file" | head -$_limit | awk '{print $1}' | sort) <(cat "$_vocab_file_test" | awk '{print $1}' | sort)))" | wc -l)
  echo "scale=2; 100 * $oov_abs / $_total_test_vocab" | bc
}

run_option() {
  OPTION_NUMBER=$(echo "$1" | awk -F';' '{print $1}')
  DESC=$(echo "$1" | awk -F';' '{print $2}')
  COMMAND=$(echo "$1" | awk -F';' '{print $3}')

  if [ '-' == "$COMMAND" ]; then return; fi

  echo "-------> $OPTION_NUMBER $DESC"
  echo "$ $COMMAND -p $PATH_TO_DATASET --calc-vocab"
  $COMMAND -p "$PATH_TO_DATASET" --calc-vocab
  $COMMAND -p "$PATH_TO_TEST_DATASET" --calc-vocab

  RES=$(print_latest_calculated_vocab)
  echo "$OPTION_NUMBER,$DESC,$RES" >> $RESULT_FILE

  print_run_result "$RES"
  echo ""
  echo ""
}

#################  Printing

print_latest_calculated_vocab () {
    VOCAB_DIR_TEST="$PATH_TO_VOCABS/$(ls -1t $PATH_TO_VOCABS | head -1)"
    VOCAB_FILE_TEST="$VOCAB_DIR_TEST/vocab"
    VOCAB_SIZE_TEST=$(cat "$VOCAB_DIR_TEST/vocabsize" | head -1)

    VOCAB_DIR="$PATH_TO_VOCABS/$(ls -1t $PATH_TO_VOCABS | head -2 | tail -1)"
    VOCAB_FILE="$VOCAB_DIR/vocab"

    VOCAB_SIZE=$(cat "$VOCAB_DIR/vocabsize" | head -1)
    CORPUS_SIZE=$(cat "$VOCAB_FILE" | awk '{print $2}' | paste -sd+ | bc)

    F1=$(rel_freq "$VOCAB_FILE" "^\(100[1-9]\|10[1-9][0-9]\|1[1-9][0-9][0-9]\|[2-9][0-9][0-9][0-9]\)$" "$VOCAB_SIZE")
    F2=$(rel_freq "$VOCAB_FILE" "^\(10[1-9]\|1[1-9][0-9]\|[2-9][0-9][0-9]\|1000\)$" "$VOCAB_SIZE")
    F3=$(rel_freq "$VOCAB_FILE" "^\(1[1-9]\|[2-9][0-9]\|100\)$" "$VOCAB_SIZE")
    F4=$(rel_freq "$VOCAB_FILE" "^\([2-9]\|10\)$" "$VOCAB_SIZE")
    F5=$(rel_freq "$VOCAB_FILE" "^1$" "$VOCAB_SIZE")

    OOV1=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 1000000000 "$VOCAB_SIZE_TEST")
    OOV2=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 200000 "$VOCAB_SIZE_TEST")
    OOV3=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 100000 "$VOCAB_SIZE_TEST")
    OOV4=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 75000 "$VOCAB_SIZE_TEST")
    OOV5=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 50000 "$VOCAB_SIZE_TEST")
    OOV6=$(rel_oov "$VOCAB_FILE" "$VOCAB_FILE_TEST" 25000 "$VOCAB_SIZE_TEST")

    OOVs="$OOV1,$OOV2,$OOV3,$OOV4,$OOV5,$OOV6"

    FREQS="$F1,$F2,$F3,$F4,$F5"

    echo -e "$VOCAB_SIZE,$CORPUS_SIZE,$OOVs,$FREQS"
}

print_run_result () {
    echo -e "$1" | awk -F',' -v desc="$DESC_PREFIX $VOCAB_DESC: " '{print desc$1}'
    echo -e "$1" | awk -F',' -v desc="$DESC_PREFIX $CORPUS_SIZE_DESC: " '{print desc$2}'
    echo -e "$1" | awk -F',' -v desc="$DESC_PREFIX $OOV_DESC: " '{print desc$3"/"$4"/"$5"/"$6"/"$7"/"$8}'
    echo -e "$1" | awk -F',' -v desc="$DESC_PREFIX $FREQS_DESC: " '{print desc$9"/"$10"/"$11"/"$12"/"$13}'
}

print_modeling_choices_header() {
  echo -e "Option\tExample\n------\t---------" | awk -F '\t' '{ printf("%-90s      %-5s\n", $1, $2) }'
}

print_modeling_choices() {
  local _options="$1"
  local _example="$2"

  print_modeling_choices_header "$_example"
  _commands=$(echo -e "$_options" | awk -F';' '{print $3}')
  _split_examples=$(echo -e "$_commands" | xargs -I{} bash -c "if ! [ '-' == \"{}\" ]; then {} \"$_example\"; else echo ''; fi")
  paste <(echo -e "$_options" | awk -F';' '{print $1" "$2}') <(echo "$_split_examples") | awk -F '\t' '{ printf("%-90s      %-5s\n", $1, $2) }'
}

print_metrics() {
  echo "Metrics used for evaluation:"
  echo "$DESC_PREFIX $VOCAB_DESC:"
  echo "-------- the number of unique tokens across the pre-processed corpus"
  echo ""
  echo "$DESC_PREFIX $CORPUS_SIZE_DESC:"
  echo "-------- the total number of tokens in the pre-processed corpus"
  echo ""
  echo "$DESC_PREFIX $OOV_DESC:"
  echo "-------- the percentage of unique tokens that are found in the test set but are not present in the training set vocabulary"
  echo "-------- (in the whole training set vocabulary/top 200k frequent tokens/top 100k/top 75k/top 50k/top 25k)"
  echo ""
  echo "$DESC_PREFIX $FREQS_DESC:"
  echo "-------- the percentage of tokens that occur (>1000/101-1000/11-100/2-10/1) times in the coprus"
  echo ""
}

print_intro() {
  echo -e "\n\n\n"
  echo "This is a script for evaluation of different vocabulary modeling choices."
  echo "For each modeling choice, the input corpus is pre-processed accordingly and then multiple metrics ard calculated on the pre-processed corpus."
  echo ""
  echo "The vocabulary modeling choices we evaluate are:"
  echo ""
  echo "*********************************************************************************************************************************************************"
  print_modeling_choices "$1" "$2"
  echo "*********************************************************************************************************************************************************"
  echo ""
  print_metrics
  echo "*********************************************************************************************************************************************************"
  echo ""
  echo ""
}

print_final_stats() {
  echo -e "================>     Printing final stats\n"
  header="Pre-processing option,$VOCAB_DESC,$CORPUS_SIZE_DESC,$OOV_SHORT_DESC,$FREQS_DESC\n"
  sep="------,----,----,----,----\n"
  res="$(cat "$RESULT_FILE" | awk -F',' -v OFS=',' '{print $1" "$2, $3, $4, $5"/"$6"/"$7"/"$8"/"$9"/"$10, $11"/"$12"/"$13"/"$14"/"$15}')"
  res="$header$sep$res"
  echo -e "$res" | awk -F',' -v OFS='\t' '{printf("%-85s  %-12s  %-12s  %-35s  %s\n", $1, $2, $3, $4, $5)}'
  echo ""
  echo "The results are saved to $RESULT_FILE"
}

###########  Main flow

_options="$(<"$SCRIPTPATH/options.txt")"
_example="$(cat "$EXAMPLE_FILE")"
print_intro "$_options" "$_example"

echo ""
echo "===============>     Running pre-processing and calculating the stats ... "

echo -n > $RESULT_FILE
echo -e "$_options" | while IFS=$'\n' read -r option; do
    run_option "$option"
done

print_final_stats

rm -r "$PATH_TO_VOCABS"
