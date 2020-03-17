__host__ void test(int *a){
    int *b;
    cudaMalloc((int **)&b,2);
}
