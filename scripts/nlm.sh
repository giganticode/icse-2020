#!/bin/bash

echo ""
echo ""
echo "============================================================================================================"
echo "The purpose of this script is to show the setup used to run evaluations of our models for the study "
echo "and to demonstrate an example evaluation of one of our pre-trained models in one scenario on a tiny test set."
echo ""
echo "By using the same setup and running commands listed here: https://github.com/mast-group/OpenVocabCodeNLM, "
echo "the user should be able to run all other evaluation scenarios for all our models."
echo "============================================================================================================"
echo ""

BASE_DIR="/usr/src/app"



# Directory that contains train/validation/test data etc.
DATA_HOME="$BASE_DIR/sample_data/java"

MODEL_DIR="$BASE_DIR/java-bpe-10k-large"
TINY_TEST_FILE=java_tiny_test_slp_pre_enc_bpe_10000

CMD="python $BASE_DIR/OpenVocabCodeNLM/code_nlm.py --test True --data_path $DATA_HOME --train_dir $MODEL_DIR --test_filename $TINY_TEST_FILE --gru True --batch_size 32 --word_level_perplexity True --cross_entropy True"
echo "\$ $CMD"
echo ""
echo "=====> Versions of libraries used:"
cat "$BASE_DIR/requirements-docker.txt"
echo ""
echo "=====> Running evaluation of model at $MODEL_DIR  in static scenario ..."
echo "=====> Model is being evaluated on $DATA_HOME/$TINY_TEST_FILE"
echo ""
$CMD