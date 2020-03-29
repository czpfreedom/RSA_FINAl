RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_inverse : test_inverse.o $(CC_OBJ) $(CU_OBJ)
	$(NVCC) -link  $^ $(INC) $(LIB) -o $@

test_inverse.o : test_inverse.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm ./*.o
	rm ./test_inverse

