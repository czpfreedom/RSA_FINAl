RSA_PATH=/home/nvidia/rsa_final

DIR_INC = $(RSA_PATH)/include
DIR_SRC = $(RSA_PATH)/src
DIR_OBJ = $(RSA_PATH)/obj
DIR_LIB = $(RSA_PATH)/lib

RSA_LINK = $(DIR_LIB)/rsa_link.o
RSA_LIB = $(DIR_LIB)/rsa_final.a


OPENSSL_INC=/usr/local/include/
OPENSSL_LIB=/usr/local/lib/

INC=-I$(DIR_INC) -I$(OPENSSL_INC) -I/home/nvidia/openssl-1.1.1c/crypto/include
LIB=-L$(OPENSSL_LIB) -lssl -lcrypto -lcudadevrt -lcudart

NVCC=nvcc -arch=sm_60 
CXX=g++


CU_SRC = $(wildcard ${DIR_SRC}/*.cu)
CU_OBJ = $(patsubst %.cu,${DIR_OBJ}/%.o,$(notdir ${CU_SRC}))

CXX_SRC= $(wildcard ${DIR_SRC}/*.cpp)
CXX_OBJ = $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${CC_SRC}))

$(RSA_LIB) : $(RSA_LINK) $(CU_OBJ) $(RSA_PATH)/obj/rsa_final_c.o
	$(NVCC) -lib $^ -o $@

$(RSA_LINK) : $(CU_OBJ)
	$(NVCC) -dlink $^ -o $@

$(RSA_PATH)/obj/rsa_final_c.o : $(RSA_PATH)/src/rsa_final_c.cpp
	$(CXX) -c $(RSA_PATH)/src/rsa_final_c.cpp $(INC)  -o $(RSA_PATH)/obj/rsa_final_c.o

$(DIR_OBJ)/%.o: $(DIR_SRC)/%.cu
	$(NVCC) -dc  $< $(INC) -o $@

clean:
	rm -rf $(DIR_OBJ)/*.o
	rm -rf $(DIR_LIB)/*.o
	rm -rf $(DIR_LIB)/*.a
