include ../../Makefile

test_crt_exp_mod_parall_array : bn_openssl.o test_crt_exp_mod_parall_array.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_exp_mod_parall_array.o : test_crt_exp_mod_parall_array.cpp
	$(CXX) -c  $< $(INC) -o $@
