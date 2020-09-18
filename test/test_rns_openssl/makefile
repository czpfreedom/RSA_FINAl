RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_rns_openssl : test_rns_openssl.o $(CC_OBJ) $(CU_OBJ)
	        $(NVCC)   $^ $(INC) $(LIB) -o $@

test_rns_openssl.o : test_rns_openssl.cpp
	        $(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	        rm ./*.o
		        rm ./test_rns_openssl
