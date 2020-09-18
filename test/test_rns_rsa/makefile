RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_rns_rsa : test_rns_rsa.o $(CC_OBJ) $(CU_OBJ)
	        $(NVCC)   $^ $(INC) $(LIB) -o $@

test_rns_rsa.o : test_rns_rsa.cu
	        $(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	        rm ./*.o
		        rm ./test_rns_rsa
