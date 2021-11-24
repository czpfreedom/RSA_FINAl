include ../../Makefile

test_crt_mod_exp_c : test_crt_mod_exp_c.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

test_crt_mod_exp_c.o : test_crt_mod_exp_c.cpp
	$(CXX) -c  $< $(INC) -o $@
