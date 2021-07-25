include ../../Makefile

test_rns_mod_exp : bn_openssl.o test_rns_mod_exp.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_rns_mod_exp.o : test_rns_mod_exp.cpp
	$(CXX) -c  $< $(INC) -o $@
