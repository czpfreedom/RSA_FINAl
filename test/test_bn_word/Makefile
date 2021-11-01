include ../../Makefile

test_bn_word : test_bn_word.o  $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

test_bn_word.o : test_bn_word.cpp
	$(CXX) -c $< $(INC) -o $@
