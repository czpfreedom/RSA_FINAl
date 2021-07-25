include ../../Makefile

test_crt_exp_mod : bn_openssl.o test_crt_exp_mod.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_exp_mod.o : test_crt_exp_mod.cpp
	$(CXX) -c  $< $(INC) -o $@
