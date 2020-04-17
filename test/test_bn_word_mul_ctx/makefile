RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_bn_word_mul_ctx : test_bn_word_mul_ctx.o $(CC_OBJ) $(CU_OBJ)
	$(NVCC)   $^ $(INC) $(LIB) -o $@

test_bn_word_mul_ctx.o : test_bn_word_mul_ctx.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm ./*.o
	rm ./test_bn_word_mul_ctx

