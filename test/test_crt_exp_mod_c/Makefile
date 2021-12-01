include ../../Makefile

test_crt_mod_exp_c : test_crt_mod_exp_c.o $(RSA_LIB)
	$(CC) $^ -o $@ $(INC)   $(LIB)

test_crt_mod_exp_c.o : test_crt_mod_exp_c.c
	$(CC) -c  $< $(INC) -o $@
