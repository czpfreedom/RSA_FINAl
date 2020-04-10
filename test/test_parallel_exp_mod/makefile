RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_parallel_exp_mod : test_parallel_exp_mod.o $(CC_OBJ) $(CU_OBJ)
	$(NVCC) -link  $^ $(INC) $(LIB) -o $@

test_parallel_exp_mod.o : test_parallel_exp_mod.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm ./*.o
	rm ./test_parallel_exp_mod

