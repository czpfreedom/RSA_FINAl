include ../../Makefile

test_crt_mod_mul : test_crt_mod_mul.o  $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

test_crt_mod_mul.o : test_crt_mod_mul.cpp
	$(CXX) -c $< $(INC) -o $@
	

test_crt_mod_exp : test_crt_mod_exp.o  $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

test_crt_mod_exp.o : test_crt_mod_exp.cpp
	$(CXX) -c $< $(INC) -o $@
