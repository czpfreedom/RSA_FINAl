include ../../Makefile

test_crt_exp_mod_c : bn_openssl.o test_crt_exp_mod_c.o $(RSA_LIB)
	$(CC)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_exp_mod_c.o : test_crt_exp_mod_c.c
	$(CC) -c  $< $(INC) -o $@
