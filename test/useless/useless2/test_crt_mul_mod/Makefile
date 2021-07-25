include ../../Makefile

test_crt_mul_mod : bn_openssl.o test_crt_mul_mod.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_crt_mul_mod.o : test_crt_mul_mod.cpp
	$(CXX) -c  $< $(INC) -o $@
