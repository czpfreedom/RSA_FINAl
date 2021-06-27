include ../../Makefile

test_bn_word : bn_openssl.o test_bn_word.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_bn_word.o : test_bn_word.cu
	$(NVCC) -c  $< $(INC) -o $@
