include ../../Makefile

test_bn_part : test_bn_part.o $(RSA_LIB)
	$(CXX)  $^ -o $@ $(INC)   $(LIB)

test_bn_part.o : test_bn_part.cu
	$(NVCC) -c  $< $(INC) -o $@
