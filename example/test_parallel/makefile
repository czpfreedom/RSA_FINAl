RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_parallel : test_parallel.o $(CC_OBJ) $(CU_OBJ)
	$(NVCC) -link  $^ $(INC) $(LIB) -o $@

test_parallel.o : test_parallel.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm ./*.o
	rm ./test_parallel

