include ../../Makefile

test_bn_part : bn_openssl.o test_bn_part.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

bn_openssl.o : bn_openssl.cpp
	$(CXX) -c  $< $(INC) -o $@

test_bn_part.o : test_bn_part.cu
	$(NVCC) -c  $< $(INC) -o $@
