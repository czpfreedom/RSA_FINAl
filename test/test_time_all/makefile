RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/makefile


test_time_all : test_time_all.o $(CC_OBJ) $(CU_OBJ)
	        $(NVCC)   $^ $(INC) $(LIB) -o $@

test_time_all.o : test_time_all.cu
	        $(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	        rm ./*.o
		        rm ./test_time_all
