RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/Makefile


test_bn_word : bn_openssl.o test_bn_word.o $(RSA_LIB)
	$(NVCC)  $^ -o $@ -L /usr/local/cuda-10.2/targets/aarch64-linux/lib/  $(INC)  $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CC) -c  $< $(INC) -I/home/nvidia/openssl-1.1.1c/crypto/  -o $@

test_bn_word.o : test_bn_word.cu
	$(NVCC) -c  $< $(INC) -o $@



clean_test: clean
	rm -rf ./*.o
	rm -rf ./test_bn_word

