echo "Running evaluation of java-bpe-10k-large model ..."

BASE_DIR="/usr/src/app/"
#BASE_DIR="/home/hlib/dev/ecse-2020-artefacts/docker/"
# Directory that contains train/validation/test data etc.
DATA_HOME="$BASE_DIR/sample_data/java/"
MODEL_DIR="$BASE_DIR/java-bpe-10k-large"

# Filenames
TINY_TEST_FILE=java_tiny_test_slp_pre_enc_bpe_10000
TEST_PROJ_NAMES_FILE=testProjects
ID_MAP_FILE=sample_data/java/id_map_java_test_slp_pre_bpe_10000


python "$BASE_DIR/OpenVocabCodeNLM/code_nlm.py" --test True       --data_path $DATA_HOME --train_dir $MODEL_DIR --test_filename $TINY_TEST_FILE --gru True --batch_size 32 --word_level_perplexity True --cross_entropy True


#python "$BASE_DIR/OpenVocabCodeNLM/code_nlm.py" --completion True --data_path $DATA_HOME --train_dir $MODEL_DIR --test_filename $TINY_TEST_FILE      --gru True --batch_size 32
