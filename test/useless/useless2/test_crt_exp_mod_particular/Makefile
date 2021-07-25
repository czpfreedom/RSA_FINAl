include ../../Makefile

test_crt_exp_mod_particular : bn_openssl.o test_crt_exp_mod_particular.o $(RSA_LIB)
	$(CC)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_exp_mod_particular.o : test_crt_exp_mod_particular.cpp
	$(CXX) -c  $< $(INC) -o $@
