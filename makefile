RSA_PATH=/home/nvidia/rsa_final

DIR_INC = $(RSA_PATH)/include
DIR_SRC = $(RSA_PATH)/src
DIR_OBJ = $(RSA_PATH)/obj

OPENSSL_INC=/usr/local/include/
OPENSSL_LIB=/home/nvidia/openssl-1.1.1c

INC=-I$(DIR_INC) -I$(OPENSSL_INC) -I/home/nvidia/openssl-1.1.1c/crypto/include
LIB=-L$(OPENSSL_LIB) -lcrypto -lcudadevrt

NVCC=nvcc -rdc=true -arch=sm_60 
CC=g++


CU_SRC = $(wildcard ${DIR_SRC}/*.cu)
CU_OBJ = $(patsubst %.cu,${DIR_OBJ}/%.o,$(notdir ${CU_SRC}))

CC_SRC= $(wildcard ${DIR_SRC}/*.cpp)
CC_OBJ = $(patsubst %.cpp,${DIR_OBJ}/%.o,$(notdir ${CC_SRC}))

all :  $(CC_OBJ) $(CU_OBJ)

$(DIR_OBJ)/%.o: $(DIR_SRC)/%.cpp
	$(CC) -c  $< $(INC)  -o $@


$(DIR_OBJ)/%.o: $(DIR_SRC)/%.cu
	$(NVCC) -c  $< $(INC) -o $@


clean:
	rm -rf $(DIR_OBJ)/*.o
