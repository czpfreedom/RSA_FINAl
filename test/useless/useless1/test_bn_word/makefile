RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_bn_word : test_bn_word.o $(CC_OBJ) $(CU_OBJ)
	$(NVCC) -link  $^ $(INC) $(LIB) -o $@

test_bn_word.o : test_bn_word.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm ./*.o
	rm ./test_bn_word
