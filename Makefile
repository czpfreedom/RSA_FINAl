RSA_PATH=/home/nx2/rsa_final_new

DIR_INC = $(RSA_PATH)/include
DIR_SRC = $(RSA_PATH)/src
DIR_OBJ = $(RSA_PATH)/obj
DIR_LIB = $(RSA_PATH)/lib
DIR_TEST= $(RSA_PATH)/test

RSA_LINK = $(DIR_LIB)/rsa_link.o
RSA_LIB = $(DIR_LIB)/rsa_final.a

OPENSSL_DIR=/home/nx2/openssl-1.1.1c
OPENSSL_INC=-I/usr/local/include/ -I$(OPENSSL_DIR)/crypto -I$(OPENSSL_DIR)/crypto/include
OPENSSL_LIB=/usr/local/lib/

INC=-I$(DIR_INC) $(OPENSSL_INC) 
LIB=-L$(OPENSSL_LIB) -lssl -lcrypto -L /usr/local/cuda-10.2/targets/aarch64-linux/lib/ -lcudadevrt -lcudart -lstdc++

NVCC=nvcc -arch=sm_60 
CXX=g++
CC=gcc

CU_SRC = $(wildcard ${DIR_SRC}/*.cu)
CU_OBJ = $(patsubst %.cu,${DIR_OBJ}/%.o,$(notdir ${CU_SRC}))

CC_SRC= $(wildcard ${DIR_SRC}/*.c)
CC_OBJ = $(patsubst %.c,${DIR_OBJ}/%.o,$(notdir ${CC_SRC}))

CXX_SRC= $(wildcard ${DIR_SRC}/*.cpp)
CXX_OBJ = $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${CXX_SRC}))

TEST_BN_WORD=$(DIR_TEST)/test_bn_word
TEST_CRT_MUL_MOD=$(DIR_TEST)/test_crt_mul_mod
TEST_CRT_EXP_MOD=$(DIR_TEST)/test_crt_exp_mod
TEST_CRT_EXP_MOD_PARALL=$(DIR_TEST)/test_crt_exp_mod_parall
TEST_CRT_EXP_MOD_PARALL_ARRAY=$(DIR_TEST)/test_crt_exp_mod_parall_array
TEST_CRT_EXP_MOD_C=$(DIR_TEST)/test_crt_exp_mod_c
TEST_CRT_EXP_MOD_PARTICULAR=$(DIR_TEST)/test_crt_exp_mod_particular

$(RSA_LIB) : $(RSA_LINK) $(CC_OBJ) $(CXX_OBJ) $(CU_OBJ)
	$(NVCC) -lib $^ -o $@

$(RSA_LINK) : $(CU_OBJ)
	$(NVCC) -dlink --compiler-options '-fPIC' $^ -o $@

$(DIR_OBJ)/%.o: $(DIR_SRC)/%.cpp
	$(CXX) -c  -fPIC $< $(INC) -o $@

$(DIR_OBJ)/%.o: $(DIR_SRC)/%.cu
	$(NVCC) -dc  --compiler-options '-fPIC' $< $(INC) -o $@

clean:  clean_test_bn_word clean_test_crt_mul_mod clean_test_crt_exp_mod clean_test_crt_exp_mod_parall clean_test_crt_exp_mod_parall_array clean_test_crt_exp_mod_c clean_test_crt_exp_mod_particular
	rm -f $(DIR_OBJ)/*.o
	rm -f $(DIR_LIB)/*.o
	rm -f $(DIR_LIB)/*.a

clean_test_bn_word :
	rm -f $(TEST_BN_WORD)/*.o
	rm -f $(TEST_BN_WORD)/test_bn_word

clean_test_crt_mul_mod :
	rm -f $(TEST_CRT_MUL_MOD)/*.o
	rm -f $(TEST_CRT_MUL_MOD)/test_crt_mul_mod

clean_test_crt_exp_mod :
	rm -f $(TEST_CRT_EXP_MOD)/*.o
	rm -f $(TEST_CRT_EXP_MOD)/test_crt_exp_mod

clean_test_crt_exp_mod_parall :
	rm -f $(TEST_CRT_EXP_MOD_PARALL)/*.o
	rm -f $(TEST_CRT_EXP_MOD_PARALL)/test_crt_exp_mod_parall

clean_test_crt_exp_mod_parall_array :
	rm -f $(TEST_CRT_EXP_MOD_PARALL_ARRAY)/*.o
	rm -f $(TEST_CRT_EXP_MOD_PARALL_ARRAY)/test_crt_exp_mod_parall_array

clean_test_crt_exp_mod_c :
	rm -f $(TEST_CRT_EXP_MOD_C)/*.o
	rm -f $(TEST_CRT_EXP_MOD_C)/test_crt_exp_mod_c

clean_test_crt_exp_mod_particular :
	rm -f $(TEST_CRT_EXP_MOD_PARTICULAR)/*.o
	rm -f $(TEST_CRT_EXP_MOD_PARTICULAR)/test_crt_exp_mod_particular
