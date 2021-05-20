include ../../Makefile

test_crt_exp_mod_parall : bn_openssl.o test_crt_exp_mod_parall.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_exp_mod_parall.o : test_crt_exp_mod_parall.cpp
	$(CXX) -c  $< $(INC) -o $@
