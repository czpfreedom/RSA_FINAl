RSA_PATH=/home/nvidia/rsa_final

include $(RSA_PATH)/Makefile


test_crt_exp_mod_c :  test_crt_exp_mod_c.o $(RSA_LIB)
	gcc 	$^ -o $@ -L /usr/local/cuda-10.2/targets/aarch64-linux/lib/ -lstdc++  $(INC)   $(LIB)

test_crt_exp_mod_c.o : test_crt_exp_mod_c.c
	gcc -c  $< $(INC) -I/home/nvidia/openssl-1.1.1c/crypto/ -o $@



clean_test: clean
	rm -rf ./*.o
	rm -rf ./test_crt_exp_mod_c

