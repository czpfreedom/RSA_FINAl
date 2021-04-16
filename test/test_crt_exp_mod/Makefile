RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/Makefile


test_crt_exp_mod : bn_openssl.o test_crt_exp_mod.o $(RSA_LIB)
	$(CC)  $^ -o $@ -L /usr/local/cuda-10.2/targets/aarch64-linux/lib/ -lstdc++ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CC) -c  $< $(INC) -I/home/nvidia/openssl-1.1.1c/crypto/  -o $@

test_crt_exp_mod.o : test_crt_exp_mod.cpp
	$(CC) -c  $< $(INC) -I/home/nvidia/openssl-1.1.1c/crypto/ -o $@



clean_test: clean
	rm -rf ./*.o
	rm -rf ./test_crt_exp_mod

